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
