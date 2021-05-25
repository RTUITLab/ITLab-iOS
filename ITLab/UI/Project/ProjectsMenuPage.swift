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
    var body: some View {
        NavigationView {
                List {
                    Section(header: Picker(selection: $pickers, label: Text("ChoosenPage"), content: {
                        ForEach(ChoosenPage.allCases, id: \.self) {
                            Text($0.rawValue).textCase(.none)
                        }
                    }).pickerStyle(SegmentedPickerStyle())
                    .padding(.bottom, 10)) {
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
                    Text("Пока в разработке")
                        .frame(width: geometry.size.width,
                               height: geometry.size.height,
                               alignment: .center)
                }
            case .reports:
                ReportsPage()
            }
        }
    }
}
