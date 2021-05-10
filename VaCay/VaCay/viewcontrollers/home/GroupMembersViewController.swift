//
//  GroupMembersViewController.swift
//  VaCay
//
//  Created by Andre on 8/2/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit
import Kingfisher
import SCLAlertView
import Firebase
import FirebaseDatabase
import DropDown
import AVFoundation
import AudioToolbox

class GroupMembersViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
//    private var lastContentOffset: CGFloat = 0
    @IBOutlet weak var view_nav:UIView!
    @IBOutlet weak var view_noticount: UIView!
    @IBOutlet weak var lbl_noticount: UILabel!
    @IBOutlet weak var view_notification: UIView!
    @IBOutlet weak var btn_search: UIButton!
    @IBOutlet weak var view_searchbar: UIView!
    @IBOutlet weak var edt_search: UITextField!
    @IBOutlet weak var btn_nav: UIButton!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var ic_notification: UIImageView!
    @IBOutlet weak var userList: UITableView!
    @IBOutlet weak var selUserButtonsFrame: UIView!
    @IBOutlet weak var selChatButton: UIButton!
    @IBOutlet weak var selMessageButton: UIButton!
    @IBOutlet weak var selCountBox: UILabel!
    @IBOutlet weak var noResult: UILabel!
    
    let icUnchecked = UIImage(named: "ic_add_user")
    let icChecked = UIImage(named: "ic_checked")
    
    var user_buttons:HomeUserMenu!
    
    var isNotified:Bool = false
    
//    var notiFrame:NotisViewController!
    
    var users = [User]()
    var searchUsers = [User]()
    
    var groups = [Group]()
    
    let attrs: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: "Comfortaa-Medium", size: 16.0)!,
        .foregroundColor: UIColor.white,
//        .underlineStyle: NSUnderlineStyle.single.rawValue
    ]
    
    var notifiedUsers = [User]()
    var notiFrame:NotisFrame!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gRecentViewController = self
        gGroupMembersViewController = self
        
        notiFrame = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "NotisFrame")
        notiFrame.view.frame = CGRect(x: 0, y: -screenHeight, width: screenWidth, height: screenHeight)
        
//        addShadowToBar(view: view_nav)
        setIconTintColor(imageView:ic_notification, color: UIColor(rgb: 0xffffff, alpha: 0.8))
        selChatButton.setImageTintColor(.white)
        selChatButton.layer.cornerRadius = selChatButton.frame.height / 2
        selMessageButton.setImageTintColor(.white)
        selMessageButton.layer.cornerRadius = selMessageButton.frame.height / 2
        
        selUserButtonsFrame.visibility = .gone
        view_notification.visibilityh = .visible
        
//        notiFrame = self.storyboard!.instantiateViewController(withIdentifier: "NotisViewController") as! NotisViewController
        
        view_noticount.isHidden = true
        view_searchbar.isHidden = true
        edt_search.attributedPlaceholder = NSAttributedString(string: "Search...",
            attributes: attrs)
        
        view_searchbar.layer.cornerRadius = view_searchbar.frame.height / 2
        view_searchbar.backgroundColor = UIColor(rgb: 0xffffff, alpha: 0.3)
        
        user_buttons = self.storyboard!.instantiateViewController(withIdentifier: "HomeUserMenu") as! HomeUserMenu
        
        self.userList.delegate = self
        self.userList.dataSource = self
        
        self.userList.estimatedRowHeight = 260.0
        self.userList.rowHeight = UITableView.automaticDimension
        
        edt_search.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                            for: UIControl.Event.editingChanged)
        
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                self.getNoitificaitons()
//                print("FCMToken!!!", gFCMToken)
            }
        }
        
        self.getNotifiedUsers()
        self.getNotifications()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.showNotifications(_:)))
        view_notification.addGestureRecognizer(tap)
        
    }
    
    @objc func showNotifications(_ sender: UITapGestureRecognizer? = nil) {
        if self.notifiedUsers.count > 0 {
            self.notiFrame.view.frame = CGRect(x: 0, y: -screenHeight, width: screenWidth, height: screenHeight)
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
    
    override func viewWillAppear(_ animated: Bool) {
        gRecentViewController = self
        getHomeData()
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
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if users.count % 2 == 0{
            return users.count/2
        }else{
            return users.count/2 + 1
        }
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        let cell:HomeUserCell = tableView.dequeueReusableCell(withIdentifier: "HomeUserCell", for: indexPath) as! HomeUserCell
        
        userList.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
            
        let index:Int = indexPath.row * 2
            
        if users.indices.contains(index) {
                
            if users[index].photo_url != ""{
                loadPicture(imageView: cell.img_photo1, url: URL(string: users[index].photo_url)!)
            }
                
            cell.lbl_name1.text = users[index].name
            setIconTintColor(imageView: cell.ic_loc1, color: .white)
            cell.lbl_city1.text = users[index].city
            
            if users[index].city == ""{
                cell.ic_loc1.isHidden = true
            }
            
            if users[index].cohort == "admin" { cell.lbl_group1.text = "VaCay Community" } else { cell.lbl_group1.text = users[index].cohort}
            
            
            
            if gSelectedUsers.contains(where: {$0 === users[index]}){
                cell.btn_add1.setImage(icChecked, for: .normal) // You can set image direct from Storyboard
            }else{
                cell.btn_add1.setImage(icUnchecked, for: .normal) // You can set image direct from Storyboard
                cell.btn_add1.setImageTintColor(UIColor.white)
            }
                

            if self.notifiedUsers.contains(where: {$0.email == users[index].email}){
                cell.mes1.isHidden = false
            }else{
                cell.mes1.isHidden = true
            }
            
                
            cell.btn_add1.tag = index
            cell.btn_add1.addTarget(self, action: #selector(addUser), for: .touchUpInside)
                
            cell.view_item1.isHidden = false
            cell.view_item1.tag = index
            let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.tappedItem1(_ :)))
            cell.view_item1.addGestureRecognizer(tap1)
                
            cell.view_item1.sizeToFit()
                
        }else{
            cell.view_item1.isHidden = true
        }
            
        let index2:Int = indexPath.row * 2 + 1
            
        if users.indices.contains(index2){
            if users[index2].photo_url != ""{
                loadPicture(imageView: cell.img_photo2, url: URL(string: users[index2].photo_url)!)
            }
                
            cell.lbl_name2.text = users[index2].name
            setIconTintColor(imageView: cell.ic_loc2, color: .white)
            cell.lbl_city2.text = users[index2].city
            
            if users[index2].city == ""{
                cell.ic_loc2.isHidden = true
            }
            
            if users[index2].cohort == "admin" { cell.lbl_group2.text = "VaCay Community" } else { cell.lbl_group2.text = users[index2].cohort}
            
            if gSelectedUsers.contains(where: {$0 === users[index2]}){
                cell.btn_add2.setImage(icChecked, for: .normal) // You can set image direct from Storyboard
            }else{
                cell.btn_add2.setImage(icUnchecked, for: .normal) // You can set image direct from Storyboard
                cell.btn_add2.setImageTintColor(UIColor.white)
            }
                
            if self.notifiedUsers.contains(where: {$0.email == users[index2].email}){
                cell.mes2.isHidden = false
            }else{
                cell.mes2.isHidden = true
            }
                
            cell.btn_add2.tag = index2
            cell.btn_add2.addTarget(self, action: #selector(addUser), for: .touchUpInside)
                
            cell.view_item2.isHidden = false
            cell.view_item2.tag = index2
            let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.tappedItem2(_:)))
            cell.view_item2.addGestureRecognizer(tap2)
                
            cell.view_item2.sizeToFit()
                
        }else{
            cell.view_item2.isHidden = true
        }
            
        cell.view_content.sizeToFit()
        cell.view_content.layoutIfNeeded()
            
        return cell
    }
        
    @objc func addUser(sender : UIButton){
        let user = self.users[sender.tag]
        if gSelectedUsers.contains(where: { $0 === user }){
            gSelectedUsers.remove(at: gSelectedUsers.firstIndex(where: {$0 === user})!)
            sender.setImage(icUnchecked, for: .normal)
            sender.setImageTintColor(.white)
        }else{
            gSelectedUsers.append(user)
            sender.setImage(icChecked, for: .normal)
        }
        
        selCountBox.text = String(gSelectedUsers.count)
        
        if gSelectedUsers.count > 0{
            self.selUserButtonsFrame.visibility = .visible
        }else{
            self.selUserButtonsFrame.visibility = .gone
        }
    }
        
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return 190.0
    //    }

        
    @objc func tappedItem1(_ sender:UITapGestureRecognizer? = nil) {
        if self.loadingView.isAnimating{
            return
        }
        if let tag = sender?.view?.tag {
            print(tag)
            gUser = self.users[tag]
            showButtons(option: true)
//            self.openDropDownMenu(sender: sender!)
        }
    }
        
    @objc func tappedItem2(_ sender: UITapGestureRecognizer? = nil) {
        if self.loadingView.isAnimating{
            return
        }
        if let tag = sender?.view?.tag {
            print(tag)
            gUser = self.users[tag]
            showButtons(option: true)
//            self.openDropDownMenu(sender: sender!)

        }
    }
    
    func showButtons(option:Bool){
        if option == true{
            self.user_buttons.view.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
            if gUser.photo_url != "" {
                self.user_buttons.image.visibility = .visible
                loadPicture(imageView: self.user_buttons.image, url: URL(string: gUser.photo_url)!)
            }else{
                self.user_buttons.image.visibility = .gone
            }
            self.user_buttons.buttonView.alpha = 0
            UIView.animate(withDuration: 1.2) {
                self.user_buttons.buttonView.alpha = 1
                self.addChild(self.user_buttons)
                self.view.addSubview(self.user_buttons.view)
            }
        }else{
            self.user_buttons.removeFromParent()
            self.user_buttons.view.removeFromSuperview()
        }
    }
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
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
    
    func getNoitificaitons(){
//        self.getCustomerNotification()
    }
    
    var count:Int = 0
    var refs = [DatabaseReference]()
    
    func getCustomerNotification(){
        var ref:DatabaseReference!
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "order/" + String(thisUser.idx))
        
        ref.observe(.childAdded, with: {(snapshot) -> Void in
            let value = snapshot.value as! [String: Any]
            let timeStamp = value["date"] as! String
            let date = self.getDateFromTimeStamp(timeStamp: Double(timeStamp)!)
            let msg = value["msg"] as! String
            let fromid = value["fromid"] as! String
            let fromname = value["fromname"] as! String
            self.count += 1
            gBadgeCount = self.count
            self.view_notification.visibilityh = .visible
            self.view_noticount.isHidden = false
            self.lbl_noticount.text = String(gBadgeCount)
            UIApplication.shared.applicationIconBadgeNumber = self.count
            AudioServicesPlaySystemSound(SystemSoundID(1106))
//            let noti = Notification()
//            noti.sender_name = fromname
//            noti.message = "Customer's new order: " + fromname
//            noti.date_time = timeStamp
//            noti.image = ""
//            //            self.notiFrame.notis.append(noti)
//            self.notiFrame.notis.insert(noti, at: 0)
//
//            self.refs.insert(snapshot.ref, at: 0)
            
        })
    }
    
    func getHomeData(){
        self.lbl_title.text = gGroupName
        self.users = gUsers
        self.searchUsers = gUsers
        gSelectedUsers.removeAll()
        self.selUserButtonsFrame.visibility = .gone
        if gUsers.count == 0 {
            self.noResult.isHidden = false
        }
        self.userList.reloadData()
    }
    
    @IBAction func toSelChat(_ sender: Any) {
        if gSelectedUsers.count == 0{
            self.showToast(msg: "Please select members.")
            return
        }
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PChatMembersViewController")
        self.modalPresentationStyle = .fullScreen
        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
    }
    
    @IBAction func toSelMessage(_ sender: Any) {
        if gSelectedUsers.count == 0{
            self.showToast(msg: "Please select members.")
            return
        }
        gUser = User()
        gUser.idx = 0
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeSendMessageViewController")
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func clearUserSelections(_ sender: Any) {
        gSelectedUsers.removeAll()
        self.getHomeData()
        self.selUserButtonsFrame.visibility = .gone
    }
    
    
    @objc func openDropDownMenu(sender:UITapGestureRecognizer){
        let view = sender.view as! UIView
        
        let dropDown = DropDown()
        
        dropDown.anchorView = view
        
        dropDown.dataSource = ["  Posts", "  Chat", "  Message"]
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
            print("Selected item: \(item) at index: \(idx)")
            if idx == 0{
                
            }else if idx == 1{
                
            }else if idx == 2{
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeSendMessageViewController")
                self.present(vc, animated: true, completion: nil)
            }
        }
        
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().selectedTextColor = UIColor.white
        DropDown.appearance().textFont = UIFont.boldSystemFont(ofSize: 13.0)
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
                var timeStamp = String(describing: value["time"])
                timeStamp = timeStamp.replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: ")", with: "")
                let time = self.getDateTimeFromTimeStamp(timeStamp: Double(timeStamp)!/1000)

                let user = User()
                user.name = sender_name
                user.email = sender_email
                user.photo_url = sender_photo
                
                if !self.notifiedUsers.contains(where: {$0.email == user.email}) {
                    self.notifiedUsers.append(user)
                    self.userList.reloadData()
                }
                
                print("Notified Users////////////////: \(self.notifiedUsers.count)")
                if self.notifiedUsers.count > 0{
                    self.view_noticount.visibilityh = .visible
                    self.lbl_noticount.text = String(self.notifiedUsers.count)
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
                self.view_noticount.visibilityh = .visible
                self.lbl_noticount.text = String(self.notifiedUsers.count)
            }else{
                self.view_noticount.visibilityh = .gone
            }
        })
    }
    
    func getNotifications(){
        self.notifiedUsers.removeAll()
                
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
                self.view_noticount.visibilityh = .visible
                self.lbl_noticount.text = String(self.notifiedUsers.count)
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
                self.view_noticount.visibilityh = .visible
                self.lbl_noticount.text = String(self.notifiedUsers.count)
            }else{
                self.view_noticount.visibilityh = .gone
            }
        })
    }
    
    
}

















































