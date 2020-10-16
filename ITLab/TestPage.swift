//
//  TestPage.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 06.10.2020.
//

import SwiftUI

struct TestPage: View {
    
    @State var accesToken : String?
    @State var isAuthorize : Bool?
    
    var body: some View {
        VStack{
            Text(accesToken ?? "Not token")
                .font(.callout)
                .padding()
            
            
            Text(isAuthorize ?? false ? "Authorized" : "Not authorize")
                .font(.title)
                .bold()
            
            Button(action: {
                let appAuthInteractive = AuthorizeController.shared!
                
                let currentAccesToken = appAuthInteractive.getAccsesToken()
                
                appAuthInteractive.performAction { (accesToken, idToken, error) in
                    
                    if currentAccesToken == accesToken {
                        print("Current token valid")
                        return
                    }
                    
                    print("Update token")
                    
                    self.accesToken = accesToken
                    self.isAuthorize = AuthorizeController.shared!.isAuthorize()
                }
            })
            {
                Text("Update acces token")
                    .font(.body)
            }
            .padding(.top, 10)
            
            Button(action: {
                let appAuthInteractive = AuthorizeController.shared!
                
                appAuthInteractive.logOut()
            })
            {
                Text("Log Out")
                    .font(.title)
            }
            .padding(.top, 50)
        }
        .onAppear(){
            let appAuthInteractive = AuthorizeController.shared!
            
            self.accesToken = appAuthInteractive.getAccsesToken()
            self.isAuthorize =  appAuthInteractive.isAuthorize()
        }
    }
    
}

struct TestPage_Previews: PreviewProvider {
    static var previews: some View {
        TestPage()
    }
}
