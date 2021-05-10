//
//  HomeUserMenu.swift
//  VaCay
//
//  Created by Andre on 7/21/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit
import VoxeetSDK
import VoxeetUXKit
import FirebaseCore
import FirebaseDatabase

class HomeUserMenu: BaseViewController {

    @IBOutlet weak var postsButton: UIView!
    @IBOutlet weak var chatButton: UIView!
    @IBOutlet weak var messageButton: UIView!
    @IBOutlet weak var facetimeButton: UIView!
    
    @IBOutlet weak var ic_post: UIImageView!
    @IBOutlet weak var ic_chat: UIImageView!
    @IBOutlet weak var ic_message: UIImageView!
    @IBOutlet weak var ic_facetime: UIImageView!
    
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var buttonView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        VoxeetUXKit.shared.appearMaximized = true
        VoxeetUXKit.shared.telecom = false
        
        // Example of public variables to change the conference behavior.
        VoxeetSDK.shared.notification.push.type = .callKit
        VoxeetSDK.shared.conference.defaultBuiltInSpeaker = true
        VoxeetSDK.shared.conference.defaultVideo = true
        
        let blurFx = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurFxView = UIVisualEffectView(effect: blurFx)
        blurFxView.frame = view.bounds
        blurFxView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(blurFxView, at: 0)

        postsButton.layer.cornerRadius = 20
        chatButton.layer.cornerRadius = 20
        messageButton.layer.cornerRadius = 20
        facetimeButton.layer.cornerRadius = 20
        
        image.layer.cornerRadius = 20
        
        setIconTintColor(imageView: ic_post, color: .white)
        setIconTintColor(imageView: ic_chat, color: .white)
        setIconTintColor(imageView: ic_message, color: .white)
        setIconTintColor(imageView: ic_facetime, color: .white)
        
        buttonView.alpha = 0
        
        UIView.animate(withDuration: 0.8) {
            self.buttonView.alpha = 1.0
        }
        
        var tap = UITapGestureRecognizer(target: self, action: #selector(self.userPosts(_:)))
        postsButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.userChat(_:)))
        chatButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.showMessageBox(_:)))
        messageButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.openFaceTime(_ :)))
        facetimeButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedBackground(_ :)))
        self.view.addGestureRecognizer(tap)
        
        // Conference destroy observer.
        NotificationCenter.default.addObserver(self, selector: #selector(conferenceDestroyed), name: .VTConferenceDestroyed, object: nil)
        
        // Force the device screen to never going to sleep mode.
        UIApplication.shared.isIdleTimerDisabled = true
        
    }
    
    @objc func tappedBackground(_ sender:UITapGestureRecognizer? = nil) {
        UIView.animate(withDuration: 0.3) {
            self.buttonView.alpha = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Code you want to be delayed
            self.removeFromParent()
            self.view.removeFromSuperview()
//            self.buttonView.alpha = 1
        }
    }
    
    @objc func userPosts(_ sender: UITapGestureRecognizer? = nil) {
        gId = 0
        gPostOpt = "user"
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PostsViewController")
        vc.modalPresentationStyle = .fullScreen
        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
        dismiss()
    }
    
    @objc func userChat(_ sender: UITapGestureRecognizer? = nil) {
        toChat()
        dismiss()
    }
    
    @objc func showMessageBox(_ sender: UITapGestureRecognizer? = nil) {
        toSendMessage()
        dismiss()
    }
    
    @objc func openFaceTime(_ sender: UITapGestureRecognizer? = nil) {
//        facetime(phoneNumber: gUser.phone_number)
        openVideoCall()
    }
    
    func toChat(){
        gSelectedUsers.removeAll()
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PrivateChatViewController")
        self.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func toSendMessage(){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeSendMessageViewController")
        self.present(vc, animated: true, completion: nil)
    }
    
    func dismiss() {
        self.removeFromParent()
        self.view.removeFromSuperview()
    }
    
    var alias:String = ""
    var isUserOnline:Bool = false
    
    private func openVideoCall() {
        self.showLoadingView()
        let participantInfo = VTParticipantInfo(externalID: String(gUser.idx) + String(gUser.idx), name: gUser.name, avatarURL: gUser.photo_url)
        // Conference login
        let myParticipantInfo = VTParticipantInfo(externalID: String(thisUser.idx) + String(thisUser.idx), name: thisUser.name, avatarURL: thisUser.photo_url)
        // Connect a session with participant information.
        VoxeetSDK.shared.session.open(info: myParticipantInfo) { error in
           let options = VTConferenceOptions()
            self.alias =  String(gUser.idx) + "-call-" + String(thisUser.idx)
            options.alias = self.alias
           
           VoxeetSDK.shared.conference.create(options: options, success: { conference in
               let joinOptions = VTJoinOptions()
               joinOptions.constraints.video = true
               VoxeetSDK.shared.conference.join(conference: conference, options: joinOptions, fail: { error in print(error) })
            self.dismissLoadingView()
            // Invite other participants if the conference is just created.
            if conference.isNew {
                VoxeetSDK.shared.notification.invite(conference: conference, participantInfos: [participantInfo], completion: nil)
            }
            self.requestVideoCall(receiver_id: gUser.idx, sender_id: thisUser.idx, alias: self.alias, action: "call_request")
            self.getUserOnlineStatus(alias: self.alias)
            self.dismiss()
           }, fail: {
            error in print(error)
            self.dismissLoadingView()
            self.dismiss()
           })
        }
    }
    
    @objc func conferenceDestroyed(notification: NSNotification) {
        if let conference = notification.userInfo?["conference"] as? VTConference {
            if conference.id == VoxeetSDK.shared.conference.current?.id {
    //          self.dismiss(animated: true, completion: nil)
                print("Dismissing...")
                if !self.isUserOnline {
                    self.requestVideoCall(receiver_id: gUser.idx, sender_id: thisUser.idx, alias: self.alias, action: "call_missed")
                }
            }
        }
    }
    
    func requestVideoCall(receiver_id:Int64, sender_id:Int64, alias:String, action:String){
        APIs.requestVideoCall(receiver_id: receiver_id, sender_id: sender_id, alias: alias, action: action, handleCallback: {
            result in
            print("Call Result Code: \(result)")
        })
    }
    
    func getUserOnlineStatus(alias:String){
        var ref:DatabaseReference!
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "call_response").child(alias)
        ref.observe(.childAdded, with: {(snapshot) -> Void in
            let value = snapshot.value as! [String: Any]
            var timeStamp = String(describing: value["time"])
            timeStamp = timeStamp.replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: ")", with: "")
            let receiver_id = value["receiver_id"] as! String
            let status = value["status"] as! String

            print("receiver: \(receiver_id)")
            print("time: \(timeStamp)")
            print("status: \(status)")
            
            if Int64(receiver_id) == gUser.idx {
                self.isUserOnline = true
                ref.child(snapshot.key).removeValue()
            }
        })
    }
    
    private func facetime(phoneNumber:String) {
      if let facetimeURL:NSURL = NSURL(string: "facetime://\(phoneNumber)") {
        let application:UIApplication = UIApplication.shared
        if (application.canOpenURL(facetimeURL as URL)) {
            application.openURL(facetimeURL as URL);
        }
      }
    }

}
