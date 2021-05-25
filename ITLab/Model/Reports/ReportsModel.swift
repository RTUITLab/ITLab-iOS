//
//  ReportsModel.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 25.05.2021.
//

import Foundation
 
struct ReportModel: Codable {
    var id: UUID?
    var pinSender: String?
    var date: String?
    var text: String?
}
