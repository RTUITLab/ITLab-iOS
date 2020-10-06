//
//  ITLabApp.swift
//  ITLab
//
//  Created by Михаил Иванов on 21.09.2020.
//

import SwiftUI
import UIKit


@main
struct ITLabApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) static public var delegate
    
    static private let authorizeView = AuthorizeControllerUI()
    
    static public let authorizeController : AuthorizeController = authorizeView.controller as! AuthorizeController
    
    var body: some Scene {
        WindowGroup {
            ITLabApp.authorizeView
        }
    }
}

struct AuthorizeControllerUI : UIViewControllerRepresentable {
    
    public var controller: UIViewController
    
   init() {
    let storyboard = UIStoryboard(name: "AuthorizeBoard", bundle: Bundle.main)
    controller = storyboard.instantiateViewController(identifier: "Auth")
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<AuthorizeControllerUI>) -> some UIViewController {
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<AuthorizeControllerUI>) {
        //
    }
}
