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
        AF.request("\(SwaggerClientAPI.getURL())/api/reports?sorted_by=date",
                   method: .get,
                   headers: .init(SwaggerClientAPI.customHeaders))
            .validate()
            .responseDecodable(of: [ReportModel].self) { response in
                switch response.result {
                case .success(let reports):
                    self.reportsModel = reports
                    
                    self.getReportApproved()
                    
                case .failure(let error):
                    print(error)
                    self.loadingReports.toggle()
                }
            }
    }
    
    private func getReportApproved() {
        AF.request("\(SwaggerClientAPI.getURL())/api/salary/v1/report/user/\(OAuthITLab.shared.getUserInfo()!.userId)",
                   method: .get,
                   headers: .init(SwaggerClientAPI.customHeaders))
            .validate()
            .responseDecodable(of: [ReportApprovedModel].self) { responseSalary in
                switch responseSalary.result {
                case .success(let reportsApproved):
                    reportsApproved.forEach { reportApproved in
                        if let index = self.reportsModel.firstIndex(where: { report in
                            return report.id == reportApproved.reportId
                        }) {
                            self.reportsModel[index].approved = reportApproved
                        }
                    }
                    
                case .failure(let error):
                    print(error)
                }
                
                self.loadingReports.toggle()
            }
    }
}
