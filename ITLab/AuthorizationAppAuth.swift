//
//  AuthorizationAppAuth.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 26.09.2020.
//

import Foundation
import SwiftUI
import AppAuth

typealias PostRegistrationCallback = (_ configuration: OIDServiceConfiguration?, _ registrationResponse: OIDRegistrationResponse?) -> Void

struct AppAuthConfiguration {
    static let kIssuer: String = "https://issuer.example.com"
    static let kClientID: String? = "YOUR_CLIENT_ID"
    static let kRedirectURI: String = "com.example.app:/oauth2redirect/example-provider"
    static let kAppAuthAuthStateKey: String = "authState"
}

//MARK: Класс по работе с библиотекой AppAuth
class AutorizationAppAuth: NSObject {
   
    private var authState: OIDAuthState?
    
    public var delegate: AppDelegate
    
    init(delegate: AppDelegate) {
        self.delegate = delegate;
    }
    
    func doClientRegistration(configuration: OIDServiceConfiguration, callback: @escaping PostRegistrationCallback) {
        guard let redirectURL = URL(string: AppAuthConfiguration.kRedirectURI) else {
            print("Error creating URL for : \(AppAuthConfiguration.kRedirectURI)")
            return
        }
        
        let request: OIDRegistrationRequest = OIDRegistrationRequest(
                                            configuration: configuration,
                                            redirectURIs: [redirectURL],
                                            responseTypes: nil,
                                            grantTypes: nil,
                                            subjectType: nil,
                                            tokenEndpointAuthMethod: "client_secret_post",
                                            additionalParameters: nil)
        
        print("Initiating registration request")
        
        OIDAuthorizationService.perform(request) {
            response, error in
            
            if let regResponse = response {
                self.setAuthState(OIDAuthState(registrationResponse: regResponse))
                print("Got registration response: \(regResponse)")
                callback(configuration, regResponse)
            }
            else {
                print("Registration error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                self.setAuthState(nil)
            }
        }
    }
    
    func doAuthWithAutoCodeExchange(configuration: OIDServiceConfiguration, clientID: String, clientSecret: String?, view: UIViewController)
    {
        guard let redirectURL = URL(string: AppAuthConfiguration.kRedirectURI) else {
            print("Error creating URL for : \(AppAuthConfiguration.kRedirectURI)")
            return
        }
        
        
        let request = OIDAuthorizationRequest(configuration: configuration,
                                              clientId: clientID,
                                              clientSecret: clientSecret,
                                              scopes: [OIDScopeOpenID, OIDScopeProfile],
                                              redirectURL: redirectURL,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: nil)
        
        print("Initiating authorization request with scope: \(request.scope ?? "DEFAULT_SCOPE")")
        
        self.delegate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: view) { authState, error in
            
            if let authState = authState {
                self.setAuthState(authState)
                print("Got authorization tokens. Access token: \(authState.lastTokenResponse?.accessToken ?? "DEFAULT_TOKEN")")
            } else {
                print("Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                self.setAuthState(nil)
            }
            
        }
    }
}

extension AutorizationAppAuth: OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {
    func didChange(_ state: OIDAuthState) {
        self.saveState()
    }
    
    func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
        print("Received authorization error: \(error)")
    }
    
}

//MARK: Вспомогательные методы
extension AutorizationAppAuth {
    
    func saveState()
    {
        var data : Data? = nil
        
        if let authState = self.authState {
            do {
                try data = NSKeyedArchiver.archivedData(withRootObject: authState, requiringSecureCoding: false)
            } catch (_) {
                print("Try catch archivedData")
            }
        }
        
        if let userDefaults = UserDefaults(suiteName: "group.ru.RTUITLab.ITLab") {
            userDefaults.set(data, forKey: AppAuthConfiguration.kAppAuthAuthStateKey)
            userDefaults.synchronize()
        }
    }
    
    func loadState()
    {
        guard let data = UserDefaults (suiteName: "group.ru.RTUITLab.ITLab")?
                .object(forKey: AppAuthConfiguration.kAppAuthAuthStateKey) as? Data
        else {
            return
        }
        
        do {
            let authState = try NSKeyedUnarchiver.unarchivedObject(ofClass: OIDAuthState.self, from: data)
            
            self.setAuthState(authState)
            
        } catch (_) {
            print("Try catch unarchivedObject")
        }
    }
    
    func setAuthState(_ authState: OIDAuthState?)
    {
        if (self.authState == authState) { return }
        
        self.authState = authState
        self.authState?.stateChangeDelegate = self
        self.saveState()
    }
}
