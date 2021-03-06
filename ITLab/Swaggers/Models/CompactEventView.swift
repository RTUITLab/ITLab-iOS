//
// CompactEventView.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

public struct CompactEventView: Codable, Identifiable {

    public var id: UUID?
    public var title: String?
    public var eventType: EventTypeView?
    public var beginTime: Date?
    public var endTime: Date?
    public var address: String?
    public var shiftsCount: Int?
    public var currentParticipantsCount: Int?
    public var targetParticipantsCount: Int?
    public var participating: Bool?

    public init(id: UUID?, title: String?, eventType: EventTypeView?, beginTime: Date?, endTime: Date?, address: String?, shiftsCount: Int?, currentParticipantsCount: Int?, targetParticipantsCount: Int?, participating: Bool?) {
        self.id = id
        self.title = title
        self.eventType = eventType
        self.beginTime = beginTime
        self.endTime = endTime
        self.address = address
        self.shiftsCount = shiftsCount
        self.currentParticipantsCount = currentParticipantsCount
        self.targetParticipantsCount = targetParticipantsCount
        self.participating = participating
    }

    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case title
        case eventType
        case beginTime
        case endTime
        case address
        case shiftsCount
        case currentParticipantsCount
        case targetParticipantsCount
        case participating
    }

}
