//
//  ITLabApp.swift
//  ITLab
//
//  Created by Михаил Иванов on 21.09.2020.
//

import SwiftUI
//import AppAuth

@main
struct ITLabApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            AuthorizeView(delegate: self.delegate)
        }
       
    }
}
