//
//  AuthorizationPage.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 11/2/20.
//

import SwiftUI
import AppAuth

struct AuthorizationPage: View {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some View {
        VStack{
            VStack{
                Image("LogoRTU")
                    .resizable()
                    .frame(width: 280, height: 250)
                Text("RTU IT Lab")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .padding(.top, 20)
            Spacer()
            Button(action: {
                let authorizeAppAuth = AppAuthInteraction(appDelegate)
                authorizeAppAuth.authorization()
            }){
                Text("Войти")
                    .font(.title)
                    .padding(50)
            }
            Spacer()
        }
    }
}

struct AuthorizationPage_Previews: PreviewProvider {
    static var previews: some View {
        AuthorizationPage()
    }
}
