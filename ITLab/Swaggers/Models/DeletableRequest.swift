//
// DeletableRequest.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct DeletableRequest: Codable {

    public var delete: Bool?
    public var _id: UUID

    public init(delete: Bool?, _id: UUID) {
        self.delete = delete
        self._id = _id
    }

    public enum CodingKeys: String, CodingKey { 
        case delete
        case _id = "id"
    }

}

