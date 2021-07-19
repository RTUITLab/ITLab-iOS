//
//  EquipmentObservable.swift
//  ITLab
//
//  Created by Даня Демин on 12.07.2021.
//

import Foundation

final class EquipmentObservable: ObservableObject {
    @Published var equipment: EquipmentModel? = nil
    
    #if targetEnvironment(simulator)
    func createEquipment() {
        print("created")
    }
    #else
    func createEquipment() {
        
    }
    #endif
}
