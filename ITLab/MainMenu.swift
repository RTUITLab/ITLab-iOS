//
//  MainMenu.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 29.09.2020.
//

import SwiftUI
import AppAuth

struct MainMenu: View {
    
    let authorizeController: UIViewController?
    
    init()
    {
        self.authorizeController = nil
    }
    
    init(_ viewController: UIViewController)
    {
        self.authorizeController = viewController
    }
    
    var body: some View {
        VStack{
            Text(AppAuthInteraction.getAuthState()?.lastTokenResponse?.accessToken ?? "Token")
                .font(.body)
            
            
            Text(AppAuthInteraction.getAuthState()?.isAuthorized ?? false ? "Authorized" : "Not authorize")
                .font(.title)
                .bold()
            
            Button(action: {
                let appAuthInteractive = AppAuthInteraction()
                appAuthInteractive.clearAuthState(self.authorizeController!)
                
                
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
