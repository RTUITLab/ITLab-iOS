//
// ShiftView.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

public struct ShiftView: Codable {

    public var _id: UUID?
    public var beginTime: Date?
    public var endTime: Date?
    public var _description: String?
    public var places: [PlaceView]?

    public init(_id: UUID?, beginTime: Date?, endTime: Date?, _description: String?, places: [PlaceView]?) {
        self._id = _id
        self.beginTime = beginTime
        self.endTime = endTime
        self._description = _description
        self.places = places
    }

    public enum CodingKeys: String, CodingKey {
        case _id = "id"
        case beginTime
        case endTime
        case _description = "description"
        case places
    }

}
