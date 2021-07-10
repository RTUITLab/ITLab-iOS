//
//  EquipmentModel.swift
//  ITLab
//
//  Created by Даниил on 10.07.2021.
//

import Foundation

struct EquipmentModel {
    var id: String
    var serialNumber: String
    var description: String
    var number: Int
    var equipmentTypeId: String
    var equipmentType: EquipmentTypeModel
    var ownerId: String
    var parentId: String
}
