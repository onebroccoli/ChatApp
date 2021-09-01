//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Sophia Zhu on 8/30/21.
//

import Foundation
import UIKit
import ProgressHUD

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
        setupBackgroundTap()
    }
    
    // MARK: - IBActions
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        //login or resgister
        if isDataInputedFor(type: isLogin ? "login" : "register") {
            //login or register
            print("have data login/reg")
            
        } else {
            ProgressHUD.showFailed("All fields are required")
        }
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
        if isDataInputedFor(type: "password"){
            //reset password
            print("have data for forgot password")
            
        } else {
            ProgressHUD.showFailed("Email is required.")
        }
    }
    
    @IBAction func resendEmailButtonPressed(_ sender: Any) {
        if isDataInputedFor(type: "password"){
            //resend verification email
            print("have data for resend email")
        } else {
            ProgressHUD.showFailed("Email is required")
        }
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
    
    // whenever user type on the screen, need to show keyboard
    private func setupBackgroundTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func backgroundTap() {
//        print ("background tap")
        view.endEditing(false)
    }
    
    
    // MARK: - Animation
    
    private func updateUIfor(login: Bool) {
        
        loginButtonOutlet.setTitle(login ? "Login" : "Register", for: .normal);
//
        
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
    
    // MARK: - Helpers
    private func isDataInputedFor(type: String) -> Bool {
        
        switch type {
        case "login":
            return emailTextField.text != "" && passwordTextField.text != ""
        case "registration":
            return emailTextField.text != "" && passwordTextField.text != "" && repeatPasswordTextField.text != ""
        default:
            return emailTextField.text != ""
            
        }
    }
    
}

