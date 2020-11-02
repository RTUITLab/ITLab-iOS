//
//  ITLabApp.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 11/2/20.
//

import SwiftUI

@main
struct ITLabApp: App {
  
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup{
            AuthorizationPage()
        }
    }
}
