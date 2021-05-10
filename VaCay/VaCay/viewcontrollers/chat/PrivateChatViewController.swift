//
//  PrivateChatViewController.swift
//  VaCay
//
//  Created by Andre on 8/3/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit
import Kingfisher
import SCLAlertView
import YPImagePicker
import SwiftyJSON
import DropDown
import Auk
import DynamicBlurView
import GSImageViewerController
import Firebase
import FirebaseDatabase
import FirebaseStorage
import AVFoundation
import AVKit
import AudioToolbox

class PrivateChatViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var commentList: UITableView!
    @IBOutlet weak var attachButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var commentBox: UITextView!
    @IBOutlet weak var commentImageBox: UIImageView!
    @IBOutlet weak var noResult: UILabel!
    @IBOutlet weak var view_emoji: UIView!
    @IBOutlet weak var img_user: UIImageView!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_status: UILabel!
    
    @IBOutlet weak var lbl_emoji0: UILabel!
    @IBOutlet weak var lbl_emoji1: UILabel!
    @IBOutlet weak var lbl_emoji2: UILabel!
    @IBOutlet weak var lbl_emoji3: UILabel!
    @IBOutlet weak var lbl_emoji4: UILabel!
    @IBOutlet weak var lbl_emoji5: UILabel!
    @IBOutlet weak var lbl_emoji6: UILabel!
    @IBOutlet weak var lbl_emoji7: UILabel!
    @IBOutlet weak var lbl_emoji8: UILabel!
    @IBOutlet weak var lbl_emoji9: UILabel!
    
    @IBOutlet weak var lbl_notified: UILabel!
    @IBOutlet weak var btn_menu: UIButton!
    
    var imageFile:Data!
    var ImageArray = NSMutableArray()
    
    var comments = [Comment]()
    
    var emojiButtons = [UILabel]()
    var emojiStrings = [String]()
    
    var CHAT_ID:String = ""
    var CHAT_ID2:String = ""
    
    @IBOutlet weak var btn_image_upload: UIButton!
    @IBOutlet weak var btn_image_cancel: UIButton!
    @IBOutlet weak var view_image_form: UIView!
    
    @IBOutlet weak var img_user1: UIImageView!
    @IBOutlet weak var img_user2: UIImageView!
    @IBOutlet weak var img_user3: UIImageView!
    
    @IBOutlet weak var lbl_status2: UILabel!
    
    var userImages = [UIImageView]()
    
    var isUserOnline:Bool = false
    var isMeOnline:Bool = true
    
    var menu = [String]()
    var blocked_me:Bool = false
    var blocked_user:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gRecentViewController = self
        gPrivateChatViewController = self
        
        lbl_status2.isHidden = true
        lbl_status.visibility = .gone

        addShadowToBar(view: navBar)
        
        lbl_notified.layer.cornerRadius = 3
        lbl_notified.layer.masksToBounds = true
        lbl_notified.visibilityh = .gone
        
        btn_menu.setImageTintColor(.white)
        
        sendButton.setImageTintColor(primaryDarkColor)
        btn_image_upload.layer.cornerRadius = btn_image_upload.frame.height / 2
        btn_image_cancel.layer.cornerRadius = btn_image_cancel.frame.height / 2
        
        img_user.layer.cornerRadius = img_user.frame.height / 2
        
        view_emoji.visibility = .gone
        
        sendButton.visibilityh = .gone
        
        userImages = [img_user1, img_user2, img_user3]
        for userImage in userImages{
            userImage.isHidden = true
            userImage.layer.cornerRadius = userImage.frame.height / 2
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(showParticipants))
            userImage.isUserInteractionEnabled = true
            userImage.addGestureRecognizer(tap)
        }
        
        commentBox.layer.cornerRadius = commentBox.frame.height / 2
        
        self.view_image_form.isHidden = true
        
        commentBox.setPlaceholder(string: "Write something ...")
        commentBox.textContainerInset = UIEdgeInsets(top: commentBox.textContainerInset.top, left: 8, bottom: commentBox.textContainerInset.bottom, right: 5)
//        commentBox.becomeFirstResponder()
        
        self.commentList.delegate = self
        self.commentList.dataSource = self
        
        self.commentList.estimatedRowHeight = 170.0
        self.commentList.rowHeight = UITableView.automaticDimension
        
        UITextView.appearance().linkTextAttributes = [ .foregroundColor: UIColor.yellow ]
        
        emojiButtons = [lbl_emoji0, lbl_emoji1, lbl_emoji2, lbl_emoji3, lbl_emoji4, lbl_emoji5, lbl_emoji6, lbl_emoji7, lbl_emoji8, lbl_emoji9]
        emojiStrings = ["Close", "💖","👍","😊","😄","😍","🙁","😂","😠","😛"]
        
        for emjButton in emojiButtons {
            let index = emojiButtons.firstIndex(of: emjButton)!
            emjButton.text = emojiStrings[index].decodeEmoji
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(addEmoji))
            emjButton.tag = index
            emjButton.isUserInteractionEnabled = true
            emjButton.addGestureRecognizer(tap)
        }
        
        loadPicture(imageView: img_user, url: URL(string: gUser.photo_url)!)
        lbl_name.text = gUser.name
        
        CHAT_ID = thisUser.email.replacingOccurrences(of: ".", with: "ddoott") + "_" + gUser.email.replacingOccurrences(of: ".", with: "ddoott")
        CHAT_ID2 = gUser.email.replacingOccurrences(of: ".", with: "ddoott") + "_" + thisUser.email.replacingOccurrences(of: ".", with: "ddoott")
        
        self.getComments()
        self.getUserEndSnapshotKeyList()
        
        self.beParticipant(online: true)
        self.removeExternalReceivedNotification()
        self.getUserStatus()
        self.updateUI()
        
        // Move this viewcontroller to background by clicking on Home Button
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appToBackground),
            name: UIApplication.willResignActiveNotification,
            object: nil)
        
        // Move this viewcontroller to foreground by clicking on app icon
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appToForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil)
    
    }
    
    @objc func appToBackground(notification: NSNotification) {
        print("I moved to background")
        isMeOnline = false
        self.beParticipant(online: false)
    }
    
    @objc func appToForeground(notification: NSNotification) {
        print("I moved to foreground.")
        isMeOnline = true
        self.beParticipant(online: true)
    }
    
    @objc func addEmoji(sender:UITapGestureRecognizer){
        let label = sender.view as! UILabel
        let index = label.tag
        if index == 0 {
            self.view_emoji.visibility = .gone
        }else{
            self.commentBox.text = self.commentBox.text + emojiStrings[index].decodeEmoji
            self.commentBox.checkPlaceholder()
            if self.commentBox.text == ""{
                sendButton.visibilityh = .gone
            }else{
                sendButton.visibilityh = .visible
            }
        }
    }

    @IBAction func back(_ sender: Any) {
        self.beParticipant(online: false)
        isMeOnline = false
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // Close this viewcontroller manually without clicking on close button
        print("I've gone")
        isMeOnline = false
        self.beParticipant(online: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("I am here")
        isMeOnline = true
        self.beParticipant(online: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isMeOnline = false
        self.beParticipant(online: false)
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
        return comments.count
    }
            
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell:ConfCommentCell = tableView.dequeueReusableCell(withIdentifier: "ConfCommentCell", for: indexPath) as! ConfCommentCell
                
        let index:Int = indexPath.row
        
        self.commentList.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
                
        if comments.indices.contains(index) {
            
            let comment = comments[index]
            
            if comment.user.idx == thisUser.idx {
                if comment.disp == 0 {
                    cell.myImageBox.roundCorners(corners: [.topLeft, .topRight, .bottomLeft], radius: 15)
                    cell.myCommentBox.roundCorners(corners: [.topLeft, .topRight, .bottomLeft], radius: 15)
                    cell.myCommentedTimeBox.visibility = .visible
                }else if comment.disp == 1 {
                    cell.myImageBox.roundCorners(corners: [.topLeft, .bottomLeft], radius: 15)
                    cell.myCommentBox.roundCorners(corners: [.topLeft, .bottomLeft], radius: 15)
                    cell.myCommentedTimeBox.visibility = .gone
                }else if comment.disp == 2 {
                    cell.myImageBox.roundCorners(corners: [.topLeft, .topRight, .bottomLeft], radius: 15)
                    cell.myCommentBox.roundCorners(corners: [.topLeft, .topRight, .bottomLeft], radius: 15)
                    cell.myCommentedTimeBox.visibility = .visible
                }else if comment.disp == 3 {
                    cell.myImageBox.roundCorners(corners: [.topLeft, .bottomLeft], radius: 15)
                    cell.myCommentBox.roundCorners(corners: [.topLeft, .bottomLeft], radius: 15)
                    cell.myCommentedTimeBox.visibility = .gone
                }
                
                cell.contentLayout.visibility = .gone
                cell.myContentLayout.visibility = .visible
                
                if comment.image_url != ""{
                    if comment.image_url.count < 1000 {
                        loadPicture(imageView: cell.myImageBox, url: URL(string: comment.image_url)!)
                    }
                    cell.myImageBox.visibility = .visible
                }else{
                    if comment.video_url != "" {
                        cell.imageBox.image = UIImage(named: "video")
                        cell.imageBox.visibility = .visible
                    }else{
                        cell.myImageBox.visibility = .gone
                    }
                }

                cell.myImageBox.layer.borderColor = UIColor(rgb: 0xcce6ff, alpha: 1.0).cgColor
                cell.myImageBox.layer.borderWidth = 5

                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(gesture:)))

                cell.myImageBox.tag = index
                cell.myImageBox.addGestureRecognizer(tapGesture)
                cell.myImageBox.isUserInteractionEnabled = true

                if comment.comment != ""{
                    cell.myCommentBox.text = comment.comment.decodeEmoji
                    cell.myCommentBox.visibility = .visible
                }else{
                    cell.myCommentBox.visibility = .gone
                }

                cell.myCommentBox.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)

                cell.myCommentedTimeBox.text = comment.commented_time
                
                cell.myMenuButton.tag = index
                cell.myMenuButton.addTarget(self, action: #selector(self.openDropDownMenu), for: .touchUpInside)
                            
                // setRoundShadowView(view: cell.contentLayout, corner: 5.0)
                                    
                cell.myCommentBox.sizeToFit()
                cell.myContentLayout.sizeToFit()
                cell.myContentLayout.layoutIfNeeded()
                
            }else{
                if comment.disp == 0 {
                    cell.imageBox.roundCorners(corners: [.topRight, .bottomLeft, .bottomRight], radius: 15)
                    cell.commentBox.roundCorners(corners: [.topRight, .bottomLeft, .bottomRight], radius: 15)
                    cell.view_user.visibility = .visible
                }else if comment.disp == 1 {
                    cell.imageBox.roundCorners(corners: [.topRight, .bottomRight], radius: 15)
                    cell.commentBox.roundCorners(corners: [.topRight, .bottomRight], radius: 15)
                    cell.view_user.visibility = .visible
                }else if comment.disp == 2 {
                    cell.imageBox.roundCorners(corners: [.topRight, .bottomLeft, .bottomRight], radius: 15)
                    cell.commentBox.roundCorners(corners: [.topRight, .bottomLeft, .bottomRight], radius: 15)
                    cell.view_user.visibility = .gone
                }else if comment.disp == 3 {
                    cell.imageBox.roundCorners(corners: [.topRight, .bottomRight], radius: 15)
                    cell.commentBox.roundCorners(corners: [.topRight, .bottomRight], radius: 15)
                    cell.view_user.visibility = .gone
                }
                
                cell.contentLayout.visibility = .visible
                cell.myContentLayout.visibility = .gone
                
                if comment.image_url != ""{
                    if comment.image_url.count < 1000 {
                        loadPicture(imageView: cell.imageBox, url: URL(string: comment.image_url)!)
                    }
                    cell.imageBox.visibility = .visible
                }else{
                    if comment.video_url != "" {
                        cell.imageBox.image = UIImage(named: "video")
                        cell.imageBox.visibility = .visible
                    }else{
                        cell.imageBox.visibility = .gone
                    }
                }
                
                cell.imageBox.layer.borderColor = UIColor(rgb: 0xe6e6e6, alpha: 1.0).cgColor
                cell.imageBox.layer.borderWidth = 5
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(gesture:)))

                cell.imageBox.tag = index
                cell.imageBox.addGestureRecognizer(tapGesture)
                cell.imageBox.isUserInteractionEnabled = true
                
                if comment.user.photo_url != ""{
                    loadPicture(imageView: cell.userPicture, url: URL(string: comment.user.photo_url)!)
                }else {
                    cell.userPicture.image = UIImage(named: "ic_user")
                }
                
                cell.userPicture.layer.cornerRadius = cell.userPicture.frame.width / 2
                
                if comment.comment != ""{
                    cell.commentBox.text = comment.comment.decodeEmoji
                    cell.commentBox.visibility = .visible
                }else{
                    cell.commentBox.visibility = .gone
                }
                
                cell.commentBox.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
                
                cell.commentedTimeBox.text = comment.commented_time
                
                cell.menuButton.tag = index
                cell.menuButton.addTarget(self, action: #selector(self.openDropDownMenu), for: .touchUpInside)
                            
                // setRoundShadowView(view: cell.contentLayout, corner: 5.0)
                                    
                cell.commentBox.sizeToFit()
                cell.contentLayout.sizeToFit()
                cell.contentLayout.layoutIfNeeded()
            }
                
        }
        
        return cell
        
    }
    
    @objc func imageTapped(gesture:UITapGestureRecognizer){
        if (gesture.view as? UIImageView) != nil {
            print("Image Tapped")
            let imgView = gesture.view as! UIImageView
            let index = imgView.tag
            let comment = comments[index]
            
            if comment.image_url != "" && comment.video_url == ""{
                let image = self.getImageFromURL(url: URL(string: comment.image_url)!)
                if image != nil {
                    let imageInfo   = GSImageInfo(image: image, imageMode: .aspectFit)
                    let transitionInfo = GSTransitionInfo(fromView:imgView)
                    let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
                        
                    imageViewer.dismissCompletion = {
                            print("dismissCompletion")
                    }
                        
                    self.present(imageViewer, animated: true, completion: nil)
                }
            }else{
                if comment.video_url != "" {
                    gComment = comment
                    let vc = self.storyboard?.instantiateViewController(identifier: "VideoPlayViewController")
                    self.modalPresentationStyle = .fullScreen
                    self.present(vc!, animated: false, completion: nil)
                }
            }
        }
    }
    
    var editF:Bool = false
    var indx:Int!
    
    @objc func openDropDownMenu(sender:UIButton){
        let index = sender.tag
        let cell = sender.superview?.superviewOfClassType(ConfCommentCell.self) as! ConfCommentCell
        
        let dropDown = DropDown()
        
        let comment = self.comments[index]
        print("comment index: \(index)")
        print("comment key: \(comment.key)")
        
        if comment.user.idx == thisUser.idx{
            dropDown.anchorView = cell.myMenuButton
            dropDown.dataSource = ["  Edit", "  Delete"]
            // Action triggered on selection
            dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
                print("Selected item: \(item) at index: \(idx)")
                if idx == 0{
                    self.commentBox.text = comment.comment
                    self.commentBox.checkPlaceholder()
                    self.commentBox.becomeFirstResponder()
                    self.editF = true
                    self.indx = index
                }else if idx == 1{
                    let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this message?", preferredStyle: .alert)
                    let noAction = UIAlertAction(title: "No", style: .cancel, handler: {
                        (action : UIAlertAction!) -> Void in })
                    let yesAction = UIAlertAction(title: "Yes", style: .destructive, handler: { alert -> Void in
                        var ref:DatabaseReference!
                        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "messages").child(self.CHAT_ID).child(comment.key)
                        ref.removeValue()
                        let userEndKey = self.uKeys[index]
                        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "messages").child(self.CHAT_ID2).child(userEndKey)
                        ref.removeValue()
                    })
                    
                    alert.addAction(yesAction)
                    alert.addAction(noAction)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }else{
            dropDown.anchorView = cell.menuButton
            dropDown.dataSource = ["  Message"]
            // Action triggered on selection
            dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
                print("Selected item: \(item) at index: \(idx)")
                if idx == 0{
                    gUser = comment.user
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeSendMessageViewController")
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
        dropDown.width = 100
        
        dropDown.show()
        
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        textView.checkPlaceholder()
        if textView.text == ""{
            sendButton.visibilityh = .gone
        }else{
            sendButton.visibilityh = .visible
        }
        self.isTyping(typedText: self.commentBox.text)
    }
    
    @IBAction func openAttachMenu(_ sender: Any) {
        
        let dropDown = DropDown()
        
        dropDown.anchorView = self.attachButton
        dropDown.dataSource = ["  📷".decodeEmoji, "  😊".decodeEmoji]
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
            if idx == 0{
                var picker:YPImagePicker!
                var config = YPImagePickerConfiguration()
                config.wordings.libraryTitle = "Gallery"
                config.wordings.cameraTitle = "Camera"
                YPImagePickerConfiguration.shared = config
                picker = YPImagePicker()
                picker.didFinishPicking { [picker] items, _ in
                    if let photo = items.singlePhoto {
                        self.commentImageBox.image = photo.image
                        self.commentImageBox.layer.cornerRadius = 5
                        self.view_image_form.isHidden = false
                        self.imageFile = photo.image.jpegData(compressionQuality: 0.8)
                    }
                    picker!.dismiss(animated: true, completion: nil)
                }
                self.present(picker, animated: true, completion: nil)
            }else if idx == 1{
                self.view_emoji.visibility = .visible
            }
        }
        
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().selectedTextColor = UIColor.white
        DropDown.appearance().textFont = UIFont.boldSystemFont(ofSize: 25.0)
        DropDown.appearance().backgroundColor = UIColor.white
        DropDown.appearance().selectionBackgroundColor = UIColor.gray
        DropDown.appearance().cellHeight = 45
        
        dropDown.separatorColor = UIColor.lightGray
        dropDown.width = 70
        
        dropDown.show()
        
    }
    
    @IBAction func submitComment(_ sender: Any) {
        if commentBox.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            showToast(msg: "Please type something...")
            return
        }
        
        if editF {
            var ref:DatabaseReference!
            let selComment = self.comments[self.indx]
            ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "messages").child(self.CHAT_ID).child(selComment.key).child("message")
            ref.setValue(self.commentBox.text)
            let userEndKey = self.uKeys[self.indx]
            ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "messages").child(self.CHAT_ID2).child(userEndKey).child("message")
            ref.setValue(self.commentBox.text)
            editF = false
            self.commentBox.text = ""
            self.commentBox.checkPlaceholder()
            self.commentBox.resignFirstResponder()
            self.sendButton.visibilityh = .gone
            return
        }
        
        var ref:DatabaseReference!
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "messages").child(CHAT_ID).childByAutoId()
        let load:[String:AnyObject] =
            [
                "user": thisUser.email as AnyObject,
                "message": self.commentBox.text as AnyObject,
                "image": "" as AnyObject,
                "video": "" as AnyObject,
                "lat": "" as AnyObject,
                "lon": "" as AnyObject,
                "time": String(Date().currentTimeMillis()) as AnyObject
            ]
        ref.setValue(load)
        
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "messages").child(CHAT_ID2).childByAutoId()
        let load2:[String:AnyObject] =
            [
                "user": thisUser.email as AnyObject,
                "message": self.commentBox.text as AnyObject,
                "image": "" as AnyObject,
                "video": "" as AnyObject,
                "lat": "" as AnyObject,
                "lon": "" as AnyObject,
                "time": String(Date().currentTimeMillis()) as AnyObject
            ]
        ref.setValue(load2)
        
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "notification")
            .child(gUser.email.replacingOccurrences(of: ".", with: "ddoott")).child(thisUser.email.replacingOccurrences(of: ".", with: "ddoott"))
        ref.removeValue()
        ref = ref.childByAutoId()
        let load3:[String:AnyObject] =
            [
                "sender_id": String(thisUser.idx) as AnyObject,
                "sender": thisUser.email as AnyObject,
                "senderName": thisUser.name as AnyObject,
                "senderPhoto": thisUser.photo_url as AnyObject,
                "msg": self.commentBox.text as AnyObject,
                "time": String(Date().currentTimeMillis()) as AnyObject
            ]
        ref.setValue(load3)
        
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "notification2")
            .child(gUser.email.replacingOccurrences(of: ".", with: "ddoott")).child(thisUser.email.replacingOccurrences(of: ".", with: "ddoott"))
        ref.removeValue()
        ref = ref.childByAutoId()
        let load4:[String:AnyObject] =
            [
                "sender_id": String(thisUser.idx) as AnyObject,
                "sender": thisUser.email as AnyObject,
                "senderName": thisUser.name as AnyObject,
                "senderPhoto": thisUser.photo_url as AnyObject,
                "msg": self.commentBox.text as AnyObject,
                "time": String(Date().currentTimeMillis()) as AnyObject
            ]
        ref.setValue(load4)
        
        self.beParticipant(online: true)
        
        let message = self.commentBox.text

        self.commentBox.text = ""
        self.commentBox.checkPlaceholder()
        self.commentBox.resignFirstResponder()
        self.sendButton.visibilityh = .gone
        
        // Send Push Notification
        if !isUserOnline {
            self.sendChatPush(receiver_id: gUser.idx, sender_id: thisUser.idx, message: message!)
        }
                
    }
    
    func deleteComment(comment_id: Int64){
        
    }
    
    func getComments(){
        self.comments.removeAll()
        self.showLoadingView()
        var ref:DatabaseReference!
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "messages").child(CHAT_ID)
        print("CHAT ID: \(CHAT_ID)")
        ref.observe(.childAdded, with: {(snapshot) -> Void in
            let value = snapshot.value as! [String: Any]
            var timeStamp = String(describing: value["time"])
            timeStamp = timeStamp.replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: ")", with: "")
            let time = self.getDateTimeFromTimeStamp(timeStamp: Double(timeStamp)!/1000)
            let message = value["message"] as! String
            let image = value["image"] as! String
            let video = value["video"] as! String
            let sender_email = value["user"] as! String

            print("\(time)")
            print("\(message)")
            print("\(sender_email)")
            
            let comment = Comment()
            var user = User()
            if gMainViewController.users.contains(where: {$0.email == sender_email}){
                user = gMainViewController.users.filter{ user in
                    return user.email == sender_email
                }[0]
            }else if sender_email == thisUser.email {
                user = thisUser
            }
            comment.user = user
            comment.commented_time = time
            comment.timestamp = Int64(timeStamp)!
            comment.comment = message
            if image.count < 1000{
                comment.image_url = image
            }
            comment.video_url = video
            comment.key = snapshot.key
            
            print("Snapshot Key: \(snapshot.key)")
            
            if self.comments.count == 0{
                comment.disp = 0
            }else{
                if self.comments[self.comments.count - 1].user.idx == comment.user.idx {
                    if self.comments[self.comments.count - 1].timestamp + 60000 < comment.timestamp {
                        comment.disp = 0
                    }else{
                        if comment.user.idx == thisUser.idx {
                            comment.disp = 1
                        }else{
                            comment.disp = 2
                            if self.comments[self.comments.count - 1].disp == 0{
                                self.comments[self.comments.count - 1].disp = 1
                            }else{
                                self.comments[self.comments.count - 1].disp = 3
                            }
                        }
                    }
                }else{
                    comment.disp = 0
                }
            }

            self.comments.append(comment)
            
            print("comments1: \(self.comments.count)")

            self.commentList.reloadData()
            self.scrollToBottom()

        })
        
        ref.observe(.childRemoved, with: {(snapshot) -> Void in
            print("Removed////////////////: \(snapshot.key)")
            let key = snapshot.key
            if self.comments.contains(where: {$0.key == key}){
                self.comments.remove(at: self.comments.firstIndex(where: {$0.key == key})!)
                print("comments2: \(self.comments.count)")
                self.commentList.reloadData()
            }
        })
        
        ref.observe(.childChanged, with: {(snapshot) -> Void in
            print("Changed////////////////: \(snapshot.key)")
            let key = snapshot.key
            let value = snapshot.value as! [String: Any]
            let message = value["message"] as! String
            if self.comments.contains(where: {$0.key == key}){
                self.comments.filter{ comment in
                    return comment.key == key
                    }[0].comment = message
                self.commentList.reloadData()
            }
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.dismissLoadingView()
        }
        
    }
    
    func scrollToBottom(){
        let indexPath = NSIndexPath(row: self.comments.count-1, section: 0)
        self.commentList.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
    }
    
    func getUserStatus(){
        var ref:DatabaseReference!
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "status").child(CHAT_ID)
        print("CHAT ID: \(CHAT_ID)")
        ref.observe(.childAdded, with: {(snapshot) -> Void in
            let value = snapshot.value as! [String: Any]
            var timeStamp = String(describing: value["time"])
            timeStamp = timeStamp.replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: ")", with: "")
            let time = self.getDateTimeFromTimeStamp(timeStamp: Double(timeStamp)!/1000)
            let status = value["online"] as! String

            print("\(time)")
            print("\(status)")
            
            self.lbl_status2.text = ""
            self.lbl_status2.isHidden = true

            if status == "offline" {
                self.lbl_status.text = "Last seen at " + time
                self.isUserOnline = false
            }else if status == "online" {
                self.lbl_status.text = "Online"
                self.isUserOnline = true
            }else {
                self.lbl_status.text = status
                if status.starts(with: "is typing"){
                    self.lbl_status2.text = gUser.name + " " + status
                    self.lbl_status2.isHidden = false
                    self.isUserOnline = true
                }
            }
            self.lbl_status.visibility = .visible
        })
    }
    
    func isTyping(typedText: String) {
        var ref:DatabaseReference!
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "status").child(CHAT_ID2)
        ref.removeValue()
        let subRef = ref.childByAutoId()
        if typedText.count > 0{
            let load:[String:AnyObject] =
                [
                    "user": thisUser.email as AnyObject,
                    "time": String(Date().currentTimeMillis()) as AnyObject,
                    "online": "is typing..." as AnyObject
                ]
            subRef.setValue(load)
        }else {
            let load:[String:AnyObject] =
                [
                    "user": thisUser.email as AnyObject,
                    "time": String(Date().currentTimeMillis()) as AnyObject,
                    "online": "online" as AnyObject
                ]
            subRef.setValue(load)
        }
    }
    
    func uploadFileToStorage(file:Data){
        
        self.showLoadingView()
        
        // Get a reference to the storage service using the default Firebase App
        // Get a non-default Storage bucket
        let storage = Storage.storage(url:"gs://vacay-demo-1c8e4.appspot.com")
        let storageRef = storage.reference()

        // Create a reference to the file you want to upload
        let fileRef = storageRef.child(String(Date().currentTimeMillis()) + ".jpg")

        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = fileRef.putData(file, metadata: nil) { (metadata, error) in
          guard let metadata = metadata else {
            // Uh-oh, an error occurred!
            return
          }
          // Metadata contains file metadata such as size, content-type.
          let size = metadata.size
          // You can also access to download URL after upload.
          fileRef.downloadURL { (url, error) in
            self.dismissLoadingView()
            guard let downloadURL = url else {
              // Uh-oh, an error occurred!
              return
            }
            print("Download URL: \(downloadURL)")
            
            var ref:DatabaseReference!
            ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "messages").child(self.CHAT_ID).childByAutoId()
            let load:[String:AnyObject] =
                [
                    "user": thisUser.email as AnyObject,
                    "message": "" as AnyObject,
                    "image": "\(downloadURL)" as AnyObject,
                    "video": "" as AnyObject,
                    "lat": "" as AnyObject,
                    "lon": "" as AnyObject,
                    "time": String(Date().currentTimeMillis()) as AnyObject
                ]
            ref.setValue(load)
            
            ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "messages").child(self.CHAT_ID2).childByAutoId()
            let load2:[String:AnyObject] =
                [
                    "user": thisUser.email as AnyObject,
                    "message": "" as AnyObject,
                    "image": "\(downloadURL)" as AnyObject,
                    "video": "" as AnyObject,
                    "lat": "" as AnyObject,
                    "lon": "" as AnyObject,
                    "time": String(Date().currentTimeMillis()) as AnyObject
                ]
            ref.setValue(load2)
            
            ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "notification")
                .child(gUser.email.replacingOccurrences(of: ".", with: "ddoott")).child(thisUser.email.replacingOccurrences(of: ".", with: "ddoott"))
            ref.removeValue()
            ref = ref.childByAutoId()
            let load3:[String:AnyObject] =
                [
                    "sender_id": String(thisUser.idx) as AnyObject,
                    "sender": thisUser.email as AnyObject,
                    "senderName": thisUser.name as AnyObject,
                    "senderPhoto": thisUser.photo_url as AnyObject,
                    "msg": "Shared a file" as AnyObject,
                    "time": String(Date().currentTimeMillis()) as AnyObject
                ]
            ref.setValue(load3)
            
            ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "notification2")
                .child(gUser.email.replacingOccurrences(of: ".", with: "ddoott")).child(thisUser.email.replacingOccurrences(of: ".", with: "ddoott"))
            ref.removeValue()
            ref = ref.childByAutoId()
            let load4:[String:AnyObject] =
                [
                    "sender_id": String(thisUser.idx) as AnyObject,
                    "sender": thisUser.email as AnyObject,
                    "senderName": thisUser.name as AnyObject,
                    "senderPhoto": thisUser.photo_url as AnyObject,
                    "msg": "Shared a file" as AnyObject,
                    "time": String(Date().currentTimeMillis()) as AnyObject
                ]
            ref.setValue(load4)
            
            self.beParticipant(online: true)

            self.view_image_form.isHidden = true
            self.imageFile = nil
            
            // Send Push Notification
            if !self.isUserOnline {
                self.sendChatPush(receiver_id: gUser.idx, sender_id: thisUser.idx, message: "Shared a file.")
            }
            
          }
        }
        
    }
    
    
    @IBAction func uploadImage(_ sender: Any) {
        if self.imageFile != nil{
            self.uploadFileToStorage(file: self.imageFile)
        }
    }
    
    @IBAction func cancelImage(_ sender: Any) {
        self.view_image_form.isHidden = true
        self.imageFile = nil
    }
    
    func removeExternalReceivedNotification() {
        var ref:DatabaseReference!
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "notification").child(thisUser.email.replacingOccurrences(of: ".", with: "ddoott"))
        ref.observe(.childAdded, with: {(snapshot) -> Void in
            let userEmail = snapshot.key.replacingOccurrences(of: "ddoott", with: ".")
            if userEmail == gUser.email && self.isMeOnline {
                let subRef = ref.child(snapshot.key)
                subRef.removeValue()
            }
        })
    }
    
    func beParticipant(online:Bool){
        var status = "offline"
        if online {
            status = "online"
        }
        // Send My Status
        var ref:DatabaseReference!
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "status").child(CHAT_ID2)
        ref.removeValue()
        let subRef = ref.childByAutoId()
        let load:[String:AnyObject] =
            [
                "user": thisUser.email as AnyObject,
                "time": String(Date().currentTimeMillis()) as AnyObject,
                "online": status as AnyObject
            ]
        subRef.setValue(load)
    }
    
    @objc func showParticipants(gesture:UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateUI(){
        if gSelectedUsers.count == 0 {
            self.userImages[2].isHidden = true
            self.userImages[1].isHidden = true
            self.userImages[0].isHidden = true
            self.lbl_notified.visibilityh = .gone
            if gSelectedUsers.count == 0 && gRecentViewController == gHomeViewController {
                gHomeViewController.getHomeData(member_id: thisUser.idx)
            }
            return
        }else {
            if gSelectedUsers.count == 1{
                self.loadPicture(imageView: self.userImages[2], url: URL(string: gSelectedUsers[0].photo_url)!)
                self.userImages[2].isHidden = false
                self.userImages[1].isHidden = true
                self.userImages[0].isHidden = true
            }else if gSelectedUsers.count == 2{
                self.loadPicture(imageView: self.userImages[2], url: URL(string: gSelectedUsers[0].photo_url)!)
                self.loadPicture(imageView: self.userImages[1], url: URL(string: gSelectedUsers[1].photo_url)!)
                self.userImages[2].isHidden = false
                self.userImages[1].isHidden = false
                self.userImages[0].isHidden = true
            }else if gSelectedUsers.count >= 3{
                self.loadPicture(imageView: self.userImages[2], url: URL(string: gSelectedUsers[gSelectedUsers.count - 1].photo_url)!)
                self.loadPicture(imageView: self.userImages[1], url: URL(string: gSelectedUsers[gSelectedUsers.count - 2].photo_url)!)
                self.loadPicture(imageView: self.userImages[0], url: URL(string: gSelectedUsers[gSelectedUsers.count - 3].photo_url)!)
                self.userImages[2].isHidden = false
                self.userImages[1].isHidden = false
                self.userImages[0].isHidden = false
            }
        }
        
        self.getNotifiedUsers()
    }
    
    
    func createSelUsersJsonString() -> String{
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
    
    
    func getNotifiedUsers(){
        var notifiedUsers = [User]()
                
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

                if !notifiedUsers.contains(where: {$0.email == user.email}) && gSelectedUsers.contains(where: {$0.email == user.email}) && user.email != gUser.email{
                    notifiedUsers.append(user)
                }
                
                if user.email == gUser.email {
                    subRef.removeValue()
                }
    
                print("Notified Users////////////////: \(notifiedUsers.count)")
                if notifiedUsers.count > 0{
                    self.lbl_notified.visibilityh = .visible
                    self.lbl_notified.text = String(notifiedUsers.count)
                }
                
            })
        })
        
        ref.observe(.childRemoved, with: {(snapshot) -> Void in
            print("Removed////////////////: \(snapshot.key)")
            let userEmail = snapshot.key.replacingOccurrences(of: "ddoott", with: ".")
            if notifiedUsers.contains(where: {$0.email == userEmail}){
                notifiedUsers.remove(at: notifiedUsers.firstIndex(where: {$0.email == userEmail})!)
                print("Notified Users////////////////: \(notifiedUsers.count)")
            }
            if notifiedUsers.count > 0{
                self.lbl_notified.visibilityh = .visible
                self.lbl_notified.text = String(notifiedUsers.count)
            }else{
                self.lbl_notified.visibilityh = .gone
            }
        })
    }
    
    func sendChatPush(receiver_id:Int64, sender_id:Int64, message:String){
        APIs.sendChatPush(receiver_id: receiver_id, sender_id: sender_id, message: message, handleCallback: {
            result in
            print("Result Code: \(result)")
        })
    }
    
    
    //////////////////// Get user-end key array /////////////////////////////////////////////////////////////////////////////////////////////////////
    
    var uKeys = [String]()
    
    func getUserEndSnapshotKeyList(){
        uKeys.removeAll()
        var ref:DatabaseReference!
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "messages").child(CHAT_ID2)
        print("CHAT ID2: \(CHAT_ID2)")
        ref.observe(.childAdded, with: {(snapshot) -> Void in
            if !self.uKeys.contains(snapshot.key){
                self.uKeys.append(snapshot.key)
                print("uKey1s: \(self.uKeys.count)")
                print("uKey1s: \(self.uKeys)")
            }
        })
        
        ref.observe(.childRemoved, with: {(snapshot) -> Void in
            print("Removed////////////////: \(snapshot.key)")
            let key = snapshot.key
            if self.uKeys.contains(key){
                self.uKeys.remove(at: self.uKeys.firstIndex(of: key)!)
                print("uKeys2: \(self.uKeys.count)")
                print("uKeys2: \(self.uKeys)")
            }
        })
        
    }
    
    
    func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
        DispatchQueue.global().async { //1
            let asset = AVAsset(url: url) //2
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
            avAssetImageGenerator.appliesPreferredTrackTransform = true //4
            let thumnailTime = CMTimeMake(value: 2, timescale: 1) //5
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                let thumbImage = UIImage(cgImage: cgThumbImage) //7
                DispatchQueue.main.async { //8
                    completion(thumbImage) //9
                }
            } catch {
                print(error.localizedDescription) //10
                DispatchQueue.main.async {
                    completion(nil) //11
                }
            }
        }
    }
    
    @IBAction func openMenu(_ sender: Any) {
        let dropDown = DropDown()
        
        dropDown.anchorView = self.btn_menu
        if self.blocked_user {
            dropDown.dataSource = ["  Unblock", "  Report User"]
        }else {
            dropDown.dataSource = ["  Block", "  Report User"]
        }
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
            if idx == 0{
                if self.blocked_user {
                    self.unBlockUser()
                }else {
                    self.blockUser()
                }
            }else if idx == 1 {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ReportViewController")
                self.present(vc, animated: true, completion: nil)
            }
        }
        
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().selectedTextColor = UIColor.white
        DropDown.appearance().textFont = UIFont.boldSystemFont(ofSize: 14.0)
        DropDown.appearance().backgroundColor = UIColor.white
        DropDown.appearance().selectionBackgroundColor = UIColor.gray
        DropDown.appearance().cellHeight = 45
        
        dropDown.separatorColor = UIColor.lightGray
        dropDown.width = 110
        
        dropDown.show()
    }
    
    func blockUser() {
        var ref:DatabaseReference!
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "block").child(CHAT_ID)
        ref.childByAutoId()
        let load:[String:AnyObject] =
            [
                "user": thisUser.email as AnyObject,
                "time": String(Date().currentTimeMillis()) as AnyObject
            ]
        ref.setValue(load)
    }
    
    func unBlockUser() {
        var ref:DatabaseReference!
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "block").child(CHAT_ID)
        ref.removeValue()
    }
    
    func checkBlockedUserStatus(){
        var ref:DatabaseReference!
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "block").child(CHAT_ID)
        ref.observe(.childAdded, with: {(snapshot) -> Void in
            self.blocked_user = true
            self.commentBox.isEditable = false
            self.commentBox.isSelectable = false
            self.attachButton.isEnabled = false
            self.commentBox.text = "You can\'t chat with this user."
            self.commentBox.checkPlaceholder()
            self.commentBox.resignFirstResponder()
            self.sendButton.visibilityh = .gone
        })
        
        ref.observe(.childRemoved, with: {(snapshot) -> Void in
            self.blocked_user = false
            if !self.blocked_me {
                self.commentBox.isEditable = true
                self.commentBox.isSelectable = true
                self.attachButton.isEnabled = true
                self.commentBox.text = ""
                self.commentBox.checkPlaceholder()
                self.sendButton.visibilityh = .gone
            }
        })
        
        var ref2:DatabaseReference!
        ref2 = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "block").child(CHAT_ID2)
        ref2.observe(.childAdded, with: {(snapshot) -> Void in
            self.blocked_me = true
            self.commentBox.isEditable = false
            self.commentBox.isSelectable = false
            self.attachButton.isEnabled = false
            self.commentBox.text = "You can\'t chat with this user."
            self.commentBox.checkPlaceholder()
            self.commentBox.resignFirstResponder()
            self.sendButton.visibilityh = .gone
        })
        
        ref2.observe(.childRemoved, with: {(snapshot) -> Void in
            self.blocked_me = false
            if !self.blocked_user {
                self.commentBox.isEditable = true
                self.commentBox.isSelectable = true
                self.attachButton.isEnabled = true
                self.commentBox.text = ""
                self.commentBox.checkPlaceholder()
                self.sendButton.visibilityh = .gone
            }
        })
        
    }
    
    
}

