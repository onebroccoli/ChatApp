//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Sophia Zhu on 8/30/21.
//

import Foundation
import UIKit
import ProgressHUD
import RealmSwift

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
    var isLogin: Bool = true //start project is true
    
    
    
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
            isLogin ? loginUser() : registerUser()
//            print("have data login/reg")
            
        } else {
            ProgressHUD.showFailed("All fields are required")
        }
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
        if isDataInputedFor(type: "password"){
            //reset password
            resetPassword()
            print("have data for forgot password")
            
        } else {
            ProgressHUD.showFailed("Email is required.")
        }
    }
    
    @IBAction func resendEmailButtonPressed(_ sender: Any) {
        if isDataInputedFor(type: "password"){
            //resend verification email
            resendVerificationEmail()
            print("have data for resend email")
        } else {
            ProgressHUD.showFailed("Email is required")
        }
    }
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        updateUIfor(login: sender.titleLabel?.text == "Login")
        isLogin.toggle() //切换bool value Toggles the Boolean variable’s value.
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
        view.endEditing(false) //disable the keyboard for anny view
    }
    
    
    // MARK: - Animation
    
    private func updateUIfor(login: Bool) {
        loginButtonOutlet.setImage(UIImage(named: login ? "loginBtn" : "registerBtn"), for: .normal)
        
        signUpButtonOutlet.setTitle(login ? "Login" : "Register", for: .normal);
//
        
//        signUpButtonOutlet.setTitle(login ? "Signup" : "Login", for: .normal)
//
        signUpLabel.text = login ? "Don't have an account?" : "Have an account?"
        
        //update for UI
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
    
    private func loginUser() {
        FirebaseUserListener.shared.loginUserWithEmail(email: emailTextField.text!, password: passwordTextField.text!) { (error, isEmailVerified) in
            //got to app
            if error == nil {
                if isEmailVerified {
                    self.goToApp()
//                    print(" user has logged in", User.currentUser?.email)
                } else {
                    ProgressHUD.showFailed("Please verify email.")
                    self.resendEmailButtonOutlet.isHidden = false
                }
            } else {
                ProgressHUD.showFailed(error!.localizedDescription)
            }
        }
        
        
    }
    
    
    private func registerUser() {
        if passwordTextField.text == repeatPasswordTextField.text! {
            FirebaseUserListener.shared.registerUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
                if error == nil {
                    ProgressHUD.showSuccess("Verification email sent")
                    self.resendEmailButtonOutlet.isHidden = false
                } else {
                    ProgressHUD.showFailed(error!.localizedDescription)
                    print(error!.localizedDescription)
                }
            }
        } else {
            ProgressHUD.showFailed("The passwords dont match")
        }
    }
    
    //
    private func resetPassword() {
        FirebaseUserListener.shared.resetPasswordFor(email: emailTextField.text!) { (error) in
            if error == nil {
                ProgressHUD.showSuccess("Reset link sent to email")
            } else {
                ProgressHUD.showFailed(error!.localizedDescription)
            }
        }
    }
    
    private func resendVerificationEmail() {
        FirebaseUserListener.shared.resendVerificationEmail(email: emailTextField.text!) { (error) in
            if error == nil {
                ProgressHUD.showSuccess("New verification email sent")
            } else {
                ProgressHUD.showFailed(error!.localizedDescription)
            }
        }
    }
    
//    private func resetPassword(){
//        FirebaseUserListener.shared.resetPasswordFor(email: emailTextField.text!) { (error) in
//
//            if error == nil {
//                ProgressHUD.showSuccess("Reset link sent to email.")
//
//            } else {
//                ProgressHUD.showFailed(error!.localizedDescription)
//            }
//        }
//
//    }
    
//    private func resendVerificationEmail() {
//        FirebaseUserListener.shared.resendVerificationEmail(email: emailTextField.text!) { (error) in
//            if error == nil {
//                ProgressHUD.showSuccess("New verification email sent")
//            } else {
//                ProgressHUD.showFailed(error!.localizedDescription)
//            }
//        }
//    }
    
    // MARK: -Navigation
    private func goToApp(){
        let mainView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MainView") as! UITabBarController
        
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true, completion: nil)
    }
    
//    print("user has logged in with email", User.currentUser?.email)
}

