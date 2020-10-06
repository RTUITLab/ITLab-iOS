//
//  TestPage.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 06.10.2020.
//

import SwiftUI

struct TestPage: View {
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
                    
                    print(accesToken ?? "not token")
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

struct TestPage_Previews: PreviewProvider {
    static var previews: some View {
        TestPage()
    }
}
