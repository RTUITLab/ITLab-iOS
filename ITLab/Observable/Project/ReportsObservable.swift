//
//  ReportsObservable.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 25.05.2021.
//

import SwiftUI
import Alamofire

final class ReportsObservable: ObservableObject {
    @Published var reportsModel: [ReportModel] = []
    @Published var loadingReports: Bool = false
    
    func getReports() {
        loadingReports = true
        
        print(SwaggerClientAPI.getURL())
        AF.request("\(SwaggerClientAPI.getURL())/api/reports", method: .get, headers: .init(SwaggerClientAPI.customHeaders))
            .validate()
            .responseDecodable(of: [ReportModel].self) { response in
                switch response.result {
                case .success(let reports):
                    
                    print(reports.count)
                    self.reportsModel = reports
                case .failure(let error):
                    print(error)
                }
                
                self.loadingReports.toggle()
            }
    }
}
