//
//  ChatNotifiedMembersViewController.swift
//  VaCay
//
//  Created by Andre on 8/3/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit
import Kingfisher
import DropDown
import Firebase
import FirebaseDatabase
import FirebaseStorage

class ChatNotifiedMembersViewController:  BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var userList: UITableView!
    
    @IBOutlet weak var view_searchbar: UIView!
    @IBOutlet weak var edt_search: UITextField!
    @IBOutlet weak var btn_search: UIButton!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var noResult: UILabel!
    @IBOutlet weak var btn_all_sel: UIButton!
    
    let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Comfortaa-Medium", size: 16.0)!,
            .foregroundColor: UIColor.white,
    //        .underlineStyle: NSUnderlineStyle.single.rawValue
    ]
    
    var users = [User]()
    var searchUsers = [User]()
    var onlineUsers = [User]()
    
    let icUnchecked = UIImage(named: "ic_add_user")
    let icChecked = UIImage(named: "ic_checked")

    override func viewDidLoad() {
        super.viewDidLoad()

        view_searchbar.isHidden = true
        edt_search.attributedPlaceholder = NSAttributedString(string: "Search...",
            attributes: attrs)
        
        view_searchbar.layer.cornerRadius = view_searchbar.frame.height / 2
        
        btn_all_sel.setImageTintColor(.white)
        btn_all_sel.layer.cornerRadius = 3
        btn_all_sel.layer.masksToBounds = true
        
        self.userList.delegate = self
        self.userList.dataSource = self
        
        self.userList.estimatedRowHeight = 50.0
        self.userList.rowHeight = UITableView.automaticDimension
        
        edt_search.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        self.users = gUsers
        self.searchUsers = gUsers
        
        if gSelectedUsers.count == gUsers.count {
            self.btn_all_sel.setImage(icChecked, for: .normal)
        }
        
        self.getParticipants()
        
        self.userList.reloadData()
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
            self.users = searchUsers
            edt_search.resignFirstResponder()
            
            self.userList.reloadData()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
            
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell:ChatUserCell = tableView.dequeueReusableCell(withIdentifier: "ChatUserCell", for: indexPath) as! ChatUserCell
            
        userList.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
                
        let index:Int = indexPath.row
                
        if users.indices.contains(index) {
            
            let user = users[index]
                    
            if user.photo_url != ""{
                loadPicture(imageView: cell.img_user, url: URL(string: user.photo_url)!)
            }
                    
            cell.lbl_name.text = user.name
            
            if user.username != "" { cell.lbl_username.text = user.username }
            else {
                let string = user.email
                if let firstIndex = string.firstIndex(of: "@") {
                    cell.lbl_username.text = "@" + string[..<firstIndex]
                }else{
                    if gMainViewController.users.contains(where: {$0.idx == user.idx}){
                        cell.lbl_username.text = gMainViewController.users.filter{usr in
                            return usr.idx == user.idx
                            }[0].username
                    }else{
                        if user.idx == thisUser.idx {
                            cell.lbl_username.text = thisUser.username
                        }else{
                            cell.lbl_username.visibility = .gone
                        }
                    }
                }
            }
            
            if user.cohort != "" { if user.cohort == "admin" { cell.lbl_cohort.text = "VaCay Community" } else { cell.lbl_cohort.text = user.cohort }}
            else {
                if gMainViewController.users.contains(where: {$0.idx == user.idx}){
                    cell.lbl_cohort.text = gMainViewController.users.filter{usr in
                        return usr.idx == user.idx
                        }[0].cohort
                }else{
                    if user.idx == thisUser.idx {
                        cell.lbl_cohort.text = thisUser.cohort
                    }else{
                        cell.lbl_cohort.visibility = .gone
                    }
                }
            }
            
            if self.onlineUsers.contains(where: {$0.idx == user.idx}){
                cell.lbl_status.isHidden = false
            }else{
                cell.lbl_status.isHidden = true
            }
            
            cell.btn_sel.setImageTintColor(UIColor.white)
            
            if user.idx == thisUser.idx{
                cell.btn_sel.isHidden = true
            }else{
                cell.btn_sel.isHidden = false
            }
            
            if gSelectedUsers.contains(where: {$0 === user}){
                cell.btn_sel.setImage(icChecked, for: .normal)
            }else{
                cell.btn_sel.setImage(icUnchecked, for: .normal)
                cell.btn_sel.setImageTintColor(UIColor.white)
            }
                
            cell.btn_sel.tag = index
            cell.btn_sel.addTarget(self, action: #selector(addUser), for: .touchUpInside)
                    
        }
                
        cell.view_content.sizeToFit()
        cell.view_content.layoutIfNeeded()
                
        return cell
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        edt_search.attributedText = NSAttributedString(string: edt_search.text!,
        attributes: attrs)
        
        users = filter(keyword: (textField.text?.lowercased())!)
        if users.isEmpty{
            
        }
        self.userList.reloadData()
    }
    
    func filter(keyword:String) -> [User]{
        if keyword == ""{
            return searchUsers
        }
        var filteredUsers = [User]()
        for user in searchUsers{
            if user.name.lowercased().contains(keyword){
                filteredUsers.append(user)
            }else{
                if user.phone_number.lowercased().contains(keyword){
                    filteredUsers.append(user)
                }else{
                    if user.city.lowercased().contains(keyword){
                        filteredUsers.append(user)
                    }else{
                        if user.address.contains(keyword){
                            filteredUsers.append(user)
                        }else{
                            if user.cohort.contains(keyword){
                                filteredUsers.append(user)
                            }
                        }
                    }
                }
            }
        }
        return filteredUsers
    }
    
    @objc func addUser(sender:UIButton){
        let user = self.users[sender.tag]
        if gSelectedUsers.contains(where: { $0 === user }){
            gSelectedUsers.remove(at: gSelectedUsers.firstIndex(where: {$0 === user})!)
            sender.setImage(icUnchecked, for: .normal)
            sender.setImageTintColor(.white)
        }else{
            gSelectedUsers.append(user)
            sender.setImage(icChecked, for: .normal)
        }
        
        if gRecentViewController == gGroupChatViewController {
            if gSelectedUsers.count > 0{
                gGroupChatViewController.lbl_sel_notify.text = String(gSelectedUsers.count) + " users will be notified"
                gGroupChatViewController.lbl_sel_notify.isHidden = false
            }else{
                gGroupChatViewController.lbl_sel_notify.isHidden = true
                gGroupChatViewController.lbl_sel_notify.text = ""
            }
        }
            
    }
    
    @IBAction func selectAllUsers(_ sender: Any) {
        print("Selected: \(gSelectedUsers.count) /////// \(gUsers.count)")
        if gSelectedUsers.count == gUsers.count {
            gSelectedUsers.removeAll()
            self.btn_all_sel.setImage(icUnchecked, for: .normal)
            self.btn_all_sel.setImageTintColor(.white)
            if gRecentViewController == gGroupChatViewController {
                gGroupChatViewController.lbl_sel_notify.isHidden = true
                gGroupChatViewController.lbl_sel_notify.text = ""
            }
        }else{
            gSelectedUsers = gUsers
            self.btn_all_sel.setImage(icChecked, for: .normal)
            if gRecentViewController == gGroupChatViewController {
                gGroupChatViewController.lbl_sel_notify.text = String(gSelectedUsers.count) + " users will be notified"
                gGroupChatViewController.lbl_sel_notify.isHidden = false
            }
        }
        self.userList.reloadData()
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getParticipants(){
        self.onlineUsers.removeAll()
        
        var CHAT_ID:String = ""
        if gSelectedGroupId > 0{
            CHAT_ID = "\(gAdmin.idx)gr\(gSelectedGroupId)"
        }else if gSelectedCohort != ""{
            CHAT_ID = "\(gAdmin.idx)\(gSelectedCohort)"
        }
                
        var ref:DatabaseReference!
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "gmusers" + CHAT_ID)
        ref.observe(.childAdded, with: {(snapshot) -> Void in
            let subRef = ref.child(snapshot.key)
            subRef.observe(.childAdded, with: {(snapshot) -> Void in
                let value = snapshot.value as! [String: Any]
                
                let sender_id = value["sender_id"] as! String
                let sender_name = value["sender_name"] as! String
                let sender_email = value["sender_email"] as! String
                let sender_photo = value["sender_photo"] as! String

                print("\(sender_name)")
                print("\(sender_id)")
                print("\(sender_email)")
                print("\(sender_photo)")

                let user = User()
                user.idx = Int64(sender_id)!
                user.name = sender_name
                user.email = sender_email
                user.photo_url = sender_photo

                if !self.onlineUsers.contains(where: {$0.idx == user.idx}) {
                    self.onlineUsers.append(user)
                    self.userList.reloadData()
                }
                if !self.users.contains(where: {$0.idx == user.idx}) {
                    self.users.append(user)
                    self.userList.reloadData()
                }
                if !self.searchUsers.contains(where: {$0.idx == user.idx}) {
                    self.searchUsers.append(user)
                }
                print("Online Users////////////////: \(self.onlineUsers.count)")
                
            })
        })
        
        ref.observe(.childRemoved, with: {(snapshot) -> Void in
            print("Removed////////////////: \(snapshot.key)")
            let userEmail = snapshot.key.replacingOccurrences(of: "ddoott", with: ".")
            if self.onlineUsers.contains(where: {$0.email == userEmail}){
                self.onlineUsers.remove(at: self.onlineUsers.firstIndex(where: {$0.email == userEmail})!)
                print("Online Users////////////////: \(self.onlineUsers.count)")
                self.userList.reloadData()
            }
            if self.users.contains(where: {$0.email == userEmail}){
                self.users.remove(at: self.users.firstIndex(where: {$0.email == userEmail})!)
                self.userList.reloadData()
            }
            if self.searchUsers.contains(where: {$0.email == userEmail}){
                self.searchUsers.remove(at: self.searchUsers.firstIndex(where: {$0.email == userEmail})!)
            }
        })
    }

}
