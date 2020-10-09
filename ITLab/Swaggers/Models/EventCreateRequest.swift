//
// EventCreateRequest.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct EventCreateRequest: Codable {

    public var title: String
    public var address: String
    public var eventTypeId: UUID
    public var _description: String?
    public var shifts: [ShiftCreateRequest]?

    public init(title: String, address: String, eventTypeId: UUID, _description: String?, shifts: [ShiftCreateRequest]?) {
        self.title = title
        self.address = address
        self.eventTypeId = eventTypeId
        self._description = _description
        self.shifts = shifts
    }

    public enum CodingKeys: String, CodingKey { 
        case title
        case address
        case eventTypeId
        case _description = "description"
        case shifts
    }

}
