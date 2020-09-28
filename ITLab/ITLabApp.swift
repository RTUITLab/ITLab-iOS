//
//  ITLabApp.swift
//  ITLab
//
//  Created by Михаил Иванов on 21.09.2020.
//

import SwiftUI
import UIKit
//import AppAuth

@main
struct ITLabApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) static public var delegate
    
    var body: some Scene {
        WindowGroup {
            AuthorizeControllerUI()
        }
       
    }
}

struct AuthorizeControllerUI : UIViewControllerRepresentable {
    
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<AuthorizeControllerUI>) -> some UIViewController {
        let storyboard = UIStoryboard(name: "AuthorizeBoard", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(identifier: "Auth")
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<AuthorizeControllerUI>) {
        //
    }
}
