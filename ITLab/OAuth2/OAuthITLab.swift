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
                complited(nil)
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
                case .success(_):
                    complited(nil)
                case .failure(let error):
                    complited(error)
                }
            }
        } else {
            complited(nil)
        }
    }
    
    public func isAuthorize() -> Bool {
        let credential = self.oauthSwift.client.credential
        return !credential.oauthToken.isEmpty && !credential.isTokenExpired()
    }
}

extension OAuthITLab {
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
