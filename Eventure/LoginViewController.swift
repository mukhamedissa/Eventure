//
//  LoginViewController.swift
//  Eventure
//
//  Created by Mukhamed Issa on 1/3/17.
//  Copyright © 2017 Mukhamed Issa. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftMessages

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didLoginButtonPressed(_ sender: UIButton) {
        let errorView = MessageView.viewFromNib(layout: .TabView)
        errorView.configureTheme(.error)
        errorView.button?.isHidden = true
        
        var config = SwiftMessages.defaultConfig
        config.duration = .seconds(seconds: 10)
        
        if let email = self.emailTextField.text, let password = self.passwordTextField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if let error = error {
                    errorView.configureContent(title: "Error", body: error.localizedDescription)
                    SwiftMessages.show(config: config, view: errorView)
                    return
                }
                self.navigationController?.popViewController(animated: true)
            })
        } else {
            errorView.configureContent(title: "Error", body: "email/password can't be empty")
            SwiftMessages.show(config: config, view: errorView)
        }
    }
}
