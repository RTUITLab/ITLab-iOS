//
//  AuthorizationPage.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 11/2/20.
//

import SwiftUI
import AppAuth

struct AuthorizationPage: View {
    
    @ObservedObject private var appAuth : AppAuthInteraction = AppAuthInteraction.shared
    
    var body: some View {
        VStack{
            if appAuth.getAuthState()?.isAuthorized ?? false {
                MainMenu()
            } else {
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
                if appAuth.isLoader {
                    ProgressView()
                } else {
                Button(action: {
                    appAuth.authorization()
                }){
                    Text("Войти")
                        .font(.title)
                        .padding(50)
                }
                }
                Spacer()
            }
        }
    }
}

struct AuthorizationPage_Previews: PreviewProvider {
    static var previews: some View {
        AuthorizationPage()
    }
}
