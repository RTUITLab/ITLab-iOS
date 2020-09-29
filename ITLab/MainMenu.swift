//
//  MainMenu.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 29.09.2020.
//

import SwiftUI
import AppAuth

struct MainMenu: View {
    
    @State var authState : OIDAuthState? = AppAuthInteraction.getAuthState()
    
    init()
    {
        self.authState = AppAuthInteraction.getAuthState()
    }
    
    
    var body: some View {
        VStack{
            Text(authState?.lastTokenResponse?.accessToken ?? "Token")
                .font(.body)
            
            
            Text(authState?.isAuthorized ?? false ? "Authorized" : "Not authorize")
                .font(.title)
                .bold()
            
            Button(action: {
                let appAuthInteractive = AppAuthInteraction()
                appAuthInteractive.clearAuthState()
                
                self.authState = AppAuthInteraction.getAuthState()
            })
            {
                Text("Clear token")
            }
        }
    }
}


struct MainMenu_Previews: PreviewProvider {
    static var previews: some View {
        MainMenu()
    }
}
