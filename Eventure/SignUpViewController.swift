//
//  SignUpViewController.swift
//  Eventure
//
//  Created by Mukhamed Issa on 1/3/17.
//  Copyright © 2017 Mukhamed Issa. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftMessages

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func didSignUpButtonPressed(_ sender: UIButton) {
        
        
        if let email = emailTextField.text, let password = passwordTextField.text,
            let repeatPassword = repeatPasswordTextField.text {
    
            if password == repeatPassword {
                FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                    if let error = error {
                        self.showErrorView(errorDescription: error.localizedDescription)
                        return
                    } else {
                        self.showSuccessView()
                        self.navigationController?.popViewController(animated: true)
                    }
                })
            } else {
                self.showErrorView(errorDescription: "Passwords don't match")
            }
            
        } else {
            self.showErrorView(errorDescription: "E-mail or password can't be empty")
        }
    }
    
    func showErrorView(errorDescription: String) {
        let errorView = MessageView.viewFromNib(layout: .TabView)
        errorView.configureTheme(.error)
        errorView.button?.isHidden = true
        errorView.configureContent(title: "Error", body: errorDescription)
        var config = SwiftMessages.defaultConfig
        config.duration = .seconds(seconds: 10)
        
        SwiftMessages.show(config: config, view: errorView)
    }
    
    func showSuccessView() {
        let success = MessageView.viewFromNib(layout: .CardView)
        success.configureTheme(.success)
        success.configureDropShadow()
        success.configureContent(title: "Success", body: "You are successfully registered!")
        success.button?.isHidden = true
        var successConfig = SwiftMessages.defaultConfig
        successConfig.presentationStyle = .bottom
        successConfig.presentationContext = .window(windowLevel: UIWindowLevelNormal)
        
        SwiftMessages.show(config: successConfig, view: success)
    }
}
