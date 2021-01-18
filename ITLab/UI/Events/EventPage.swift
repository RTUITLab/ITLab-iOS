//
//  EventPage.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 10/8/20.
//

import SwiftUI

struct EventPage: View {
    
    class MarkdownSize: ObservableObject {
        @Published var height: CGFloat = 0
    }
    
    @ObservedObject var markdownSize = MarkdownSize()
    
    @State var compactEvent : CompactEventView?
    @State var event : EventView?
    
    @State var beginDate: String?
    @State var endDate: String?
    
    @State var isExpandedDescription: Bool = false
    
    
    var body: some View {
        List {
            Section {
                
                HStack(alignment: .top) {
                    Text("Тип события")
                        .padding(.trailing, 15.0)
                    
                    Spacer()
                    Text(event?.eventType?.title ?? compactEvent?.eventType?.title ?? "Лекция")
                        .foregroundColor(/*@START_MENU_TOKEN@*/.gray/*@END_MENU_TOKEN@*/)
                        .multilineTextAlignment(.trailing)
                }
                
                
                HStack(alignment: .center) {
                    Image(systemName: "clock.fill")
                        .padding(.trailing, 10)
                        .foregroundColor(.gray)
                        .opacity(0.5)
                    
                    Text("\(beginDate ?? formateDateToString(compactEvent?.beginTime)) — \(endDate ?? formateDateToString(compactEvent?.endTime))")
                }
                .padding(.vertical, 5)
                
                HStack(alignment: .center) {
                    
                    Image(systemName: "person.2.fill")
                        .padding(.trailing, 4)
                        .foregroundColor(.gray)
                        .opacity(0.5)
                    
                    
                    Text("\(compactEvent?.currentParticipantsCount ?? 3)/\(compactEvent?.targetParticipantsCount ?? 10)")
                }
                
                HStack(alignment: .center) {
                    Image(systemName: "location.fill")
                        .padding(.trailing, 10)
                        .foregroundColor(.gray)
                        .opacity(0.5)
                    
                    
                    Button(action: {
                        if UIApplication.shared.canOpenURL(URL(string: "yandexmaps://")!) {
                            UIApplication.shared.open(URL(string: ("yandexmaps://maps.yandex.ru/?text=\(compactEvent!.address!)").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)
                        } else {
                            UIApplication.shared.open(URL(string: "https://itunes.apple.com/ru/app/yandex.maps/id313877526?mt=8")!)
                        }
                    }) {
                        Text(compactEvent!.address!)
                    }
                    .contextMenu() {
                        Button(action: {
                            if UIApplication.shared.canOpenURL(URL(string: "yandexmaps://")!) {
                                UIApplication.shared.open(URL(string: "yandexmaps://maps.yandex.ru/?text=\(compactEvent!.address!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!)
                            } else {
                                UIApplication.shared.open(URL(string: "https://itunes.apple.com/ru/app/yandex.maps/id313877526?mt=8")!)
                            }
                        }) {
                            Text("Открыть карты")
                            Image("location.fill")
                        }
                        
                        Button(action: {
                            UIPasteboard.general.string = event?.address ?? compactEvent?.address
                        }) {
                            Text("Копировать")
                            Image(systemName: "doc.on.doc")
                        }
                    }
                }
            }
            
            
            if event == nil {
                
                VStack(alignment: .center){
                    GeometryReader { g in
                        ProgressView()
                            .frame(width: g.size.width, height: g.size.height, alignment: .center)
                    }.padding(.vertical, 20)
                    
                }
                
            } else {
                Section {
                    if self.event != nil && !self.event!._description!.isEmpty {
                        NavigationLink(
                            destination: Markdown(markdown: (event?._description)!)
                                .environmentObject(markdownSize)) {
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
                
                Section(header: Text("Смены")) {
                    if event != nil {
                        ForEach (event!.shifts!, id: \._id){ shift in
                            
                            NavigationLink("\(EventPage.localizedDate(shift.beginTime!).lowercased()) - \(EventPage.localizedDate(shift.endTime!).lowercased())", destination:  ShiftUIView(shift: shift))
                        }
                        
                    }
                }
            }
            
        }
        .listStyle(GroupedListStyle())
        .onAppear() {
//            print(("yandexmaps://maps.yandex.ru/?text=\(compactEvent!.address!)").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            
            AppAuthInteraction.shared.performAction { (accesToken, _) in
                
                EventAPI.apiEventIdGet(_id: compactEvent!.id!) { (event, _) in
                    
                    self.event = event
                    
                    countingDate()
                }
            }
        }
        .navigationBarTitle(Text(event?.title ?? compactEvent?.title ?? "Название события"), displayMode: .large)
        
    }
    
    func countingDate()
    {
        let beginDate = event!.shifts!.min(by: { (a, b) -> Bool in
            return a.beginTime! < b.beginTime!
        })?.beginTime
        
        let endDate = event!.shifts!.max(by: { (a, b) -> Bool in
            return a.endTime! < b.endTime!
        })?.endTime
        
        event!.shifts!.sort { (a, b) -> Bool in
            return a.beginTime! < b.beginTime!
        }
        
        self.beginDate = formateDateToString(beginDate)
        self.endDate = formateDateToString(endDate)
    }
    
    func formateDateToString(_ date: Date?) -> String
    {
        let dateFormmat = DateFormatter()
        dateFormmat.locale = Locale(identifier: "ru")
        dateFormmat.dateFormat = "d.MM.yy HH:mm"
        
        return dateFormmat.string(from: date ?? Date())
    }
    
    static func localizedDate(_ date: Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, dd.MM.yy HH:mm"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter.string(from: date)
    }
}
