//
//  EquipmentItem.swift
//  ITLab
//
//  Created by Даниил on 11.07.2021.
//

import SwiftUI

struct EquipmentItem: View {
    var equipment: EquipmentModel
    
    var body: some View {
        HStack {
            Text(equipment.equipmentType.title)
            Spacer(minLength: 20)
            Text("\(equipment.number)")
            Spacer()
//            Button(
//                action: {
//                    
//                },
//                label: {
//                    Image(systemName: "info.circle")
//                }
//            )
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
