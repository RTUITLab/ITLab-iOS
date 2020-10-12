//
//  EventPage.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 10/8/20.
//

import SwiftUI

struct EventPage: View {
    
    @State var compactEvent : CompactEventView?
    @State var event : EventView?
    
    @State var beginDate: String?
    @State var endDate: String?
    
    
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
                        
                        Text(event?.address ?? compactEvent?.address ?? "тут должен быть адрес")
                    } .padding(.top, 10)
                }
                .padding(.vertical, 5.0)
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("Описание")
                        .bold()
                        .padding(.bottom, 1)
            
                    if self.event != nil && !self.event!._description!.isEmpty {
                        Markdown(markdown: (event?._description)!)
                    
                    }
                }
                .padding(.vertical, 5.0)
                
                Divider()
                
                if event != nil {
                    VStack (alignment: .leading, spacing: 10) {
                        ForEach (0..<event!.shifts!.count){ index in
                            Shifts(shift: event!.shifts![index])
                                .animation(.linear(duration: 0.3))
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .onAppear() {
            
            ITLabApp.authorizeController.performAction { (accesToken, _, _) in
                
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
        
        @State var shift: ShiftView
        
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
                    VStack {
                        
                        ForEach (0..<shift.places!.count){ index in
                            Place(place: shift.places![index], indexPlace: index + 1)
                                .animation(.linear(duration: 0.3))
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
            @State var place: PlaceView
            let indexPlace: Int
            @State var isExpanded: Bool = false
            
            var body: some View {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "chevron.right")
                            .rotationEffect(Angle(degrees: isExpanded ? 90 : 0))
                        Text("Место #\(indexPlace)")
                    }
                    . onTapGesture(){
                        isExpanded.toggle()
                    }
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
