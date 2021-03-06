//
// EquipmentTypeView.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

public struct EquipmentTypeView: Codable {

    public var _id: UUID?
    public var title: String?
    public var _description: String?
    public var shortTitle: String?
    public var rootId: UUID?
    public var parentId: UUID?
    public var children: [EquipmentTypeView]?

    public init(_id: UUID?, title: String?, _description: String?, shortTitle: String?, rootId: UUID?, parentId: UUID?, children: [EquipmentTypeView]?) {
        self._id = _id
        self.title = title
        self._description = _description
        self.shortTitle = shortTitle
        self.rootId = rootId
        self.parentId = parentId
        self.children = children
    }

    public enum CodingKeys: String, CodingKey {
        case _id = "id"
        case title
        case _description = "description"
        case shortTitle
        case rootId
        case parentId
        case children
    }

}
