//
//  UserPage.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 10/28/20.
//

import SwiftUI

struct UserPage: View {
    @State var user: UserView
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var equipments: [EquipmentView] = []
    @State var isLoadingEquipments: Bool = true
    
    var body: some View {
        VStack (alignment: .leading) {
            Button (action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                HStack {
                    Image(systemName: "chevron.left")
                        .font(Font.title2.weight(.medium))
                    
                    Text("Пользователи")
                        .font(.system(size: 17))
                }
            })
            .padding(.horizontal, 10)
            .padding(.top, 12.0)
            VStack (alignment: .leading) {
                Text("\(user.lastName ?? "") \(user.firstName ?? "") \(user.middleName ?? "")")
                    .font(.title)
                    .fontWeight(.bold)
                
                Divider()
                
                VStack(alignment: .leading) {
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 10) {
                            if user.email != nil {
                                Text("Email:")
                                    .font(.headline)
                            }
                            
                            if user.phoneNumber != nil {
                                Text("Телефон:")
                                    .font(.headline)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            if user.email != nil {
                                Text(user.email!)
                                    .foregroundColor(.blue)
                                    .contextMenu() {
                                        Button(action: {
                                            if let email = user.email {
                                                UIApplication.shared.open(URL(string: "mailto://compose?to=\(email)")!)
                                            }
                                        }) {
                                            Text("Отправить письмо")
                                            Image(systemName: "square.and.pencil")
                                        }
                                        
                                        Button(action: {
                                            UIPasteboard.general.string = user.email!
                                        }) {
                                            Text("Копировать")
                                            Image(systemName: "doc.on.doc")
                                        }
                                    }
                                    .onTapGesture {
                                        if let email = user.email {
                                            UIApplication.shared.open(URL(string: "mailto://compose?to=\(email)")!)
                                        }
                                        
                                    }
                            }
                            
                            if user.phoneNumber != nil {
                                Text(user.phoneNumber!)
                                    .foregroundColor(.blue)
                                    .contextMenu() {
                                        Button(action: {
                                            if var phone : String = user.phoneNumber {
                                                let regex = try! NSRegularExpression(pattern: "[^0-9]")
                                                phone = regex.stringByReplacingMatches(in: phone, options: [], range: NSRange(0..<phone.utf8.count), withTemplate: "")
                                                
                                                UIApplication.shared.open(URL(string: "tel://\(phone)")!)
                                            }
                                        }) {
                                            Text("Набрать номер")
                                            Image(systemName: "phone")
                                        }
                                        
                                        Button(action: {
                                            UIPasteboard.general.string = user.phoneNumber!
                                        }) {
                                            Text("Копировать")
                                            Image(systemName: "doc.on.doc")
                                        }
                                    }
                                    .onTapGesture {
                                        if var phone : String = user.phoneNumber {
                                            let regex = try! NSRegularExpression(pattern: "[^0-9]")
                                            phone = regex.stringByReplacingMatches(in: phone, options: [], range: NSRange(0..<phone.utf8.count), withTemplate: "")
                                            
                                            UIApplication.shared.open(URL(string: "tel://\(phone)")!)
                                        }
                                    }
                            }
                        }
                    }
                }
                
                Divider()
                
                ScrollView() {
                    VStack(alignment: .leading) {
                        VStack (alignment: .leading) {
                            Text("Оборудование")
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.bottom, 5)
                            
                            if isLoadingEquipments {
                                ProgressView()
                                    .padding(.vertical, 15)
                                    .padding(.horizontal, (UIScreen.main.bounds.width / 2) - 10)
                            } else {
                                
                                if equipments.count > 0 {
                                    VStack (alignment: .leading) {
                                        ForEach(equipments, id: \._id) {
                                            equipment in
                                            
                                            EquipmentStack(equipment: equipment)
                                        }
                                    }
                                } else {
                                    Text("Оборудование на руках нет")
                                }
                            }
                        }
                        
                        Divider().padding(.top, 10)
                        
                        VStack (alignment: .leading) {
                            Text("Участие в событиях")
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.bottom, 5)
                        }
                    }
                }
                //                Spacer()
            }
            .padding(.horizontal, 20.0)
            .padding(.top, 10)
        }
        .frame(width: UIScreen.main.bounds.width, alignment: .leading)
        .navigationBarHidden(true)
        .onAppear() {
            getEquimpment()
        }
    }
    
    func getEquimpment() {
        AuthorizeController.shared!.performAction { (token, _, _) in
            
            SwaggerClientAPI.customHeaders = ["Authorization" : "Bearer \(token ?? "")"]
            EquipmentUserAPI.apiEquipmentUserUserIdGet(userId: user._id!) { (equipments, error) in
                
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
}

extension UserPage {
    struct EquipmentStack : View {
        @State var equipment: EquipmentView
        var body: some View {
            VStack(alignment: .leading) {
                Text(equipment.equipmentType!.title!)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.bottom, 2)
                
                Text(equipment.serialNumber!)
            } .padding(5)
        }
    }
}

struct UserPage_Previews: PreviewProvider {
    static var previews: some View {
        UserPage(user: UserView(_id: nil, firstName: nil, lastName: nil, middleName: nil, phoneNumber: nil, email: nil, properties: nil))
    }
}
