//
//  UserPage.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 10/28/20.
//

import SwiftUI
import Contacts

struct UserPage: View {
    @State var user: UserView
    
    @State var contactAlert: Bool = false
    @State var isEnableButton: Bool = false
    
    var body: some View {
        List {
            Section(header: VStack(alignment: .leading) {
                if let lastName = user.lastName {
                    Text(lastName)
                        .foregroundColor(Color("user.title"))
                        .fontWeight(.bold)
                        .font(.title)
                        .textCase(.none)
                }
                
                if let firstName = user.firstName {
                    Text(firstName)
                        .foregroundColor(Color("user.title"))
                        .fontWeight(.bold)
                        .font(.title)
                        .textCase(.none)
                }
                
                if let middleName = user.middleName, !middleName.isEmpty {
                    Text(middleName)
                        .foregroundColor(Color("user.title"))
                        .fontWeight(.bold)
                        .font(.title)
                        .textCase(.none)
                }
            }) {
                if let email = user.email {
                    HStack(alignment: .center) {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.gray)
                            .opacity(0.5)
                        
                        Button(action: {
                            UIApplication.shared.open(URL(string: "mailto://compose?to=\(email)")!)
                        }, label: {
                            Text(email)
                        })
                        .contextMenu {
                            Button(action: {
                                UIApplication.shared.open(URL(string: "mailto://compose?to=\(email)")!)
                            }, label: {
                                Text("Отправить письмо")
                                Image(systemName: "square.and.pencil")
                            })
                            
                            Button(action: {
                                UIPasteboard.general.string = email
                            }, label: {
                                Text("Копировать")
                                Image(systemName: "doc.on.doc")
                            })
                        }
                    }
                }
                
                if let phone = user.phoneNumber {
                    HStack(alignment: .center) {
                        Image(systemName: "phone.circle.fill")
                            .foregroundColor(.gray)
                            .opacity(0.5)
                        
                        Button(action: {
                            if let regex = try? NSRegularExpression(pattern: "[^0-9]") {
                                let phoneRex = regex.stringByReplacingMatches(in: phone,
                                                                              options: [],
                                                                              range: NSRange(0..<phone.utf8.count),
                                                                              withTemplate: "")
                                
                                UIApplication.shared.open(URL(string: "tel://\(phoneRex)")!)
                            }
                        }, label: {
                            Text(phone)
                        })
                        
                        .contextMenu {
                            Button(action: {
                                
                                if let regex = try? NSRegularExpression(pattern: "[^0-9]") {
                                    let phoneRex = regex.stringByReplacingMatches(in: phone,
                                                                                  options: [],
                                                                                  range: NSRange(0..<phone.utf8.count),
                                                                                  withTemplate: "")
                                    
                                    UIApplication.shared.open(URL(string: "tel://\(phoneRex)")!)
                                }
                            }, label: {
                                Text("Набрать номер")
                                Image(systemName: "phone")
                            })
                            
                            Button(action: {
                                UIPasteboard.general.string = phone
                            }, label: {
                                Text("Копировать")
                                Image(systemName: "doc.on.doc")
                            })
                        }
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
            
            if Contact.isAccessContacts {
                Section {
                    Button(action: {
                        contactAlert = true
                    }, label: {
                        Text("Добавить в контакты")
                    })
                    .alert(isPresented: $contactAlert) {
                        Alert(title: Text("Вы точно хотите добавить контакт?"),
                              primaryButton: .cancel(Text("Нет")),
                              secondaryButton: .default(Text("Да")) {
                                let store = CNContactStore()
                                let contact = CNMutableContact()
                                
                                contact.givenName = user.firstName ?? ""
                                contact.familyName = user.lastName ?? ""
                                
                                if let email = user.email {
                                    contact.emailAddresses.append(CNLabeledValue(label: "email",
                                                                                 value: NSString(string: email)))
                                }
                                
                                if let phone = user.phoneNumber {
                                    contact.phoneNumbers.append(CNLabeledValue(label: "мобильный",
                                                                               value: CNPhoneNumber(stringValue: phone)))
                                }
                                
                                let saveRequest = CNSaveRequest()
                                saveRequest.add(contact, toContainerWithIdentifier: nil)
                                try? store.execute(saveRequest)
                                isEnableButton = true
                              })
                    }
                    .disabled(self.isEnableButton)
                    
                }
                
            }
            EquipmentStack(user: $user)
            EventStack(user: $user)
            
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension UserPage {
    
    struct EventStack: View {
        @Binding var user: UserView
        @State private var isLoading: Bool = true
        @State private var events: [UsersEventsView] = []
        
        @State private var fromDateEvent = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        @State private var beforeDateEvent = Date()
        
        var body: some View {
            Section(header: Text("Участие в событии\(events.count > 0 ? " — \(events.count)" : "")")) {
                VStack {
                    DatePicker("От", selection: $fromDateEvent, displayedComponents: .date)
                        .environment(\.locale, Locale.init(identifier: "ru"))
                        .onChange(of: fromDateEvent) { (_) in
                            isLoading = true
                            getEvents()
                        }
                        .frame(minWidth: 280)
                    
                    Spacer()
                    
                    DatePicker("До", selection: $beforeDateEvent, displayedComponents: .date)
                        .environment(\.locale, Locale.init(identifier: "ru"))
                        .onChange(of: beforeDateEvent) { (_) in
                            isLoading = true
                            getEvents()
                        }
                }
                if isLoading {
                    GeometryReader { geometry in
                        ProgressView()
                            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                    }
                } else {
                    if events.count > 0 {
                        ForEach(0 ..< events.count, id: \.self) { number in
                            NavigationLink(destination:
                                            EventPage(compactEvent: CompactEventView(id: events[number]._id,
                                                                                     title: events[number].title,
                                                                                     eventType: events[number].eventType,
                                                                                     beginTime: nil,
                                                                                     endTime: nil,
                                                                                     address: events[number].address,
                                                                                     shiftsCount: nil,
                                                                                     currentParticipantsCount: nil,
                                                                                     targetParticipantsCount: nil,
                                                                                     participating: true))) {
                                VStack(alignment: .leading) {
                                    Text(events[number].title!)
                                        .bold()
                                        .padding(.vertical, 1)
                                    
                                    HStack(alignment: .center) {
                                        Image(systemName: "person.fill")
                                            .font(.callout)
                                            .opacity(0.6)
                                        Text(events[number].role!.title!)
                                            .opacity(0.6)
                                    }
                                    
                                    HStack(alignment: .center) {
                                        Image(systemName: "clock")
                                            .font(.callout)
                                            .opacity(0.6)
                                        Text(dateFormate(events[number].beginTime!))
                                            .opacity(0.6)
                                    }
                                    .padding(.bottom, 1)
                                    
                                }
                            }
                        }
                    } else {
                        Text("Нет событий за данный период")
                    }
                }
            }
            .onAppear {
                if events.isEmpty {
                    getEvents()
                }
            }
        }
        
        func getEvents() {
            OAuthITLab.shared.getToken {
                EventAPI.apiEventUserUserIdGet(userId: user._id!,
                                               begin: fromDateEvent,
                                               end: beforeDateEvent) { (events, error) in
                    
                    if let error = error {
                        print(error)
                        self.isLoading = false
                        return
                    }
                    
                    self.events = events ?? []
                    self.isLoading = false
                }
            }
        }
    }
    
    struct EquipmentStack: View {
        @Binding var user: UserView
        @State private var isLoading: Bool = true
        @State private var equipments: [EquipmentView] = []
        
        var body: some View {
            Section(header: Text("Техника на руках\(equipments.count > 0 ? " — \(equipments.count)" : "")")) {
                if isLoading {
                    GeometryReader { geometry in
                        ProgressView()
                            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                    }
                } else {
                    if equipments.count > 0 {
                        ForEach(equipments, id: \._id) { equipment in
                            VStack(alignment: .leading) {
                                Text(equipment.equipmentType!.title!)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .padding(.bottom, 2)
                                
                                HStack(alignment: .center) {
                                    Text("S/N:")
                                    Text(equipment.serialNumber!)
                                }
                            } .padding(5)
                        }
                    } else {
                        Text("Оборудования на руках нет")
                    }
                }
            }
            .onAppear {
                if equipments.isEmpty {
                    getEquimpment()
                }
            }
        }
        
        func getEquimpment() {
            OAuthITLab.shared.getToken {
                
                EquipmentUserAPI.apiEquipmentUserUserIdGet(userId: user._id!) { (equipments, error) in
                    
                    if let error = error {
                        print(error)
                        self.isLoading = false
                        return
                    }
                    
                    self.equipments = equipments ?? []
                    self.isLoading = false
                }
                
            }
        }
    }
}
