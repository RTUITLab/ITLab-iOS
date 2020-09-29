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

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.appAuthInteraction = AppAuthInteraction()
        
        appAuthInteraction?.loadState()
        appAuthInteraction?.stateChanged()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let menuView = MainMenu()
        
        self.appAuthInteraction = AppAuthInteraction(view: self, newView: UIHostingController(rootView: menuView), openNewView: true)
        
        if (AppAuthInteraction.getAuthState()?.isAuthorized ?? false)
        {
            appAuthInteraction?.openMenu()
        }
    }
}

extension AuthorizeController {
    
    @IBAction func authWithAutoCodeExchange(_ sender: UIButton) {

        self.appAuthInteraction?.authorization()
    }
}

