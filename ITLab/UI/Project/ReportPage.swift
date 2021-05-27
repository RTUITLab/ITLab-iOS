//
//  ReportPage.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 25.05.2021.
//

import SwiftUI

struct ReportPage: View {
    @State var report: ReportModel
    var body: some View {
        List {
            if let approved = report.approved {
                Section(header: Text("Информация об оплате")) {
                    HStack {
                        Image(systemName: "rublesign.circle.fill")
                            .padding(.trailing, 4)
                            .foregroundColor(.gray)
                            .opacity(0.5)
                        Text("\(approved.count)")
                    }
                    
                    HStack {
                        Image(systemName: "message.fill")
                            .padding(.trailing, 4)
                            .foregroundColor(.gray)
                            .opacity(0.5)
                        Text(approved.description)
                    }
                }
            }
            Section(header: Text("Текст")) {
                
                Markdown(text: report.text)
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Отчет \(ReportsPage.formateDate(report.date))")
    }
}
