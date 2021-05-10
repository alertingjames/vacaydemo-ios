//
//  MessageViewController.swift
//  VaCay
//
//  Created by Andre on 7/27/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit
import Kingfisher
import SCLAlertView
import DropDown
import Auk
import DynamicBlurView
import GSImageViewerController
import FirebaseCore
import FirebaseDatabase
import AVFoundation
import AudioToolbox

class MessageViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var btn_search: UIButton!
    @IBOutlet weak var view_searchbar: UIView!
    @IBOutlet weak var edt_search: UITextField!
    @IBOutlet weak var btn_nav: UIButton!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var noResult: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var lbl_unreads: UILabel!
    
    @IBOutlet weak var messageList: UITableView!
    
    var messages = [Message]()
    var searchMessages = [Message]()
    
    var unreads:Int = 0
    
    let attrs: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: "Comfortaa-Medium", size: 16.0)!,
        .foregroundColor: UIColor.white,
    //   .underlineStyle: NSUnderlineStyle.single.rawValue
    ]
    
    var notiFrame:NotisFrame!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gMessageViewController = self
        
        notiFrame = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "NotisFrame")
        notiFrame.view.frame = CGRect(x: 0, y: -screenHeight, width: screenWidth, height: screenHeight)

        view_searchbar.isHidden = true
        edt_search.attributedPlaceholder = NSAttributedString(string: "Search...",
            attributes: attrs)
        
        edt_search.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        view_searchbar.layer.cornerRadius = view_searchbar.frame.height / 2
        view_searchbar.backgroundColor = UIColor(rgb: 0xffffff, alpha: 0.3)
        
        menuButton.setImageTintColor(UIColor(rgb: 0xffffff, alpha: 0.8))
        
        self.messageList.delegate = self
        self.messageList.dataSource = self
        
        self.messageList.estimatedRowHeight = 190.0
        self.messageList.rowHeight = UITableView.automaticDimension
        
        UITextView.appearance().linkTextAttributes = [ .foregroundColor: UIColor(rgb: 0x0BFFFF, alpha: 1.0) ]
        
        self.notifiedUsers.removeAll()
        self.getChatNotifiedUsers()
        self.getNotifications()
        self.getCallNotifications()
    }
    
    @IBAction func openMenu(_ sender: Any) {
        let dropDown = DropDown()
                
        dropDown.anchorView = self.menuButton
        var notiMark:String = ""
        if self.notifiedUsers.count > 0{
            notiMark = "🔴"
        }
        dropDown.dataSource = ["  Sent Messages", "  Unread (" + String(self.unreads) + ")", "  Notifications " + notiMark]
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
            print("Selected item: \(item) at index: \(idx)")
            if idx == 0{
              let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SentMessagesViewController")
              self.present(vc, animated: true, completion: nil)
            }else if idx == 1{
                gMessageFilterOption = "unread"
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "FilteredMessagesViewController")
                self.present(vc, animated: true, completion: nil)
            }else if idx == 2{
                if self.notifiedUsers.count > 0 {
                    self.notiFrame.view.frame = CGRect(x: 0, y: -self.screenHeight, width: self.screenWidth, height: self.screenHeight)
                    UIView.animate(withDuration: 0.3){() -> Void in
                        self.notiFrame.view.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
                        self.addChild(self.notiFrame)
                        self.view.addSubview(self.notiFrame.view)
                    }
                }else {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "NotificationsViewController")
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
                
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().selectedTextColor = UIColor.white
        DropDown.appearance().textFont = UIFont.boldSystemFont(ofSize: 13.0)
        DropDown.appearance().backgroundColor = UIColor.white
        DropDown.appearance().selectionBackgroundColor = UIColor.gray
        DropDown.appearance().cellHeight = 40
        
        dropDown.separatorColor = UIColor.lightGray
        dropDown.width = 140
                
        dropDown.show()
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismissViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.getReceivedMessages(member_id: thisUser.idx)
        
    }
    
    @IBAction func tap_search(_ sender: Any) {
        if view_searchbar.isHidden{
            view_searchbar.isHidden = false
            btn_search.setImage(cancel, for: .normal)
            lbl_title.isHidden = true
            edt_search.becomeFirstResponder()
            
        }else{
            view_searchbar.isHidden = true
            btn_search.setImage(search, for: .normal)
            lbl_title.isHidden = false
            self.edt_search.text = ""
            self.messages = searchMessages
            edt_search.resignFirstResponder()
            
            self.messageList.reloadData()
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
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
    }
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
            
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell:MessageCell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
            
        messageList.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
                
        let index:Int = indexPath.row
                
        if messages.indices.contains(index) {
            
            let message = messages[index]
            
            if message.sender.photo_url != ""{
                loadPicture(imageView: cell.img_sender, url: URL(string: message.sender.photo_url)!)
            }
            
            cell.img_sender.layer.cornerRadius = cell.img_sender.frame.width / 2
                    
            cell.lbl_sender_name.text = message.sender.name
            cell.lbl_cohort.text = message.sender.cohort
            cell.lbl_messaged_time.text = message.messaged_time
            
            cell.lbl_messaged_time.layer.cornerRadius = cell.lbl_messaged_time.frame.height / 2
            cell.lbl_messaged_time.layer.borderColor = UIColor.white.cgColor
            cell.lbl_messaged_time.layer.borderWidth = 1.0
            
            cell.txv_desc.text = message.message
            
            if cell.txv_desc.text.count > 500{
                cell.txv_desc.text = String(cell.txv_desc.text.prefix(500)) + " ..."
            }
            
            if message.status == "" {
                cell.btn_new.isHidden = false
            }else{
                cell.btn_new.isHidden = true
            }
            
            if message.message.lowercased().contains("reply"){
                cell.lbl_replied.visibility = .visible
            }else{
                cell.lbl_replied.visibility = .gone
            }
            
            cell.menuButton.setImageTintColor(UIColor(rgb: 0xffffff, alpha: 0.8))
            cell.detailButton.setImageTintColor(UIColor.white)
            cell.replyButton.setImageTintColor(.white)
            
            setRoundShadowView(view: cell.view_content, corner: 5.0)
            
            cell.replyButton.tag = index
            cell.replyButton.addTarget(self, action: #selector(self.reply), for: .touchUpInside)
            
            cell.menuButton.tag = index
            cell.menuButton.addTarget(self, action: #selector(self.openDropDownMenu), for: .touchUpInside)
            
            cell.detailButton.tag = index
            cell.detailButton.addTarget(self, action: #selector(self.openDetail), for: .touchUpInside)
            
            cell.btn_new.tag = index
            cell.btn_new.addTarget(self, action: #selector(self.processNewMessage), for: .touchUpInside)
                    
            cell.txv_desc.sizeToFit()
            cell.view_content.sizeToFit()
            cell.view_content.layoutIfNeeded()
                
        }
        
        return cell
        
    }
    
    @objc func reply(sender:UIButton){
        let index = sender.tag
        let message = messages[index]
        
        gMessage = message
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ReplyMessageViewController")
        self.present(vc, animated: true, completion: nil)
        
        self.processNewMsg(message_id: message.idx)
    }
    
    @objc func openDetail(sender:UIButton){
        let index = sender.tag
        let message = messages[index]
        
        gMessage = message
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MessageDetailViewController")
        self.present(vc, animated: true, completion: nil)
        
        self.processNewMsg(message_id: message.idx)
    }
    
    @objc func processNewMessage(sender:UIButton){
        let index = sender.tag
        let message = messages[index]
        
        self.processNewMsg(message_id: message.idx)
    }
    
    @objc func openDropDownMenu(sender:UIButton){
        let index = sender.tag
        let cell = sender.superview?.superviewOfClassType(MessageCell.self) as! MessageCell
        
        let dropDown = DropDown()
        
        dropDown.anchorView = cell.menuButton
        dropDown.dataSource = ["  Chat", "  Delete"]
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
            print("Selected item: \(item) at index: \(idx)")
            if idx == 0{
                gUser = self.messages[index].sender
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PrivateChatViewController")
                self.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }else if idx == 1{
                let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this message?", preferredStyle: .alert)
                let noAction = UIAlertAction(title: "No", style: .cancel, handler: {
                    (action : UIAlertAction!) -> Void in })
                let yesAction = UIAlertAction(title: "Yes", style: .destructive, handler: { alert -> Void in
                    let message = self.messages[index]
                    self.deleteMessage(message_id: message.idx, option: "received")
                })
                
                alert.addAction(yesAction)
                alert.addAction(noAction)
                
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().selectedTextColor = UIColor.white
        DropDown.appearance().textFont = UIFont.boldSystemFont(ofSize: 13.0)
        DropDown.appearance().backgroundColor = UIColor.white
        DropDown.appearance().selectionBackgroundColor = UIColor.gray
        DropDown.appearance().cellHeight = 40
        
        dropDown.separatorColor = UIColor.lightGray
        dropDown.width = 80
        
        dropDown.show()
        
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        
    @objc func textFieldDidChange(_ textField: UITextField) {
            
        edt_search.attributedText = NSAttributedString(string: edt_search.text!, attributes: attrs)
            
        messages = filter(keyword: (textField.text?.lowercased())!)
        if messages.isEmpty{
                
        }
        self.messageList.reloadData()
    }
        
    func filter(keyword:String) -> [Message]{
        if keyword == ""{
            return searchMessages
        }
        var filteredMessages = [Message]()
        for message in searchMessages{
            if message.message.lowercased().contains(keyword){
                filteredMessages.append(message)
            }else{
                if message.messaged_time.lowercased().contains(keyword){
                    filteredMessages.append(message)
                }else{
                    if message.sender.name.lowercased().contains(keyword){
                        filteredMessages.append(message)
                    }else{
                        if message.sender.cohort.contains(keyword){
                            filteredMessages.append(message)
                        }
                    }
                }
            }
        }
        return filteredMessages
    }
    
    func getReceivedMessages(member_id:Int64){
        self.showLoadingView()
        APIs.getReceivedMessages(member_id: member_id, handleCallback: {
            messages, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                
                self.messages = messages!
                self.searchMessages = messages!
                
                self.unreads = 0
                
                for message in messages!{
                    if message.status == ""{
                        self.unreads = self.unreads + 1
                        if !String(self.lbl_unreads.text!).contains("🔴"){
                            self.lbl_unreads.text = "(" + String(self.unreads) + ")"
                        }else{
                            self.lbl_unreads.text = "(" + String(self.unreads) + ")" + "🔴"
                        }
                    }
                }
                
                if messages!.count == 0 {
                    self.noResult.isHidden = false
                }
                
                self.messageList.reloadData()

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

    
    func deleteMessage(message_id: Int64, option:String){
        self.showLoadingView()
        APIs.deleteMessage(message_id: message_id, option: option, handleCallback: {
            result_code in
            self.dismissLoadingView()
            if result_code == "0"{
                self.showToast2(msg: "Deleted")
                self.getReceivedMessages(member_id: thisUser.idx)
            }else {
                self.showToast(msg:"Something wrong")
            }
        })
    }
    
    func processNewMsg(message_id: Int64){
        self.showLoadingView()
        APIs.processNewMessage(message_id: message_id, handleCallback: {
            result_code in
            self.dismissLoadingView()
            if result_code == "0"{
                self.getReceivedMessages(member_id: thisUser.idx)
            }else {
                self.showToast(msg:"Something wrong")
            }
        })
    }
    
    var notifiedUsers = [User]()
    
    func getChatNotifiedUsers(){
                
        var ref:DatabaseReference!
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "notification").child(thisUser.email.replacingOccurrences(of: ".", with: "ddoott"))
        ref.observe(.childAdded, with: {(snapshot) -> Void in
            let subRef = ref.child(snapshot.key)
            subRef.observe(.childAdded, with: {(snapshot) -> Void in
                let value = snapshot.value as! [String: Any]
                
                let message = value["msg"] as! String
                let sender_id = value["sender_id"] as! String
                let sender_name = value["senderName"] as! String
                let sender_email = value["sender"] as! String
                let sender_photo = value["senderPhoto"] as! String
                var timeStamp = String(describing: value["time"])
                timeStamp = timeStamp.replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: ")", with: "")
                let time = self.getDateTimeFromTimeStamp(timeStamp: Double(timeStamp)!/1000)

                let user = User()
                user.idx = Int64(sender_id)!
                user.name = sender_name
                user.email = sender_email
                user.photo_url = sender_photo
                
                if !self.notifiedUsers.contains(where: {$0.email == user.email}) {
                    self.notifiedUsers.append(user)
                }
                
                print("Notified Users////////////////: \(self.notifiedUsers.count)")
                if self.notifiedUsers.count > 0{
                    if !String(self.lbl_unreads.text!).contains("🔴"){
                        self.lbl_unreads.text = self.lbl_unreads.text! + "🔴"
                    }
                }
                
            })
        })
        
        ref.observe(.childRemoved, with: {(snapshot) -> Void in
            print("Removed////////////////: \(snapshot.key)")
            let userEmail = snapshot.key.replacingOccurrences(of: "ddoott", with: ".")
            if self.notifiedUsers.contains(where: {$0.email == userEmail}){
                self.notifiedUsers.remove(at: self.notifiedUsers.firstIndex(where: {$0.email == userEmail})!)
                print("Notified Users////////////////: \(self.notifiedUsers.count)")
            }
            if self.notifiedUsers.count > 0{
                if !String(self.lbl_unreads.text!).contains("🔴"){
                    self.lbl_unreads.text = self.lbl_unreads.text! + "🔴"
                }
            }else{
                if String(self.lbl_unreads.text!).contains("🔴"){
                    self.lbl_unreads.text = self.lbl_unreads.text?.replacingOccurrences(of: "🔴", with: "")
                }
            }
        })
    }
    
    func getNotifications(){
                
        var ref:DatabaseReference!
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "notify").child(String(thisUser.idx))
        ref.observe(.childAdded, with: {(snapshot) -> Void in
            let value = snapshot.value as! [String: Any]
            
            let message = value["msg"] as! String
            let sender_id = value["sender_id"] as! String
            let sender_name = value["sender_name"] as! String
            let sender_email = value["sender_email"] as! String
            let sender_photo = value["sender_photo"] as! String
            let role = value["role"] as! String
            let type = value["type"] as! String
            let id = value["id"] as! String
            let mes_id = value["mes_id"] as! String
            var timeStamp = String(describing: value["date"])
            timeStamp = timeStamp.replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: ")", with: "")
            let time = self.getDateTimeFromTimeStamp(timeStamp: Double(timeStamp)!/1000)
            let key = snapshot.key

            let user = User()
            user.idx = Int64(sender_id)!
            user.name = sender_name
            user.email = sender_email
            user.photo_url = sender_photo
            user.key = key
            
            if !self.notifiedUsers.contains(where: {$0.idx == user.idx}) {
                self.notifiedUsers.append(user)
            }
            
            print("Notified Users////////////////: \(self.notifiedUsers.count)")
            if self.notifiedUsers.count > 0{
                if !String(self.lbl_unreads.text!).contains("🔴"){
                    self.lbl_unreads.text = self.lbl_unreads.text! + "🔴"
                }
            }
        })
        
        ref.observe(.childRemoved, with: {(snapshot) -> Void in
            print("Removed////////////////: \(snapshot.key)")
            let key = snapshot.key
            if self.notifiedUsers.contains(where: {$0.key == key}){
                self.notifiedUsers.remove(at: self.notifiedUsers.firstIndex(where: {$0.key == key})!)
                print("Notified Users////////////////: \(self.notifiedUsers.count)")
            }
            if self.notifiedUsers.count > 0{
                if !String(self.lbl_unreads.text!).contains("🔴"){
                    self.lbl_unreads.text = self.lbl_unreads.text! + "🔴"
                }
            }else{
                if String(self.lbl_unreads.text!).contains("🔴"){
                    self.lbl_unreads.text = self.lbl_unreads.text?.replacingOccurrences(of: "🔴", with: "")
                }
            }
        })
    }
    
    func getCallNotifications(){
            
        var ref:DatabaseReference!
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "call").child(String(thisUser.idx))
        ref.observe(.childAdded, with: {(snapshot0) -> Void in
            let subRef = ref.child(snapshot0.key)
            subRef.observe(.childAdded, with: {(snapshot) -> Void in
                let value = snapshot.value as! [String: Any]
                    
                let message = value["msg"] as! String
                let sender_id = value["sender_id"] as! String
                let sender_name = value["sender_name"] as! String
                let sender_email = value["sender_email"] as! String
                let sender_photo = value["sender_photo"] as! String
                let role = value["role"] as! String
                let type = value["type"] as! String
                let id = value["id"] as! String
                let mes_id = value["mes_id"] as! String
                var timeStamp = String(describing: value["date"])
                timeStamp = timeStamp.replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: ")", with: "")
                let time = self.getDateTimeFromTimeStamp(timeStamp: Double(timeStamp)!/1000)
                let key = snapshot0.key

                let user = User()
                user.idx = Int64(sender_id)!
                user.name = sender_name
                user.email = sender_email
                user.photo_url = sender_photo
                user.key = key
                    
                let noti = Message()
                noti.sender = user
                noti.messaged_time = time
                noti.timestamp = Int64(timeStamp)!
                noti.message = message
                noti.key = key
                noti.role = role
                noti.type = type
                noti.id = id
                noti.mes_id = Int64(mes_id)!
                noti.status = type
                    
                if type == "call_request" {
                    self.showCallAlertDialog(title: noti.sender.name, message: "Incoming call...", alias: noti.id, ref: ref.child(key))
                }
                
                if !self.notifiedUsers.contains(where: {$0.idx == user.idx}) {
                    self.notifiedUsers.append(user)
                }
                    
                print("Notified Users////////////////: \(self.notifiedUsers.count)")
                if self.notifiedUsers.count > 0{
                    if !String(self.lbl_unreads.text!).contains("🔴"){
                        self.lbl_unreads.text = self.lbl_unreads.text! + "🔴"
                    }
                }
                
            })
                
        })
            
        ref.observe(.childRemoved, with: {(snapshot) -> Void in
            print("Removed////////////////: \(snapshot.key)")
            let key = snapshot.key
            if self.notifiedUsers.contains(where: {$0.key == key}){
                self.notifiedUsers.remove(at: self.notifiedUsers.firstIndex(where: {$0.key == key})!)
                print("Notified Users////////////////: \(self.notifiedUsers.count)")
            }
            if self.notifiedUsers.count > 0{
                if !String(self.lbl_unreads.text!).contains("🔴"){
                    self.lbl_unreads.text = self.lbl_unreads.text! + "🔴"
                }
            }else{
                if String(self.lbl_unreads.text!).contains("🔴"){
                    self.lbl_unreads.text = self.lbl_unreads.text?.replacingOccurrences(of: "🔴", with: "")
                }
            }
        })
            
    }
    
}
