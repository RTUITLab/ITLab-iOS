//
//  ReportApprovedModel.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 25.05.2021.
//

import Foundation

struct ReportApprovedModel: Codable {
    var reportId: String
    var date: Date
    var description: String
    var count: Int
    
    enum CodingKeys: String, CodingKey {
        case date = "approved"
        case description
        case count
        case reportId
      }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        reportId = try container.decode(String.self, forKey: .reportId)
        count = try container.decode(Int.self, forKey: .count)
        description = try container.decode(String.self, forKey: .description)
        
        let dateString = try container.decode(String.self, forKey: .date)
        
        let dateFormat = DateFormatter()
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = dateFormat.date(from: dateString) {
            self.date = date
        } else {
            date = Date()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(reportId, forKey: .reportId)
        try container.encode(description, forKey: .description)
        try container.encode(count, forKey: .count)
        
        let dateFormat = DateFormatter()
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let dateString = dateFormat.string(from: date)
        try container.encode(dateString, forKey: .date)
    }
}
