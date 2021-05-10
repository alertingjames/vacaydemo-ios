//
//  InputDialog.swift
//  VaCay
//
//  Created by Andre on 8/18/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit

class InputDialog: BaseViewController {

    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var titleBox: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var inputBox: UITextField!
    
    var index:Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        alertView.layer.cornerRadius = 8
        header.roundCorners(corners: [.topLeft, .topRight], radius: 8.0)
        
        inputBox.layer.cornerRadius = 5
        inputBox.layer.borderColor = UIColor.gray.cgColor
        inputBox.layer.borderWidth = 1.5
        
        let blurFx = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurFxView = UIVisualEffectView(effect: blurFx)
        blurFxView.frame = view.bounds
        blurFxView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(blurFxView, at: 0)
        
        alertView.alpha = 0
        
        UIView.animate(withDuration: 0.8) {
            self.alertView.alpha = 1.0
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissAlert))
        self.view.addGestureRecognizer(tap)
        
    }
    
    @objc func dismissAlert() {
        dismissAlertDialog()
    }

    @IBAction func tapButton(_ sender: Any) {
        if index == 0{
            if inputBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                return
            }
            
            if inputBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) != gConference.code {
                self.showToast(msg: "Your code is incorrect. Please try another one.")
                return
            }
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LiveVideoConfViewController")
            self.modalPresentationStyle = .fullScreen
            self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
            
        }else if index == 1{
            if inputBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                return
            }
            if gWeatherViewController != nil {
                isWeatherLocationChanged = true
                gWeatherViewController.newCityName = inputBox.text!
                gWeatherViewController.newLocation = nil
                gWeatherViewController.getWeatherData3(city: inputBox.text!, scale: TemperatureScale.celsius)
            }
        }else if index == 2{
            if inputBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                return
            }
            
        }
        dismissAlertDialog()
    }
    
    @IBAction func dismiss(_ sender: Any) {
        dismissAlertDialog()
    }
    
    func dismissAlertDialog() {
        UIView.animate(withDuration: 0.3) {
            self.alertView.alpha = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Code you want to be delayed
            self.removeFromParent()
            self.view.removeFromSuperview()
            //self.buttonView.alpha = 1
        }
    }
}
