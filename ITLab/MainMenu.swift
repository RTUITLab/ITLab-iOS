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
                    Text("События")
                }
            
            Text("Equipment")
                .tabItem {
                    Text("Оборудование")
                }
            
            Text("Users")
                .tabItem {
                    Text("Пользователи")
                }
            
            TestPage()
                .tabItem {
                    Text("Test")
                }
        }
    }
    
}


struct MainMenu_Previews: PreviewProvider {
    static var previews: some View {
        MainMenu()
            
    }
}
