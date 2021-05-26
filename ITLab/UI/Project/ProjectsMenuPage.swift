//
//  ProjectsPage.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 25.05.2021.
//

import SwiftUI

struct ProjectsMenuPage: View {
    enum ChoosenPage: String, CaseIterable {
        case project = "Проекты"
        case reports = "Отчеты"
    }
    
    @State var pickers: ChoosenPage = .reports
    
    @ObservedObject var reportsObject = ReportsObservable()
    
    var body: some View {
        NavigationView {
            List {
                Section(header: VStack(alignment: .leading) {
                    Picker(selection: $pickers, label: Text("ChoosenPage"), content: {
                        ForEach(ChoosenPage.allCases, id: \.self) {
                            Text($0.rawValue).textCase(.none)
                        }
                    }).pickerStyle(SegmentedPickerStyle())
                    .padding(.bottom, 10)
                    
                    if pickers == .reports {
                        Text("Отчет обо мне")
                    }
                }) {
                    content
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle(pickers.rawValue, displayMode: .automatic)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var content: some View {
        Group {
            switch pickers {
            case .project:
                GeometryReader { geometry in
                    Text("В разработке")
                        .frame(width: geometry.size.width,
                               height: geometry.size.height,
                               alignment: .center)
                }
            case .reports:
                if reportsObject.loadingReports {
                    GeometryReader { geometry in
                        ProgressView()
                            .frame(width: geometry.size.width,
                                   height: geometry.size.height,
                                   alignment: .center)
                    }
                } else {
                    ReportsPage()
                        .environmentObject(reportsObject)
                }
            }
        }
    }
}
