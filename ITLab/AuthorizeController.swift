//
//  AuthorizeController.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 28.09.2020.
//

import UIKit
import AppAuth

class AuthorizeController : UIViewController {
    
    @IBOutlet private weak var ClickButton: UIButton!
    
    private var authState: OIDAuthState?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
}

extension AuthorizeController {
    
    @IBAction func authWithAutoCodeExchange(_ sender: UIButton) {

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
extension AuthorizeController {

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
        
        guard let appDelegate = ITLabApp.delegate as? AppDelegate else {
            self.logMessage("Error accessing AppDelegate")
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
        
        self.logMessage("\(self)")

        appDelegate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: self) { authState, error in
            
            

            if let authState = authState {
                self.setAuthState(authState)
                self.logMessage("Got authorization tokens. Access token: \(authState.lastTokenResponse?.accessToken ?? "DEFAULT_TOKEN")")
            } else {
                self.logMessage("Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                self.setAuthState(nil)
            }
        }
    }
}

//MARK: OIDAuthState Delegate
extension AuthorizeController: OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {

    func didChange(_ state: OIDAuthState) {
        self.stateChanged()
    }

    func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
        self.logMessage("Received authorization error: \(error)")
    }
}

//MARK: Helper Methods
extension AuthorizeController {

    func saveState() {

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

    func loadState() {
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

