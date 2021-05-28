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
    
    private let calendarKey = "calendar"
    private let eventsKey = "events"
    
    struct EventInfo {
        var title: String
        var startDates: Date
        var endDates: Date
        var location: String
        var note: String?
        
        var id: UUID
    }
    
    var events: [UUID: String] = [:]
    
    static public func requestAccess() {
        
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            ITLabCalendar.shared.loadCalendarIdentifier()
            ITLabCalendar.shared.loadEvent()
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
}

// MARK: - Create calendar and event
extension ITLabCalendar {
    func checkEvent(eventId id: UUID) -> Bool {
        if events.count != 0 {
            if let event = events.first(where: {$0.key == id}) {
                if self.eventStore.event(withIdentifier: event.value) != nil {
                    return false
                } else {
                    events.removeValue(forKey: event.key)
                    
                    saveEvent()
                    
                    return true
                }
            }
        }
        
        return true
    }
    
    func createEvent(event info: EventInfo) -> Result<Void, ITLabCalendarError> {
        
        createCalendar()
        
        if events.count != 0 {
            if let event = events.first(where: {$0.key == info.id}) {
                if self.eventStore.event(withIdentifier: event.value) != nil {
                    return .failure(.eventAlreadyBeenCreated)
                } else {
                    events.removeValue(forKey: event.key)
                    
                    saveEvent()
                }
            }
        }
        
        let event = EKEvent(eventStore: self.eventStore)
        
        event.title = info.title
        event.location = info.location
        event.startDate = info.startDates
        event.endDate = info.endDates
        
        event.notes = info.note
        event.calendar = eventStore.calendar(withIdentifier: self.calendarIdentifier!)
        
        do {
            try self.eventStore.save(event, span: .thisEvent)
            
            self.events.updateValue(event.eventIdentifier, forKey: info.id)
            saveEvent()
            
            print("Saved event: \(String(describing: event.eventIdentifier!))")
            
            return .success(())
        } catch let error as NSError {
            print("failed to save event with error : \(error)")
            return .failure(.failedCreate)
        }
    }
    
    private func createCalendar() {
        
        if let identifier = self.calendarIdentifier,
           eventStore.calendar(withIdentifier: identifier) != nil {
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
                self.calendarIdentifier = nil
            }
        }
    }
}

// MARK: - Save Data

extension ITLabCalendar {
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
                userDefaults.set(data, forKey: calendarKey)
                userDefaults.synchronize()
            }
        }
    }
    
    private func loadCalendarIdentifier() {
        guard let data = UserDefaults(suiteName: "group.ru.RTUITLab.ITLab")?
                .object(forKey: calendarKey) as? Data
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
    
    private func saveEvent() {
        var data: Data?
        
        if self.events.count != 0 {
            do {
                data = try NSKeyedArchiver.archivedData(withRootObject: self.events,
                                                        requiringSecureCoding: true)
            } catch {
                print("Not events list")
            }
            
            if let userDefaults = UserDefaults(suiteName: "group.ru.RTUITLab.ITLab") {
                userDefaults.set(data, forKey: eventsKey)
                userDefaults.synchronize()
            }
        }
    }
    
    private func loadEvent() {
        guard let data = UserDefaults(suiteName: "group.ru.RTUITLab.ITLab")?
                .object(forKey: eventsKey) as? Data
        else {
            return
        }
        
        do {
            if let events = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [UUID: String] {
                self.events = events
            }
        } catch {
            print("Not load events list")
        }
    }
}

enum ITLabCalendarError: Error {
    case eventAlreadyBeenCreated, failedCreate
}

extension ITLabCalendarError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .eventAlreadyBeenCreated:
            return NSLocalizedString("Событие уже было добавлена в Ваш календарь ранее",
                                     comment: "Event Already Been Created")
        case .failedCreate:
            return NSLocalizedString("Произошла непредвиденная ошибка. Событие не добавилось в календарь",
                                     comment: "Failed Create")
        }
    }
}
