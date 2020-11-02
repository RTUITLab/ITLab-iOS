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
            self.logMessage("Error creating URL for : \(self.appAuthConfiguration.kIssuer)")
//            self.viewController.alertError("Error creating URL for : \(self.appAuthConfiguration.kIssuer)")
//            self.viewController.isLoading(false)
            
            self.isLoader = false
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
    
    public func performAction(freshTokens: @escaping (String?, Error?) -> Void) {
        guard let authState = self.authState else {
            self.logMessage("Not authState")
            return
        }
        
        authState.performAction { (token, _, error) in
            SwaggerClientAPI.customHeaders.updateValue("Bearer \(token ?? "")", forKey: "Authorization")
            freshTokens(token, error)
        }
    }
    
    public func getAccsesToken() -> String {
        guard let authState = self.authState else {
            self.logMessage("Not authState")
            return "Not token"
        }
        
        return authState.lastTokenResponse?.accessToken ?? "Not token"
    }
    
    public func isAuthorize() -> Bool {
        guard let authState = self.authState else {
            self.logMessage("Not authState")
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

        self.appDelegate.currentAuthorizationFlow = OIDAuthorizationService.present(request, externalUserAgent: agent!, callback: { (response, error) in
            
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
    
    private func doAuthWithAutoCodeExchange(configuration: OIDServiceConfiguration, clientID: String, clientSecret: String?) {
        
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

        
        guard let viewController = UIApplication.shared.windows.first?.rootViewController else {
            print("Not View Controller")
            return
        }
        
        self.appDelegate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: viewController) { authState, error in
            
            
            
            if let authState = authState {
                self.setAuthState(authState)
                self.logMessage("Got authorization tokens. Access token: \(authState.lastTokenResponse?.accessToken ?? "DEFAULT_TOKEN")")
                
//                self.viewController.logIn()
                
                
            } else {
                self.logMessage("Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
//                self.viewController.isLoading(false)
                self.setAuthState(nil)
            }
            
            self.isLoader = false
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

    private func saveState() {

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

    private func loadState() {
        guard let data = UserDefaults (suiteName: "group.ru.RTUITLab.ITLab")?
                .object(forKey: self.appAuthConfiguration.kAppAuthAuthStateKey) as? Data
        else {
            return
        }
        
        if let authState = NSKeyedUnarchiver.unarchiveObject(with: data) as? OIDAuthState {
            self.setAuthState(authState)
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

    private func logMessage(_ message: String?) {

        guard let message = message else {
            return
        }
        print(message);
    }
}
