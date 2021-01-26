//
//  ProfilePage.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 18.01.2021.
//

import SwiftUI

struct ProfilePage: View {
    
    @Binding var user: UserView?
    
    @State var equipments: [EquipmentView] = []
    @State var isLoadingEquipments: Bool = true
    
    @State var events: [UsersEventsView] = []
    @State private var fromDateEvent = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    @State private var beforeDateEvent = Date()
    @State var isLoadingEvents: Bool = true
    @State var isSheet: Bool = false
    
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
                        
                        Text(user?.lastName ?? "Фамилия")
                            
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
                        
                        Text(user?.firstName ?? "Имя")
                    }
                    
                    if let middleName = user?.middleName {
                        HStack(alignment: .center) {
                            Text("О")
                                .foregroundColor(.gray)
                                .bold()
                                .padding(.horizontal, 3.0)
                                .opacity(0.5)
                            
                            Text(middleName)
                        }
                    }
                    
                    if let email = user?.email {
                        HStack(alignment: .center) {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.gray)
                                .opacity(0.5)
                            
                            Text(email)
                        }
                    }
                    if let phone = user?.phoneNumber {
                        HStack(alignment: .center) {
                            Image(systemName: "phone.circle.fill")
                                .foregroundColor(.gray)
                                .opacity(0.5)
                            
                            Text(phone)
                        }
                    }
                    
                    if let vkId = user?.properties?.first(where: { (property) -> Bool in
                        return property.userPropertyType?.title == "VKID"
                    })?.value {
                        HStack(alignment: .center) {
                            Image("vk.logo.fill")
                                .foregroundColor(.gray)
                                .opacity(0.5)
                            
                            Button(action: {
                                UIApplication.shared.open(URL(string: "vk://vk.com/id\(vkId)")!)
                            }) {
                                Text("@\(vkId)")
                            }
                            .contextMenu() {
                                Button(action: {
                                    UIApplication.shared.open(URL(string: "vk://vk.com/id\(vkId)")!)
                                }) {
                                    Text("Открыть VK")
                                    Image("vk.logo.fill")
                                }
                                
                                Button(action: {
                                    UIPasteboard.general.string = vkId
                                }) {
                                    Text("Копировать")
                                    Image(systemName: "doc.on.doc")
                                }
                            }
                        }
                    }
                    
                    if let group = user?.properties?.first(where: { (property) -> Bool in
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
                
                Section(header: Text("Техника на руках")) {
                    if isLoadingEquipments {
                        GeometryReader() { g in
                            ProgressView()
                                .frame(width: g.size.width, height: g.size.height, alignment: .center)
                        }
                    } else {
                        if equipments.count > 0 {
                            ForEach(equipments, id: \._id) { equipment in
                                UserPage.EquipmentStack(equipment: equipment)
                            }
                        } else {
                            Text("Оборудование на руках нет")
                        }
                    }
                }
                
                
                Section(header: Text("Участие в событии")) {
                    VStack {
                        DatePicker("От", selection: $fromDateEvent, displayedComponents: .date)
                            .environment(\.locale, Locale.init(identifier: "ru"))
                            .onChange(of: fromDateEvent) { (_) in
                                isLoadingEvents = true
                                getEvents()
                            }
                        
                        Spacer()
                        
                        DatePicker("До", selection: $beforeDateEvent, displayedComponents: .date)
                            .environment(\.locale, Locale.init(identifier: "ru"))
                            .onChange(of: beforeDateEvent) { (_) in
                                isLoadingEvents = true
                                getEvents()
                            }
                    }
                    if isLoadingEvents {
                        GeometryReader() { g in
                            ProgressView()
                                .frame(width: g.size.width, height: g.size.height, alignment: .center)
                        }
                    } else {
                        if events.count > 0 {
                            ForEach(events, id: \._id) { event in
                                Text(event.title!)
                            }
                        } else {
                            Text("Нет событий за данный период")
                        }
                    }
                }
                
                GeometryReader() { g in
                    Button(action: {
                        AppAuthInteraction.shared.logOut()
                    }) {
                        Text("Выход")
                            .foregroundColor(.red)
                    }
                    .frame(width: g.size.width, height: g.size.height, alignment: .center)
                }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("Профиль")
            .onAppear() {
                getEquimpment()
                getEvents()
            }
        }
        
    }
    
    func getEquimpment() {
        AppAuthInteraction.shared.performAction { (token, _) in
            
            EquipmentUserAPI.apiEquipmentUserUserIdGet(userId: user!._id!) { (equipments, error) in
                
                if let error = error {
                    print(error)
                    self.isLoadingEquipments = false
                    return
                }
                
                self.equipments = equipments ?? []
                self.isLoadingEquipments = false
            }
            
        }
    }
    
    func getEvents() {
        AppAuthInteraction.shared.performAction { (_, _) in
            EventAPI.apiEventUserUserIdGet(userId: user!._id!, begin: fromDateEvent, end: beforeDateEvent) { (events, error) in
                if let error = error {
                    print(error)
                    self.isLoadingEvents = false
                    return
                }
                self.events = events ?? []
                self.isLoadingEvents = false
            }
        }
    }
}
