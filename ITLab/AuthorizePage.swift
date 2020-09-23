//
//  AuthorizePage.swift
//  ITLab
//
//  Created by Михаил Иванов on 21.09.2020.
//

import SwiftUI

struct AuthorizeView: View {
    
    @State var email = ""
    @State var password = ""
    @State var saveEmail = false
    
    var body: some View {
        VStack (spacing: 15){
            VStack {
                Image("Logo")
                    .resizable()
                    .frame(width: 260, height: 230, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                Text("RTU IT Lab")
                    .font(/*@START_MENU_TOKEN@*/.largeTitle/*@END_MENU_TOKEN@*/)
                    .bold()
            }
            
            VStack{
                HStack{
                    Image(systemName: "mail")
                    TextField("Электронная почта", text: $email)
                        .keyboardType(/*@START_MENU_TOKEN@*/.emailAddress/*@END_MENU_TOKEN@*/)
                        .textContentType(/*@START_MENU_TOKEN@*/.emailAddress/*@END_MENU_TOKEN@*/)
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    
                }
                
                Divider().padding(1)
                
                HStack{
                    Spacer(minLength: 27)
                    SecureField("Пароль", text: $password)
                        .textContentType(/*@START_MENU_TOKEN@*/.password/*@END_MENU_TOKEN@*/)
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                }
                
                Toggle("Запомнить пароль", isOn: $saveEmail)
                    .padding(.vertical)
//                    .padding(.horizontal, 20)
            }
            .padding()
            .padding(.horizontal, 30)
            .padding(.vertical, 20)
            
            Button(action: {
                print(email + " " + password + " \(saveEmail)")
            }) {
                Text("Войти")
                    .font(.title2)
            }
        }
    }
    
    func test() -> Void {
        print("Hello")
    }
}

struct AuthorizeView_Previews_XIProMax: PreviewProvider {
    static var previews: some View {
        AuthorizeView()
            .previewDisplayName("Dark")
            .preferredColorScheme(.dark)
            .previewDevice(/*@START_MENU_TOKEN@*/"iPhone 11 Pro Max"/*@END_MENU_TOKEN@*/)
        
        AuthorizeView()
            .previewDisplayName("Light")
            .preferredColorScheme(.light)
            .previewDevice(/*@START_MENU_TOKEN@*/"iPhone 11 Pro Max"/*@END_MENU_TOKEN@*/)
            
    }
}

struct AuthorizeView_Previews_VIIPlus: PreviewProvider {
    static var previews: some View {
        AuthorizeView()
            .previewDisplayName("Dark")
            .preferredColorScheme(.dark)
            .previewDevice(/*@START_MENU_TOKEN@*/"iPhone 8 Plus"/*@END_MENU_TOKEN@*/)
        
        AuthorizeView()
            .previewDisplayName("Light")
            .preferredColorScheme(.light)
            .previewDevice(/*@START_MENU_TOKEN@*/"iPhone 8 Plus"/*@END_MENU_TOKEN@*/)
            
    }
}
