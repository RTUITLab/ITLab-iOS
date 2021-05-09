//
//  Contact.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 16.11.2020.
//

import Foundation
import Contacts

class Contact: NSObject {
    public static var isAccessContacts = false

    public static func requestAccess() {
        let store = CNContactStore()
                switch CNContactStore.authorizationStatus(for: .contacts) {
                case .authorized:
                    Contact.isAccessContacts = true
                case .denied:
                    print("Нужно дать разрешение на добавление контакта")
                case .restricted, .notDetermined:
                    store.requestAccess(for: .contacts) { granted, _ in
                        if granted {
                            Contact.isAccessContacts = true
                        }
                    }
                @unknown default:
                    print("error")
                }
    }
}
