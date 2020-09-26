//
//  AuthorizePage.swift
//  ITLab
//
//  Created by Михаил Иванов on 21.09.2020.
//

import SwiftUI
import AppAuth


struct AuthorizeView: View {
    
    var delegate: AppDelegate?

    init(delegate: AppDelegate)
    {
        self.delegate = delegate;
        
    }
    
    init() {
        delegate = nil
    }
    
    var body: some View {
        VStack (spacing: 30){
            Spacer()
            VStack {
                Image("Logo")
                    .resizable()
                    .frame(width: 260, height: 230, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                Text("RTU IT Lab")
                    .font(/*@START_MENU_TOKEN@*/.largeTitle/*@END_MENU_TOKEN@*/)
                    .bold()
            }
            
            Spacer()
            
            Button(action: {
                authWithAutoCodeExchange()
            }) {
                Text("Войти")
                    .font(.title)
            }
            
            Spacer()
        }
    }
    
    func authWithAutoCodeExchange()
    {
        if(self.delegate == nil)
        {
            print("AppDelegate needs to be initialized")
            return
            
        }
        
        let authorize = AutorizationAppAuth(delegate: self.delegate!)
        
        guard let issuer = URL(string: AppAuthConfiguration.kIssuer) else {
            print("Error creating URL for : \(AppAuthConfiguration.kIssuer)")
            return
        }
        
        print("Fetching configuration for issuer: \(issuer)")
        
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in
            
            guard let config = configuration
            else {
                print("Error retrieving discovery document: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                authorize.setAuthState(nil)
                return
            }
            
            print("Got configuration: \(config)")
            
            if let clientId = AppAuthConfiguration.kClientID {
                authorize.doAuthWithAutoCodeExchange(configuration: config, clientID: clientId, clientSecret: nil, view: UIHostingController(rootView: self)) }
            else {
                authorize.doClientRegistration(configuration: config) {
                    configuration, response in
                    guard let configuration = configuration, let clientID = response?.clientID
                    else {
                        print("Error retrieving configuration OR clientID")
                        return
                    }
                    
                    authorize.doAuthWithAutoCodeExchange(configuration: configuration, clientID: clientID, clientSecret: response?.clientSecret, view: UIHostingController(rootView: self))
                }
            }
        }
    }
    
}

struct AuthorizeView_Previews_XIProMax: PreviewProvider {
    static var previews: some View {
        AuthorizeView()
            .previewDisplayName("Dark")
            .preferredColorScheme(.dark)
            .previewDevice(/*@START_MENU_TOKEN@*/"iPhone 11 Pro Max"/*@END_MENU_TOKEN@*/)
        
        AuthorizeView()
            .previewDisplayName("Light")
            .preferredColorScheme(.light)
            .previewDevice(/*@START_MENU_TOKEN@*/"iPhone 11 Pro Max"/*@END_MENU_TOKEN@*/)
            
    }
}

struct AuthorizeView_Previews_VIIPlus: PreviewProvider {
    static var previews: some View {
        AuthorizeView()
            .previewDisplayName("Dark")
            .preferredColorScheme(.dark)
            .previewDevice(/*@START_MENU_TOKEN@*/"iPhone 8 Plus"/*@END_MENU_TOKEN@*/)
        
        AuthorizeView()
            .previewDisplayName("Light")
            .preferredColorScheme(.light)
            .previewDevice(/*@START_MENU_TOKEN@*/"iPhone 8 Plus"/*@END_MENU_TOKEN@*/)
            
    }
}
