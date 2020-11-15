//
//  UsersListPage.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 10/28/20.
//

import SwiftUI
import UIKit

extension UIApplication {
    func addTapGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true // set to `false` if you don't want to detect tap during other gestures
    }
}

struct SearchBar: UIViewRepresentable {
    
    @Binding var text: String
    
    class Coordinator: NSObject, UISearchBarDelegate {
        
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
    }
    
    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.placeholder = "Поиск пользователя"
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}


struct UsersListPage: View {
    @State var isLoading: Bool = true
    @State var users: [UserView] = []
    @State var userSearch: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    if isLoading {
                        GeometryReader() { g in
                            ProgressView()
                                .frame(width: g.size.width, height: g.size.height, alignment: .center)
                        }
                    } else {
                        Section(header: SearchBar(text: $userSearch)) {
                            ForEach(self.users.filter {
                                self.userSearch.isEmpty ? true : "\($0.lastName ?? "") \($0.firstName ?? "") \($0.middleName ?? "")".lowercased().contains(self.userSearch.lowercased())
                            }, id: \._id) { user in
                                UserStack(user: user)
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                
            }
            .navigationTitle("Пользователи")
            .navigationBarTitleDisplayMode(.automatic)
            .onAppear() {
                getUsers()
                UIApplication.shared.addTapGestureRecognizer()
            }
        }
    }
    
    func getUsers() {
        AppAuthInteraction.shared.performAction { (token, _) in
            
            UserAPI.apiUserGet(count: -1) { (users, error) in
                if let error = error {
                    print(error)
                    self.isLoading = false
                    return
                }
                
                guard let users = users else {
                    print("Not data")
                    self.isLoading = false
                    return
                }
                DispatchQueue.main.async {
                    self.users =  users.filter {$0.lastName != nil}
                    self.users.sort { (a, b) -> Bool in
                        a.lastName ?? "" < b.lastName ?? ""
                    }
                    self.isLoading = false
                }
            }
        }
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
                    
                    
                    HStack (alignment: .center) {
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

struct UsersListPage_Previews: PreviewProvider {
    static var previews: some View {
        UsersListPage()
    }
}
