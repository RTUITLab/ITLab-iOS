//
//  OAuthITLab.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 01.03.2021.
//

import Foundation
import SwiftUI
import OAuthSwift

class OAuthITLab: NSObject, ObservableObject  {
    
    public static var shared: OAuthITLab = {
        let instance = OAuthITLab()
        
        return instance
    }()
    
    private var configuration : OAuthITLabConfiguration
    private var userInfo: UserInfo?
    
    @Published private var oauthSwift: OAuth2Swift
    
    override init() {
        self.configuration = OAuthITLabConfiguration()
        
        self.oauthSwift = OAuth2Swift(
            consumerKey:    configuration.kClientID,
            consumerSecret: "",
            authorizeUrl:   configuration.kIssuer + "/connect/authorize",
            accessTokenUrl: configuration.kIssuer + "/connect/token",
            responseType:   "code"
        )
        super.init()
        
        self.oauthSwift.authorizeURLHandler = ASWebAuthenticationSessionURLHandler(
            callbackUrlScheme: configuration.kRedirectURL,
            presentationAnchor: nil,  // If the app doesn't support for multiple windows, it doesn't matter to use nil.
            prefersEphemeralWebBrowserSession: true
        )
        
        self.loadState()
        
        if self.isAuthorize() {
            self.loadUserInfo()
        }
    }
}


extension OAuthITLab {
    
    private struct OAuthITLabConfiguration {
        var kIssuer: String = ""
        var kClientID: String = ""
        var kRedirectURL: String = ""
        let kOAuthITLabStateKey: String = "oauth2itlab"
        
        init() {
            self.configurationСheck()
        }
        
        private mutating func configurationСheck() {
            
            guard let serverApi = Bundle.main.object(forInfoDictionaryKey: "ServerApi") as? Dictionary<String, String> else {
                assertionFailure("Server parameters are not specified in info.plist")
                return
            }
            
            guard var serverURL = serverApi["ServerURL"] else {
                assertionFailure("No parameter specifying the connection server")
                return
            }
            
            assert(serverURL != "",
                   "Server reference not specified in config file. Property: API_Issuer");
            
            guard let isSecure = serverApi["isSecure"] as NSString? else {
                assertionFailure("No parameter specifying the connection server")
                return
            }
            
            if isSecure.boolValue {
                serverURL = "https://" + serverURL
            } else {
                serverURL = "http://" + serverURL
            }
            
            
            guard let clientName = serverApi["ClientName"] else {
                assertionFailure("No parameter specifying the connection server.")
                return
            }
            
            assert(clientName != "",
                   "Client name not specified in config file. Property: API_Client");
            
            guard let redirectURL = serverApi["RedirectURL"] else {
                assertionFailure("No parameter specifying the connection server")
                return
            }
            
            assert(redirectURL != "",
                   "RedirectURL not specified in config file. API_RedirectURL");
            
            self.kIssuer = serverURL
            self.kClientID = clientName
            self.kRedirectURL = redirectURL
            
        }
    }
}

extension OAuthITLab {
    
    public func authorize(complited: @escaping (Error?) -> Void) {
        
        oauthSwift.authorize(
            withCallbackURL: URL(string: configuration.kRedirectURL + "/itlab")!,
            scope: "roles openid profile itlab.events offline_access",
            state: configuration.kOAuthITLabStateKey) { result in
            switch result {
            case .success(_):
                self.saveState()
                
                self.getUserInfoReq {
                    complited(nil)
                }
            case .failure(let error):
                
                complited(error)
            }
        }
    }
    
    public func getToken(complited: @escaping (Error?) -> Void) {
        let credential = self.oauthSwift.client.credential
        if credential.isTokenExpired() {
            
            debugPrint("token expired, going to refresh")
            self.oauthSwift.renewAccessToken(withRefreshToken: credential.oauthRefreshToken) { (result) in
                switch result {
                case .success(let token):
                    SwaggerClientAPI.customHeaders.updateValue("Bearer \(token.credential.oauthToken)", forKey: "Authorization")
                    complited(nil)
                case .failure(let error):
                    complited(error)
                }
            }
        } else {
            SwaggerClientAPI.customHeaders.updateValue("Bearer \(credential.oauthToken)", forKey: "Authorization")
            complited(nil)
        }
    }
    
    public func isAuthorize() -> Bool {
        let credential = self.oauthSwift.client.credential
        return !credential.oauthToken.isEmpty && !credential.isTokenExpired()
    }
}

extension OAuthITLab {
    
    private func saveUserInfo() {
        let encoder = JSONEncoder()
        
        if let data = try? encoder.encode(self.userInfo ) {
            let userDefaults = UserDefaults.standard
            userDefaults.set(data, forKey: "userInfo")
            userDefaults.synchronize()
        }
    }
    
    public func loadUserInfo() {
        if let data = UserDefaults.standard.object(forKey: "userInfo") as? Data {
            let decoder = JSONDecoder()
            if let userInfo = try? decoder.decode(UserInfo.self, from: data) {
                self.userInfo = userInfo
            }
        }
    }
    
    private func saveState() {
        
        var data : Data? = nil
        
        do {
            data = try NSKeyedArchiver.archivedData(withRootObject: oauthSwift.client.credential, requiringSecureCoding: true)
        } catch {
            print("Not save data")
        }
        
        if let userDefaults = UserDefaults(suiteName: "group.ru.RTUITLab.ITLab") {
            userDefaults.set(data, forKey: self.configuration.kOAuthITLabStateKey)
            userDefaults.synchronize()
        }
    }
    
    private func loadState() {
        guard let data = UserDefaults (suiteName: "group.ru.RTUITLab.ITLab")?
                .object(forKey: self.configuration.kOAuthITLabStateKey) as? Data
        else {
            return
        }
        
        do {
            let credential = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as! OAuthSwiftCredential
            self.oauthSwift.client = OAuthSwiftClient(credential: credential)
        }
        catch {
            print("Not load data")
        }
    }
}

extension OAuthITLab {
    
    struct UserInfo: Codable {
        let userId: UUID
        var profile: UserView?
        private var roles: [String:Bool] = ["CanEditEquipment": false,
                                            "CanEditEvent": false,
                                            "CanInviteToSystem": false,
                                            "Participant": false,
                                            "CanDeleteEventRole": false,
                                            "CanEditEquipmentOwner": false,
                                            "CanEditRoles": false,
                                            "CanEditEquipmentType": false,
                                            "CanEditEventType": false,
                                            "CanEditUserPropertyTypes": false]
        
        func getRole(_ key: String) ->  Bool {
            
            guard let index = roles.index(forKey: key) else {
                return false
            }
            
            return roles[index].value
        }
        
        public enum CodingKeys: String, CodingKey {
            case userId = "sub"
            case roles = "role"
            case profile
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            userId = try container.decode(UUID.self, forKey: .userId)
            profile = try? container.decode(UserView.self, forKey: .profile)
            if let roles = try? container.decode([String].self, forKey: .roles) {
                roles.forEach { (role) in
                    self.roles.updateValue(true, forKey: role)
                }
            } else if let role = try? container.decode(String.self, forKey: .roles)  {
                self.roles.updateValue(true, forKey: role)
            } else if let roles = try? container.decode([String:Bool].self, forKey: .roles) {
                self.roles = roles
            }
        }
    }
}

extension OAuthITLab {
    
    public func getUserInfo() -> UserInfo? {
        return self.userInfo
    }
    
    public func getUserInfoReq(complited: @escaping () -> Void) {
        self.getToken { (error) in
            
            if error != nil {
                print(error.debugDescription)
                return
            }
            
            
            var urlRequest = URLRequest(url: URL(string: self.configuration.kIssuer + "/connect/userinfo")!)
            urlRequest.allHTTPHeaderFields = ["Authorization":"Bearer \(self.oauthSwift.client.credential.oauthToken)"]
            
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                
                DispatchQueue.main.async { [self] in
                    
                    guard error == nil else {
                        print("HTTP request failed \(error?.localizedDescription ?? "ERROR")")
                        return
                    }
                    
                    guard let response = response as? HTTPURLResponse else {
                       print("Non-HTTP response")
                        return
                    }
                    
                    guard let data = data else {
                        print("HTTP response data is empty")
                        return
                    }
                    
                    if response.statusCode != 200 {
                        // server replied with an error
                        let responseText: String? = String(data: data, encoding: String.Encoding.utf8)
                        
                        if response.statusCode == 401 {
                            // "401 Unauthorized" generally indicates there is an issue with the authorization
                            // grant. Puts OIDAuthState into an error state.
                            print(error.debugDescription)
                        } else {
                            print("HTTP: \(response.statusCode), Response: \(responseText ?? "RESPONSE_TEXT")")
                        }
                        return
                    }
                    
                    guard let user: UserInfo = try? JSONDecoder().decode(UserInfo.self, from: data) else {
                        print("JSON serialization error in UserInfo")
                        return
                    }
                    self.userInfo = user
                    
                    UserAPI.apiUserIdGet(_id: user.userId) { (profile, error) in
                        if let error = error {
                            print(error)
                            return
                        }
                        
                        self.userInfo?.profile = profile
                        self.saveUserInfo()
                        
                        complited()
                    }
                    
                }
            }
            
            task.resume()
        }
    }
}
