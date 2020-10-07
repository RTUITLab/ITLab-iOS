//
//  EventsPage.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 06.10.2020.
//

import SwiftUI

struct EventsPage: View {
    @State var events : [CompactEventView]?
    
    var body: some View {
        NavigationView {
            
            List(events ?? []) { event in
                Text(event.title ?? "Not title")
            }
            .navigationTitle("События")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button(action: {
               
            }) {
                Image(systemName: "plus")
            }.onAppear{
                getEvents()
            }
            )
        }
    }
    
    func getEvents()
    {
        ITLabApp.authorizeController.performAction { (token, _, _) in
            SwaggerClientAPI.customHeaders = ["Authorization" : "Bearer \(token ?? "")"]
            EventAPI.apiEventGet { (events, error) in
                self.events = events
            }
        }
    }
    
    func test()
    {
        
        ITLabApp.authorizeController.performAction { (accessToken, idToken, error) in
            
            guard let accessToken = accessToken else {
                print("not token")
                return
            }
            
            guard let url = URL(string: "https://dev.rtuitlab.ru/api/event") else { return }
            var urlReq = URLRequest(url: url)
            urlReq.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: urlReq) { (data, response, error) in
                DispatchQueue.main.async {
                    
                    guard let response = response as? HTTPURLResponse else {
                        print("Non-HTTP response")
                        return
                    }
                    
                    guard let data = data else {
                        print("HTTP response data is empty")
                        return
                    }
                    
                    print(response.statusCode)
                    print(String(data: data, encoding: String.Encoding.utf8))
                   
                }
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
