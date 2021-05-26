//
//  UsersListPage.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 10/28/20.
//

import SwiftUI
import Combine
import UIKit

struct UsersListPage: View {
    @ObservedObject private var usersList = UsersListObservable()
    @State var userSearch: String = ""

    var body: some View {
        NavigationView {
            List {
                if usersList.isLoading {
                    GeometryReader { geometry in
                        ProgressView()
                                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                    }
                } else {
                    Section(header: SearchBar(text: $userSearch)) {
                        ForEach(usersList.users.filter {
                            self.userSearch.isEmpty ? true : "\($0.lastName ?? "") \($0.firstName ?? "") \($0.middleName ?? "")"
                                .lowercased().contains(self.userSearch.lowercased())
                        }, id: \._id) { user in
                            UserStack(user: user)
                        }
                    }
                }
            }
                    .listStyle(GroupedListStyle())

                    .navigationBarTitle("Пользователи", displayMode: .automatic)
                    .onAppear {
                        UIApplication.shared.addTapGestureRecognizer()
                    }
        }
                .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func loadingData() {
        usersList.getUsers()
    }
}

extension UsersListPage {
    struct UserStack: View {
        @State var user: UserView

        var body: some View {
            NavigationLink(destination: UserPage(user: self.user)) {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text("\(user.lastName ?? "") \(user.firstName ?? "")")
                                .font(.title3)
                                .fontWeight(.bold)
                        if let middleName = user.middleName {
                            if !middleName.isEmpty {
                                Text(middleName)
                                        .font(.title3)
                                        .fontWeight(.bold)
                            }
                        }
                    }
                            .padding(.top, 10)
                            .padding(.bottom, 5)

                    HStack(alignment: .center) {
                        VStack(alignment: .center, spacing: 10) {
                            if user.email != nil {
                                Image(systemName: "envelope.fill")
                                        .foregroundColor(.gray)
                                        .opacity(0.5)
                                        .padding(.top, 3)
                            }

                            if user.phoneNumber != nil {
                                Image(systemName: "phone.circle.fill")
                                        .foregroundColor(.gray)
                                        .opacity(0.5)
                                        .padding(.top, 1)
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            if let email = user.email {
                                Text(email)
                            }

                            if let phone = user.phoneNumber {
                                Text(phone)
                            }
                        }
                    }
                            .padding(.bottom, 10)
                }
            }
                    .buttonStyle(PlainButtonStyle())
        }
    }
}
