//
//  ReportPage.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 25.05.2021.
//

import SwiftUI

struct ReportPage: View {
    @State var report: ReportModel
    @State private var height: CGFloat = .zero
    var body: some View {
        List {
            if let approved = report.approved {
                Section(header: Text("Информацио об оплате")) {
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
                Markdown(text: report.text, height: $height)
                    .frame(minHeight: height)
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Отчет \(ReportsPage.formateDate(report.date))")
    }
}
