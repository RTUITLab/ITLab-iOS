//
//  UserObservable.swift
//  ITLab
//
//  Created by Даня Демин on 12.07.2021.
//

import Foundation
import SwiftUI

final class UserObservable: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var user: UserView? = nil
    
    #if targetEnvironment(simulator)
    func getUser(userId: String) {
        if userId == "some_user_id_1" {
            self.user = UserView(
                _id: UUID(),
                firstName: "UserName",
                lastName: "LastName",
                middleName: nil,
                phoneNumber: nil,
                email: "some_email",
                properties: nil
            )
        }
    }
    #else
    func getUser(userId: String) {
        // Api stuff
    }
    #endif
    
    func getFullName() -> String? {
        if user?.firstName == nil || user?.lastName == nil {
            return nil
        } else {
            return "\(user?.firstName!) \(user?.lastName)"
        }
    }
    
    func getFullNameWithEmail() -> String? {
        let fullName = self.getFullName()
        
        if fullName == nil || user?.email == nil {
            return nil
        } else {
            return "\(fullName), \(user?.email)"
        }
    }
}
