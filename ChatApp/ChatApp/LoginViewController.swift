//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Sophia Zhu on 8/30/21.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {

    // MARK: IBOutlets
    //labels
    @IBOutlet weak var emailLabelOutlet: UILabel!
    
    @IBOutlet weak var passwordLabelOutlet: UILabel!
    
    @IBOutlet weak var repeatPasswordLabel: UILabel!
    
    @IBOutlet weak var signUpLabel: UILabel!
    
    //textFields
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    //Buttons
    
    @IBOutlet weak var loginButtonOutlet: UIButton!
    
    
    
    @IBOutlet weak var signUpButtonOutlet: UIButton!
    
    @IBOutlet weak var resendEmailButtonOutlet: UIButton!
    
    
    //Views
    
    @IBOutlet weak var repeatPasswordLineView: UIView!
    
    
    // MARK: - Vars
    var isLogin = true
    
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUIfor(login: true)
        setupTextFieldDelegates()
    }
    
    // MARK: - IBActions
    
    @IBAction func loginButtonPressed(_ sender: Any) {
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
    }
    
    @IBAction func resendEmailButtonPressed(_ sender: Any) {
    }
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        updateUIfor(login: sender.titleLabel?.text == "Login")
        isLogin.toggle()
    }
    
    // MARK: - Setup
    
    private func setupTextFieldDelegates() {
        emailTextField.addTarget(self, action: #selector(textFieldChange(_ :)), for: .editingChanged) //whenever is typed, action changed
        
        passwordTextField.addTarget(self, action: #selector(textFieldChange(_ :)), for: .editingChanged) //whenever is typed, action changed
        
        repeatPasswordTextField.addTarget(self, action: #selector(textFieldChange(_ :)), for: .editingChanged) //whenever is typed, action changed
        
    }
    
    @objc func textFieldChange(_ textField: UITextField) {
        
        print("changing text field")
        updatePlaceholderLabels(textField: textField)
    }

    // MARK: - Animation
    
    private func updateUIfor(login: Bool) {
        
        loginButtonOutlet.setImage(UIImage(named: login ? "loginBtn" : "registerBtn"), for: .normal)// based on login flag choose register or login
        
        signUpButtonOutlet.setTitle(login ? "Signup" : "Login", for: .normal)
        
        signUpLabel.text = login ? "Don't have an account?" : "Have an account?"
        
        UIView.animate(withDuration: 0.5) {
            self.repeatPasswordTextField.isHidden = login
            self.repeatPasswordLabel.isHidden = login
            self.repeatPasswordLineView.isHidden = login
        }
        
    }
    
    
    
    private func updatePlaceholderLabels(textField: UITextField) {
        
        switch textField {
        case emailTextField:
            emailLabelOutlet.text = textField.hasText ? "Email" : ""
        case passwordTextField:
            passwordLabelOutlet.text = textField.hasText ? "Password" : ""

        default:
            repeatPasswordLabel.text = textField.hasText ? "Repeat Password" : ""
        
        }
    }
    
}

