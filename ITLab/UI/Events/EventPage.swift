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
                
                
                HStack(alignment: .top) {
                    Text("Начало")
                        .padding(.trailing, 15.0)
                    
                    Spacer()
                    Text(beginDate ?? formateDateToString(compactEvent?.beginTime))
                        .foregroundColor(/*@START_MENU_TOKEN@*/.gray/*@END_MENU_TOKEN@*/)
                        .multilineTextAlignment(.trailing)
                }
                .padding(.vertical, 5)
                
                HStack(alignment: .top) {
                    Text("Конец")
                        .padding(.trailing, 15.0)
                    Spacer()
                    Text(endDate ?? formateDateToString(compactEvent?.endTime))
                        .foregroundColor(/*@START_MENU_TOKEN@*/.gray/*@END_MENU_TOKEN@*/)
                        
                        .multilineTextAlignment(.trailing)
                }
                .padding(.vertical, 5)
                
                HStack(alignment: .top) {
                    Text("Готовность")
                        .padding(.trailing, 15.0)
                    
                    Spacer()
                    Text("\(compactEvent?.currentParticipantsCount ?? 4)/\(compactEvent?.targetParticipantsCount ?? 10)")
                        .foregroundColor(/*@START_MENU_TOKEN@*/.gray/*@END_MENU_TOKEN@*/)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack(alignment: .top) {
                    Text("Адрес")
                        .padding(.trailing, 15.0)
                    
                    Spacer()
                    Text(event?.address ?? compactEvent?.address ?? "")
                        .foregroundColor(/*@START_MENU_TOKEN@*/.gray/*@END_MENU_TOKEN@*/)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            
            if event == nil {
                
                VStack(alignment: .center){
                    ProgressView()
                        .padding(.vertical)
                        .padding(.horizontal, (UIScreen.main.bounds.width / 2) - 30)
                }.listRowBackground(Color.clear)
                
            } else {
                Section {
                    if self.event != nil && !self.event!._description!.isEmpty {
                        NavigationLink("Описание события", destination: Markdown(markdown: (event?._description)!)
                                        .environmentObject(markdownSize))
                    }
                }
                
                Section(header: Text("Смены")) {
                    if event != nil {
                        ForEach (event!.shifts!, id: \._id){ shift in
                            
                            NavigationLink("\(EventPage.localizedDate(shift.beginTime!).lowercased()) - \(EventPage.localizedDate(shift.endTime!).lowercased())", destination:  Shifts(shift: shift))
                        }
                        
                    }
                }
            }
            
        }
        .listStyle(GroupedListStyle())
        .onAppear() {
            
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
        dateFormmat.dateFormat = "d MMMM yyyy \nHH:mm"
        
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

extension EventPage {
    private struct Shifts: View {
        
        let shift: ShiftView
        
        @State var isExpanded: Bool = false
        
        var body : some View {
            List {
                
                ForEach (0..<shift.places!.count) { index in
                    
                    if index == 0 {
                        Section(header: Text("\(EventPage.localizedDate(shift.beginTime!).lowercased()) - \(EventPage.localizedDate(shift.endTime!).lowercased())")) {
                            Place(place: shift.places![index], indexPlace: index + 1)
                                .padding(.vertical, 2.0)
                        }
                    } else {
                        Section {
                            Place(place: shift.places![index], indexPlace: index + 1)
                                
                                .padding(.vertical, 2.0)
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitleDisplayMode(.inline)
            
        }
        
        
        
        private struct Place: View {
            let place: PlaceView
            let indexPlace: Int
            
            @State var isUsers: Bool = false
            @State var isEquipment: Bool = false
            
            @State var isExpanded: Bool = false
            
            var body: some View {
                VStack(alignment: .leading) {
                    HStack(alignment: .center) {
                        if isUsers || isEquipment {
                            VStack{
                                Image(systemName: "chevron.right")
                                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                                    .animation(.spring())
                            }
                                .padding(.trailing, 10)
                        }
                        VStack(alignment: .leading) {
                            Text("Место #\(indexPlace)")
                                .fontWeight(.bold)
                                .padding(.bottom, 1)
                            
                            HStack {
                                Image(systemName: "person.2.fill")
                                    .font(.callout)
                                    .foregroundColor(.gray)
                                    .opacity(0.5)
                                Text(declinationOfNumberOfParticipants(indexPlace))
                                    .font(.callout)
                                    .foregroundColor(Color.gray)
                            }
                           
                        }
                        
                        Spacer()
                        
                        Text("Подать заявку")
                            .foregroundColor(Color.blue)
                            .onTapGesture(){
                                print("Пока не работает")
                            }
                        
//                        Button(action: {
//                            print("Пока не работает =)")
//                        }, label: {
//                            Text("Подать заявку")
//                        })
                    }
                    . onTapGesture(){
                        if isUsers || isEquipment {
                            isExpanded.toggle()
                        }
                    }
                    if isExpanded
                    {
                        VStack(alignment: .leading) {
                            
                            Divider()
                            
                            if isUsers {
                                
                                VStack(alignment: .leading) {
                                    
                                    if let participants = place.participants {
                                        ForEach(participants, id: \.user!._id) { participant in
                                            UserPlace(user: participant, userType: .participants)
                                        }
                                    }
                                    
                                    if let invited = place.invited {
                                        ForEach(invited, id: \.user!._id) { invite in
                                            UserPlace(user: invite, userType: .invited)
                                        }
                                    }
                                    
                                    if let wishers = place.wishers {
                                        ForEach(wishers, id: \.user!._id) { wisher in
                                            UserPlace(user: wisher, userType: .wishers)
                                        }
                                    }
                                    
                                    
                                }
                            }
                        }
                        .padding(.horizontal, 20.0)
                        .padding(.vertical, 10.0)
                        .transition(AnyTransition.slide.animation(.linear(duration: 0.3)))
                    }
                }
                .onAppear() {
                    self.isUsers = place.participants!.count + place.wishers!.count + place.invited!.count != 0
                    self.isEquipment = place.equipment!.count != 0
                }
                
            }
            
            func declinationOfNumberOfParticipants(_ index: Int) -> String {
                
//                var n = index
//
//                n -= place.participants!.count + place.wishers!.count + place.invited!.count
//
//                if n <= 0
//                {
//                    return "Участники не нужны"
//                }
//                n %= 100
//
//                if (n >= 5 && n <= 20) {
//                    return "Нужно \(index) участников"
//                }
//
//                n %= 10;
//                if n == 1 {
//                    return "Нужен \(index) участник";
//                }
//
//                if (n >= 2 && n <= 4) {
//                    return "Нужно \(index) участника";
//                }
//
//                return "Нужно \(index) участников";
                
                return "\(place.participants!.count + place.wishers!.count + place.invited!.count)/\(place.targetParticipantsCount!)"
            }
            
            private struct UserPlace: View {
                enum UserType {
                    case participants
                    case wishers
                    case invited
                }
                
                let user: UserAndEventRole
                let userType: UserType
                
                var body: some View {
                    VStack(alignment: .leading) {
                        HStack(alignment: .center) {
                            
                            switch userType {
                            case .participants:
                                Image(systemName: "checkmark.square.fill")
                                    .foregroundColor(.green)
                            case .invited:
                                Image(systemName: "checkmark.square.fill")
                                    .foregroundColor(.yellow)
                            case .wishers:
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.gray)
                                    .opacity(0.5)
                            }
                            
                            Text("\(user.user!.lastName!) \(user.user!.firstName!)")
                                .font(.callout)
                                .bold()
                            
                            Text("—")
                                .font(.callout)
                            
                            Text(user.eventRole!.title!.lowercased())
                                .font(.callout)
                        }
                    }
                    .padding(1.0)
                    
                }
            }
            
            private struct EquipmentPlace: View {
                let equipment: EquipmentView
                
                var body: some View {
                    VStack(alignment: .leading) {
                        
                        Text("\(equipment.equipmentType!.title!)")
                            .font(.footnote)
                            .bold()
                            .lineLimit(2)
                        
                        Text(equipment.serialNumber!)
                            .font(.caption)
                        
                    }
                    .padding(5.0)
                }
            }
        }
        
    }
}



struct EventPage_Previews: PreviewProvider {
    
    static var previews: some View {
        EventPage()
    }
}
