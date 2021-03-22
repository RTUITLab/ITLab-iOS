//
//  ITLabApp.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 11/2/20.
//

import SwiftUI

@main
struct ITLabApp: App {
    
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    init() {
        //TODO: deleted
        UserDefaults(suiteName: "group.ru.RTUITLab.ITLab")?.removeObject(forKey: "authState")
    }
    
    var body: some Scene {
        WindowGroup{
            AuthorizationPage()
                .alertError()
                
        }
    }
}

fileprivate struct ITLabAlert: ViewModifier {
    @ObservedObject private var config = ITLabAlertConfig.shared
    func body(content: Content) -> some View {
        content
            .alert(isPresented: $config.showAlert, content: {
                Alert(title: Text(config.title), message: Text(config.msg), dismissButton: .default(Text("Окей")))
            })
    }
}

fileprivate extension View {
    func alertError() -> some View {
        self.modifier(ITLabAlert())
    }
}
