//
//  ITLabAlert.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 03.03.2021.
//

import Foundation
import SwiftUI

typealias AlertError = ITLabAlertConfig

class ITLabAlertConfig: ObservableObject {
    
    public static let shared = ITLabAlertConfig()
    
    @Published public var showAlert: Bool = false
    @Published public var title: String = ""
    @Published public var msg: String = ""
    
    public func callAlert(title: String = "Ошибка", message msg: String)
    {
        self.title = title
        self.msg = msg
        
        showAlert.toggle()
    }
}

struct ITLabAlert: ViewModifier {
    @ObservedObject private var config = ITLabAlertConfig.shared
    func body(content: Content) -> some View {
        content
            .alert(isPresented: $config.showAlert, content: {
                Alert(title: Text(config.title), message: Text(config.msg), dismissButton: .default(Text("Окей")))
            })
    }
}

extension View {
    func alertError() -> some View {
        self.modifier(ITLabAlert())
    }
}
