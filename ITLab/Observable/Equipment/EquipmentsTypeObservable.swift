//
//  EquipmentsTypeObservable.swift
//  ITLab
//
//  Created by Даниил on 15.07.2021.
//

import Foundation

class EquipmentsTypeObservable: ObservableObject {
    @Published var equipmentsType: [EquipmentTypeModel] = []
    
    #if targetEnvironment(simulator)
    func getEquipmentType() {
        for i in 1...20 {
            self.equipmentsType.append(
                EquipmentTypeModel(id: "mock_id_\(i)", title: "mock_title_\(i)", description: "mock_description_\(i)")
            )
        }
    }
    #else
    func getEquipmentType() {
    // Some api styff
    }
    #endif
}
