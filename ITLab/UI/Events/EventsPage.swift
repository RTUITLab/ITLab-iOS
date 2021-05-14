//
//  EventsPage.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 06.10.2020.
//

import SwiftUI

class EventRole: ObservableObject {
    static var data: [EventRoleView] = []
}

struct EventsPage: View {
    
    @ObservedObject private var eventsObject = EventsObservable()
    
    var isEditingRight: Bool {
        get {
            self.eventsObject.isEditingRight
        }
        nonmutating set {
            self.eventsObject.isEditingRight = newValue
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                if eventsObject.isLoadingEvents {
                    GeometryReader { geometry in
                        ProgressView()
                            .frame(width: geometry.size.width,
                                   height: geometry.size.height,
                                   alignment: .center)
                    }
                } else {
                    Section(header: Text("От: \(eventsObject.fromDate)")) {
                        if eventsObject.events.count == 0 {
                            GeometryReader { geometry in
                                Text("На данный момент событий нет!")
                                    .frame(width: geometry.size.width,
                                           height: geometry.size.height,
                                           alignment: .center)
                            }
                        } else {
                            ForEach(eventsObject.events, id: \.id) { event in
                                EventStack(event: event)
                                    .padding(.vertical, 10)
                            }
                        }
                    }
                    Section {
                        GeometryReader { geometry in
                            Button(action: {
                                eventsObject.showOldEvent.toggle()
                                
                                if eventsObject.showOldEvent {
                                    eventsObject.getOldEvents()
                                }
                            }, label: {
                                Text(eventsObject.showOldEvent ? "Скрыть более поздние события"
                                        :"Показать более поздние события")
                            })
                            .frame(width: geometry.size.width,
                                   height: geometry.size.height,
                                   alignment: .center)
                        }
                        if eventsObject.showOldEvent {
                            if eventsObject.isLoadingOldEvents {
                                GeometryReader { geometry in
                                    ProgressView()
                                        .frame(width: geometry.size.width,
                                               height: geometry.size.height,
                                               alignment: .center)
                                }
                            } else {
                                if eventsObject.oldEvents.count == 0 {
                                    GeometryReader { geometry in
                                        Text("На данный момент устаревших событий нет!")
                                            .frame(width: geometry.size.width,
                                                   height: geometry.size.height,
                                                   alignment: .center)
                                    }
                                } else {
                                    ForEach(eventsObject.oldEvents, id: \.id) { event in
                                        EventStack(event: event)
                                            .padding(.vertical, 10)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("События", displayMode: .automatic)
            .navigationBarItems(leading: Button(action: {
                eventsObject.isLoadingEvents = true
                eventsObject.getEvents()
                
                if eventsObject.showOldEvent {
                    eventsObject.oldEvents = []
                    
                    eventsObject.getOldEvents()
                }
            }, label: {
                Image(systemName: "arrow.clockwise").padding([.top, .bottom, .trailing], 15)
            }), trailing:
                VStack {
                    if eventsObject.isEditingRight {
                        Button(action: {
                            eventsObject.addedAlert = true
                        }, label: {
                            Image(systemName: "plus")
                                .padding([.top, .leading, .bottom], 15)
                        })
                        .alert(isPresented: $eventsObject.addedAlert) { Alert(title: Text("Пока не готово =(")) }
                    }
                })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

func dateFormate(_ date: Date) -> String {
    let dateFormmat = DateFormatter()
    
    dateFormmat.dateFormat = "dd.MM.yy HH:mm"
    return dateFormmat.string(from: date)
}
