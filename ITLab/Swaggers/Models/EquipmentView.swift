//
// EquipmentView.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct EquipmentView: Codable {

    public var _id: UUID?
    public var serialNumber: String?
    public var _description: String?
    public var number: Int?
    public var equipmentType: CompactEquipmentTypeView?
    public var equipmentTypeId: UUID?
    public var ownerId: UUID?
    public var parentId: UUID?
    public var children: [EquipmentView]?

    public init(_id: UUID?, serialNumber: String?, _description: String?, number: Int?, equipmentType: CompactEquipmentTypeView?, equipmentTypeId: UUID?, ownerId: UUID?, parentId: UUID?, children: [EquipmentView]?) {
        self._id = _id
        self.serialNumber = serialNumber
        self._description = _description
        self.number = number
        self.equipmentType = equipmentType
        self.equipmentTypeId = equipmentTypeId
        self.ownerId = ownerId
        self.parentId = parentId
        self.children = children
    }

    public enum CodingKeys: String, CodingKey { 
        case _id = "id"
        case serialNumber
        case _description = "description"
        case number
        case equipmentType
        case equipmentTypeId
        case ownerId
        case parentId
        case children
    }

}
