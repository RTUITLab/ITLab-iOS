//
//  ShiftAndPlacePage.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 06.11.2020.
//

import SwiftUI

struct ShiftUIView: View {
    
    let shift: ShiftView
    
    @State private var isExpanded: Bool = false
    
    @Binding var salary: EventSalaryFullView?
    
    var body : some View {
        List {
            
            ForEach (0..<shift.places!.count) { index in
                
                if index == 0 {
                    Section(header: Text("\(EventPage.localizedDate(shift.beginTime!).lowercased()) - \(EventPage.localizedDate(shift.endTime!).lowercased())")) {
                        PlaceUIView(place: shift.places![index], indexPlace: index + 1, salary: salary?.placeSalaries?.first(where: { $0.placeId == shift.places![index]._id}))
                            .padding(.vertical, 2.0)
                    }
                } else {
                    Section {
                        PlaceUIView(place: shift.places![index], indexPlace: index + 1, salary: salary?.placeSalaries?.first(where: { $0.placeId == shift.places![index]._id}))
                            
                            .padding(.vertical, 2.0)
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
}


