//
//  EquipmentTypeObservable.swift
//  ITLab
//
//  Created by Даниил on 15.07.2021.
//

import Foundation

class EquipmentTypeObservable: ObservableObject {
    @Published var equipmentType: EquipmentTypeModel? = nil
    
    /// Возврашает EquipmentTypeID
    #if targetEnvironment(simulator)
    func createType() -> String {
        return "some_EquipmentTypeID"
    }
    #else
    func createType() -> String {
        // some api stuff
        return ""
    }
    #endif
}
