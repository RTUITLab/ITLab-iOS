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
            
            TestPage()
                .tabItem {
                    VStack {
                        Image(systemName: "person.crop.circle")
                        Text("Профиль")
                        
                    }
                }
        }
        .onAppear() {
            AppAuthInteraction.shared.getUserInfoReq {
                eventPage.isEditungRight = AppAuthInteraction.shared.getUserInfo()?.getRole("CanEditEvent") ?? false
            }
        }
    }
    
    
}


struct MainMenu_Previews: PreviewProvider {
    static var previews: some View {
        MainMenu()
        
    }
}
