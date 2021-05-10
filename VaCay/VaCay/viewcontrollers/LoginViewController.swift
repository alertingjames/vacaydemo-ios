//
//  LoginViewController.swift
//  VaCay
//
//  Created by Andre on 7/19/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit

class LoginViewController: BaseViewController {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var view_email: UIView!
    @IBOutlet weak var emailBox: UITextField!
    @IBOutlet weak var view_password: UIView!
    @IBOutlet weak var passwordBox: UITextField!
    @IBOutlet weak var showButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    var show = UIImage(named: "eyeunlock")
    var unshow = UIImage(named: "eyelock")
    var showF = false
    
    let attrs: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: "Comfortaa-Medium", size: 17.0)!,
        .foregroundColor: primaryColor,
        .underlineStyle: NSUnderlineStyle.single.rawValue
    ]
    

    override func viewDidLoad() {
        super.viewDidLoad()

        logo.layer.cornerRadius = 50
        
        let attributeString = NSMutableAttributedString(string: "Forgot Password",
                                                        attributes: attrs)
        forgotPasswordButton.setAttributedTitle(attributeString, for: .normal)
        
        setRoundShadowView(view: view_email, corner: 25)
        setRoundShadowView(view: view_password, corner: 25)
        setRoundShadowButton(button: loginButton, corner: 25)
        setRoundShadowButton(button: signupButton, corner: 25)
        
        emailBox.keyboardType = UIKeyboardType.emailAddress
        
        
        
    }
    
    @IBAction func toForgotPassword(_ sender: Any) {
        print("Clicked on ForgotPassword button")
        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier:"ForgotPasswordViewController")
        vc.modalPresentationStyle = .fullScreen
        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
    }
    
    @IBAction func toggle(_ sender: Any) {
        if showF == false{
            showButton.setImage(unshow, for: UIControl.State.normal)
            showF = true
            passwordBox.isSecureTextEntry = false
        }else{
            showButton.setImage(show, for: UIControl.State.normal)
            showF = false
            passwordBox.isSecureTextEntry = true
        }
    }
    
    @IBAction func login(_ sender: Any) {
        if emailBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            showToast(msg: "Enter your email")
            return
        }
        
        if isValidEmail(testStr: (emailBox.text?.trimmingCharacters(in: .whitespacesAndNewlines))!) == false{
            showToast(msg: "Please enter a valid email.")
            return
        }
        
        if passwordBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            showToast(msg: "Enter your password")
            return
        }
        
        login(email: emailBox.text!, password: passwordBox.text!)
    }
    
    
    
    func login(email:String, password: String)
    {
        showLoadingView()
        APIs.login(email: email, password: password, handleCallback:{
            user, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                thisUser = user!
                UserDefaults.standard.set(thisUser.email, forKey: "email")
                UserDefaults.standard.set(thisUser.password, forKey: "password")
                if thisUser.status2.count == 0 {
                    gNote = "Please read the Terms & Conditions."
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TermsViewController")
                    vc.modalPresentationStyle = .fullScreen
                    self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
                }else{
                    gNote = "Successfully logged in"
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController")
                    vc.modalPresentationStyle = .fullScreen
                    self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
                }
            }else if result_code == "1" {
                thisUser = user!
                gNote = "Please add your location"
                UserDefaults.standard.set(thisUser.email, forKey: "email")
                UserDefaults.standard.set(thisUser.password, forKey: "password")
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddLocationViewController")
                vc.modalPresentationStyle = .fullScreen
                self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
            }else if result_code == "2" {
                thisUser = user!
                UserDefaults.standard.set(thisUser.email, forKey: "email")
                UserDefaults.standard.set(thisUser.password, forKey: "password")
                if thisUser.status2.count == 0 {
                    gNote = "Please read the Terms & Conditions."
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TermsViewController")
                    vc.modalPresentationStyle = .fullScreen
                    self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
                }else{
                    gNote = "Please register your profile"
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignupViewController")
                    vc.modalPresentationStyle = .fullScreen
                    self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
                }
            }else{
                if result_code == "3" {
                    thisUser.idx = 0
                    self.showToast(msg: "Your password is incorrect.")
                }else if result_code == "4" {
                    thisUser.idx = 0
                    self.showToast(msg: "This user doen\'t exist.")
                }else {
                    thisUser.idx = 0
                    self.showToast(msg: "Something wrong!")
                }
            }
        })
    }
    
    @IBAction func toSignup(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignupViewController")
        vc.modalPresentationStyle = .fullScreen
        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
    }
    
}
