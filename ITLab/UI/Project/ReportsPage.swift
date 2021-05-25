//
//  ReportsPage.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 25.05.2021.
//

import SwiftUI

struct ReportsPage: View {
    @EnvironmentObject var reportsObject: ReportsObservable
    
    var body: some View {
        
        if reportsObject.reportsModel.count == 0 {
            GeometryReader { geometry in
                Text("На данный момент отчеты отсутствуют")
                    .frame(width: geometry.size.width,
                           height: geometry.size.height,
                           alignment: .center)
            }
        } else {
            
            ForEach(reportsObject.reportsModel, id: \.id) { report in
                NavigationLink(
                    destination: Text("В разработке")) {
                    VStack(alignment: .leading) {
                        Text("Отчет (\(formateDate(report.date)))")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.bottom, 2)
                        
//                        Text("Утвержден: \(report.approved != nil ? "Да" : "Нет")")
                        if let approved = report.approved {
                            HStack {
                                Image(systemName: "eye.fill")
                                    .font(.callout)
                                    .opacity(0.6)
                                Text("Утверждено")
                                    .opacity(0.6)
                                
                                Spacer()
                                
                                Image(systemName: "rublesign.circle.fill")
                                    .font(.callout)
                                    .opacity(0.6)
                                Text("\(approved.count)")
                                    .opacity(0.6)
                            }
                        } else {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.callout)
                                    .opacity(0.6)
                                Text("На рассмотрении")
                                    .opacity(0.6)
                            }
                        }
                    }
                    .padding(.vertical, 5.0)
                }
            }
        }
    }
    
    func formateDate(_ date: Date, isClock: Bool = true) -> String {
        let dateFormat = DateFormatter()
        dateFormat.locale = Locale(identifier: "ru")
        
        dateFormat.dateFormat = isClock ? "d.MM.yy HH:mm" : "d.MM.yy"
        
        return dateFormat.string(from: date)
    }
}
