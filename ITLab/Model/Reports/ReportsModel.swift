//
//  ReportsModel.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 25.05.2021.
//

import Foundation
 
struct ReportModel: Codable {
    var id: String
    var pinSender: String?
    var date: Date
    var text: String
    
    var approved: ReportApprovedModel?
    
    enum CodingKeys: String, CodingKey {
        case id
        case pinSender
        case date
        case text
      }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        pinSender = try? container.decode(String.self, forKey: .pinSender)
        text = try container.decode(String.self, forKey: .text)
        
        let dateString = try container.decode(String.self, forKey: .date)
        let dateFormat = DateFormatter()
        dateFormat.timeZone = .init(abbreviation: "GMT")
        dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let date = dateFormat.date(from: dateString) {
            self.date = date
        } else {
            date = Date()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(pinSender, forKey: .pinSender)
        
        let dateFormat = DateFormatter()
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        dateFormat.timeZone = .init(abbreviation: "GMT")
        dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let dateString = dateFormat.string(from: date)
        try container.encode(dateString, forKey: .date)
    }
}
