//
// ProblemDetails.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct ProblemDetails: Codable {

//    public var type: String?
//    public var title: String?
//    public var status: Int?
//    public var detail: String?
//    public var instance: String?
//    public var extensions: [String:Any]?
//
//    public init(type: String?, title: String?, status: Int?, detail: String?, instance: String?, extensions: [String:Any]?) {
//        self.type = type
//        self.title = title
//        self.status = status
//        self.detail = detail
//        self.instance = instance
//        self.extensions = extensions
//    }


    public var type: String?
    public var title: String?
    public var status: Int?
    public var detail: String?
    public var instance: String?

    public init(type: String?, title: String?, status: Int?, detail: String?, instance: String?) {
        self.type = type
        self.title = title
        self.status = status
        self.detail = detail
        self.instance = instance
    }
    
}

