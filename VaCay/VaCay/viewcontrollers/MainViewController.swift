//
//  MainViewController.swift
//  VaCay
//
//  Created by Andre on 7/22/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit
import DropDown
import MarqueeLabel
import Firebase
import FirebaseDatabase
import AVFoundation
import AudioToolbox

class MainViewController: BaseViewController {

    @IBOutlet weak var menuButton: UIButton!
    
    @IBOutlet weak var view_noticount: UIView!
    @IBOutlet weak var lbl_noticount: UILabel!
    @IBOutlet weak var ic_notification: UIImageView!
    @IBOutlet weak var view_notification: UIView!
    
    @IBOutlet weak var view_meet: UIView!
    @IBOutlet weak var view_group: UIView!
    @IBOutlet weak var view_communities: UIView!
    @IBOutlet weak var view_conferences: UIView!
    @IBOutlet weak var view_posts: UIView!
    @IBOutlet weak var view_messages: UIView!
    @IBOutlet weak var view_nearby: UIView!
    @IBOutlet weak var view_weather: UIView!
    
    @IBOutlet weak var img_meet: UIImageView!
    @IBOutlet weak var mask_meet: UIView!
    @IBOutlet weak var lbl_meet: UILabel!
    
    @IBOutlet weak var img_group: UIImageView!
    @IBOutlet weak var mask_group: UIView!
    @IBOutlet weak var lbl_group: UILabel!
    
    @IBOutlet weak var img_community: UIImageView!
    @IBOutlet weak var mask_community: UIView!
    @IBOutlet weak var lbl_community: UILabel!
    
    @IBOutlet weak var img_conferences: UIImageView!
    @IBOutlet weak var mask_conferences: UIView!
    @IBOutlet weak var lbl_conference: UILabel!
    
    @IBOutlet weak var img_posts: UIImageView!
    @IBOutlet weak var mask_posts: UIView!
    @IBOutlet weak var lbl_posts: UILabel!
    
    @IBOutlet weak var img_messages: UIImageView!
    @IBOutlet weak var mask_messages: UIView!
    @IBOutlet weak var lbl_messages: UILabel!
    
    @IBOutlet weak var img_nearby: UIImageView!
    @IBOutlet weak var mask_nearby: UIView!
    @IBOutlet weak var lbl_nearby: UILabel!
    
    @IBOutlet weak var img_weather: UIImageView!
    @IBOutlet weak var mask_weather: UIView!
    @IBOutlet weak var lbl_weather: UILabel!
    
    @IBOutlet weak var descBox: MarqueeLabel!
    
    var dropDown = DropDown()
    var users = [User]()
    
    var notiFrame:NotisFrame!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gMainViewController = self
        
        if gNote.count > 0{
            showToast2(msg: gNote)
        }

        view_notification.visibilityh = .visible
        view_noticount.isHidden = true
        
        setIconTintColor(imageView:ic_notification, color: UIColor(rgb: 0xffffff, alpha: 0.8))
        
        notiFrame = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "NotisFrame")
        notiFrame.view.frame = CGRect(x: 0, y: -screenHeight, width: screenWidth, height: screenHeight)
        
        setRoundShadowView(view: view_meet, corner: 5)
        setRoundShadowView(view: view_group, corner: 5)
        setRoundShadowView(view: view_communities, corner: 5)
        setRoundShadowView(view: view_conferences, corner: 5)
        setRoundShadowView(view: view_posts, corner: 5)
        setRoundShadowView(view: view_messages, corner: 5)
        setRoundShadowView(view: view_nearby, corner: 5)
        setRoundShadowView(view: view_weather, corner: 5)
        
        img_meet.layer.cornerRadius = 5
        img_group.layer.cornerRadius = 5
        img_community.layer.cornerRadius = 5
        img_conferences.layer.cornerRadius = 5
        img_posts.layer.cornerRadius = 5
        img_messages.layer.cornerRadius = 5
        img_nearby.layer.cornerRadius = 5
        img_weather.layer.cornerRadius = 5
        
        mask_meet.layer.cornerRadius = 5
        mask_group.layer.cornerRadius = 5
        mask_community.layer.cornerRadius = 5
        mask_conferences.layer.cornerRadius = 5
        mask_posts.layer.cornerRadius = 5
        mask_messages.layer.cornerRadius = 5
        mask_nearby.layer.cornerRadius = 5
        mask_weather.layer.cornerRadius = 5
        
        lbl_meet.layer.cornerRadius = lbl_meet.frame.height / 2
        lbl_group.layer.cornerRadius = lbl_group.frame.height / 2
        lbl_community.layer.cornerRadius = lbl_community.frame.height / 2
        lbl_posts.layer.cornerRadius = lbl_posts.frame.height / 2
        lbl_conference.layer.cornerRadius = lbl_conference.frame.height / 2
        lbl_messages.layer.cornerRadius = lbl_messages.frame.height / 2
        lbl_nearby.layer.cornerRadius = lbl_nearby.frame.height / 2
        lbl_weather.layer.cornerRadius = lbl_weather.frame.height / 2
        
        lbl_meet?.layer.masksToBounds = true
        lbl_group?.layer.masksToBounds = true
        lbl_community?.layer.masksToBounds = true
        lbl_posts?.layer.masksToBounds = true
        lbl_conference?.layer.masksToBounds = true
        lbl_messages?.layer.masksToBounds = true
        lbl_nearby?.layer.masksToBounds = true
        lbl_weather?.layer.masksToBounds = true
        
        menuButton.setImageTintColor(.lightGray)
        
        dropDown.anchorView = menuButton
        dropDown.dataSource = ["  My Profile", "  Log Out"]
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            if index == 0{
                self.showMyProfile()
            }else if index == 1{
                self.logout()
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
        
        var tap = UITapGestureRecognizer(target: self, action: #selector(self.toMeet(_:)))
        view_meet.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.getGroups))
        view_group.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.getCommunities(_:)))
        view_communities.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.getPosts(_:)))
        view_posts.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.getConfs(_:)))
        view_conferences.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.getMessages(_:)))
        view_messages.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.getNearby(_:)))
        view_nearby.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.showWeather(_:)))
        view_weather.addGestureRecognizer(tap)
        
        self.menuButton.setImage(getImageFromURL(url: URL(string: thisUser.photo_url)!), for: .normal)
        self.menuButton.layer.cornerRadius = self.menuButton.frame.height / 2
        self.menuButton.layer.masksToBounds = true
        
        if gFCMToken.count > 0{
            registerFCMToken(member_id: thisUser.idx, token: gFCMToken)
        }
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.showNotifications(_:)))
        view_notification.addGestureRecognizer(tap)
        
        self.notifiedUsers.removeAll()
        self.getChatNotifiedUsers()
        self.getNotifications()
        self.getCallNotifications()
        
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
    
    func registerFCMToken(member_id: Int64, token:String){
        APIs.registerFCMToken(member_id: member_id, token: token, handleCallback: {
            fcm_token, result_code in
            if result_code == "0"{
                print("token registered!!!", fcm_token)
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        gId = 0
        gRecentViewController = self
        self.getHomeData(member_id: thisUser.idx)
        self.getUnreadCount(member_id: thisUser.idx)
    }
    
    @objc func toMeet(_ sender: UITapGestureRecognizer? = nil) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeViewController")
        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
    }
    
    @objc func getGroups(_ sender: UITapGestureRecognizer? = nil) {
        gUsers = self.users
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeCohortViewController")
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func getCommunities(_ sender: UITapGestureRecognizer? = nil) {
        if gGroups.count == 0{
            showToast(msg: "No community you belong to.")
            return
        }
        gUsers = self.users
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeGroupViewController")
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func getPosts(_ sender: UITapGestureRecognizer? = nil) {
        gId = 0
        gPostOpt = "all"
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PostsViewController")
        vc.modalPresentationStyle = .fullScreen
        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
    }
    
    @objc func getConfs(_ sender: UITapGestureRecognizer? = nil) {
        gSelectedGroupId = 0
        gSelectedCohort = ""
        gId = 0
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ConferencesViewController")
        vc.modalPresentationStyle = .fullScreen
        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
    }
    
    @objc func getMessages(_ sender: UITapGestureRecognizer? = nil) {
        gId = 0
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MessageViewController")
        vc.modalPresentationStyle = .fullScreen
        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
    }
    
    @objc func getNearby(_ sender: UITapGestureRecognizer? = nil) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "NearbyMenuViewController")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func showWeather(_ sender: UITapGestureRecognizer? = nil) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "WeatherViewController")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func openMenu(_ sender: Any) {
        dropDown.show()
    }
    
    func showMyProfile(){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ProfileViewController")
        vc.modalPresentationStyle = .fullScreen
        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
    }
    
    func getHomeData(member_id:Int64){
        self.showLoadingView()
        APIs.getHomeData(member_id: member_id, handleCallback: {
            users, groups, admin, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                gGroups = groups!
                self.users = users!
                
                let admins = users!.filter{ user in
                    return user.idx == thisUser.admin_id
                }
                
                if admins.count > 0 {
                    gAdmin = admins[0]
                }else {
                    gAdmin = admin!
                }
            }
            else{
                if result_code == "1" {
                    self.logout()
                }else if result_code == "2" {
                    /// cohort is empty and update profile //////////////////////////////
                }else {
                    self.logout()
                }
            }
        })
    }
    
    func getUnreadCount(member_id:Int64){
        APIs.getUnreadCount(me_id: member_id, handleCallback: {
            unreads, result_code in
            print(result_code)
            if result_code == "0"{
                if Int(unreads)! > 0{
                    self.lbl_messages.backgroundColor = UIColor(rgb: 0xFF0000, alpha: 1.0)
                }else {
                    self.lbl_messages.backgroundColor = UIColor(rgb: 0x000000, alpha: 0.35)
                }
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
                    let currentVC = UIApplication.getTopViewController()
                    if currentVC is BaseViewController {
                        (currentVC as! BaseViewController).showCallAlertDialog(title: noti.sender.name, message: "Incoming call...", alias: noti.id, ref: ref.child(key))
                    }
                }
                
                if !self.notifiedUsers.contains(where: {$0.idx == user.idx}) {
                    self.notifiedUsers.append(user)
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
