//
//  ITLabApp.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 11/2/20.
//

import SwiftUI

@main
struct ITLabApp: App {
    
    init() {
        //TODO: deleted
        UserDefaults(suiteName: "group.ru.RTUITLab.ITLab")?.removeObject(forKey: "authState")
    }
    
    var body: some Scene {
        WindowGroup{
            AuthorizationPage()
        }
    }
}
