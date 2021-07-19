//
//  EquipmentModel.swift
//  ITLab
//
//  Created by Даниил on 10.07.2021.
//

import Foundation

struct EquipmentModel: Codable {
    var id: String
    var serialNumber: String
    var description: String?
    var number: Int
    var equipmentTypeId: String
    var equipmentType: EquipmentTypeModel
    var ownerId: String?
    var parentId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case serialNumber
        case description
        case number
        case equipmentTypeId
        case equipmentType
        case ownerId
        case parentId
    }
    
    init(id: String, serialNumber: String, description: String? = nil, number: Int, equipmentTypeId: String, equipmentType: EquipmentTypeModel, ownerId: String? = nil, parentId: String? = nil) {
        self.id = id
        self.serialNumber = serialNumber
        self.description = description
        self.number = number
        self.equipmentTypeId = equipmentTypeId
        self.equipmentType = equipmentType
        self.ownerId = ownerId
        self.parentId = parentId
    }
    
    init(serialNumber: String, equipmentTypeID: String) {
        self.id = ""
        self.serialNumber = serialNumber
        self.description = ""
        self.equipmentTypeId = equipmentTypeID
        self.number = 0
        self.equipmentType = EquipmentTypeModel()
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        serialNumber = try container.decode(String.self, forKey: .serialNumber)
        description = try? container.decode(String.self, forKey: .description)
        number = try container.decode(Int.self, forKey: .number)
        equipmentTypeId = try container.decode(String.self, forKey: .equipmentTypeId)
        equipmentType = try container.decode(EquipmentTypeModel.self, forKey: .equipmentType)
        ownerId = try? container.decode(String.self, forKey: .ownerId)
        parentId = try? container.decode(String.self, forKey: .parentId)
    }
    
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(serialNumber, forKey: .serialNumber)
        try container.encode(description, forKey: .description)
        try container.encode(number, forKey: .number)
        try container.encode(equipmentTypeId, forKey: .equipmentTypeId)
        try container.encode(equipmentType, forKey: .equipmentType)
        try container.encode(ownerId, forKey: .ownerId)
        try container.encode(parentId, forKey: .parentId)
    }
}
