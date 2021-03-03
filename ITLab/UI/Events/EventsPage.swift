//
//  EventsPage.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 06.10.2020.
//

import SwiftUI

class EventRole: ObservableObject {
    static var data : [EventRoleView] = []
}


struct EventsPage: View {

    @State private var events : [CompactEventView] = []
    @State private var oldEvents : [CompactEventView] = []
    @State private var isLoadingEvents: Bool = true
    @State private var showOldEvent: Bool = false

    @State var isEditingRight: Bool = OAuthITLab.shared.getUserInfo()?.getRole("CanEditEvent") ?? false

    @State private var addedAlert: Bool = false

    @State private var fromDate: String = ""

    var body: some View {
        NavigationView {
            List {
                if isLoadingEvents {
                    GeometryReader() { g in
                        ProgressView()
                                .frame(width: g.size.width, height: g.size.height, alignment: .center)
                    }
                } else {
                    Section(header: Text("От: \(fromDate)")) {
                        if events.count == 0 {
                            GeometryReader() { g in
                                Text("На данный момент событий нет!")
                                        .frame(width: g.size.width, height: g.size.height, alignment: .center)
                            }
                        } else {
                            ForEach(events, id: \.id) { event in
                                EventStack(event: event)
                                        .padding(.vertical, 10)
                            }
                        }
                    }
                    Section {
                        GeometryReader() { g in
                            Button(action: {
                                self.showOldEvent.toggle()

                                if showOldEvent {
                                    getOldEvents()
                                }
                            }) {
                                Text(showOldEvent ? "Скрыть более поздние события" :"Показать более поздние события")
                            }
                                    .frame(width: g.size.width, height: g.size.height, alignment: .center)
                        }
                        if showOldEvent {
                            if oldEvents.count <= 0 {
                                GeometryReader() { g in
                                    ProgressView()
                                            .frame(width: g.size.width, height: g.size.height, alignment: .center)
                                }
                            } else {
                                ForEach(oldEvents, id: \.id) { event in
                                    EventStack(event: event)
                                            .padding(.vertical, 10)
                                }
                            }
                        }
                    }
                }
            }
                    .listStyle(GroupedListStyle())
                    .navigationBarTitle("События", displayMode: .automatic)
                    .navigationBarItems(leading: Button(action: {
                        isLoadingEvents = true
                        getEvents()

                        if showOldEvent {
                            self.oldEvents = []

                            getOldEvents()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise").padding([.top, .bottom, .trailing], 15)
                    }, trailing:
                    VStack{
                        if self.isEditingRight{
                            Button(action: {
                                addedAlert = true
                            }) {
                                Image(systemName: "plus")
                                        .padding([.top, .leading, .bottom], 15)
                            }
                                    .alert(isPresented: $addedAlert) { Alert(title: Text("Пока не готово =(")) }
                        }
                    })
        }
                .navigationViewStyle(StackNavigationViewStyle())
                .onAppear{
                    getEvents()

                    if showOldEvent {
                        getOldEvents()
                    }
                }
    }



    func getEvents()
    {
        if self.events.isEmpty {
            self.isLoadingEvents = true
        }

        OAuthITLab.shared.getToken{

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
                    AlertError.shared.callAlert(message: error.localizedDescription)
                    return
                }
                
                self.events = events?.sorted() { (a, b) -> Bool in
                    a.beginTime! > b.beginTime!
                } ?? []
                self.isLoadingEvents = false

            }

            EventRoleAPI.apiEventRoleGet { (eventsRole, error) in
                
                if let error = error {
                    print(error)
                    AlertError.shared.callAlert(message: error.localizedDescription)
                    return
                }
                
                guard let eventsRole = eventsRole else {
                    print("Not get events role")
                    AlertError.shared.callAlert(message: "Not get events role")
                    return
                }

                EventRole.data = eventsRole
            }
        }
    }

    func getOldEvents() {
        OAuthITLab.shared.getToken{

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
                
                if let error = error {
                    print(error)
                    AlertError.shared.callAlert(message: error.localizedDescription)
                    return
                }
                
                self.oldEvents = events?.sorted() { (a, b) -> Bool in
                    a.beginTime! > b.beginTime!
                } ?? []

            }
        }
    }
}

extension EventsPage {
    private struct EventStack : View {

        @State var event : CompactEventView

        var body: some View {
            NavigationLink(destination: EventPage(compactEvent: event))
            {
                HStack {
                    VStack (alignment: .leading) {
                        Text(event.title ?? "Not title")
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.top, 10)
                        Text(event.eventType?.title ?? "Not event type")
                                .opacity(0.6)
                                .padding(.bottom, 5)

                        ProgressView(value: Float(event.currentParticipantsCount ?? 4), total: Float((event.targetParticipantsCount ?? 10) >= (event.currentParticipantsCount ?? 4) ? event.targetParticipantsCount ?? 10 : event.currentParticipantsCount ?? 4 )).progressViewStyle(LinearProgressViewStyle(tint: .blue))

                        HStack{
                            HStack(alignment: .center) {
                                Image(systemName: "clock")
                                        .font(.callout)
                                        .opacity(0.6)
                                Text(dateFormate(event.beginTime ?? Date()))
                                        .opacity(0.6)
                            }

                            Spacer()

                            HStack {
                                Text("Готовность \(event.currentParticipantsCount ?? 4)/\(event.targetParticipantsCount ?? 10)")
                                        .opacity(0.6)
                            }
                        }
                                .padding(.vertical, 5)
                    }
                }
                        //                .padding(.horizontal, 10)
                        .frame(height: 100)

            }
                    .buttonStyle(PlainButtonStyle())
        }
    }
}

func dateFormate(_ date: Date) -> String
{
    let dateFormmat = DateFormatter()

    dateFormmat.dateFormat = "dd.MM.yy HH:mm"
    return dateFormmat.string(from: date)
}
