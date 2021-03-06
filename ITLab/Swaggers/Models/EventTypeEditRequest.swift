//
// EventTypeEditRequest.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

public struct EventTypeEditRequest: Codable {

    public var title: String?
    public var _description: String?
    public var _id: UUID

    public init(title: String?, _description: String?, _id: UUID) {
        self.title = title
        self._description = _description
        self._id = _id
    }

    public enum CodingKeys: String, CodingKey {
        case title
        case _description = "description"
        case _id = "id"
    }

}
