//
//  AppAuthInteraction.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 29.09.2020.
//

import Foundation
import SwiftUI
import AppAuth

typealias PostRegistrationCallback = (_ configuration: OIDServiceConfiguration?, _ registrationResponse: OIDRegistrationResponse?) -> Void

class AppAuthInteraction: NSObject, ObservableObject {
    
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
    
    private var userInfo: UserInfo?
    
    public func getUserInfo() -> UserInfo? {
        return self.userInfo
    }
    
    public static let shared: AppAuthInteraction = AppAuthInteraction()
    
    private var appAuthConfiguration : AppAuthConfiguration = AppAuthConfiguration()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    @Published private var authState: OIDAuthState?
    
    @Published public var isLoader : Bool = false
    
    private struct AppAuthConfiguration {
        var kIssuer: String = ""
        var kClientID: String = ""
        var kRedirectURL: String = ""
        let kAppAuthAuthStateKey: String = "authState"
    }
    
    override init() {
        super.init()
        
        self.configurationСheck()
        
        self.loadState()
        
        if authState?.isAuthorized ?? false {
            self.loadUserInfo()
        }
        
        self.stateChanged()
    }
    
    public func getAuthState() -> OIDAuthState?
    {
        return self.authState
    }
    
    private func configurationСheck() {
        
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
        
        self.appAuthConfiguration.kIssuer = serverURL
        self.appAuthConfiguration.kClientID = clientName
        self.appAuthConfiguration.kRedirectURL = redirectURL
        
    }
    
}

extension AppAuthInteraction {
    
    public func authorization() {
        
        self.isLoader = true
        guard let issuer = URL(string: self.appAuthConfiguration.kIssuer) else {
            self.errorApp("Error creating URL for : \(self.appAuthConfiguration.kIssuer)")
            return
        }
        
        print("Fetching configuration for issuer: \(issuer)")
        
        // discovers endpoints
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in
            
            guard let config = configuration else {
                self.errorApp("Error retrieving discovery document: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                return
            }
            
            print("Got configuration: \(config)")
            
            self.doAuthWithAutoCodeExchange(configuration: config, clientID: self.appAuthConfiguration.kClientID, clientSecret: nil)
        }
    }
    
    public func logOut()
    {
        guard let issuer = URL(string: self.appAuthConfiguration.kIssuer) else {
            self.errorApp("Error creating URL for : \(self.appAuthConfiguration.kIssuer)")
            return
        }
        
        print("Fetching configuration for issuer: \(issuer)")
        
        // discovers endpoints
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in
            
            guard let config = configuration else {
                self.errorApp("Error retrieving discovery document: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                return
            }
            
            print("Got configuration: \(config)")
            
            self.endSession(configuration: config)
        }
    }
    
    public func performAction(freshTokens: @escaping (String?, Error?) -> Void) {
        
        guard let authState = self.authState else {
            self.errorApp("Not authState")
            return
        }
        
        authState.performAction { (token, _, error) in
            guard let token = token else {
                self.errorApp("not token")
                return
            }
            
            SwaggerClientAPI.customHeaders.updateValue("Bearer \(token)", forKey: "Authorization")
            
            freshTokens(token, error)
        }
    }
    
    public func getAccsesToken() -> String {
        guard let authState = self.authState else {
            self.errorApp("Not authState")
            return "Not token"
        }
        
        return authState.lastTokenResponse?.accessToken ?? "Not token"
    }
    
    public func isAuthorize() -> Bool {
        guard let authState = self.authState else {
            self.errorApp("Not authState")
            return false
        }
        
        return authState.isAuthorized
    }
}

//MARK: AppAuth Methods
extension AppAuthInteraction {
    
    private func endSession(configuration: OIDServiceConfiguration)
    {
        guard let redirectURI = URL(string: self.appAuthConfiguration.kRedirectURL) else {
            self.errorApp("Error creating URL for : \(self.appAuthConfiguration.kRedirectURL)")
            return
        }
        
        let request: OIDEndSessionRequest = OIDEndSessionRequest(configuration: configuration, idTokenHint: self.getAuthState()?.lastTokenResponse?.idToken ?? "", postLogoutRedirectURL: redirectURI, additionalParameters: nil)
        
        
        //        self.viewController.isLoading(false)
        //        self.viewController.dismiss(animated: true, completion: nil)
        
        guard let viewController = UIApplication.shared.windows.first?.rootViewController else {
            self.errorApp("Not View Controller")
            return
        }
        
        let agent = OIDExternalUserAgentIOS(presenting: viewController)
        
        self.appDelegate.currentAuthorizationFlow = OIDAuthorizationService.present(request, externalUserAgent: agent!, callback: { (response, error) in
            
            if let respon = response
            {
                print(respon)
                self.authState = nil
                self.userInfo = nil
                self.isLoader = false
                self.stateChanged()
                self.saveUserInfo()
            }
            
            if let err = error
            {
                print(err)
                self.authState = nil
                self.userInfo = nil
                self.isLoader = false
                self.stateChanged()
                self.saveUserInfo()
            }
        })
    }
    
    private func errorApp(_ message: String)
    {
        print(message)
        self.isLoader = false
        self.setAuthState(nil)
    }
    
    private func doAuthWithAutoCodeExchange(configuration: OIDServiceConfiguration, clientID: String, clientSecret: String?) {
        
        guard let redirectURI = URL(string: self.appAuthConfiguration.kRedirectURL) else {
            self.errorApp("Error creating URL for : \(self.appAuthConfiguration.kRedirectURL)")
            //            self.viewController.alertError("Error creating URL for : \(self.appAuthConfiguration.kRedirectURL)")
            //            self.viewController.isLoading(false)
            return
        }
        
        // builds authentication request
        let request = OIDAuthorizationRequest(configuration: configuration,
                                              clientId: clientID,
                                              clientSecret: clientSecret,
                                              scopes: [OIDScopeOpenID, OIDScopeProfile, "itlab.events", "itlab.salary", "roles", "offline_access"],
                                              redirectURL: redirectURI,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: nil)
        
        // performs authentication request
        print("Initiating authorization request with scope: \(request.scope ?? "DEFAULT_SCOPE")")
        
        
        guard let viewController = UIApplication.shared.windows.first?.rootViewController else {
            self.errorApp("Not View Controller")
            return
        }
        
        self.appDelegate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: viewController) { authState, error in
            
            if let authState = authState {
                self.setAuthState(authState)
                print("Got authorization tokens. Access token: \(authState.lastTokenResponse?.accessToken ?? "DEFAULT_TOKEN")")
                
                //                self.viewController.logIn()
                self.getUserInfoReq()
                
            } else {
                self.errorApp("Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                //                self.viewController.isLoading(false)
                self.setAuthState(nil)
            }
            
            
        }
    }
    
    public func getUserInfoReq(complited: @escaping () -> Void) {
        self.performAction { (token, error) in
            
            if error != nil {
                self.errorApp(error!.localizedDescription)
                return
            }
            
            guard let userinfoEndpoint = self.authState?.lastAuthorizationResponse.request.configuration.discoveryDocument?.userinfoEndpoint else {
                self.errorApp("Userinfo endpoint not declared in discovery document")
                return
            }
            
            guard let accessToken = token else {
                self.errorApp("Error getting accessToken")
                return
            }
            
            var urlRequest = URLRequest(url: userinfoEndpoint)
            urlRequest.allHTTPHeaderFields = ["Authorization":"Bearer \(accessToken)"]
            
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                
                DispatchQueue.main.async { [self] in
                    
                    guard error == nil else {
                        self.errorApp("HTTP request failed \(error?.localizedDescription ?? "ERROR")")
                        return
                    }
                    
                    guard let response = response as? HTTPURLResponse else {
                        self.errorApp("Non-HTTP response")
                        return
                    }
                    
                    guard let data = data else {
                        self.errorApp("HTTP response data is empty")
                        return
                    }
                    
                    var json: [AnyHashable: Any]?
                    
                    do {
                        json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    } catch {
                        self.errorApp("JSON Serialization Error")
                        return
                    }
                    
                    if response.statusCode != 200 {
                        // server replied with an error
                        let responseText: String? = String(data: data, encoding: String.Encoding.utf8)
                        
                        if response.statusCode == 401 {
                            // "401 Unauthorized" generally indicates there is an issue with the authorization
                            // grant. Puts OIDAuthState into an error state.
                            let oauthError = OIDErrorUtilities.resourceServerAuthorizationError(withCode: 0,
                                                                                                errorResponse: json,
                                                                                                underlyingError: error)
                            self.authState?.update(withAuthorizationError: oauthError)
                            print("Authorization Error (\(oauthError)). Response: \(responseText ?? "RESPONSE_TEXT")")
                        } else {
                            print("HTTP: \(response.statusCode), Response: \(responseText ?? "RESPONSE_TEXT")")
                        }
                        self.isLoader = false
                        self.setAuthState(nil)
                        return
                    }
                    
                    guard let user: UserInfo = try? JSONDecoder().decode(UserInfo.self, from: data) else {
                        self.errorApp("JSON serialization error in UserInfo")
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
                        
                        self.isLoader = false
                        complited()
                    }
                    
                    
                }
            }
            
            task.resume()
        }
    }
    
    public func getUserInfoReq() {
        self.getUserInfoReq {
            
        }
    }
    
}

//MARK: OIDAuthState Delegate
extension AppAuthInteraction: OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {
    
    func didChange(_ state: OIDAuthState) {
        self.stateChanged()
    }
    
    func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
        print("Received authorization error: \(error)")
    }
}

//MARK: Helper Methods
extension AppAuthInteraction {
    
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
        
        if let authState = self.authState {
            do {
                data = try NSKeyedArchiver.archivedData(withRootObject: authState, requiringSecureCoding: true)
            } catch {
                print("Not save data")
            }
        }
        
        if let userDefaults = UserDefaults(suiteName: "group.ru.RTUITLab.ITLab") {
            userDefaults.set(data, forKey: self.appAuthConfiguration.kAppAuthAuthStateKey)
            userDefaults.synchronize()
        }
    }
    
    private func loadState() {
        guard let data = UserDefaults (suiteName: "group.ru.RTUITLab.ITLab")?
                .object(forKey: self.appAuthConfiguration.kAppAuthAuthStateKey) as? Data
        else {
            return
        }
        do {
            let authState = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? OIDAuthState
            self.setAuthState(authState)
        }
        catch {
            print("Not load data")
        }
    }
    
    private func setAuthState(_ authState: OIDAuthState?) {
        if (self.authState == authState) {
            return;
        }
        self.authState = authState;
        self.authState?.stateChangeDelegate = self;
        self.stateChanged()
    }
    
    private func stateChanged() {
        self.saveState()
    }
}
