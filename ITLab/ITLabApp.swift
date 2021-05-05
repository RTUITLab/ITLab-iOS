//
//  ITLabApp.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 11/2/20.
//

import SwiftUI

@main
struct ITLabApp: App {
    
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup{
            AuthorizationPage()
        }
    }
}
