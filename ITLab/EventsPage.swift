//
//  EventsPage.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 06.10.2020.
//

import SwiftUI

struct EventsPage: View {
    
    @State var events : [CompactEventView] = []
    @State var isLoading: Bool = true;
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView()
                } else {
                    ScrollView{
                        VStack {
                            ForEach(0..<events.count) { index in
                                EventStack(event: events[index])
                                    
                                if index + 1 != events.count {
                                Divider()
                                    .padding(.vertical, 5.0)
                                }
                                
                            }
                            .padding([.leading, .trailing], 10)
                        }
                        
                    }
                }
                
            }
            .navigationTitle("События")
            .navigationBarTitleDisplayMode(.automatic)
            .navigationBarItems(leading: Button(action: {
                isLoading = true
                getEvents()
                
            }) {
                Image(systemName: "arrow.clockwise")
            }, trailing: Button(action: {
                print("Not working")
            }) {
                Image(systemName: "plus")
            })
        }
        
        
        .onAppear{
            getEvents()
        }
    }
    
   
    
    func getEvents()
    {
        if self.events.isEmpty {
            self.isLoading = true
        }
        
        ITLabApp.authorizeController.performAction { (token, _, _) in
            
            SwaggerClientAPI.customHeaders = ["Authorization" : "Bearer \(token ?? "")"]
        
            let date = Date()
            var dateComponents = DateComponents()
            
            dateComponents.year = Calendar.current.component(.year, from: date)
            dateComponents.month = Calendar.current.component(.month, from: date) - 1
            dateComponents.day = Calendar.current.component(.day, from: date)
            dateComponents.hour = Calendar.current.component(.hour, from: date)
            dateComponents.minute = Calendar.current.component(.minute, from: date)
            dateComponents.timeZone = Calendar.current.timeZone
            
            let newDate = Calendar.current.date(from: dateComponents)
            
            EventAPI.apiEventGet(begin: newDate) { (events, error) in
            
                self.events = events?.sorted() { (a, b) -> Bool in
                    a.beginTime! > b.beginTime!
                } ?? []
                self.isLoading = false
                
            }
        }
    }
}

struct EventStack : View {

    @State private var beginDate : String = ""
    @State private var beginTime : String = ""
    @State private var endDate : String = ""
    @State private var endTime : String = ""
//    @State var beginDateFormate : Bool = false
//    @State var endDateFormate : Bool = false
    
    @State var event : CompactEventView
    
    
    
    var body: some View {
        NavigationLink(destination: EventPage(compactEvent: event))
        {
        HStack {
        VStack (alignment: .leading) {
            Text(event.title ?? "Not title")
                .font(.title3)
                .padding(.top, 10)
            HStack{
                HStack {
                    VStack{
                        Spacer()
                        Text("Начало:")
                            .font(.callout)
                        Spacer()
                    }
                    VStack {
//                        if beginDateFormate {
                            Text(beginTime)
//                        }
                        Text(beginDate)
                        
                    }
                }
//                .onTapGesture {
//                    beginDateFormate.toggle()
//                }
                
                Spacer()
                    
                
                HStack {
                    VStack{
                        Spacer()
                        Text("Конец:")
                            .font(.callout)
                        Spacer()
                    }
                    VStack {
//                        if endDateFormate {
                            Text(endTime)
//                        }
                        Text(endDate)
                        
                    }
                }
//                .onTapGesture {
//                    endDateFormate.toggle()
//                }
            }
            .padding(.vertical, 5)
        }
       
            Image(systemName: "chevron.right")
                .padding(.leading, 15.0)
            
            Spacer()
        }
        .padding(.horizontal, 10)
        .frame(height: 100)
        .background(Color.gray.opacity(0.4))
        
        }
        .buttonStyle(PlainButtonStyle())
        
        .onAppear() {
            
            let dateFormmat = DateFormatter()
            
            dateFormmat.dateFormat = "dd.MM.yy"
            beginDate = dateFormmat.string(from: event.beginTime ?? Date())
            endDate = dateFormmat.string(from: event.endTime ?? Date())
            
            dateFormmat.dateFormat = "HH:mm"
            
            beginTime = dateFormmat.string(from: event.beginTime ?? Date())
            endTime = dateFormmat.string(from: event.endTime ?? Date())
        }
    }
}

struct EventsPage_Previews: PreviewProvider {
    static var previews: some View {
        EventsPage()
    }
}
