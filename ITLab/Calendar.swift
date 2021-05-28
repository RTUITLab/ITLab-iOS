//
//  Calendar.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 28.05.2021.
//

import EventKit
import SwiftUI

final class ITLabCalendar {
    
    let eventStore = EKEventStore()
    
    private var calendarIdentifier: String?
    
    static public let shared = ITLabCalendar()
    
    private let nameKey = "calendar"
    
    struct EventInfo {
        var title: String
        var startDates: Date
        var endDates: Date
        var location: String
        var note: String?
    }
    
    var events: [EventInfo] = []
    
    static public func requestAccess() {
        
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            ITLabCalendar.shared.loadCalendarIdentifier()
        case .notDetermined:
            
            ITLabCalendar.shared.eventStore.requestAccess(to: .event) { granted, _ in
                if granted {
                    ITLabCalendar.shared.createCalendar()
                }
            }
        default:
            break
        }
    }
    
    func getEvent(retry: Bool = true) {
        let calendars = eventStore.calendars(for: .event)
        
        if let calendar = calendars.first(where: { element in
            return element.title == "ITLab"
        }) {
            print(calendar.calendarIdentifier)
            let oneMonthAgo = Date(timeIntervalSinceNow: -30*24*3600)
            let oneMonthAfter = Date(timeIntervalSinceNow: +30*24*3600)
            
            let predicate = eventStore.predicateForEvents(withStart: oneMonthAgo,
                                                          end: oneMonthAfter,
                                                          calendars: [calendar])
            let events = eventStore.events(matching: predicate)
            
            for event in events {
                let eve = EventInfo.init(title: event.title,
                                         startDates: event.startDate,
                                         endDates: event.endDate,
                                         location: event.location ?? "")
                self.events.append(eve)
            }
            
            print(self.events)
        } else if retry {
            getEvent(retry: false)
        } else {
            print("Can't create calendar")
        }
    }
    
    func createEvent(event info: EventInfo) -> Bool {
        let event = EKEvent(eventStore: self.eventStore)
        
        event.title = info.title
        event.location = info.location
        event.startDate = info.startDates
        event.endDate = info.endDates
        
        event.notes = info.note
        event.calendar = eventStore.calendar(withIdentifier: self.calendarIdentifier!)
        
        do {
            try self.eventStore.save(event, span: .thisEvent)
            print("Saved event: \(String(describing: event.eventIdentifier))")
            
            return true
        } catch let error as NSError {
            print("failed to save event with error : \(error)")
            return false
        }
    }
    
    private func createCalendar() {
        
        if self.calendarIdentifier != nil {
            return
        }
        
        let calendars = eventStore.calendars(for: .event)
        if let calendar = calendars.first(where: {$0.title == "ITLab"}) {
            self.calendarIdentifier = calendar.calendarIdentifier
            saveCalendarIdentifier()
            return
        }
        
        let calendar: EKCalendar = .init(for: .event,
                                         eventStore: self.eventStore)
        calendar.title = "ITLab"
        if let local = self.eventStore.sources.first(where: { $0.sourceType == .local }) {
            calendar.source = local
            
            do {
                try self.eventStore.saveCalendar(calendar, commit: true)
                
                self.calendarIdentifier = calendar.calendarIdentifier
                saveCalendarIdentifier()
            } catch {
                print("Not create calendar")
            }
        }
    }
    
    private func saveCalendarIdentifier() {
        var data: Data?
        
        if let identifier = self.calendarIdentifier {
            do {
                data = try NSKeyedArchiver.archivedData(withRootObject: identifier,
                                                        requiringSecureCoding: true)
            } catch {
                print("Not calendar identifier")
            }
            
            if let userDefaults = UserDefaults(suiteName: "group.ru.RTUITLab.ITLab") {
                userDefaults.set(data, forKey: nameKey)
                userDefaults.synchronize()
            }
        }
    }
    
    private func loadCalendarIdentifier() {
        guard let data = UserDefaults(suiteName: "group.ru.RTUITLab.ITLab")?
                .object(forKey: nameKey) as? Data
        else {
            return
        }
        
        do {
            if let identifier = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? String {
                self.calendarIdentifier = identifier
            }
        } catch {
            print("Not load calendar identifier")
        }
    }
}
