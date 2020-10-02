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
    static let kIssuer: String = "https://demo.identityserver.io"
    static let kClientID: String? = "interactive.public"
    static let kRedirectURI: String = "ru.RTUITLab.ITLab:/oauth2redirect/example-provider"
    static let kAppAuthAuthStateKey: String = "authState"
}

class AppAuthInteraction: NSObject {
    static private var authState: OIDAuthState?
    
    private var viewController : UIViewController
    private var newViewController : UIViewController
    
    private var openNewView: Bool = false
    
    override init()
    {
        self.viewController = UIViewController()
        self.newViewController = UIViewController()
        
        super.init()
        
        self.loadState()
        self.stateChanged()
    }
    
    convenience init(view: UIViewController) {
        self.init()
        
        self.viewController = view
    }
    
    convenience init(view: UIViewController, newView: UIViewController, openNewView: Bool) {
        self.init(view: view)
        
        self.newViewController = newView
        self.openNewView = openNewView
    }
    
    static public func getAuthState() -> OIDAuthState?
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
}

//MARK: AppAuth Methods
extension AppAuthInteraction {
    
    func endSession(configuration: OIDServiceConfiguration, viewController: UIViewController)
    {
        guard let redirectURI = URL(string: AppAuthConfiguration.kRedirectURI) else {
            self.logMessage("Error creating URL for : \(AppAuthConfiguration.kRedirectURI)")
            return
        }
        
        
        
        let request: OIDEndSessionRequest = OIDEndSessionRequest(configuration: configuration, idTokenHint: AppAuthInteraction.getAuthState()?.lastTokenResponse?.idToken ?? "", postLogoutRedirectURL: redirectURI, additionalParameters: nil)
        
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
            
            viewController.dismiss(animated: true, completion: nil)
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
                                              scopes: [OIDScopeOpenID, OIDScopeProfile],
                                              redirectURL: redirectURI,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: nil)

        // performs authentication request
        logMessage("Initiating authorization request with scope: \(request.scope ?? "DEFAULT_SCOPE")")

        ITLabApp.delegate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: self.viewController) { authState, error in
            
            

            if let authState = authState {
                self.setAuthState(authState)
                self.logMessage("Got authorization tokens. Access token: \(authState.lastTokenResponse?.accessToken ?? "DEFAULT_TOKEN")")
                
                if (self.openNewView)
                {
                    self.self.openMenu()
                }
                
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
        
        if let authState = AppAuthInteraction.authState {
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
    
    func clearAuthState(_ viewController: UIViewController)
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
            
            self.endSession(configuration: config, viewController: viewController)
        }
        
        AppAuthInteraction.authState = nil
        stateChanged()
    }

    func setAuthState(_ authState: OIDAuthState?) {
        if (AppAuthInteraction.authState == authState) {
            return;
        }
        AppAuthInteraction.authState = authState;
        AppAuthInteraction.authState?.stateChangeDelegate = self;
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
    
    public func openMenu()
    {
        newViewController.modalPresentationStyle = .fullScreen
        
        viewController.present(newViewController, animated: false, completion: nil)
        
    }
}
