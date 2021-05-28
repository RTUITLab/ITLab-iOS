//
//  Calendar.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 28.05.2021.
//

import EventKit
import SwiftUI

final class ITLabCalendar: NSObject {
    
    static public func requestAccess() {
        let eventStore = EKEventStore()
        
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            print("authorize")
        case .denied:
            print("denied")
        case .notDetermined:
            print("notDetermined")
            eventStore.requestAccess(to: .event) { granted, _ in
                if granted {
                    print("granted")
                } else {
                    print("false")
                }
            }
        default:
            print("default")
        }
    }
}
