//
//  EventPage.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 10/8/20.
//

import SwiftUI

struct EventPage: View {
    
    @State var event : CompactEventView
    
    var body: some View {
        Text(event.title!)
    }
}

struct EventPage_Previews: PreviewProvider {
    static var previews: some View {
        EventPage(event: CompactEventView(id: UUID(), title: "Тест", eventType: nil, beginTime: nil, endTime: nil, address: nil, shiftsCount: nil, currentParticipantsCount: nil, targetParticipantsCount: nil, participating: nil))
    }
}
