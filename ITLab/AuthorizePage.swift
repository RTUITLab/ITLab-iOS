//
//  AuthorizePage.swift
//  ITLab
//
//  Created by Михаил Иванов on 21.09.2020.
//

import SwiftUI


struct AuthorizeView: View {
    
    init()
    {
        print("Hello AuthorizeView")
        
        let test : UIViewController = UIHostingController(rootView: self)
        
    }
    
    var body: some View {
        VStack (spacing: 30){
            Spacer()
            VStack {
                Image("Logo")
                    .resizable()
                    .frame(width: 260, height: 230, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                Text("RTU IT Lab")
                    .font(/*@START_MENU_TOKEN@*/.largeTitle/*@END_MENU_TOKEN@*/)
                    .bold()
            }
            
            Spacer()
            
            Button(action: {
                //
            }) {
                Text("Войти")
                    .font(.title)
            }
            
            Spacer()
        }
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
