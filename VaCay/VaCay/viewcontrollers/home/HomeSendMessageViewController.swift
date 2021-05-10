//
//  HomeSendMessageViewController.swift
//  VaCay
//
//  Created by Andre on 7/21/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit
import Kingfisher

class HomeSendMessageViewController: BaseViewController {

    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textBox: UITextView!
    
    @IBOutlet weak var multipleUsersBox: UIView!
    @IBOutlet weak var selectedCountBox: UILabel!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var img4: UIImageView!
    @IBOutlet weak var img5: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        img1.layer.cornerRadius = 15
        img2.layer.cornerRadius = 15
        img3.layer.cornerRadius = 15
        img4.layer.cornerRadius = 15
        img5.layer.cornerRadius = 15
        
        userPicture.layer.cornerRadius = 35 / 2
        if gUser.idx == 0{
            userPicture.isHidden = true
            multipleUsersBox.visibility = .visible
            if gSelectedUsers.count == 1{
                loadPicture(imageView: img1, url: URL(string: gSelectedUsers[0].photo_url)!)
                img2.visibilityh = .gone
                img3.visibilityh = .gone
                img4.visibilityh = .gone
                img5.visibilityh = .gone
            }else if gSelectedUsers.count == 2{
                loadPicture(imageView: img1, url: URL(string: gSelectedUsers[0].photo_url)!)
                loadPicture(imageView: img2, url: URL(string: gSelectedUsers[1].photo_url)!)
                img3.visibilityh = .gone
                img4.visibilityh = .gone
                img5.visibilityh = .gone
            }else if gSelectedUsers.count == 3{
                loadPicture(imageView: img1, url: URL(string: gSelectedUsers[0].photo_url)!)
                loadPicture(imageView: img2, url: URL(string: gSelectedUsers[1].photo_url)!)
                loadPicture(imageView: img3, url: URL(string: gSelectedUsers[2].photo_url)!)
                img4.visibilityh = .gone
                img5.visibilityh = .gone
            }else if gSelectedUsers.count == 4{
                loadPicture(imageView: img1, url: URL(string: gSelectedUsers[0].photo_url)!)
                loadPicture(imageView: img2, url: URL(string: gSelectedUsers[1].photo_url)!)
                loadPicture(imageView: img3, url: URL(string: gSelectedUsers[2].photo_url)!)
                loadPicture(imageView: img4, url: URL(string: gSelectedUsers[3].photo_url)!)
                img5.visibilityh = .gone
            }else if gSelectedUsers.count >= 5{
                loadPicture(imageView: img1, url: URL(string: gSelectedUsers[0].photo_url)!)
                loadPicture(imageView: img2, url: URL(string: gSelectedUsers[1].photo_url)!)
                loadPicture(imageView: img3, url: URL(string: gSelectedUsers[2].photo_url)!)
                loadPicture(imageView: img4, url: URL(string: gSelectedUsers[3].photo_url)!)
                loadPicture(imageView: img5, url: URL(string: gSelectedUsers[4].photo_url)!)
            }
            selectedCountBox.text = "Selected: " + String(gSelectedUsers.count)
        }else{
            loadPicture(imageView: userPicture, url: URL(string: gUser.photo_url)!)
            userPicture.isHidden = false
            multipleUsersBox.visibility = .gone
        }
        
        sendButton.roundCorners(corners: [.topLeft], radius: 35 / 2)

        textBox.setPlaceholder(string: "Write something here...")
        textBox.textContainerInset = UIEdgeInsets(top: textBox.textContainerInset.top, left: 8, bottom: textBox.textContainerInset.bottom, right: textBox.textContainerInset.right)
        
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.checkPlaceholder()
        if textView.text == ""{
            sendButton.isHidden = true
        }else{
            sendButton.isHidden = false
        }
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
                imageView.layer.cornerRadius = imageView.frame.width/2
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
    }

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        if textBox.text.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            showToast(msg: "Please write your message...")
            return
        }
        if gUser.idx > 0 {
            sendMessage(me_id: thisUser.idx, member_id: gUser.idx, message: textBox.text.trimmingCharacters(in: .whitespacesAndNewlines))
        }else if gSelectedUsers.count > 0{
            self.sendMessageToSelecteds(me_id: thisUser.idx, members: createReceiverJsonString(), message: textBox.text.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
    
    func sendMessage(me_id:Int64, member_id: Int64, message:String){
        self.showLoadingView()
        APIs.sendUserMessage(me_id:me_id, member_id: member_id, message: message, handleCallback: {
            result_code in
            self.dismissLoadingView()
            if result_code == "0"{
                self.showToast2(msg: "Message sent!")
                self.textBox.text = ""
                self.textBox.checkPlaceholder()
                self.sendButton.isHidden = true
            }else if result_code == "1"{
                self.showToast(msg: "Your account doesn\'t exist")
                gMainMenu.logout()
            }else if result_code == "2"{
                self.showToast(msg: "This user doesn\'t exist")
                self.dismissViewController()
            }else{
                self.showToast(msg: "Somthing wrong")
                
            }
        })
    }
    
    
    func sendMessageToSelecteds(me_id:Int64, members: String, message:String){
        self.showLoadingView()
        APIs.sendMessageToSelecteds(me_id:me_id, members: members, message: message, handleCallback: {
            result_code in
            self.dismissLoadingView()
            if result_code == "0"{
                self.showToast2(msg: "Message sent!")
                self.textBox.text = ""
                self.textBox.checkPlaceholder()
                self.sendButton.isHidden = true
            }else if result_code == "1"{
                self.showToast(msg: "Your account doesn\'t exist")
                self.logout()
            }else if result_code == "2"{
                self.showToast(msg: "This user doesn\'t exist")
                self.dismiss(animated: true, completion: nil)
            }else{
                self.showToast(msg: "Somthing wrong")
                
            }
        })
    }
    
    func createReceiverJsonString() -> String{
        var jsonArray = [Any]()
        for user in gSelectedUsers{
            let jsonObject: [String: String] = [
                    "member_id": String(user.idx),
                    "name": String(user.name),
            ]
            
            jsonArray.append(jsonObject)
        }
        
        let jsonItemsObj:[String: Any] = [
            "members":jsonArray
        ]
        
        let jsonStr = self.stringify(json: jsonItemsObj)
        return jsonStr
        
    }
    
    func stringify(json: Any, prettyPrinted: Bool = false) -> String {
        var options: JSONSerialization.WritingOptions = []
        if prettyPrinted {
            options = JSONSerialization.WritingOptions.prettyPrinted
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: options)
            if let string = String(data: data, encoding: String.Encoding.utf8) {
                return string
            }
        } catch {
            print(error)
        }
        return ""
    }
    
}
