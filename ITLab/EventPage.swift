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
                    
                    Text(event?._description ?? "")
                    Markdown(markdownString:  event?._description ?? "")
                }
                .padding(.vertical, 5.0)
                
                Divider()
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

struct EventPage_Previews: PreviewProvider {
    
    static var previews: some View {
        EventPage()
    }
}
