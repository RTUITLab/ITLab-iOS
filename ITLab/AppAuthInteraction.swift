//
//  AppAuthInteraction.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 29.09.2020.
//

import Foundation
import AppAuth

typealias PostRegistrationCallback = (_ configuration: OIDServiceConfiguration?, _ registrationResponse: OIDRegistrationResponse?) -> Void

struct AppAuthConfiguration {
    static let kIssuer: String = "https://dev.identity.rtuitlab.ru/"
    static let kClientID: String? = "itlab_mobile_app"
    static let kRedirectURI: String = "ru.RTUITLab.ITLab:/oauth2redirect/example-provider"
    static let kAppAuthAuthStateKey: String = "authState"
}

class AppAuthInteraction: NSObject {
    private var authState: OIDAuthState?
    
    private var viewController : AuthorizeController
    
    init(view: AuthorizeController) {
        self.viewController = view
        
        super.init()
        
        self.loadState()
        self.stateChanged()
    }
    
    public func getAuthState() -> OIDAuthState?
    {
        return self.authState
    }
    
}

extension AppAuthInteraction {
    
    public func authorization() {
        
        
        guard let issuer = URL(string: AppAuthConfiguration.kIssuer) else {
            self.logMessage("Error creating URL for : \(AppAuthConfiguration.kIssuer)")
            return
        }

        self.logMessage("Fetching configuration for issuer: \(issuer)")

        // discovers endpoints
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in

            guard let config = configuration else {
                self.logMessage("Error retrieving discovery document: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                self.setAuthState(nil)
                return
            }

            self.logMessage("Got configuration: \(config)")

            if let clientId = AppAuthConfiguration.kClientID {
                self.doAuthWithAutoCodeExchange(configuration: config, clientID: clientId, clientSecret: nil)
            } else {
                self.doClientRegistration(configuration: config) { configuration, response in

                    guard let configuration = configuration, let clientID = response?.clientID else {
                        self.logMessage("Error retrieving configuration OR clientID")
                        return
                    }

                    self.doAuthWithAutoCodeExchange(configuration: configuration,
                                                    clientID: clientID,
                                                    clientSecret: response?.clientSecret)
                }
            }
        }
    }
    
   public func logOut()
    {
        guard let issuer = URL(string: AppAuthConfiguration.kIssuer) else {
            self.logMessage("Error creating URL for : \(AppAuthConfiguration.kIssuer)")
            return
        }

        self.logMessage("Fetching configuration for issuer: \(issuer)")

        // discovers endpoints
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in

            guard let config = configuration else {
                self.logMessage("Error retrieving discovery document: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                self.setAuthState(nil)
                return
            }

            self.logMessage("Got configuration: \(config)")
            
            self.endSession(configuration: config)
        }
        
        self.authState = nil
        stateChanged()
    }
}

//MARK: AppAuth Methods
extension AppAuthInteraction {
    
    func endSession(configuration: OIDServiceConfiguration)
    {
        guard let redirectURI = URL(string: AppAuthConfiguration.kRedirectURI) else {
            self.logMessage("Error creating URL for : \(AppAuthConfiguration.kRedirectURI)")
            return
        }
        
        
        
        let request: OIDEndSessionRequest = OIDEndSessionRequest(configuration: configuration, idTokenHint: self.getAuthState()?.lastTokenResponse?.idToken ?? "", postLogoutRedirectURL: redirectURI, additionalParameters: nil)
        
        let agent = OIDExternalUserAgentIOS(presenting: viewController)
        
        OIDAuthorizationService.present(request, externalUserAgent: agent!, callback: {
            (response, error) in
                if let respon = response
                           {
                               print(respon)
                           }

                           if let err = error
                           {
                               print(err)
                           }
        })
        
    }

    func doClientRegistration(configuration: OIDServiceConfiguration, callback: @escaping PostRegistrationCallback) {

        guard let redirectURI = URL(string: AppAuthConfiguration.kRedirectURI) else {
            self.logMessage("Error creating URL for : \(AppAuthConfiguration.kRedirectURI)")
            return
        }
        let request: OIDRegistrationRequest = OIDRegistrationRequest(configuration: configuration,
                                                                     redirectURIs: [redirectURI],
                                                                     responseTypes: nil,
                                                                     grantTypes: nil,
                                                                     subjectType: nil,
                                                                     tokenEndpointAuthMethod: "client_secret_post",
                                                                     additionalParameters: nil)

        // performs registration request
        self.logMessage("Initiating registration request")

        OIDAuthorizationService.perform(request) { response, error in

            if let regResponse = response {
                self.setAuthState(OIDAuthState(registrationResponse: regResponse))
                self.logMessage("Got registration response: \(regResponse)")
                callback(configuration, regResponse)
            } else {
                self.logMessage("Registration error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                self.setAuthState(nil)
            }
        }
    }

    func doAuthWithAutoCodeExchange(configuration: OIDServiceConfiguration, clientID: String, clientSecret: String?) {

        guard let redirectURI = URL(string: AppAuthConfiguration.kRedirectURI) else {
            self.logMessage("Error creating URL for : \(AppAuthConfiguration.kRedirectURI)")
            return
        }

        // builds authentication request
        let request = OIDAuthorizationRequest(configuration: configuration,
                                              clientId: clientID,
                                              clientSecret: clientSecret,
                                              scopes: [OIDScopeOpenID, OIDScopeProfile, "itlab.events", "roles", "offline_access"],
                                              redirectURL: redirectURI,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: nil)
        
        // performs authentication request
        logMessage("Initiating authorization request with scope: \(request.scope ?? "DEFAULT_SCOPE")")
        
        ITLabApp.delegate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: self.viewController) { authState, error in
            
            
            
            if let authState = authState {
                self.setAuthState(authState)
                self.logMessage("Got authorization tokens. Access token: \(authState.lastTokenResponse?.accessToken ?? "DEFAULT_TOKEN")")
                
                self.viewController.logIn()
                
                
            } else {
                self.logMessage("Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                self.setAuthState(nil)
            }
        }
    }
}

//MARK: OIDAuthState Delegate
extension AppAuthInteraction: OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {

    func didChange(_ state: OIDAuthState) {
        self.stateChanged()
    }

    func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
        self.logMessage("Received authorization error: \(error)")
    }
}

//MARK: Helper Methods
extension AppAuthInteraction {

    func saveState() {

        var data : Data? = nil
        
        if let authState = self.authState {
            data = NSKeyedArchiver.archivedData(withRootObject: authState)
        }
        
        if let userDefaults = UserDefaults(suiteName: "group.ru.RTUITLab.ITLab") {
            userDefaults.set(data, forKey: AppAuthConfiguration.kAppAuthAuthStateKey)
//            print(data)
            userDefaults.synchronize()
        }
    }

    func loadState() {
        guard let data = UserDefaults (suiteName: "group.ru.RTUITLab.ITLab")?
                .object(forKey: AppAuthConfiguration.kAppAuthAuthStateKey) as? Data
        else {
            return
        }
        
        if let authState = NSKeyedUnarchiver.unarchiveObject(with: data) as? OIDAuthState {
            self.setAuthState(authState)
        }
    }

    func setAuthState(_ authState: OIDAuthState?) {
        if (self.authState == authState) {
            return;
        }
        self.authState = authState;
        self.authState?.stateChangeDelegate = self;
        self.stateChanged()
    }

    func stateChanged() {
        self.saveState()
    }

    func logMessage(_ message: String?) {

        guard let message = message else {
            return
        }

        print(message);
    }
}
