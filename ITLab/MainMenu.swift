//
//  MainMenu.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 29.09.2020.
//

import SwiftUI
import AppAuth

struct MainMenu: View {
    
    let authState : OIDAuthState?
    
    init()
    {
        self.authState = nil
    }
    
    init(authState: OIDAuthState) {
        self.authState = authState
    }
    
    var body: some View {
        Text(authState?.lastTokenResponse?.accessToken ?? "kek")
    }
}

struct MainMenu_Previews: PreviewProvider {
    static var previews: some View {
        MainMenu()
    }
}
