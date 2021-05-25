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
                Text("На данный момент отчеты отсутсвтуют")
                    .frame(width: geometry.size.width,
                           height: geometry.size.height,
                           alignment: .center)
            }
        } else {
            
            ForEach(reportsObject.reportsModel, id: \.id) { report in
                VStack {
                    Text("\(report.date)")
                }
            }
        }
    }
}
