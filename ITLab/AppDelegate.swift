//
//  AppDelegate.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 26.09.2020.
//

import UIKit
import AppAuth

class AppDelegate: UIResponder, UIApplicationDelegate
{
    public var currentAuthorizationFlow : OIDExternalUserAgentSession?
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if let authorizationFlow = self.currentAuthorizationFlow, authorizationFlow.resumeExternalUserAgentFlow(with: url) {
            self.currentAuthorizationFlow = nil
            return true
        }

        return false
    }
}
