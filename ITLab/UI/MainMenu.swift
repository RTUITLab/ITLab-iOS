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
                        Image(systemName: "calendar")
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
        .onAppear()
        {
            
        }
    }
    
    
}


struct MainMenu_Previews: PreviewProvider {
    static var previews: some View {
        MainMenu()
        
    }
}
