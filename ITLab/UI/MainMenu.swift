//
//  MainMenu.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 29.09.2020.
//

import SwiftUI
import AppAuth

struct MainMenu: View {
    
    var body: some View {
        TabView {
            
            EventsPage()
                .tabItem {
                    VStack {
                        Image(systemName: "newspaper.fill")
                        Text("События")
                    }
                }
            
            //            Text("Equipment")
            //                .tabItem {
            //                    Text("Оборудование")
            //                }
            
            UsersListPage()
                .tabItem {
                    VStack {
                        Image(systemName: "person.2.fill")
                        Text("Пользователи")
                    }
                }
            
            TestPage()
                .tabItem {
                    VStack {
                        Image(systemName: "gearshape.2.fill")
                        Text("Настройки")
                           
                    }
                }
        }
    }
}


struct MainMenu_Previews: PreviewProvider {
    static var previews: some View {
        MainMenu()
        
    }
}
