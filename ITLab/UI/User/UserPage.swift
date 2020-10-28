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
    
    var body: some View {
        VStack (alignment: .leading) {
            Button (action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                HStack {
                    Image(systemName: "chevron.left")
                        .font(Font.title2.weight(.medium))
                    
                    Text("Пользователи")
                        .font(.title3)
                }
            }) .padding([.top, .leading], 12.0)
            VStack (alignment: .leading) {
                Text("\(user.lastName ?? "") \(user.firstName ?? "") \(user.middleName ?? "")")
                    .font(.title)
                    .fontWeight(.bold)
                
                Divider()
                
                if user.phoneNumber != nil {
                    HStack {
                        Text("Телефон: ")
                            .font(.headline)
                        Button(action: {
                            if var phone : String = user.phoneNumber {
                                let regex = try! NSRegularExpression(pattern: "[^0-9]")
                                phone = regex.stringByReplacingMatches(in: phone, options: [], range: NSRange(0..<phone.utf8.count), withTemplate: "")
                                
                                UIApplication.shared.open(URL(string: "tel://\(phone)")!)
                            }
                        }) {
                            Text(user.phoneNumber!)
                        }
                    }.padding(.bottom, 5)
                }
                
                if user.email != nil {
                    HStack {
                        Text("Email: ")
                            .font(.headline)
                        Button(action: {
                            if let email = user.email {
                                UIApplication.shared.open(URL(string: "mailto://compose?to=\(email)")!)
                            }
                        }) {
                            Text(user.email!)
                        }
                    }
                }
                Divider()
                
                Spacer()
            }
            .padding(.horizontal, 20.0)
            .padding(.top, 10)
        }        .frame(width: UIScreen.main.bounds.width, alignment: .leading)
        .navigationBarHidden(true)
    }
}

struct UserPage_Previews: PreviewProvider {
    static var previews: some View {
        UserPage(user: UserView(_id: nil, firstName: nil, lastName: nil, middleName: nil, phoneNumber: nil, email: nil, properties: nil))
    }
}
