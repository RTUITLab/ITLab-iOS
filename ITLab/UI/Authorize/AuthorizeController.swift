//
//  AuthorizeController.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 28.09.2020.
//

import UIKit
import SwiftUI
import AppAuth

class AuthorizeController : UIViewController {
    
    @IBOutlet private weak var ClickButton: UIButton!
    @IBOutlet private weak var LoadingIndicator: UIActivityIndicatorView!
    
    public func isLoading(_ value:Bool) {
        LoadingIndicator.isHidden = !value;
        ClickButton.isHidden = value;
    }
    
    public static var shared : AuthorizeController?
    
    private var appAuthInteraction : AppAuthInteraction?
    
    struct UserInfo: Codable {
        let userId: UUID
        private var roles: [String:Bool] = ["CanEditEquipment": false,
                                           "CanEditEvent": false,
                                           "CanInviteToSystem": false,
                                           "Participant": false,
                                           "CanDeleteEventRole": false,
                                           "CanEditEquipmentOwner": false,
                                           "CanEditRoles": false,
                                           "CanEditEquipmentType": false,
                                           "CanEditEventType": false,
                                           "CanEditUserPropertyTypes": false]
        
        func getRole(_ key: String) ->  Bool {
            
            guard let index = roles.index(forKey: key) else {
                return false
            }
            
            return roles[index].value
        }
        
        public enum CodingKeys: String, CodingKey {
            case userId = "sub"
            case roles
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            userId = try container.decode(UUID.self, forKey: .userId)
            let roles: [String]? = try? container.decode([String].self, forKey: .roles)
            
            if let roles = roles {
                roles.forEach { (role) in
                    self.roles.updateValue(true, forKey: role)
                }
            } else {
                let role: String? = try? container.decode(String.self, forKey: .roles)
                
                if let role = role {
                    self.roles.updateValue(true, forKey: role)
                }
            }
        }
    }
    
    private var userInfo: UserInfo?
    
    public func getUserInfo() -> UserInfo? {
        return self.userInfo
    }
    
    public func getAccsesToken() -> String{
        return self.appAuthInteraction?.getAuthState()?.lastTokenResponse?.accessToken ?? ""
    }
    
    public func isAuthorize() -> Bool {
        return self.appAuthInteraction?.getAuthState()?.isAuthorized ?? false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AuthorizeController.shared = self
        self.appAuthInteraction = AppAuthInteraction(view: self)
        
        appAuthInteraction?.loadState()
        appAuthInteraction?.stateChanged()
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if((appAuthInteraction?.getAuthState()?.isAuthorized) ?? false)
        {
            self.logIn()
            return
        }
        self.isLoading(false)
        
       
    }
    
    public func alertError(_ message: String) {
        
        let alert = UIAlertController(title: "Ой, ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
}

extension AuthorizeController {
    
    @IBAction func authWithAutoCodeExchange(_ sender: UIButton) {
        self.isLoading(true)
        self.appAuthInteraction?.authorization()
    }
}

extension AuthorizeController {
    
    public func logOut() {
        
        self.dismiss(animated: true, completion: nil)
        self.isLoading(true)
        
        self.appAuthInteraction?.logOut()
    }
    
    func logIn() {
        getUserInfoReq() {
        let menuView = UIHostingController(rootView: MainMenu())
        
        menuView.modalPresentationStyle = .fullScreen
        
        self.present(menuView, animated: false, completion: nil)
        }
    }
    
    func performAction(freshTokens: @escaping OIDAuthStateAction)
    {
        appAuthInteraction?.getAuthState()?.performAction(freshTokens: freshTokens)
    }
    
    func getUserInfoReq(completion: @escaping () -> Void) {
        appAuthInteraction?.getAuthState()?.performAction(freshTokens: { (accessToken, _, error) in
            if error != nil  {
               print("Error fetching fresh tokens: \(error?.localizedDescription ?? "ERROR")")
                self.alertError("Error fetching fresh tokens: \(error?.localizedDescription ?? "ERROR")")
                self.isLoading(false)
                return
            }
            
            guard let accessToken = accessToken else {
                print("Error getting accessToken")
                self.alertError("Error getting accessToken")
                self.isLoading(false)
                return
            }
            
            guard let userinfoEndpoint = self.appAuthInteraction?.getAuthState()?.lastAuthorizationResponse.request.configuration.discoveryDocument?.userinfoEndpoint else {
                print("Userinfo endpoint not declared in discovery document")
                self.alertError("Userinfo endpoint not declared in discovery document")
                self.isLoading(false)
                return
            }
            
            var urlRequest = URLRequest(url: userinfoEndpoint)
            
            urlRequest.allHTTPHeaderFields = ["Authorization":"Bearer \(accessToken)"]
            
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                
                DispatchQueue.main.async { [self] in
                    
                    guard error == nil else {
                        print("HTTP request failed \(error?.localizedDescription ?? "ERROR")")
                        self.alertError("HTTP request failed \(error?.localizedDescription ?? "ERROR")")
                        self.isLoading(false)
                        return
                    }

                    guard let response = response as? HTTPURLResponse else {
                        print("Non-HTTP response")
                        self.alertError("Non-HTTP response")
                        self.isLoading(false)
                        return
                    }

                    guard let data = data else {
                        print("HTTP response data is empty")
                        self.alertError("HTTP response data is empty")
                        self.isLoading(false)
                        return
                    }

                    var json: [AnyHashable: Any]?

                    do {
                        json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    } catch {
                        print("JSON Serialization Error")
                        self.alertError("JSON Serialization Error")
                        self.isLoading(false)
                    }
                    
                    if response.statusCode != 200 {
                        // server replied with an error
                        let responseText: String? = String(data: data, encoding: String.Encoding.utf8)
                        
                        if response.statusCode == 401 {
                            // "401 Unauthorized" generally indicates there is an issue with the authorization
                            // grant. Puts OIDAuthState into an error state.
                            let oauthError = OIDErrorUtilities.resourceServerAuthorizationError(withCode: 0,
                                                                                                errorResponse: json,
                                                                                                underlyingError: error)
                            self.appAuthInteraction?.getAuthState()?.update(withAuthorizationError: oauthError)
                            print("Authorization Error (\(oauthError)). Response: \(responseText ?? "RESPONSE_TEXT")")
                            self.alertError("Authorization Error (\(oauthError)). Response: \(responseText ?? "RESPONSE_TEXT")")
                        } else {
                            print("HTTP: \(response.statusCode), Response: \(responseText ?? "RESPONSE_TEXT")")
                            self.alertError("HTTP: \(response.statusCode), Response: \(responseText ?? "RESPONSE_TEXT")")
                        }
                        self.isLoading(false)
                        return
                    }
                        
                    guard let user: UserInfo = try? JSONDecoder().decode(UserInfo.self, from: data) else {
                        print("JSON serialization error in UserInfo")
                        self.alertError("JSON serialization error in UserInfo")
                        self.isLoading(false)
                        return
                    }
                        self.userInfo = user
                    completion()
                }
            }
            
            task.resume()
        })
    }
}

