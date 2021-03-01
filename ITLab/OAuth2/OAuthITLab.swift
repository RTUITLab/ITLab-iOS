//
//  OAuthITLab.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 01.03.2021.
//

import Foundation
import OAuthSwift

class OAuthITLab {
    
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
    
    private var configuration : OAuthITLabConfiguration
    
    public let oauthSwift: OAuth2Swift
    
    init() {
        self.configuration = OAuthITLabConfiguration()
        self.oauthSwift = OAuth2Swift(
            consumerKey:    configuration.kClientID,
            consumerSecret: "",
            authorizeUrl:   configuration.kIssuer + "/connect/authorize",
            accessTokenUrl: configuration.kIssuer + "/connect/token",
            responseType:   "code"
        )
    }
}
