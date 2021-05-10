//
//  SignupViewController.swift
//  VaCay
//
//  Created by Andre on 7/19/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit
import YPImagePicker
import SwiftyJSON

class SignupViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var cameraButton: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var nameBox: UITextField!
    @IBOutlet weak var emailBox: UITextField!
    @IBOutlet weak var passwordBox: UITextField!
    @IBOutlet weak var phoneBox: UITextField!
    @IBOutlet weak var groupBox: UITextField!
    
    @IBOutlet weak var showButton: UIButton!
    
    
    @IBOutlet weak var view_picture: UIView!
    @IBOutlet weak var view_name: UIView!
    @IBOutlet weak var view_email: UIView!
    @IBOutlet weak var view_password: UIView!
    @IBOutlet weak var view_phone: UIView!
    @IBOutlet weak var view_group: UIView!
    
    
    @IBOutlet weak var sigupButton: UIButton!
    
    var picker:YPImagePicker!
    var imageFile:Data!
    var ImageArray = NSMutableArray()
    
    var show = UIImage(named: "eyeunlock")
    var unshow = UIImage(named: "eyelock")
    var showF = false
    
    let thePicker = UIPickerView()
    let groups = [String](arrayLiteral:
        "- Choose a group -",
        "E81",
        "E83",
        "E84",
        "E86",
        "E87",
        "S82",
        "S85",
        "S88",
        "E(v)89",
        "E(v)90",
        "S(v)91",
        "E(v)92",
        "E(v)93",
        "S(v)94",
        "VACAY Leaders")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if gNote != ""{
            showToast(msg: gNote)
        }

        picture.layer.cornerRadius = 50
        
        setRoundShadowView(view: view_name, corner: 25)
        setRoundShadowView(view: view_email, corner: 25)
        setRoundShadowView(view: view_password, corner: 25)
        setRoundShadowView(view: view_phone, corner: 25)
        setRoundShadowView(view: view_group, corner: 25)
        
        setRoundShadowButton(button: sigupButton, corner: 25)
        
        emailBox.keyboardType = UIKeyboardType.emailAddress
        textView.text = "Please complete your profile"
        
        var config = YPImagePickerConfiguration()
        config.wordings.libraryTitle = "Gallery"
        config.wordings.cameraTitle = "Camera"
        YPImagePickerConfiguration.shared = config
        picker = YPImagePicker()
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.openCamera))
        self.view_picture.addGestureRecognizer(gesture)
        
        thePicker.delegate = self
        groupBox.inputView = thePicker
        thePicker.backgroundColor = UIColor.white
        createToolbar()
        
        if thisUser.idx > 0 {
            nameBox.text = thisUser.name
            emailBox.text = thisUser.email
            emailBox.isEnabled = false
            if thisUser.cohort != "" {
                self.groupBox.text = thisUser.cohort
                let index = self.groups.firstIndex(where: {$0 == thisUser.cohort})
//                thePicker.selectRow(index!, inComponent: index!, animated: true)
            }
        }else {
            emailBox.isEnabled = true
        }
        
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
    
    @objc func openCamera(sender : UITapGestureRecognizer) {
        if (sender.view as? UIView) != nil {
            print("Logo Tapped")
            picker.didFinishPicking { [picker] items, _ in
                if let photo = items.singlePhoto {
                    self.picture.image = photo.image
                    self.picture.layer.cornerRadius = 50
                    self.imageFile = photo.image.jpegData(compressionQuality: 0.8)
                    self.cameraButton.isHidden = true
                }
                picker!.dismiss(animated: true, completion: nil)
            }
            present(picker, animated: true, completion: nil)
        }
    }
    
    @IBAction func openGroupList(_ sender: Any) {
        
    }
    
    // MARK: UIPickerView Delegation
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return groups.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row > 0{
            groupBox.text = groups[row]
        }else{
            groupBox.text = ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return groups[row]
    }
    
    @objc func closePickerView()
    {
        view.endEditing(true)
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50.0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label:UILabel
        
        if let v = view as? UILabel{
            label = v
        }
        else{
            label = UILabel()
        }
        
        if row == 0{
            label.textColor = UIColor.systemOrange
        }else{
            label.textColor = UIColor.black
        }
        label.textAlignment = .center
        label.font = UIFont(name: "Helvetica", size: 20)
        label.text = groups[row]
        
        return label
    }
    
    func createToolbar()
    {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.tintColor = primaryDarkColor
        toolbar.backgroundColor = UIColor.lightGray
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(SignupViewController.closePickerView))
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        groupBox.inputAccessoryView = toolbar
    }
    
    
    @IBAction func register(_ sender: Any) {
        if nameBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            showToast(msg: "Enter your full name")
            return
        }
            
        if emailBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            showToast(msg: "Enter your email")
            return
        }
            
        if isValidEmail(testStr: (emailBox.text?.trimmingCharacters(in: .whitespacesAndNewlines))!) == false{
            showToast(msg: "Please enter a valid email.")
            return
        }
        
        if phoneBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            showToast(msg: "Enter your full phone number.")
            return
        }
            
        if isValidPhone(phone: (phoneBox.text?.trimmingCharacters(in: .whitespacesAndNewlines))!) == false{
            showToast(msg: "Please enter a valid phone number.")
            return
        }
        
        if groupBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            showToast(msg: "Choose a group.")
            return
        }
        
        var userId:Int64 = 0
        if thisUser.idx > 0 { userId = thisUser.idx }
            
        let parameters: [String:Any] = [
            "member_id" : String(userId),
            "name" : nameBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) as Any,
            "email" : emailBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) as Any,
            "password" : passwordBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) as Any,
            "cohort" : groupBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) as Any,
            "phone_number": phoneBox.text?.trimmingCharacters(in: .whitespacesAndNewlines) as Any,
            "address" : "",
            "city" : "",
            "lat" : "",
            "lng" : ""
        ]
            
        if self.imageFile != nil{
            
            let ImageDic = ["file" : self.imageFile!]
            // Here you can pass multiple image in array i am passing just one
            ImageArray = NSMutableArray(array: [ImageDic as NSDictionary])
                
            self.showLoadingView()
            APIs().registerWithPicture(withUrl: ReqConst.SERVER_URL + "register", withParam: parameters, withImages: ImageArray) { (isSuccess, response) in
                // Your Will Get Response here
                self.dismissLoadingView()
                print("Response: \(response)")
                if isSuccess == true{
                    let result_code = response["result_code"] as Any
                    if result_code as! String == "0"{
                        let json = JSON(response)
                        self.processData(json: json)
                        
                    }else if result_code as! String == "1"{
                        thisUser.idx = 0
                        self.showToast(msg: "This user doesn\'t exist.")
                    }else {
                        thisUser.idx = 0
                        self.showToast(msg: "Something wrong")
                    }
                }else{
                    let message = "File size: " + String(response.fileSize()) + "\n" + "Description: " + response.description
                    self.showToast(msg: "Issue: \n" + message)
                }
            }
        }else{
            self.showLoadingView()
            APIs().registerWithoutPicture(withUrl: ReqConst.SERVER_URL + "register", withParam: parameters) { (isSuccess, response) in
                // Your Will Get Response here
                self.dismissLoadingView()
                print("Response: \(response)")
                if isSuccess == true{
                    let result_code = response["result_code"] as Any
                    if result_code as! String == "0"{
                        let json = JSON(response)
                        self.processData(json: json)
                        
                    }else if result_code as! String == "1"{
                        thisUser.idx = 0
                        self.showToast(msg: "This user doesn\'t exist.")
                    }else {
                        thisUser.idx = 0
                        self.showToast(msg: "Something wrong")
                    }
                }else{
                    let message = "File size: " + String(response.fileSize()) + "\n" + "Description: " + response.description
                    self.showToast(msg: "Issue: \n" + message)
                }
            }
        }
            
    }
    
    func processData(json:JSON){
        let data = json["data"].object as! [String: Any]
        
        let user = User()
        user.idx = data["id"] as! Int64
        user.name = data["name"] as! String
        user.email = data["email"] as! String
        user.password = data["password"] as! String
        user.photo_url = data["photo_url"] as! String
        user.phone_number = data["phone_number"] as! String
        user.city = data["city"] as! String
        user.address = data["address"] as! String
        user.lat = data["lat"] as! String
        user.lng = data["lng"] as! String
        user.cohort = data["cohort"] as! String
        user.registered_time = data["registered_time"] as! String
        user.fcm_token = data["fcm_token"] as! String
        user.status = data["status"] as! String
            
        thisUser = user

        UserDefaults.standard.set(thisUser.email, forKey: "email")
        UserDefaults.standard.set(thisUser.password, forKey: "password")
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddLocationViewController")
        vc.modalPresentationStyle = .fullScreen
        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
    }
    
    @IBAction func back(_ sender: Any) {
        
        self.dismissViewController()
        
    }
}










































