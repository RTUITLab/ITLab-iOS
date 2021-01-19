//
//  MainMenu.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 29.09.2020.
//

import SwiftUI
import AppAuth

struct MainMenu: View {
    
    let eventPage = EventsPage()
    @State var user: UserView?
    
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
        .onAppear() {
            Contact.requestAccess()
            
            if let profile = AppAuthInteraction.shared.getUserInfo()?.profile {
                user = profile
            }
            
            AppAuthInteraction.shared.getUserInfoReq {
                eventPage.isEditungRight = AppAuthInteraction.shared.getUserInfo()?.getRole("CanEditEvent") ?? false
                
                user = AppAuthInteraction.shared.getUserInfo()?.profile
            }
            
            
        }
    }
    
    
}

struct СolorPaletteView: View {
    var body: some View {
        VStack {
            Rectangle()
                .frame(width: 300, height: 300, alignment: .center)
                .padding(.top, 20.0)
            
            Spacer()
            
            Text("-1")
            
            Spacer()
            
            HStack {
                Rectangle()
                    .frame(width: 100, height: 100, alignment: .center)
                    .padding(.horizontal)
                
                Rectangle()
                    .frame(width: 100, height: 100, alignment: .center)
                    .padding(.horizontal)
                
                Rectangle()
                    .frame(width: 100, height: 100, alignment: .center)
                    .padding(.horizontal)
            }
            .padding(.bottom, 15.0)
        }
    }
}
