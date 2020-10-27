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
        ScrollView{
            VStack (alignment: .leading) {
                
                Text(event?.eventType?.title ?? compactEvent?.eventType?.title ?? "Лекция")
                    .font(.title3)
                
                Divider()
                
                VStack(alignment: .leading) {
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Начало:")
                                .bold()
                            
                            Text("Конец:")
                                .bold()
                            
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(beginDate ?? formateDateToString(compactEvent?.beginTime))
                            Text(endDate ?? formateDateToString(compactEvent?.endTime))
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Адрес:")
                            .bold()
                        
                        Text(event?.address ?? compactEvent?.address ?? "")
                    } .padding(.top, 10)
                }
                .padding(.vertical, 5.0)
                
                Divider()
                
                if event == nil {
                    
                    VStack(alignment: .center){
                        ProgressView()
                            .padding(.top, 20.0)
                            .padding(.horizontal, (UIScreen.main.bounds.width / 2) - 30)
                    }
                    
                } else {
                    
                    if self.event != nil && !self.event!._description!.isEmpty {
                        VStack(alignment: .leading) {
                            HStack{
                                Image(systemName: "chevron.right")
                                    .rotationEffect(Angle(degrees: isExpandedDescription ? 90 : 0))
                                Text("Описание")
                                    .bold()
                                    .padding(.bottom, 1)
                                    .padding(.trailing, 20.0)
                                    .padding(.leading, 10.0)
                            }
                            .onTapGesture{
                                isExpandedDescription.toggle()
                            }
                            
                            if isExpandedDescription {
                                Markdown(markdown: (event?._description)!)
                                    .environmentObject(markdownSize)
                            }
                        }
                        .padding(.vertical, 5.0)
                        
                        Divider()
                    }
                    
                    if event != nil {
                        VStack (alignment: .leading, spacing: 10) {
                            ForEach (0..<event!.shifts!.count){ index in
                                Shifts(shift: event!.shifts![index])
                                    .animation(.linear(duration: 0.3))
                            }
                        }
                    }
                    
                    Spacer(minLength: 20)
                    
                }
            }
            .padding(.horizontal, 20)
            
        }
        .onAppear() {
            
            AuthorizeController.shared!.performAction { (accesToken, _, _) in
                
                SwaggerClientAPI.customHeaders = ["Authorization" : "Bearer \(accesToken ?? "")"]
                
                EventAPI.apiEventIdGet(_id: compactEvent!.id!) { (event, _) in
                    
                    self.event = event
                    
                    countingDate()
                }
            }
        }
        .navigationBarTitle(Text(event?.title ?? compactEvent?.title ?? "Название события"), displayMode: .automatic)
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
        
        dateFormmat.dateFormat = "dd.MM.yy HH:mm"
        
        return dateFormmat.string(from: date ?? Date())
    }
}

extension EventPage {
    private struct Shifts: View {
        
        let shift: ShiftView
        
        @State var isExpanded: Bool = false
        
        var body : some View {
            VStack (alignment: .leading){
                HStack {
                    Image(systemName: "chevron.right")
                        .rotationEffect(Angle(degrees: isExpanded ? 90 : 0))
                    
                    Text("\(localizedDate(shift.beginTime!).lowercased()) - \(localizedDate(shift.endTime!).lowercased())")
                        .fontWeight(.bold)
                        .padding(.trailing, 20.0)
                        .padding(.leading, 10.0)
                }
                . onTapGesture(){
                    isExpanded.toggle()
                }
                
                
                if isExpanded {
                    VStack(alignment: .leading) {
                        
                        ForEach (0..<shift.places!.count){ index in
                            Place(place: shift.places![index], indexPlace: index + 1)
                                .animation(.linear(duration: 0.3))
                                .padding(.vertical, 2.0)
                        }
                    }.padding([.top, .leading, .trailing], 15.0)
                }
            }
            .padding(.vertical, 10.0)
        }
        
        func localizedDate(_ date: Date) -> String
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E, dd.MM.yy HH:mm"
            dateFormatter.locale = Locale(identifier: "ru_RU")
            return dateFormatter.string(from: date)
        }
        
        private struct Place: View {
            let place: PlaceView
            let indexPlace: Int
            
            @State var isUsers: Bool = false
            @State var isEquipment: Bool = false
            
            @State var isExpanded: Bool = false
            
            var body: some View {
                VStack(alignment: .leading) {
                    HStack {
                        if isUsers || isEquipment {
                            Image(systemName: "chevron.right")
                                .rotationEffect(Angle(degrees: isExpanded ? 90 : 0))
                        }
                        
                        Text("Место #\(indexPlace) | \(declinationOfNumberOfParticipants(indexPlace))")
                    }
                    . onTapGesture(){
                        if isUsers || isEquipment {
                            isExpanded.toggle()
                        }
                    }
                    if isExpanded
                    {
                        VStack(alignment: .leading) {
                            
                            if isUsers {
                                
                                VStack(alignment: .leading) {
                                    
                                    Text("Участники:")
                                        .font(.callout)
                                        .fontWeight(.bold)
                                    
                                    ForEach(0..<place.participants!.count) { index in
                                        UserPlace(user: place.participants![index])
                                    }
                                    ForEach(0..<place.wishers!.count) { index in
                                        UserPlace(user: place.wishers![index])
                                    }
                                    ForEach(0..<place.invited!.count) { index in
                                        UserPlace(user: place.invited![index])
                                    }
                                }
                            }
                            
                            if isUsers && isEquipment {
                                Divider()
                            }
                            
                            if isEquipment {
                                
                                VStack(alignment: .leading) {
                                    
                                    Text("Оборудование:")
                                        .font(.callout)
                                        .fontWeight(.bold)
                                    ForEach(0..<place.equipment!.count) { index in
                                        EquipmentPlace(equipment: place.equipment![index])
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 5.0)
                        .padding(.vertical, 10.0)
                    }
                }
                .onAppear() {
                    self.isUsers = place.participants!.count + place.wishers!.count + place.invited!.count != 0
                    self.isEquipment = place.equipment!.count != 0
                }
                
            }
            
            func declinationOfNumberOfParticipants(_ index: Int) -> String {
                
                var n = index
                
                n -= place.participants!.count + place.wishers!.count + place.invited!.count
                
                if n <= 0
                {
                    return "Участники не нужны"
                }
                n %= 100
                
                if (n >= 5 && n <= 20) {
                    return "Нужно \(index) участников"
                }
                
                n %= 10;
                if n == 1 {
                    return "Нужен \(index) участник";
                }
                
                if (n >= 2 && n <= 4) {
                    return "Нужно \(index) участника";
                }
                
                return "Нужно \(index) участников";
                
            }
            
            private struct UserPlace: View {
                let user: UserAndEventRole
                
                var body: some View {
                    VStack(alignment: .leading) {
                        HStack(alignment: .center) {
                            Text("\(user.user!.lastName!) \(user.user!.firstName!) \(user.user!.middleName!)")
                                .font(.footnote)
                                .bold()
                                .lineLimit(2)
                            
                            Spacer()
                            
                            Text(user.eventRole!.title!)
                                .font(.caption)
                        }
                    }
                    .padding(5.0)
                    
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
