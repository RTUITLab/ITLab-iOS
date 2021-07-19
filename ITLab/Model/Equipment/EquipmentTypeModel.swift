//
//  EquipmentTypeModel.swift
//  ITLab
//
//  Created by Даниил on 10.07.2021.
//

import Foundation

struct EquipmentTypeModel: Codable {
    var id: String
    var title: String
    var description: String
    var shortTitle: String?
    var rootId: String?
    var parentId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case shortTitle
        case rootId
        case parentId
    }
    
    init(id: String, title: String, description: String, shortTitle: String? = nil, rootId: String? = nil, parentId: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.shortTitle = shortTitle
        self.rootId = rootId
        self.parentId = parentId
    }
    
    init() {
        self.id = ""
        self.title = ""
        self.description = ""
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        shortTitle = try? container.decode(String.self, forKey: .shortTitle)
        rootId = try? container.decode(String.self, forKey: .rootId)
        parentId = try? container.decode(String.self, forKey: .parentId)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(shortTitle, forKey: .shortTitle)
        try container.encode(rootId, forKey: .rootId)
        try container.encode(parentId, forKey: .parentId)
    }
}
