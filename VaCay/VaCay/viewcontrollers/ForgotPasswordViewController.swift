//
//  ForgotPasswordViewController.swift
//  VaCay
//
//  Created by Andre on 7/19/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: BaseViewController {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var view_email: UIView!
    @IBOutlet weak var emailBox: UITextField!
    @IBOutlet weak var submitButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        logo.layer.cornerRadius = 50
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 10
        
        let text = "Please enter your email.\nWe will send password reset link to your email."

        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont(name: "Comfortaa-Medium", size: 15.0)!,
            .foregroundColor: UIColor.black
        ]
        let attributedString = NSAttributedString(string: text, attributes: attributes)

        textView.attributedText = attributedString
        
        setRoundShadowView(view: view_email, corner: 25)
        setRoundShadowButton(button: submitButton, corner: 25)
        
        emailBox.keyboardType = UIKeyboardType.emailAddress
        
    }
    
    @IBAction func toLogin(_ sender: Any) {
        dismissViewController()
    }

    @IBAction func submit(_ sender: Any) {
        if emailBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            showToast(msg: "Enter your email")
            return
        }
        
        if isValidEmail(testStr: (emailBox.text?.trimmingCharacters(in: .whitespacesAndNewlines))!) == false{
            showToast(msg: "Please enter a valid email.")
            return
        }
        
        forgotPassword(email: emailBox.text!)
    }
    
    func forgotPassword(email:String)
    {
        showLoadingView()
        APIs.forgotPassword(email: email, handleCallback:{
            result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                self.showToast2(msg: "We've sent a password reset link to your email. Please check...")
                self.openMailBox(email: email)
            }else if result_code == "1"{
                self.showToast(msg: "Sorry, but we don\'t know your email.")
            }else {
                self.showToast(msg: "Something wrong")
            }
        })
    }
    
    func openMailBox(email:String){
        if let url = URL(string: "mailto:\(email)") {
          if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
          } else {
            UIApplication.shared.openURL(url)
          }
        }
    }
    
}
