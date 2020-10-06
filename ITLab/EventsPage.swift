//
//  EventsPage.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 06.10.2020.
//

import SwiftUI

struct EventsPage: View {
    var body: some View {
        NavigationView {
            
            List {
                Text("Event")
                Text("Event")
            }
            .navigationTitle("События")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button(action: {
                test()
            }) {
                Image(systemName: "plus")
            }
            )
        }
    }
    
    func test()
    {
        ITLabApp.authorizeController.performAction { (accessToken, idToken, error) in
            
            guard let url = URL(string: "https://dev.rtuitlab.ru/events") else { return }
            var urlReq = URLRequest(url: url)
            urlReq.addValue("Authorization", forHTTPHeaderField: "Bearer \(accessToken)")
            
            URLSession.shared.dataTask(with: urlReq) { (data, response, error) in
                
                guard let response = response as? HTTPURLResponse else {
                    print("Non-HTTP response")
                    return
                }

                guard let data = data else {
                    print("HTTP response data is empty")
                    return
                }
                
                print(response.statusCode)
                print(data)
            }
            .resume()
        }
    }
}

struct EventsPage_Previews: PreviewProvider {
    static var previews: some View {
        EventsPage()
    }
}
