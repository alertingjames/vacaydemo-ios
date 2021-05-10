//
//  SplashViewController.swift
//  VaCay
//
//  Created by Andre on 7/15/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit

class SplashViewController: BaseViewController {

    @IBOutlet weak var icon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        UserDefaults.standard.set("", forKey:"email")
//        UserDefaults.standard.set("", forKey:"password")
        
        icon.layer.cornerRadius = 60
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Code you want to be delayed
            
            let email = UserDefaults.standard.string(forKey: "email")
            let password = UserDefaults.standard.string(forKey: "password")
            
            if email?.count ?? 0 > 0 && password?.count ?? 0 > 0{
                self.login(email: email!, password: password!)
            }else{
                thisUser.idx = 0
                let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier:"LoginViewController")
                vc.modalPresentationStyle = .fullScreen
                self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
            }
        }
        
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
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController")
                    vc.modalPresentationStyle = .fullScreen
                    self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
                }
            }else if result_code == "1" {
                thisUser = user!
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddLocationViewController")
                vc.modalPresentationStyle = .fullScreen
                self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
            }else if result_code == "2" {
                thisUser = user!
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
                let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
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
                if let currentVC = UIApplication.getTopViewController() {
                    if currentVC != loginVC {
                        loginVC.modalPresentationStyle = .fullScreen
                        self.transitionVc(vc: loginVC, duration: 0.3, type: .fromRight)
                    }
                }
            }
        })
    }


}

