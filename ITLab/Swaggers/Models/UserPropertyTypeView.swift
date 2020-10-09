//
// UserPropertyTypeView.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct UserPropertyTypeView: Codable {

    public var _id: UUID?
    public var title: String?
    public var _description: String?
    public var instancesCount: Int?
    public var isLocked: Bool?

    public init(_id: UUID?, title: String?, _description: String?, instancesCount: Int?, isLocked: Bool?) {
        self._id = _id
        self.title = title
        self._description = _description
        self.instancesCount = instancesCount
        self.isLocked = isLocked
    }

    public enum CodingKeys: String, CodingKey { 
        case _id = "id"
        case title
        case _description = "description"
        case instancesCount
        case isLocked
    }

}
