//
//  EventsObservable.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 14.05.2021.
//

import SwiftUI
import Combine

final class EventsObservable: ObservableObject {
    @Published var events: [CompactEventView] = []
    @Published var oldEvents: [CompactEventView] = []
    @Published var isLoadingEvents: Bool = true
    @Published var isLoadingOldEvents: Bool = false
    @Published var showOldEvent: Bool = false
    
    @Published var isEditingRight: Bool = false
    
    @Published var addedAlert: Bool = false
    
    @Published var fromDate: String = ""
    
    func loading() {
        getEvents()
        
        if showOldEvent {
            getOldEvents()
        }
        
        isEditingRight = OAuthITLab.shared.getUserInfo()?.getRole("CanEditEvent") ?? false
    }
    
    func getEvents() {
        if self.events.isEmpty {
            self.isLoadingEvents = true
        }
        
        let date = Date()
        var dateComponents = DateComponents()
        
        dateComponents.year = Calendar.current.component(.year, from: date)
        dateComponents.month = Calendar.current.component(.month, from: date) - 1
        dateComponents.day = Calendar.current.component(.day, from: date)
        dateComponents.hour = Calendar.current.component(.hour, from: date)
        dateComponents.minute = Calendar.current.component(.minute, from: date)
        dateComponents.timeZone = Calendar.current.timeZone
        
        let newDate = Calendar.current.date(from: dateComponents)
        
        let dateFormmat = DateFormatter()
        dateFormmat.dateFormat = "dd MMMM yyyy"
        self.fromDate = dateFormmat.string(from: newDate!)
        
        EventAPI.apiEventGet(begin: newDate) { (events, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            self.events = events?.sorted {
                $0.beginTime! > $1.beginTime!
            } ?? []
            self.isLoadingEvents = false
            
        }
        
        EventRoleAPI.apiEventRoleGet { (eventsRole, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let eventsRole = eventsRole else {
                print("Not get events role")
                return
            }
            
            EventRole.data = eventsRole
        }
    }
    
    func getOldEvents() {
        self.isLoadingOldEvents = true
        
        let date = Date()
        var dateComponents = DateComponents()
        
        dateComponents.year = Calendar.current.component(.year, from: date)
        dateComponents.month = Calendar.current.component(.month, from: date) - 1
        dateComponents.day = Calendar.current.component(.day, from: date)
        dateComponents.hour = Calendar.current.component(.hour, from: date)
        dateComponents.minute = Calendar.current.component(.minute, from: date) - 1
        dateComponents.timeZone = Calendar.current.timeZone
        
        let newDate = Calendar.current.date(from: dateComponents)
        
        EventAPI.apiEventGet(end: newDate) { (events, error) in
            
            self.isLoadingOldEvents = false
            
            if let error = error {
                print(error)
                return
            }
            
            self.oldEvents = events?.sorted {
                $0.beginTime! > $1.beginTime!
            } ?? []
        }
    }
}
