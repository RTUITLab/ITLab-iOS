//
// CreateEditShiftView.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

public struct CreateEditShiftView: Codable {

    public var _id: UUID?
    public var clientId: Int?
    public var beginTime: Date?
    public var endTime: Date?
    public var _description: String?
    public var places: [CreateEditPlaceView]?

    public init(_id: UUID?, clientId: Int?, beginTime: Date?, endTime: Date?, _description: String?, places: [CreateEditPlaceView]?) {
        self._id = _id
        self.clientId = clientId
        self.beginTime = beginTime
        self.endTime = endTime
        self._description = _description
        self.places = places
    }

    public enum CodingKeys: String, CodingKey {
        case _id = "id"
        case clientId
        case beginTime
        case endTime
        case _description = "description"
        case places
    }

}
