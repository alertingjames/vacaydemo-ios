//
//  YouTubeConfViewController.swift
//  VaCay
//
//  Created by Andre on 7/29/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit
import Kingfisher
import GSImageViewerController
import YoutubePlayerView
import Firebase
import FirebaseDatabase
import VoxeetSDK
import VoxeetUXKit

class YouTubeConfViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var lbl_confname: UILabel!
    @IBOutlet weak var lbl_groupname: UILabel!
    @IBOutlet weak var btn_users: UIButton!
    @IBOutlet weak var btn_video: UIButton!
    @IBOutlet weak var view_player: YoutubePlayerView!
    @IBOutlet weak var commentList: UITableView!
    @IBOutlet weak var btn_comment: UIButton!
    @IBOutlet weak var noResult: UILabel!
    
    var comments = [Comment]()
    
    private var participants = [VTParticipantInfo]()
    private var conferenceAlias:String = ""
    
    var CHAT_ID:String = ""
    var adminParticipantID = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gYouTubeConfViewController = self
        gRecentViewController = self
        
        conferenceAlias = gConference.name
        adminParticipantID = String(gAdmin.idx) + String(gAdmin.idx)
        
        btn_comment.layer.cornerRadius = btn_comment.frame.height / 2
        btn_comment.backgroundColor = primaryDarkColor
        btn_comment.setImageTintColor(.white)
        
        btn_users.setImageTintColor(.white)
        btn_video.setImageTintColor(.white)
        
        lbl_confname.text = gConference.name
        
        if gConference.group_id > 0{
            CHAT_ID = "\(gAdmin.idx)gr\(gConference.group_id)conf\(gConference.idx)"
            self.lbl_groupname.text = gConference.group_name
        }else if gConference.cohort != ""{
            CHAT_ID = "\(gAdmin.idx)\(gConference.cohort)conf\(gConference.idx)"
            self.lbl_groupname.text = gConference.cohort
        }
        
        print("CHATID!!! \(CHAT_ID)")
        
        let playerVars: [String: Any] = [
            "controls": 1,
            "modestbranding": 1,
            "playsinline": 1,
            "rel": 0,
            "showinfo": 0,
            "autoplay": 1
        ]
        
        view_player.delegate = self
        
        if gConference.type == "youtube" && gConference.video_url.count > 0{
            view_player.loadWithVideoId(gConference.video_url, with: playerVars)
        }
        
        VoxeetUXKit.shared.appearMaximized = true
        VoxeetUXKit.shared.telecom = false
        
        // Example of public variables to change the conference behavior.
        VoxeetSDK.shared.notification.push.type = .none
        VoxeetSDK.shared.conference.defaultBuiltInSpeaker = true
        VoxeetSDK.shared.conference.defaultVideo = true
        
        // Conference delegates.
        VoxeetSDK.shared.conference.delegate = self
        
        self.commentList.delegate = self
        self.commentList.dataSource = self
        
        self.commentList.estimatedRowHeight = 170.0
        self.commentList.rowHeight = UITableView.automaticDimension
        
        self.noResult.isHidden = false
        
        // Conference login
        let myParticipantInfo = VTParticipantInfo(externalID: String(thisUser.idx) + String(thisUser.idx), name: thisUser.name, avatarURL: thisUser.photo_url)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // Connect a session with participant information.
        VoxeetSDK.shared.session.open(info: myParticipantInfo) { error in
           UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
        self.beParticipant(online: true)
        
        openConference(member_id: thisUser.idx, conf_id: gConference.idx)
        
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
        self.beParticipant(online: false)
    }
        
    @objc func appToForeground(notification: NSNotification) {
        print("I moved to foreground.")
        self.beParticipant(online: true)
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
        return self.comments.count
    }
            
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell:CommentCell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        
        cell.backgroundColor = .clear
//        self.commentList.backgroundColor = .clear
                
        let index:Int = indexPath.row
                
        if self.comments.indices.contains(index) {
            
            let comment = self.comments[index]
            
            if comment.image_url != ""{
                loadPicture(imageView: cell.imageBox, url: URL(string: comment.image_url)!)
                cell.imageBox.visibility = .visible
            }else{
                cell.imageBox.visibility = .gone
            }

            cell.imageBox.roundCorners(corners: [.topRight, .bottomLeft, .bottomRight], radius: 15)

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(gesture:)))

            cell.imageBox.tag = index
            cell.imageBox.addGestureRecognizer(tapGesture)
            cell.imageBox.isUserInteractionEnabled = true

            cell.commentBox.text = comment.comment.decodeEmoji
            cell.commentBox.roundCorners(corners: [.topRight, .bottomLeft, .bottomRight], radius: 15)
            cell.commentBox.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            
            if cell.commentBoxWidth.constant > self.screenWidth - 60 { cell.commentBoxWidth.constant = self.screenWidth - 60 }
            
            if comment.user.photo_url != ""{
                loadPicture(imageView: cell.userPicture, url: URL(string: comment.user.photo_url)!)
            }
            
            cell.userPicture.layer.cornerRadius = cell.userPicture.frame.width / 2
            
            cell.userNameBox.text = comment.user.name

            cell.commentedTimeBox.text = comment.commented_time
            if comment.user.idx == thisUser.idx {
                cell.userCohortBox.text = thisUser.cohort
            }else{
                if gMainViewController.users.contains(where: {$0.idx == comment.user.idx}){
                    cell.userCohortBox.text = gMainViewController.users.filter{
                        user in user.idx == comment.user.idx
                        }[0].cohort
                }
            }
                                
            cell.commentBox.sizeToFit()
            cell.contentLayout.sizeToFit()
            cell.contentLayout.layoutIfNeeded()
                
        }
        
        return cell
        
    }
    
    @objc func imageTapped(gesture:UITapGestureRecognizer){
        if (gesture.view as? UIImageView) != nil {
            print("Image Tapped")
            let imgView = gesture.view as! UIImageView
            let index = imgView.tag
            
            let comment = gConfComments[index]
            
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
            }
        }
    }
    
    
    

    @IBAction func back(_ sender: Any) {
        self.closeVideoConference()
    }
    
    
    @IBAction func openLiveVideo(_ sender: Any) {
        guard VoxeetSDK.shared.conference.current == nil else { return }
        self.showLoadingView()
        self.joinVideoConference()
    }
    
    @IBAction func showParticipants(_ sender: Any) {
        if self.loadingView.isAnimating {
            return
        }
        
        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(identifier:"ConfParticipantsViewController")
        self.present(vc, animated:true, completion:nil)
    }
    
    func openConference(member_id:Int64, conf_id:Int64){
        self.showLoadingView()
        APIs.openConference(member_id: member_id, conf_id: conf_id, handleCallback: {
            users, result in
            self.dismissLoadingView()
            gConfUsers = users!
            self.lbl_groupname.text = self.lbl_groupname.text! + " Participants: " + String(users!.count)
            self.getComments(chatID: self.CHAT_ID)
        })
    }
    
    
    @IBAction func openCommentFrame(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ConfCommentFrame")
        self.present(vc, animated: true, completion: nil)
    }
    
    func getComments(chatID:String){
        gConfComments.removeAll()
        self.comments.removeAll()
            
        var ref:DatabaseReference!
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "gmmsg" + chatID)
        ref.observe(.childAdded, with: {(snapshot) -> Void in
            let value = snapshot.value as! [String: Any]
            var timeStamp = String(describing: value["time"])
            timeStamp = timeStamp.replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: ")", with: "")
            let time = self.getDateTimeFromTimeStamp(timeStamp: Double(timeStamp)!/1000)
            let message = value["message"] as! String
            let image = value["image"] as! String
            let video = value["video"] as! String
            let sender_id = value["sender_id"] as! String
            let sender_name = value["sender"] as! String
            let sender_email = value["sender_email"] as! String
            let sender_photo = value["sender_photo"] as! String

            print("\(time)")
            print("\(sender_name)")
            print("\(sender_id)")
            print("\(message)")
            print("\(sender_email)")
            print("\(sender_photo)")
    //
            let comment = Comment()
            let user = User()
            user.idx = Int64(sender_id)!
            user.name = sender_name
            user.email = sender_email
            user.photo_url = sender_photo

            comment.user = user
            comment.commented_time = time
            comment.comment = message
            comment.image_url = image
            comment.key = snapshot.key

            gConfComments.insert(comment, at: 0)
            self.comments.insert(comment, at: 0)
            self.noResult.isHidden = true
                
            self.commentList.reloadData()
            self.scrollToFirstRow()
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
            
    }
    
    func scrollToFirstRow() {
        let indexPath = NSIndexPath(row: 0, section: 0)
        self.commentList.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
    }
    
    func beParticipant(online:Bool){
        var ref:DatabaseReference!
        ref = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "gmusers" + self.CHAT_ID).child(thisUser.email.replacingOccurrences(of: ".", with: "ddoott"))
        ref.removeValue()
        if !online {
            return
        }
        let subRef = ref.childByAutoId()
        let load:[String:AnyObject] =
            [
                "sender_id": String(thisUser.idx) as AnyObject,
                "sender_name": thisUser.name as AnyObject,
                "sender_email": thisUser.email as AnyObject,
                "sender_photo": thisUser.photo_url as AnyObject
            ]
        subRef.setValue(load)
    }
    
    func joinVideoConference(){
        for user in gConfUsers{
            if user.idx != thisUser.idx {
                self.participants.append(VTParticipantInfo(externalID: String(user.idx) + String(user.idx), name: user.name, avatarURL: user.photo_url))
            }
        }
        
        // Create a conference (with a custom conference alias).
        let options = VTConferenceOptions()
        options.alias = conferenceAlias
        VoxeetSDK.shared.conference.create(options: options, success: { conference in
            // Join the created conference.
            let joinOptions = VTJoinOptions()
            joinOptions.constraints.video = false
            VoxeetSDK.shared.conference.join(conference: conference, options: joinOptions, success: { conference in
                if self.loadingView.isAnimating { self.dismissLoadingView() }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }, fail: { error in
                if self.loadingView.isAnimating { self.dismissLoadingView() }
                self.errorPopUp(error: error)
            })
            
            // Invite other participants if the conference is just created.
            if conference.isNew {
                VoxeetSDK.shared.notification.invite(conference: conference, participantInfos: self.participants, completion: nil)
            }
        }, fail: { error in
            if self.loadingView.isAnimating { self.dismissLoadingView() }
            self.errorPopUp(error: error)
        })
        
    }
    
    private func errorPopUp(error: Error) {
        DispatchQueue.main.async {
            // Error message.
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func closeVideoConference() {
        guard VoxeetSDK.shared.conference.current == nil else { return }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        // Disconnect current session.
        VoxeetSDK.shared.session.close { error in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.beParticipant(online: false)
            self.dismissViewController()
        }
    }
    
}


extension YouTubeConfViewController: YoutubePlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YoutubePlayerView) {
        print("Ready")
        playerView.play()
    }

    func playerView(_ playerView: YoutubePlayerView, didChangedToState state: YoutubePlayerState) {
        print("Changed to state: \(state)")
    }

    func playerView(_ playerView: YoutubePlayerView, didChangeToQuality quality: YoutubePlaybackQuality) {
        print("Changed to quality: \(quality)")
    }

    func playerView(_ playerView: YoutubePlayerView, receivedError error: Error) {
        print("Error: \(error)")
    }

    func playerView(_ playerView: YoutubePlayerView, didPlayTime time: Float) {
        print("Play time: \(time)")
    }
}


/*
 *  MARK: - Conference delegate
 */

extension YouTubeConfViewController: VTConferenceDelegate {
    func statusUpdated(status: VTConferenceStatus) {}
    
    func participantAdded(participant: VTParticipant) {
        // refresh
    }
    
    func participantUpdated(participant: VTParticipant) {
        // refresh
    }
    
    func streamAdded(participant: VTParticipant, stream: MediaStream) {
        switch stream.type {
        case .Camera:
            print("Participant ID: \(participant.id)")
            if participant.id == VoxeetSDK.shared.session.participant?.id {
                // Attaching own participant's video stream to the renderer.
                if !stream.videoTracks.isEmpty {
                    print("My Stream added: \(participant.id)")
//                    ownCameraView.attach(participant: participant, stream: stream)
//                    ownCameraView.isHidden = false
                }
            } else if participant.info.externalID == self.adminParticipantID {
                //refresh
                print("admin stream added")
            }else {
                //refresh
                print("stream added")
            }
        case .ScreenShare:
            // Attaching a video stream to a renderer.
            print("stream added")
        default:
            break
        }
    }
    
    func streamUpdated(participant: VTParticipant, stream: MediaStream) {
        // Get the video renderer.
        print("Participant ID: \(participant.id)")
        if participant.id == VoxeetSDK.shared.session.participant?.id {
            // Attaching own participant's video stream to the renderer.
            if !stream.videoTracks.isEmpty {
                print("My stream updated: \(participant.id)")
        //    ownCameraView.attach(participant: participant, stream: stream)
        //    ownCameraView.isHidden = false
            }
        } else if participant.info.externalID == self.adminParticipantID {
            //refresh
            print("admin stream updated")
        }else {
            //refresh
            print("stream updated")
        }
    }
    
    func streamRemoved(participant: VTParticipant, stream: MediaStream) {
        switch stream.type {
        case .Camera:
            //refresh
            print("stream removed")
        case .ScreenShare:
            // screenshareview alpha = 0
            print("stream removed")
        default:
            break
        }
    }
}
