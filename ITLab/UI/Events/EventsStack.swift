//
//  EventsStack.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 14.05.2021.
//

import SwiftUI

struct EventStack: View {
    
    @State var event: CompactEventView
    
    var body: some View {
        NavigationLink(destination: EventPage(compactEvent: event)) {
            HStack {
                VStack(alignment: .leading) {
                    Text(event.title ?? "Not title")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.bottom, 0.1)
                    Text(event.eventType?.title ?? "Not event type")
                        .opacity(0.6)
                        .padding(.bottom, 5)
                    
                    ProgressView(value: Float(event.currentParticipantsCount ?? 4),
                                 total: Float((event.targetParticipantsCount ?? 10) >=
                                                (event.currentParticipantsCount ?? 4)
                                                ? event.targetParticipantsCount ?? 10
                                                : event.currentParticipantsCount ?? 4 ))
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    
                    HStack {
                        HStack(alignment: .center) {
                            Image(systemName: "clock")
                                .font(.callout)
                                .opacity(0.6)
                            Text(dateFormate(event.beginTime ?? Date()))
                                .opacity(0.6)
                        }
                        
                        Spacer()
                        
                        HStack {
                            Text("Готовность \(event.currentParticipantsCount ?? 4)/\(event.targetParticipantsCount ?? 10)")
                                .opacity(0.6)
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
            .frame(height: 100)
            
        }
        .buttonStyle(PlainButtonStyle())
    }
}
