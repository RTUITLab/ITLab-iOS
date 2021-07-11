//
//  EquipmentObservable.swift
//  ITLab
//
//  Created by Даниил on 11.07.2021.
//

import Foundation
import SwiftUI

final class EquipmentsObservable: ObservableObject {
    @Published var equipmentModel: [EquipmentModel] = []
    @Published var loading: Bool = false
    var onlyFree: Binding<Bool>? = nil
    @Published var match: String = ""
    
    init(onlyFree: Binding<Bool>? = nil) {
        self.onlyFree = onlyFree
    }
    
    #if targetEnvironment(simulator)
    func getEquipment() {
        if self.equipmentModel.isEmpty {
            self.loading = true
        }
        
        for i in 1...20 {
            equipmentModel.append(
                EquipmentModel(
                    id: "mock_id_\(i)",
                    serialNumber: "mock_serial_number_\(i)",
                    number: i,
                    equipmentTypeId: "mock_equipment_type_id_\(i)",
                    equipmentType: EquipmentTypeModel(
                        id: "mock_id_\(i)",
                        title: "mock_title_\(i)",
                        description: "mock_description_\(i)",
                        shortTitle: "mock_short_title_\(i)"
                    )
                )
            )
        }
        self.loading = false
    }
    #else
    func getEquipment() {
        // TODO: Some api stuff
    }
    #endif
}
