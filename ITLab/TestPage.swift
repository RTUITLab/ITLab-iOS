//
//  TestPage.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 06.10.2020.
//

import SwiftUI

struct TestPage: View {
    
    @State var accesToken : String = AppAuthInteraction.shared.getAccsesToken()
    @State var isAuthorize : Bool = AppAuthInteraction.shared.isAuthorize()
    
    var body: some View {
        VStack{
            Text(accesToken)
                .font(.callout)
                .padding()
            
            
            Text(isAuthorize ? "Authorized" : "Not authorize")
                .font(.title)
                .bold()
            
            Button(action: {
                let appAuthInteractive = AppAuthInteraction.shared
                
                let currentAccesToken = appAuthInteractive.getAccsesToken()
                
                appAuthInteractive.performAction { (accesToken, error) in
                    
                    if currentAccesToken == accesToken {
                        print("Current token valid")
                        return
                    }
                    
                    print("Update token")
                }
            })
            {
                Text("Update acces token")
                    .font(.body)
            }
            .padding(.top, 10)
            
            Button(action: {
                let appAuthInteractive = AppAuthInteraction.shared
                
                appAuthInteractive.logOut()
            })
            {
                Text("Log Out")
                    .font(.title)
            }
            .padding(.top, 50)
        }
        .onAppear(){
            let appAuthInteractive = AppAuthInteraction.shared
            
            self.accesToken = appAuthInteractive.getAccsesToken()
            self.isAuthorize = appAuthInteractive.isAuthorize()
        }
    }
    
}

struct TestPage_Previews: PreviewProvider {
    static var previews: some View {
        TestPage()
    }
}
