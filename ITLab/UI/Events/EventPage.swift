//
//  EventPage.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 10/8/20.
//

import SwiftUI
import EventKit
import Down

struct EventPage: View {
    
    enum ActiveAlert {
        case add, success, failure
    }
    
    @State var compactEvent: CompactEventView
    @State private var event: EventView?
    @State private var salary: EventSalaryFullView?
    
    @State private var beginDate: String?
    @State private var endDate: String?
    
    @State private var isLoadedSalary: Bool = false
    @State private var isExpandedDescription: Bool = false
    
    @State private var isAddCalendar: Bool = false
    @State private var alertMode: ActiveAlert = .add
    @State private var alertFailedMessage: String = ""
    
    var body: some View {
        List {
            Section {
                
                HStack(alignment: .top) {
                    Text("Тип события")
                        .padding(.trailing, 15.0)
                    
                    Spacer()
                    Text(event?.eventType?.title ?? compactEvent.eventType?.title ?? "Лекция")
                        .foregroundColor(/*@START_MENU_TOKEN@*/.gray/*@END_MENU_TOKEN@*/)
                        .multilineTextAlignment(.trailing)
                }
                
                if beginDate != nil || compactEvent.beginTime != nil {
                    HStack(alignment: .center) {
                        Image(systemName: "clock.fill")
                            .padding(.trailing, 10)
                            .foregroundColor(.gray)
                            .opacity(0.5)
                        
                        Text("\(beginDate ?? formatDateToString(compactEvent.beginTime)) — \(endDate ?? formatDateToString(compactEvent.endTime))")
                    }
                    .padding(.vertical, 5)
                }
                
                if compactEvent.currentParticipantsCount != nil && compactEvent.targetParticipantsCount != nil {
                    HStack(alignment: .center) {
                        
                        Image(systemName: "person.2.fill")
                            .padding(.trailing, 4)
                            .foregroundColor(.gray)
                            .opacity(0.5)
                        
                        Text("\(compactEvent.currentParticipantsCount!)/\(compactEvent.targetParticipantsCount!)")
                    }
                }
                
                if isLoadedSalary {
                    HStack(alignment: .center) {
                        
                        Image(systemName: "creditcard.fill")
                            .padding(.trailing, 4)
                            .foregroundColor(.gray)
                            .opacity(0.5)
                        
                        Text(salary != nil ? "\(salary!.count!) \u{20BD}" : "Оплата не назначена")
                    }
                }
                
                location
            }
            
            if event == nil {
                
                VStack(alignment: .center) {
                    GeometryReader { geometry in
                        ProgressView()
                            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                    }.padding(.vertical, 20)
                    
                }
                
            } else {
                description
                
                shifts
            }
            
        }
        .listStyle(GroupedListStyle())
        .onAppear {
            
            OAuthITLab.shared.getToken {
                
                EventSalaryAPI.apiSalaryV1EventEventIdGet(eventId: self.compactEvent.id!) { salary, error in
                    
                    if let error = error as? ErrorResponse {
                        switch error {
                        case .error(let code, _, _):
                            if code == 404 {
                                return
                            }
                            
                            print(error)
                            return
                        }
                    }
                    
                    self.salary = salary
                    self.isLoadedSalary = true
                }
                
                EventAPI.apiEventIdGet(_id: self.compactEvent.id!) { (event, error) in
                    
                    if let error = error {
                        print(error)
                        return
                    }
                    
                    self.event = event
                    
                    countingDate()
                }
            }
        }
        .navigationBarTitle(Text(event?.title ?? compactEvent.title ?? "Название события"), displayMode: .large)
        .navigationBarItems(trailing: addCalendar)
    }
    
    var addCalendar: some View {
        VStack {
            if EKEventStore.authorizationStatus(for: .event) == .authorized,
               let event = self.event {
                Button(action: {
                    self.alertMode = .add
                    self.isAddCalendar.toggle()
                }, label: {
                    Image(systemName: "calendar.badge.plus")
                })
                .disabled(!ITLabCalendar.shared.checkEvent(eventId: event._id!))
                .alert(isPresented: $isAddCalendar) {
                    switch alertMode {
                    case .add:
                        return Alert(title: Text("Добавить событие?"),
                                     message: Text("В Ваш каледнарь добавиться событие \(event.title!)"),
                                     primaryButton: .default(Text("Да")) {
                                        
                                        DispatchQueue(label: "add Calendar").async {
                                            
                                            var node = "Cсылка на событие: \(SwaggerClientAPI.getURL())/events/\(event._id!.uuidString)"
                                            
                                            if let description = event._description {
                                                let down = Down(markdownString: description)
                                                node = (try? down.toAttributedString().string + "\n\n\(node)") ?? node
                                            }
                                            
                                            let event = ITLabCalendar.EventInfo(title: event.title!,
                                                                                startDates: compactEvent.beginTime!,
                                                                                endDates: compactEvent.endTime!,
                                                                                location: event.address!,
                                                                                note: node,
                                                                                id: event._id!)
                                            
                                            let result = ITLabCalendar.shared.createEvent(event: event)
                                            DispatchQueue.main.async {
                                                switch result {
                                                case .success():
                                                    alertMode = .success
                                                case .failure(let error):
                                                    alertFailedMessage = error.localizedDescription
                                                    alertMode = .failure
                                                }
                                                
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                    self.isAddCalendar.toggle()
                                                }
                                            }
                                        }
                                     },
                                     secondaryButton: .cancel(Text("Нет")))
                    case .success:
                        return Alert(title: Text("Событие добавлено в Ваш календарь"))
                    case .failure:
                        return Alert(title: Text(alertFailedMessage))
                    }
                }
            }
        }
    }
    
    var shifts: some View {
        Section(header: Text("Смены")) {
            ForEach(event!.shifts!, id: \._id) { shift in
                
                NavigationLink(destination: ShiftUIView(shift: shift, salary: $salary)) {
                    VStack(alignment: .leading) {
                        Text("\(EventPage.localizedDate(shift.beginTime!).lowercased()) - \(EventPage.localizedDate(shift.endTime!).lowercased())")
                        
                        if let salary = self.salary?.shiftSalaries?
                            .first(where: {$0.shiftId == shift._id})?.count {
                            HStack(alignment: .center) {
                                Image(systemName: "creditcard.fill")
                                    .font(.callout)
                                    .foregroundColor(.gray)
                                    .opacity(0.5)
                                Text("\(salary) \u{20BD}")
                                    .font(.callout)
                                    .foregroundColor(Color.gray)
                            }
                            .padding(.top, 1)
                        }
                    }
                }
            }
        }
    }
    
    var description: some View {
        Group {
            if let eventDescription = self.event?._description,
               !eventDescription.isEmpty {
                Section {
                    NavigationLink(
                        destination: EventDescription(markdown: eventDescription)) {
                        HStack(alignment: .center) {
                            Image(systemName: "info.circle.fill")
                                .padding(.trailing, 10)
                                .foregroundColor(.gray)
                                .opacity(0.5)
                            
                            Text("Описание")
                        }
                    }
                }
            }
        }
    }
    
    var location: some View {
        HStack(alignment: .center) {
            Image(systemName: "location.fill")
                .padding(.trailing, 10)
                .foregroundColor(.gray)
                .opacity(0.5)
            
            Button(action: {
                if UIApplication.shared.canOpenURL(URL(string: "yandexmaps://")!) {
                    UIApplication.shared.open(URL(string: "yandexmaps://maps.yandex.ru/?text=\(compactEvent.address!)"
                                                    .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)
                } else {
                    UIApplication.shared.open(URL(string: "https://itunes.apple.com/ru/app/yandex.maps/id313877526?mt=8")!)
                }
            }, label: {
                Text(event?.address ?? compactEvent.address!)
            })
            .contextMenu {
                Button(action: {
                    if UIApplication.shared.canOpenURL(URL(string: "yandexmaps://")!) {
                        UIApplication.shared.open(URL(string: "yandexmaps://maps.yandex.ru/?text=\(compactEvent.address!)"
                                                        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                        )!)
                    } else {
                        UIApplication.shared.open(URL(string: "https://itunes.apple.com/ru/app/yandex.maps/id313877526?mt=8")!)
                    }
                }, label: {
                    Text("Яндекс.Карты")
                    Image(systemName: "map")
                })
                
                Button(action: {
                    UIPasteboard.general.string = event?.address ?? compactEvent.address
                }, label: {
                    Text("Копировать")
                    Image(systemName: "doc.on.doc")
                })
            }
        }
    }
    
    func countingDate() {
        let beginDate = event!.shifts!.min(by: {
            $0.beginTime! < $1.beginTime!
        })?.beginTime
        
        let endDate = event!.shifts!.max(by: {
            $0.endTime! < $1.endTime!
        })?.endTime
        
        event!.shifts!.sort {
            $0.beginTime! < $1.beginTime!
        }
        
        self.beginDate = formatDateToString(beginDate)
        self.endDate = formatDateToString(endDate)
    }
    
    func formatDateToString(_ date: Date?) -> String {
        let dateFormat = DateFormatter()
        dateFormat.locale = Locale(identifier: "ru")
        dateFormat.dateFormat = "d.MM.yy HH:mm"
        
        return dateFormat.string(from: date ?? Date())
    }
    
    static func localizedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, dd.MM.yy HH:mm"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter.string(from: date)
    }
}
