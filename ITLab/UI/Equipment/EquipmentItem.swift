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
                        self.showFull.toggle()
                    },
                    label: {
                        Image(systemName: "info.circle")
                    }
                )
            }
            if showFull {
                ShowFullEquipmentInfo(equipment: equipment)
                    .environmentObject(userObserved)
            }
        }
    }
    
    func loadData() {
        if let ownerId = self.equipment.ownerId {
            self.userObserved.getUser(userId: ownerId)
        }
    }
}

private struct EquipmentInfoTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .padding(.vertical)
    }
}

struct ShowFullEquipmentInfo: View {
    @EnvironmentObject var userObserved: UserObservable
    var fullMode: Bool = false
    var equipment: EquipmentModel
    var body: some View {
        VStack(alignment: .leading) {
            if fullMode {
                HStack {
                    Text("Тип:")
                        .padding(.horizontal)
                    Spacer()
                    Text("\(equipment.equipmentType.title)")
                        .modifier(EquipmentInfoTextModifier())
                    Spacer()
                }
                HStack {
                    Text("Номер:")
                        .padding(.horizontal)
                    Spacer()
                    Text("\(equipment.number)")
                        .modifier(EquipmentInfoTextModifier())
                    Spacer()
                }
            }
            HStack {
                Text("Владелец:")
                    .padding(.horizontal)
                Spacer()
                Text("\(self.userObserved.getFullNameWithEmail() ?? "Лаборатория")")
                    .modifier(EquipmentInfoTextModifier())
                Spacer()
            }
            HStack {
                Text("Серийный номер: ")
                    .padding(.leading)
                Spacer()
                Text("\(self.equipment.serialNumber)")
                    .modifier(EquipmentInfoTextModifier())
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

struct EquipmentShowFull_Previews: PreviewProvider {
    static var previews: some View {
        let user = UserObservable()
        user.user = UserView(_id: UUID(), firstName: "Даниил", lastName: "Демин", middleName: nil, phoneNumber: nil, email: "name.lastname@example.com", properties: nil)
        return ShowFullEquipmentInfo(equipment: EquipmentModel(id: "some_id", serialNumber: "some_serial_number", number: 0, equipmentTypeId: "some_elementtypeid", equipmentType: EquipmentTypeModel(id: "some_id", title: "some_title", description: "some_description", shortTitle: "some_short_title")))
                .environmentObject(user)
    }
}

struct EquipmentShowFull_Fullmode_Previews: PreviewProvider {
    static var previews: some View {
        ShowFullEquipmentInfo(fullMode: true, equipment: EquipmentModel(id: "some_id", serialNumber: "some_serial_number", number: 0, equipmentTypeId: "some_elementtypeid", equipmentType: EquipmentTypeModel(id: "some_id", title: "some_title", description: "some_description", shortTitle: "some_short_title"))).environmentObject(UserObservable())
    }
}
