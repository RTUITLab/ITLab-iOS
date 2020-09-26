//
//  ITLabApp.swift
//  ITLab
//
//  Created by Михаил Иванов on 21.09.2020.
//

import SwiftUI
import AppAuth

@main
struct ITLabApp: App {
    
    var currentAuthoriationFlow : OIDExternalUserAgentSession?
    
    var body: some Scene {
        WindowGroup {
            AuthorizeView(app: self)
        }
       
    }
    
    init() {
        currentAuthoriationFlow = nil
        print("Hello")
    }
}
