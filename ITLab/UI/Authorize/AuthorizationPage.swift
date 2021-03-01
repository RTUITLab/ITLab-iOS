//
//  AuthorizationPage.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 11/2/20.
//

import SwiftUI

struct AuthorizationPage: View {
    
    @ObservedObject private var oauthITLab : OAuthITLab = OAuthITLab.shared
    
    @State var isLoading: Bool = false
    
    var body: some View {
        VStack{
            if oauthITLab.isAuthorize {
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
                if isLoading {
                    ProgressView()
                } else {
                Button(action: {
                    isLoading = true
                    OAuthITLab.shared.authorize { (error) in
                        isLoading = false
                        print(error)
                    }
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
