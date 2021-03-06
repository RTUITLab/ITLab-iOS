//
// EquipmentCreateRequest.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

public struct EquipmentCreateRequest: Codable {

    public var serialNumber: String?
    public var equipmentTypeId: UUID?
    public var _description: String?
    public var children: [UUID]?

    public init(serialNumber: String?, equipmentTypeId: UUID?, _description: String?, children: [UUID]?) {
        self.serialNumber = serialNumber
        self.equipmentTypeId = equipmentTypeId
        self._description = _description
        self.children = children
    }

    public enum CodingKeys: String, CodingKey {
        case serialNumber
        case equipmentTypeId
        case _description = "description"
        case children
    }

}
