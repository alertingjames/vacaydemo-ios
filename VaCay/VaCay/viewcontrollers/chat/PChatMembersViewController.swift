//
//  PChatMembersViewController.swift
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

class PChatMembersViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var userList: UITableView!
    
    @IBOutlet weak var view_searchbar: UIView!
    @IBOutlet weak var edt_search: UITextField!
    @IBOutlet weak var btn_search: UIButton!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var noResult: UILabel!
    @IBOutlet weak var lbl_notified: UILabel!
    
    let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Comfortaa-Medium", size: 16.0)!,
            .foregroundColor: UIColor.white,
    //        .underlineStyle: NSUnderlineStyle.single.rawValue
    ]
    
    var users = [User]()
    var searchUsers = [User]()
    var notifiedUsers = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()

        view_searchbar.isHidden = true
        edt_search.attributedPlaceholder = NSAttributedString(string: "Search...",
            attributes: attrs)
        
        view_searchbar.layer.cornerRadius = view_searchbar.frame.height / 2
        
        lbl_notified.layer.cornerRadius = 3
        lbl_notified.layer.masksToBounds = true
        lbl_notified.visibilityh = .gone
        
        self.userList.delegate = self
        self.userList.dataSource = self
        
        self.userList.estimatedRowHeight = 50.0
        self.userList.rowHeight = UITableView.automaticDimension
        
        edt_search.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        self.users = gSelectedUsers
        self.searchUsers = gSelectedUsers
        
        self.getNotifiedUsers()
        
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
                
        let cell:ConfUserCell = tableView.dequeueReusableCell(withIdentifier: "ConfUserCell", for: indexPath) as! ConfUserCell
            
        userList.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
                
        let index:Int = indexPath.row
                
        if users.indices.contains(index) {
            
            let user = users[index]
                    
            if user.photo_url != ""{
                loadPicture(imageView: cell.img_user, url: URL(string: user.photo_url)!)
            }
                    
            cell.lbl_name.text = user.name
            
            if user.cohort == "admin" { cell.lbl_cohort.text = "VaCay Community" } else { cell.lbl_cohort.text = user.cohort}
            
            if self.notifiedUsers.contains(where: {$0.email == user.email}){
                cell.lbl_status.isHidden = false
            }else{
                cell.lbl_status.isHidden = true
            }
            
            cell.btn_menu.setImageTintColor(UIColor.white)
            
            if user.idx == thisUser.idx{
                cell.btn_menu.isHidden = true
            }else{
                cell.btn_menu.isHidden = false
            }
                
            cell.btn_menu.tag = index
            cell.btn_menu.addTarget(self, action: #selector(openDropDownMenu), for: .touchUpInside)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(tappedView(gesture:)))
            cell.view_content.tag = index
            cell.view_content.addGestureRecognizer(tap)
            cell.view_content.isUserInteractionEnabled = true
                    
        }
                
        cell.view_content.sizeToFit()
        cell.view_content.layoutIfNeeded()
                
        return cell
    }
    
    @objc func tappedView(gesture:UITapGestureRecognizer){
        let index = gesture.view?.tag
        gUser = gSelectedUsers[index!]
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PrivateChatViewController")
        self.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
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
    
    @objc func openDropDownMenu(sender:UIButton){
        let index = sender.tag
        let cell = sender.superview?.superviewOfClassType(ConfUserCell.self) as! ConfUserCell
            
        let dropDown = DropDown()
        
        let user = self.users[index]
            
        dropDown.anchorView = cell.btn_menu
        dropDown.dataSource = ["  Chat with...", "  Message"]
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
            print("Selected item: \(item) at index: \(idx)")
            if idx == 0{
                gUser = user
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PrivateChatViewController")
                self.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }else if idx == 1 {
                gUser = user
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeSendMessageViewController")
                self.present(vc, animated: true, completion: nil)
            }
        }
            
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().selectedTextColor = UIColor.white
        DropDown.appearance().textFont = UIFont.systemFont(ofSize: 13.0)
        DropDown.appearance().backgroundColor = UIColor.white
        DropDown.appearance().selectionBackgroundColor = UIColor.gray
        DropDown.appearance().cellHeight = 40
            
        dropDown.separatorColor = UIColor.lightGray
        dropDown.width = 100
            
        dropDown.show()
            
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismissViewController()
    }
    
    func getNotifiedUsers(){
        self.notifiedUsers.removeAll()
                
        var ref:DatabaseReference!
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "notification").child(thisUser.email.replacingOccurrences(of: ".", with: "ddoott"))
        ref.observe(.childAdded, with: {(snapshot) -> Void in
            let subRef = ref.child(snapshot.key)
            subRef.observe(.childAdded, with: {(snapshot) -> Void in
                let value = snapshot.value as! [String: Any]
                
                let message = value["msg"] as! String
                let sender_name = value["senderName"] as! String
                let sender_email = value["sender"] as! String
                let sender_photo = value["senderPhoto"] as! String

                let user = User()
                user.name = sender_name
                user.email = sender_email
                user.photo_url = sender_photo
                
                if !self.notifiedUsers.contains(where: {$0.email == user.email}) && gSelectedUsers.contains(where: {$0.email == user.email}){
                    self.notifiedUsers.append(user)
                    self.userList.reloadData()
                }
                
                print("Notified Users////////////////: \(self.notifiedUsers.count)")
                if self.notifiedUsers.count > 0{
                    self.lbl_notified.visibilityh = .visible
                    self.lbl_notified.text = String(self.notifiedUsers.count)
                }
                
            })
        })
        
        ref.observe(.childRemoved, with: {(snapshot) -> Void in
            print("Removed////////////////: \(snapshot.key)")
            let userEmail = snapshot.key.replacingOccurrences(of: "ddoott", with: ".")
            if self.notifiedUsers.contains(where: {$0.email == userEmail}){
                self.notifiedUsers.remove(at: self.notifiedUsers.firstIndex(where: {$0.email == userEmail})!)
                print("Notified Users////////////////: \(self.notifiedUsers.count)")
                self.userList.reloadData()
            }
            if self.notifiedUsers.count > 0{
                self.lbl_notified.visibilityh = .visible
                self.lbl_notified.text = String(self.notifiedUsers.count)
            }else{
                self.lbl_notified.visibilityh = .gone
            }
        })
    }

}
