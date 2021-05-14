//
//  ProfilePage.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 18.01.2021.
//

import SwiftUI
import PushNotification

struct ProfilePage: View {
    
    @Binding var user: UserView
    
    @State private var showLogOutAlert: Bool = false
    
    @State private var isSheet: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack(alignment: .center) {
                        Text("Ф")
                            .foregroundColor(.gray)
                            .bold()
                            .padding(.horizontal, 3.0)
                            .opacity(0.5)
                        
                        Text(user.lastName ?? "Фамилия")
                        
                    }
                    .onTapGesture(count: 6) {
                        self.isSheet = true
                    }
                    .sheet(isPresented: $isSheet) {
                        СolorPaletteView()
                    }
                    
                    HStack(alignment: .center) {
                        Text("И")
                            .foregroundColor(.gray)
                            .bold()
                            .padding(.horizontal, 3.0)
                            .opacity(0.5)
                        
                        Text(user.firstName ?? "Имя")
                    }
                    
                    if let middleName = user.middleName, !middleName.isEmpty {
                        HStack(alignment: .center) {
                            Text("О")
                                .foregroundColor(.gray)
                                .bold()
                                .padding(.horizontal, 3.0)
                                .opacity(0.5)
                            
                            Text(middleName)
                        }
                    }
                    
                    if let email = user.email {
                        HStack(alignment: .center) {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.gray)
                                .opacity(0.5)
                            
                            Text(email)
                        }
                    }
                    if let phone = user.phoneNumber {
                        HStack(alignment: .center) {
                            Image(systemName: "phone.circle.fill")
                                .foregroundColor(.gray)
                                .opacity(0.5)
                            
                            Text(phone)
                        }
                    }
                    
                    if let vkId = user.properties?.first(where: { (property) -> Bool in
                        return property.userPropertyType?.title == "VKID"
                    })?.value {
                        HStack(alignment: .center) {
                            Image("vk.logo.fill")
                                .foregroundColor(.gray)
                                .opacity(0.5)
                            
                            Button(action: {
                                UIApplication.shared.open(URL(string: "vk://vk.com/id\(vkId)")!)
                            }, label: {
                                Text("@\(vkId)")
                            })
                            .contextMenu {
                                Button(action: {
                                    UIApplication.shared.open(URL(string: "vk://vk.com/id\(vkId)")!)
                                }, label: {
                                    Text("Открыть VK")
                                    Image("vk.logo.fill")
                                })
                                
                                Button(action: {
                                    UIPasteboard.general.string = vkId
                                }, label: {
                                    Text("Копировать")
                                    Image(systemName: "doc.on.doc")
                                })
                            }
                        }
                    }
                    
                    if let group = user.properties?.first(where: { (property) -> Bool in
                        return property.userPropertyType?.title == "Учебная группа"
                    })?.value {
                        HStack(alignment: .center) {
                            Image(systemName: "graduationcap.fill")
                                .foregroundColor(.gray)
                                .opacity(0.5)
                            Text(group)
                        }
                    }
                }
                
                UserPage.EquipmentStack(user: $user)
                UserPage.EventStack(user: $user)
                
                GeometryReader { geometry in
                    Button(action: {
                        self.showLogOutAlert.toggle()
                    }, label: {
                        Text("Выход")
                            .foregroundColor(.red)
                    })
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                }
                .alert(isPresented: $showLogOutAlert, content: {
                    
                    Alert(title: Text("Выход из аккаунта"),
                          message: Text("Вы точно хотите выйти?"),
                          primaryButton: .cancel(Text("Нет")),
                          secondaryButton: .default(Text("Да"),
                                                    action: {
                                                        
                                                        PushNotification.removeDevice()
                                                        OAuthITLab.shared.logOut()
                                                    }))
                })
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Профиль", displayMode: .automatic)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
