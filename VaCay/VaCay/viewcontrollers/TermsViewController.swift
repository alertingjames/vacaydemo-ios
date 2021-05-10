//
//  TermsViewController.swift
//  VaCay
//
//  Created by Andre on 9/14/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit

class TermsViewController: BaseViewController {
    
    @IBOutlet weak var textBox: UITextView!
    @IBOutlet weak var agreeButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if gNote != ""{
            showToast(msg: gNote)
            gNote = ""
        }

        setRoundShadowButton(button: agreeButton, corner: agreeButton.frame.height / 2)
        textBox.text = "Thank you for signing up for VaCay!\n\n***By signing up to VaCay, you are agreeing to not engage in any type of:***\n\n"
        textBox.text = textBox.text + "- hate speech\n\n- cyberbullying\n\n- solicitation and/or selling of goods or services\n\n- posting content inappropriate for our diverse community including but not limited to political or religious views\n\n"
        textBox.text = textBox.text + "We want VaCay to be a safe place for support and inspiration. Help us foster this community and please respect everyone on VACAY.\n\n"
        textBox.text = textBox.text + "If you find any content abusive or violationg the terms, please report it to the VaCay Administrator.\n\n"
        textBox.text = textBox.text + "Thank you and enjoy your VACAY All Days!"
        
    }
    
    @IBAction func agreeTerms(_ sender: Any) {
        self.showLoadingView()
        APIs.readTerms(member_id: thisUser.idx, handleCallback: {
            result in
            self.dismissLoadingView()
            if result == "0" {
                thisUser.status2 = "read_terms"
                if thisUser.registered_time.count == 0 {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignupViewController")
                    vc.modalPresentationStyle = .fullScreen
                    self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
                }else if thisUser.address.count == 0 {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddLocationViewController")
                    vc.modalPresentationStyle = .fullScreen
                    self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
                }else{
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController")
                    vc.modalPresentationStyle = .fullScreen
                    self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
                }
            }
        })
    }
    
}
