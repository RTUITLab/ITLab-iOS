//
//  EventsPage.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 06.10.2020.
//

import SwiftUI

struct EventsPage: View {
   
    @State var events : [CompactEventView] = []
   
    var body: some View {
        NavigationView {
            
            List {
                ForEach(events.sorted() { (a, b) -> Bool in
                    a.endTime! > b.endTime!
                }) { event in
                    EventStack(event: event)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 5)
                }
            }
            .navigationTitle("События")
            .navigationBarTitleDisplayMode(.inline)
            
            .navigationBarItems(trailing: Button(action: {
                print("Not working")
            }) {
                Image(systemName: "plus")
            })
            .onAppear{
                getEvents()
            }
        }
    }
    
   
    
    func getEvents()
    {
        ITLabApp.authorizeController.performAction { (token, _, _) in
            SwaggerClientAPI.customHeaders = ["Authorization" : "Bearer \(token ?? "")"]
            EventAPI.apiEventGet { (events, error) in
                self.events = events ?? []
            }
        }
    }
}

struct EventStack : View {
    
    enum dateMode {
        case begin
        case end
    }
    
    var dateFormmat : DateFormatter = DateFormatter()
    
    @State private var beginDate : String = ""
    @State private var endDate : String = ""
    
    @State var event : CompactEventView
    
    @State var beginDateFormate : Bool = true
    @State var endDateFormate : Bool = true
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(event.title ?? "Not title")
                .font(.title2)
            HStack{
                Text("Начало: \(beginDate)")
                    .font(.callout)
                    .onTapGesture {
                        getDateFormat(mode: .begin)
                    }
                Spacer()
                Text("Конец: \(endDate)")
                    .font(.callout)
                    .onTapGesture {
                        getDateFormat(mode: .end)
                    }
            }
        }
        .onAppear() {
            dateFormmat.dateFormat = "dd.MM.yy"
            beginDate = dateFormmat.string(from: event.beginTime ?? Date())
            endDate = dateFormmat.string(from: event.endTime ?? Date())
        }
    }
    
    func getDateFormat(mode: dateMode)
    {
        switch mode {
        case .begin:
            beginDateFormate.toggle()
            dateFormmat.dateFormat = beginDateFormate ? "dd.MM.yy" : "dd.MM.yy HH:mm"
            beginDate = dateFormmat.string(from: event.beginTime ?? Date())
            break
        case .end:
            endDateFormate.toggle()
            dateFormmat.dateFormat = endDateFormate ? "dd.MM.yy" : "dd.MM.yy HH:mm"
            endDate = dateFormmat.string(from: event.endTime ?? Date())
            break
        }
    }
}

struct EventsPage_Previews: PreviewProvider {
    static var previews: some View {
        EventsPage()
    }
}
