//
//  MainMenu.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 29.09.2020.
//

import SwiftUI
import PushNotification

struct MainMenu: View {
    
    let eventPage = EventsPage()
    @State var user: UserView = UserView(_id: UUID(),
                                         firstName: nil,
                                         lastName: nil,
                                         middleName: nil,
                                         phoneNumber: nil,
                                         email: nil,
                                         properties: nil)
    
    var body: some View {
        TabView {
            
            eventPage
                .tabItem {
                    VStack {
                        Image(systemName: "calendar")
                        Text("События")
                    }
                }
            
            UsersListPage()
                .tabItem {
                    VStack {
                        Image(systemName: "person.2.fill")
                        Text("Сотрудники")
                    }
                }
            
            ProfilePage(user: $user)
                .tabItem {
                    VStack {
                        Image(systemName: "person.crop.circle")
                        Text("Профиль")
                        
                    }
                }
        }
        .onAppear {
            
            OAuthITLab.shared.getToken { token in
                activateNotify(user: token)
                
                eventPage.isEditingRight = OAuthITLab.shared.getUserInfo()?.getRole("CanEditEvent") ?? false
                
                if let profile = OAuthITLab.shared.getUserInfo()?.profile {
                    user = profile
                }
            }
            
            Contact.requestAccess()
        }
    }
    
    private func activateNotify(user jwt: String) {
        if let serverAPI = Bundle.main.object(forInfoDictionaryKey: "ServerApi") as? [String: String] {
            if let pushURL = serverAPI["PushNotification"],
               !pushURL.isEmpty,
               var url = URLComponents(string: pushURL) {
                url.scheme = "https"
                
                PushNotification.notificationActivate(url.string!,
                                                      authenticationMethod: .jwt(token: jwt))
            } else if let url = URL(string: SwaggerClientAPI.getURL()
                                                + "/api/push") {
                
                PushNotification.notificationActivate(url.string,
                                                      authenticationMethod: .jwt(token: jwt))
            }
        }
    }
}
