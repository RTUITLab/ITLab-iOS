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
    
    @State var mainColor: Color = Color.blue
    @State var oneButtonColor: Color = Color.green
    @State var twoButtonColor: Color = Color.green
    @State var threeButtonColor: Color = Color.green
    
    @State private var totalHeight = CGFloat(100)
    
    @State var scope: Int = 0
    
    var body: some View {
        VStack {
            Rectangle()
                .frame(width: 300, height: 300, alignment: .center)
                .foregroundColor(mainColor)
                .padding(.top, 20.0)
            
            Spacer()
            
            Text("\(scope)")
                .font(.title)
                .fontWeight(.bold)
            
            Spacer()
            
            VStack {
                GeometryReader { g in
                    HStack {
                        Spacer()
                        
                        Text("1")
                            .frame(width: g.size.width / 4, height: g.size.width / 4)
                            .background(Rectangle()
                                            .foregroundColor(oneButtonColor))
                        
                        Text("2")
                            .frame(width: g.size.width / 4, height: g.size.width / 4)
                            .background(Rectangle()
                                            .foregroundColor(twoButtonColor))
                            .padding(.horizontal)
                        
                        Text("3")
                            .frame(width: g.size.width / 4, height: g.size.width / 4)
                            .background(Rectangle()
                                            .foregroundColor(threeButtonColor))
                        
                        Spacer()
                    }
                    .frame(width: g.size.width, height: g.size.width / 4, alignment: .center)
                    .background(GeometryReader {gp -> Color in
                                        DispatchQueue.main.async {
                                            self.totalHeight = gp.size.height
                                        }
                                        return Color.clear
                                    })
                }
                
            }
            .frame(height: totalHeight)
            .padding(.bottom, 20.0)
        }
    }
    
    func generateRandomColor() -> UIColor {
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
}
