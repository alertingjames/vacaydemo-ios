//
//  ProfileViewController.swift
//  VaCay
//
//  Created by Andre on 7/29/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit
import YPImagePicker
import Kingfisher
import SwiftyJSON


class ProfileViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var btn_pwd_reset: UIButton!
    @IBOutlet weak var btn_save: UIButton!
    @IBOutlet weak var img_picture: UIImageView!
    @IBOutlet weak var btn_edt_picture: UIButton!
    @IBOutlet weak var edt_name: UITextField!
    @IBOutlet weak var ic_mail: UIImageView!
    @IBOutlet weak var edt_email: UITextField!
    @IBOutlet weak var ic_phone: UIImageView!
    @IBOutlet weak var edt_phone: UITextField!
    @IBOutlet weak var ic_group: UIImageView!
    @IBOutlet weak var edt_group: UITextField!
    @IBOutlet weak var ic_address: UIImageView!
    @IBOutlet weak var edt_address: UITextField!
    @IBOutlet weak var btn_address: UIButton!
    @IBOutlet weak var btn_posts: UIButton!
    
    var picker:YPImagePicker!
    var imageFile:Data!
    var ImageArray = NSMutableArray()
    
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
    
    var city:String = ""
    var lat:String = ""
    var lng:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gProfileViewController = self
        gRecentViewController = self

        img_picture.layer.cornerRadius = img_picture.frame.height / 2
        self.loadPicture(imageView: img_picture, url: URL(string: thisUser.photo_url)!)
        
        edt_name.text = thisUser.name
        edt_email.text = thisUser.email
        edt_phone.text = thisUser.phone_number
        edt_group.text = thisUser.cohort
        edt_address.text = thisUser.address
        
        edt_name.layer.cornerRadius = edt_name.frame.height / 2
        edt_email.layer.cornerRadius = edt_email.frame.height / 2
        edt_phone.layer.cornerRadius = edt_phone.frame.height / 2
        edt_group.layer.cornerRadius = edt_group.frame.height / 2
        edt_address.layer.cornerRadius = edt_address.frame.height / 2
        
        btn_pwd_reset.setImageTintColor(.white)
        btn_save.setImageTintColor(.white)
        btn_address.setImageTintColor(.white)
        
        ic_mail.image = ic_mail.image?.imageWithColor(color1: UIColor.white)
        ic_phone.image = ic_phone.image?.imageWithColor(color1: UIColor.white)
        ic_group.image = ic_group.image?.imageWithColor(color1: UIColor.white)
        ic_address.image = ic_address.image?.imageWithColor(color1: UIColor.white)
        
        
        edt_email.keyboardType = UIKeyboardType.emailAddress
        
        var config = YPImagePickerConfiguration()
        config.wordings.libraryTitle = "Gallery"
        config.wordings.cameraTitle = "Camera"
        YPImagePickerConfiguration.shared = config
        picker = YPImagePicker()
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.openCamera))
        self.img_picture.addGestureRecognizer(gesture)
        self.img_picture.isUserInteractionEnabled = true
        
        thePicker.delegate = self
        edt_group.inputView = thePicker
        thePicker.backgroundColor = UIColor.white
        createToolbar()
        
        city = thisUser.city
        lat = thisUser.lat
        lng = thisUser.lng
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getMyPosts(member_id: thisUser.idx)
    }
    
    func loadPicture(imageView:UIImageView, url:URL){
        let processor = DownsamplingImageProcessor(size: imageView.frame.size)
            >> ResizingImageProcessor(referenceSize: imageView.frame.size, mode: .aspectFill)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "logo.jpg"),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        {
            result in
            switch result {
            case .success(let value):
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func openCamera(sender : UITapGestureRecognizer) {
        if !isEditable {
            return
        }
        if (sender.view as? UIView) != nil {
            print("Logo Tapped")
            picker.didFinishPicking { [picker] items, _ in
                if let photo = items.singlePhoto {
                    self.img_picture.image = photo.image
                    self.img_picture.layer.cornerRadius = self.img_picture.frame.height / 2
                    self.imageFile = photo.image.jpegData(compressionQuality: 0.8)
                }
                picker!.dismiss(animated: true, completion: nil)
            }
            present(picker, animated: true, completion: nil)
        }
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
            edt_group.text = groups[row]
        }else{
            edt_group.text = thisUser.cohort
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
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(ProfileViewController.closePickerView))
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        edt_group.inputAccessoryView = toolbar
    }
    
    var isEditable:Bool = false
    
    @IBAction func back(_ sender: Any) {
        self.dismissViewController()
    }
    
    @IBAction func save(_ sender: Any) {
        if !isEditable {
            self.btn_save.setImage(UIImage(named: "ic_save"), for: .normal)
            self.btn_save.setImageTintColor(.white)
            
            self.btn_edt_picture.isHidden = false
            self.btn_address.isHidden = false
            
            self.edt_name.backgroundColor = UIColor(rgb: 0xffffff, alpha: 0.12)
            self.edt_email.backgroundColor = UIColor(rgb: 0xffffff, alpha: 0.12)
            self.edt_phone.backgroundColor = UIColor(rgb: 0xffffff, alpha: 0.12)
            self.edt_group.backgroundColor = UIColor(rgb: 0xffffff, alpha: 0.12)
            self.edt_address.backgroundColor = UIColor(rgb: 0xffffff, alpha: 0.12)
            
            self.edt_name.isEnabled = true
//            self.edt_email.isEnabled = true
            self.edt_phone.isEnabled = true
            self.edt_group.isEnabled = true
//            self.edt_address.isEnabled = true
            
            isEditable = true
        }else{
            if edt_name.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
                showToast(msg: "Enter your full name")
                return
            }
                
            if edt_email.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
                showToast(msg: "Enter your email")
                return
            }
                
            if isValidEmail(testStr: (edt_email.text?.trimmingCharacters(in: .whitespacesAndNewlines))!) == false{
                showToast(msg: "Please enter a valid email.")
                return
            }
            
            if edt_phone.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
                showToast(msg: "Enter your full phone number.")
                return
            }
                
            if isValidPhone(phone: (edt_phone.text?.trimmingCharacters(in: .whitespacesAndNewlines))!) == false{
                showToast(msg: "Please enter a valid phone number.")
                return
            }
            
            if edt_group.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
                showToast(msg: "Choose a group.")
                return
            }
            
                
            let parameters: [String:Any] = [
                "member_id" : String(thisUser.idx),
                "name" : edt_name.text?.trimmingCharacters(in: .whitespacesAndNewlines) as Any,
                "email" : edt_email.text?.trimmingCharacters(in: .whitespacesAndNewlines) as Any,
                "password" : "",
                "cohort" : edt_group.text?.trimmingCharacters(in: .whitespacesAndNewlines) as Any,
                "phone_number": edt_phone.text?.trimmingCharacters(in: .whitespacesAndNewlines) as Any,
                "address" : edt_address.text?.trimmingCharacters(in: .whitespacesAndNewlines) as Any,
                "city" : self.city,
                "lat" : self.lat,
                "lng" : self.lng
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
    }
    
    @IBAction func resetPassword(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ResetPasswordViewController")
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func editAddress(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PickLocationViewController")
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func editPicture(_ sender: Any) {
        if !isEditable {
            return
        }
        print("Logo Tapped")
        picker.didFinishPicking { [picker] items, _ in
            if let photo = items.singlePhoto {
                self.img_picture.image = photo.image
                self.img_picture.layer.cornerRadius = self.img_picture.frame.height / 2
                self.imageFile = photo.image.jpegData(compressionQuality: 0.8)
            }
            picker!.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
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
        
        showToast2(msg: "Successfully updated")
        
        self.updateUI()
    }
    
    func updateUI(){
        isEditable = false
        
        self.btn_save.setImage(UIImage(named: "ic_pen"), for: .normal)
        self.btn_save.setImageTintColor(.white)
                    
        self.btn_edt_picture.isHidden = true
        self.btn_address.isHidden = true
                    
        self.edt_name.backgroundColor = UIColor.clear
        self.edt_email.backgroundColor = UIColor.clear
        self.edt_phone.backgroundColor = UIColor.clear
        self.edt_group.backgroundColor = UIColor.clear
        self.edt_address.backgroundColor = UIColor.clear
                    
        self.edt_name.isEnabled = false
        self.edt_phone.isEnabled = false
        self.edt_group.isEnabled = false
        
        if self.imageFile != nil {
            self.imageFile = nil
            gHomeViewController.loadPicture(imageView:gHomeViewController.menu_vc.logo, url:URL(string: thisUser.photo_url)!)
        }

    }
    
    func getMyPosts(member_id:Int64){
        self.showLoadingView()
        APIs.getPosts(member_id: member_id, handleCallback: {
            posts, users, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                
                var myPosts = [Post]()
                
                for post in posts!{
                    if post.user.idx == thisUser.idx {
                        myPosts.append(post)
                    }
                }
                
                self.btn_posts.setTitle("Posts: " + String(myPosts.count), for: .normal)

            }
            else{
                if result_code == "1" {
                    self.logout()
                } else {
                    self.showToast(msg: "Something wrong!")
                }
            }
        })
    }
    
    @IBAction func showMyPosts(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MyPostsViewController")
        self.modalPresentationStyle = .fullScreen
        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
    }
}
