//
//  AppAuthInteraction.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 29.09.2020.
//

import Foundation
import AppAuth

typealias PostRegistrationCallback = (_ configuration: OIDServiceConfiguration?, _ registrationResponse: OIDRegistrationResponse?) -> Void

class AppAuthInteraction: NSObject {
    private var authState: OIDAuthState?
    private var appAuthConfiguration : AppAuthConfiguration = AppAuthConfiguration()
//    private var viewController : AuthorizeController
    
    private var delegate: AppDelegate?
    
    private struct AppAuthConfiguration {
        var kIssuer: String = ""
        var kClientID: String = ""
        var kRedirectURL: String = ""
        let kAppAuthAuthStateKey: String = "authState"
    }
    
    override init() {
//        self.viewController = view
        
        super.init()
        
        self.configurationСheck()
        
        self.loadState()
        self.stateChanged()
    }
    
    convenience init(_ delegate: AppDelegate) {
        
        self.init()
        self.delegate = delegate
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
        
        
        guard let issuer = URL(string: self.appAuthConfiguration.kIssuer) else {
            self.logMessage("Error creating URL for : \(self.appAuthConfiguration.kIssuer)")
//            self.viewController.alertError("Error creating URL for : \(self.appAuthConfiguration.kIssuer)")
//            self.viewController.isLoading(false)
            return
        }

        self.logMessage("Fetching configuration for issuer: \(issuer)")

        // discovers endpoints
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in

            guard let config = configuration else {
                self.logMessage("Error retrieving discovery document: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
//                self.viewController.alertError("Error retrieving discovery document: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
//                self.viewController.isLoading(false)
                return
            }
            
            self.logMessage("Got configuration: \(config)")
        
            self.doAuthWithAutoCodeExchange(configuration: config, clientID: self.appAuthConfiguration.kClientID, clientSecret: nil)
        }
    }
    
   public func logOut()
    {
        guard let issuer = URL(string: self.appAuthConfiguration.kIssuer) else {
            self.logMessage("Error creating URL for : \(self.appAuthConfiguration.kIssuer)")
//            self.viewController.alertError("Error creating URL for : \(self.appAuthConfiguration.kIssuer)")
            self.closeApp()
            return
        }

        self.logMessage("Fetching configuration for issuer: \(issuer)")

        // discovers endpoints
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in

            guard let config = configuration else {
                self.logMessage("Error retrieving discovery document: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
//                self.viewController.alertError("Error retrieving discovery document: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                self.closeApp()
                return
            }

            self.logMessage("Got configuration: \(config)")
            
            self.endSession(configuration: config)
        }
    }
}

//MARK: AppAuth Methods
extension AppAuthInteraction {
    
    func endSession(configuration: OIDServiceConfiguration)
    {
        guard let redirectURI = URL(string: self.appAuthConfiguration.kRedirectURL) else {
            self.logMessage("Error creating URL for : \(self.appAuthConfiguration.kRedirectURL)")
//            self.viewController.alertError("Error creating URL for : \(self.appAuthConfiguration.kRedirectURL)")
            self.closeApp()
            return
        }
        
        let request: OIDEndSessionRequest = OIDEndSessionRequest(configuration: configuration, idTokenHint: self.getAuthState()?.lastTokenResponse?.idToken ?? "", postLogoutRedirectURL: redirectURI, additionalParameters: nil)
        
        
//        self.viewController.isLoading(false)
//        self.viewController.dismiss(animated: true, completion: nil)
        
        guard let viewController = UIApplication.shared.windows.first?.rootViewController else {
            print("Not View Controller")
            return
        }
        
        let agent = OIDExternalUserAgentIOS(presenting: viewController)
        
        guard let appDelegate = self.delegate else {
            print("Not AppDelegate")
//            self.viewController.alertError("Not AppDelegate")
            return
        }

        appDelegate.currentAuthorizationFlow = OIDAuthorizationService.present(request, externalUserAgent: agent!, callback: { (response, error) in
            
            if let respon = response
            {
                print(respon)
                self.authState = nil
                self.stateChanged()
//                self.viewController.dismiss(animated: true, completion: nil)
            }
            
            if let err = error
            {
                print(err)
                self.authState = nil
                self.stateChanged()
//                self.viewController.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    private func closeApp()
    {
//        self.viewController.isLoading(false)
        
        self.authState = nil
        self.stateChanged()
    }
    
    func doAuthWithAutoCodeExchange(configuration: OIDServiceConfiguration, clientID: String, clientSecret: String?) {
        
        guard let redirectURI = URL(string: self.appAuthConfiguration.kRedirectURL) else {
            self.logMessage("Error creating URL for : \(self.appAuthConfiguration.kRedirectURL)")
//            self.viewController.alertError("Error creating URL for : \(self.appAuthConfiguration.kRedirectURL)")
//            self.viewController.isLoading(false)
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
        
        guard let appDelegate = self.delegate else {
            print("Not AppDelegate")
//            self.viewController.alertError("Not AppDelegate")
//            self.viewController.isLoading(false)
            return
        }
        
        guard let viewController = UIApplication.shared.windows.first?.rootViewController else {
            print("Not View Controller")
            return
        }
        
        appDelegate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: viewController) { authState, error in
            
            
            
            if let authState = authState {
                self.setAuthState(authState)
                self.logMessage("Got authorization tokens. Access token: \(authState.lastTokenResponse?.accessToken ?? "DEFAULT_TOKEN")")
                
//                self.viewController.logIn()
                
                
            } else {
                self.logMessage("Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
//                self.viewController.isLoading(false)
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
            userDefaults.set(data, forKey: self.appAuthConfiguration.kAppAuthAuthStateKey)
//            print(data)
            userDefaults.synchronize()
        }
    }

    func loadState() {
        guard let data = UserDefaults (suiteName: "group.ru.RTUITLab.ITLab")?
                .object(forKey: self.appAuthConfiguration.kAppAuthAuthStateKey) as? Data
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
