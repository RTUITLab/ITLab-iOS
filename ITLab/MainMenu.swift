//
//  MainMenu.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 29.09.2020.
//

import SwiftUI
import AppAuth

struct MainMenu: View {
    
    var body: some View {
        VStack{
            Text(ITLabApp.authorizeController.getAccsesToken())
                .font(.body)
                .padding()
            
            
            Text(ITLabApp.authorizeController.isAuthorize() ? "Authorized" : "Not authorize")
                .font(.title)
                .bold()
            
            Button(action: {
                let appAuthInteractive = ITLabApp.authorizeController
                
                appAuthInteractive.performAction { (accesToken, idToken, error) in
                    
                    print(accesToken)
                }
            })
            {
                Text("Update token")
                    .font(.body)
            }
            .padding(.top, 10)
            
            
            Button(action: {
                let appAuthInteractive = ITLabApp.authorizeController
                
                appAuthInteractive.logOut()
            })
            {
                Text("Log Out")
                    .font(.title)
            }
            .padding(.top, 50)
        }
    }
    
}


struct MainMenu_Previews: PreviewProvider {
    static var previews: some View {
        MainMenu()
    }
}
