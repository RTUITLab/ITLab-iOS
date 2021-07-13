//
//  EquipmentItem.swift
//  ITLab
//
//  Created by Даниил on 11.07.2021.
//

import SwiftUI

struct EquipmentItem: View {
    @State private var showFull = false
    var equipment: EquipmentModel
    @ObservedObject private var userObserved = UserObservable()
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(equipment.equipmentType.title)
                Spacer(minLength: 20)
                Text("\(equipment.number)")
                Spacer()
                Button(
                    action: {
                        self.loadData()
                        withAnimation() {
                            self.showFull.toggle()
                        }
                    },
                    label: {
                        Image(systemName: "info.circle")
                    }
                )
            }
            if showFull {
                AnyView(
                        ShowFullEquipmentInfo(
                        fullName: self.userObserved.getFullName(),
                        serialNumber: equipment.serialNumber
                    )
                )
                .transition(AnyTransition.asymmetric(insertion: .scale, removal: .scale))
                .animation(Animation.linear(duration: 1))
            }
        }
    }
    
    func loadData() {
        if let ownerId = self.equipment.ownerId {
            self.userObserved.getUser(userId: ownerId)
        }
    }
}

private struct ShowFullEquipmentInfo: View {
    var fullName: String?
    var serialNumber: String
    var body: some View {
            VStack {
                HStack(alignment: .center) {
                    Text("Владелец:")
                    Spacer(minLength: 40)
                    Text("\(self.fullName ?? "Лаборатория")")
                    Spacer()
                }
                HStack(alignment: .center) {
                    Text("Серийный номер: ")
                    Spacer(minLength: 40)
                    Text("\(self.serialNumber)")
                    Spacer()
                }
            }
    }
}

struct EquipmentItem_Previews: PreviewProvider {
    static var previews: some View {
        EquipmentItem(
            equipment: EquipmentModel(id: "some_id", serialNumber: "some_serial_number", number: 0, equipmentTypeId: "some_elementtypeid", equipmentType: EquipmentTypeModel(id: "some_id", title: "some_title", description: "some_description", shortTitle: "some_short_title"))
        )
    }
}
