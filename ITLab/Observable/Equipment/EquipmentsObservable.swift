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
    @Published var onlyFree: Bool = false
    @Published var match: String = ""
    
    
    #if targetEnvironment(simulator)
    func getEquipment() {
        equipmentModel = []
        
        if self.equipmentModel.isEmpty {
            self.loading = true
        }
        
        if self.match == "mock_serial_number" {
            let i = 1
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
            
        } else if self.match == "mock_serial_number_404" {
            
        } else {
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
        }
        self.loading = false
    }
    #else
    func getEquipment() {
        // TODO: Some api stuff
    }
    #endif
}
