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
    
    private var appAuthInteraction : AppAuthInteraction?
    
    public func getAccsesToken() -> String{
        return self.appAuthInteraction?.getAuthState()?.lastTokenResponse?.accessToken ?? ""
    }
    
    public func isAuthorize() -> Bool {
        return self.appAuthInteraction?.getAuthState()?.isAuthorized ?? false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.appAuthInteraction = AppAuthInteraction(view: self)
        
        appAuthInteraction?.loadState()
        appAuthInteraction?.stateChanged()
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if((appAuthInteraction?.getAuthState()?.isAuthorized) ?? false)
        {
            self.logIn()
        }
        
    }
}

extension AuthorizeController {
    
    @IBAction func authWithAutoCodeExchange(_ sender: UIButton) {

        self.appAuthInteraction?.authorization()
    }
}

extension AuthorizeController {
    
    public func logOut() {
        
        self.dismiss(animated: true, completion: nil)
        self.appAuthInteraction?.logOut()
    }
    
    func logIn() {
        let menuView = UIHostingController(rootView: MainMenu())
        
        menuView.modalPresentationStyle = .fullScreen
        
        self.present(menuView, animated: false, completion: nil)
    }
}

