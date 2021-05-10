//
//  VideoFileConfViewController.swift
//  VaCay
//
//  Created by Andre on 7/29/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Firebase
import FirebaseDatabase
import VoxeetSDK
import VoxeetUXKit

class VideoFileConfViewController: BaseViewController {
    
    @IBOutlet weak var btn_users: UIButton!
    @IBOutlet weak var btn_video: UIButton!
    @IBOutlet weak var view_player: UIView!
    @IBOutlet weak var btn_comment: UIButton!
    
    @IBOutlet weak var lbl_conf_name: UILabel!
    @IBOutlet weak var lbl_group: UILabel!
    
    private var participants = [VTParticipantInfo]()
    private var conferenceAlias:String = ""
    
    var CHAT_ID:String = ""
    var adminParticipantID = ""
    
    var player: AVPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gVideoFileViewController = self
        gRecentViewController = self
        
        conferenceAlias = gConference.name
        adminParticipantID = String(gAdmin.idx) + String(gAdmin.idx)
        
        if gConference.group_id > 0{
            CHAT_ID = "\(gAdmin.idx)gr\(gConference.group_id)conf\(gConference.idx)"
            self.lbl_group.text = gConference.group_name
        }else if gConference.cohort != ""{
            CHAT_ID = "\(gAdmin.idx)\(gConference.cohort)conf\(gConference.idx)"
            self.lbl_group.text = gConference.cohort
        }

        btn_users.setImageTintColor(.white)
        btn_video.setImageTintColor(.white)
        
        btn_comment.layer.cornerRadius = btn_comment.frame.height / 2
        btn_comment.backgroundColor = primaryDarkColor
        btn_comment.setImageTintColor(.white)
        
        VoxeetUXKit.shared.appearMaximized = true
        VoxeetUXKit.shared.telecom = false
        
        // Example of public variables to change the conference behavior.
        VoxeetSDK.shared.notification.push.type = .none
        VoxeetSDK.shared.conference.defaultBuiltInSpeaker = true
        VoxeetSDK.shared.conference.defaultVideo = true
        
        // Conference delegates.
        VoxeetSDK.shared.conference.delegate = self
        
        lbl_conf_name.text = gConference.name
        
        if gConference.type == "file" && gConference.video_url.count > 0{

            self.showLoadingView()
            
            let url = URL(string: gConference.video_url)!
            let playerItem = CachingPlayerItem(url: url)
            playerItem.delegate = self
            self.player = AVPlayer(playerItem: playerItem)
            self.player.rate = 1 //auto play
            let playerFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 50)
            let playerController = AVPlayerViewController()
            playerController.player = self.player
            playerController.showsPlaybackControls = true
            playerController.view.frame = playerFrame
            self.view_player.addSubview(playerController.view)
            self.addChild(playerController)
            playerController.didMove(toParent: self)
            let playerLayer = AVPlayerLayer(player: self.player)
            playerLayer.frame = self.view_player.bounds
            self.view_player.layer.addSublayer(playerLayer)
            self.player.play()

        }
        
        let myParticipantInfo = VTParticipantInfo(externalID: String(thisUser.idx) + String(thisUser.idx), name: thisUser.name, avatarURL: thisUser.photo_url)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // Connect a session with participant information.
        VoxeetSDK.shared.session.open(info: myParticipantInfo) { error in
           UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
        openConference(member_id: thisUser.idx, conf_id: gConference.idx)
        
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
            self.lbl_group.text = self.lbl_group.text! + " Participants: " + String(users!.count)
            self.getComments(chatID: self.CHAT_ID)
        })
    }
    
    @IBAction func openCommentFrame(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ConfCommentFrame")
        self.present(vc, animated: true, completion: nil)
    }
    
    func getComments(chatID:String){
        gConfComments.removeAll()
            
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

            gConfComments.insert(comment, at: 0)
                
        })
            
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
            self.dismissViewController()
        }
    }
    
}


/*
 *  MARK: - Conference delegate
 */

extension VideoFileConfViewController: VTConferenceDelegate {
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
            //    ownCameraView.attach(participant: participant, stream: stream)
            //    ownCameraView.isHidden = false
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
                print("My Steam updated: \(participant.id)")
        //    ownCameraView.attach(participant: participant, stream: stream)
        //    ownCameraView.isHidden = false
            }
        } else if participant.info.externalID == self.adminParticipantID {
            //refresh
            print("admin stream updated")
        }else {
            //refresh
            print("stream added")
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

extension VideoFileConfViewController: CachingPlayerItemDelegate {
    
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        if self.loadingView.isAnimating { self.dismissLoadingView() }
        print("File is downloaded and ready for storing")
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int) {
        print("\(bytesDownloaded)/\(bytesExpected)")
    }
    
    func playerItemPlaybackStalled(_ playerItem: CachingPlayerItem) {
        print("Not enough data for playback. Probably because of the poor network. Wait a bit and try to play later.")
        if self.loadingView.isAnimating { self.dismissLoadingView() }
        showToast(msg: "Not enough data for playback. Probably because of the poor network. Wait a bit and try to play later.")
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, downloadingFailedWith error: Error) {
        print(error)
        if self.loadingView.isAnimating { self.dismissLoadingView() }
        showToast(msg: error.localizedDescription)
    }
    
}
