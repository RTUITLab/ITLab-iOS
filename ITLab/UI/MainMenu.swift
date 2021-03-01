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
    @State var user: UserView = UserView(_id: UUID(), firstName: nil, lastName: nil, middleName: nil, phoneNumber: nil, email: nil, properties: nil)
    
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

            if let profile = AppAuthInteraction.shared.getUserInfo()?.profile {
                user = profile
            }
            
            OAuthITLab.shared.getToken{ error in
                
                eventPage.isEditingRight = AppAuthInteraction.shared.getUserInfo()?.getRole("CanEditEvent") ?? false

                if let profile = AppAuthInteraction.shared.getUserInfo()?.profile {
                    user = profile
                }
            }

            Contact.requestAccess()
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
                            .fontWeight(.bold)
                            .frame(width: g.size.width / 4, height: g.size.width / 4)
                            .background(Rectangle()
                                            .foregroundColor(oneButtonColor))
                            .onTapGesture {
                                changeScope(oneButtonColor)
                            }
                        
                        Text("2")
                            .fontWeight(.bold)
                            .frame(width: g.size.width / 4, height: g.size.width / 4)
                            .background(Rectangle()
                                            .foregroundColor(twoButtonColor))
                            .padding(.horizontal)
                            .onTapGesture {
                                changeScope(twoButtonColor)
                            }
                        
                        Text("3")
                            .fontWeight(.bold)
                            .frame(width: g.size.width / 4, height: g.size.width / 4)
                            .background(Rectangle()
                                            .foregroundColor(threeButtonColor))
                            .onTapGesture {
                                changeScope(threeButtonColor)
                            }
                        
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
        .onAppear() {
            changeColor()
        }
    }
    
    func generateColor() -> UIColor {
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
    
    func changeColor() {
         mainColor = Color(generateColor())
         let randomButton = arc4random_uniform(3)
        switch randomButton {
         case 0:
             oneButtonColor = mainColor
             twoButtonColor = Color(generateColor())
             threeButtonColor = Color(generateColor())
         case 1:
            oneButtonColor = Color(generateColor())
            twoButtonColor = mainColor
            threeButtonColor = Color(generateColor())
         case 2:
            oneButtonColor = Color(generateColor())
            twoButtonColor = Color(generateColor())
            threeButtonColor = mainColor
         default:
            oneButtonColor = mainColor
            twoButtonColor = Color(generateColor())
            threeButtonColor = Color(generateColor())
         }
    }
    
    func changeScope (_ color: Color) {
        if mainColor == color {
            scope += 1
        } else {
            scope -= 1
        }
        
        changeColor()
    }
}
