//
//  LiveVideoConfViewController.swift
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

class LiveVideoConfViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var btn_users: UIButton!
    @IBOutlet weak var btn_video: UIButton!
    @IBOutlet weak var btn_comment: UIButton!
    
    @IBOutlet weak var lbl_conf_name: UILabel!
    @IBOutlet weak var lbl_group: UILabel!
    @IBOutlet weak var ic_live: UIImageView!
    @IBOutlet weak var btn_live: UIButton!
    
    @IBOutlet weak var ownVideoView: VTVideoView!
    @IBOutlet weak var videoView: VTVideoView!
    @IBOutlet weak var participantList: UICollectionView!
    
    private var participants = [VTParticipantInfo]()
    private var conferenceAlias:String = ""
    
    var CHAT_ID:String = ""
    var adminParticipantID = ""
    
    // Player for video presentation.
    var player: AVPlayer?
    
    var ownParticipant:VTParticipant!
    var adminParticipant:VTParticipant!
    
    var selectedCell:LiveParticipantCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        gLiveVideoConfViewController = self
        gRecentViewController = self
        
        conferenceAlias = gConference.name
        adminParticipantID = String(gAdmin.idx) + String(gAdmin.idx)

        btn_users.setImageTintColor(.white)
        btn_video.setImageTintColor(.white)
        
        btn_comment.layer.cornerRadius = btn_comment.frame.height / 2
        btn_comment.backgroundColor = primaryDarkColor
        btn_comment.setImageTintColor(.white)
        
        btn_live.layer.cornerRadius = btn_comment.frame.height / 2
        btn_live.setImageTintColor(.white)
        
        ownVideoView.layer.cornerRadius = 5
        ownVideoView.layer.masksToBounds = true
        ownVideoView.contentFill(true, animated: true)
        
        lbl_conf_name.text = gConference.name
        lbl_group.text = gConference.group_name
        
        if gConference.group_id > 0{
            CHAT_ID = "\(gAdmin.idx)gr\(gConference.group_id)conf\(gConference.idx)"
            self.lbl_group.text = gConference.group_name
        }else if gConference.cohort != ""{
            CHAT_ID = "\(gAdmin.idx)\(gConference.cohort)conf\(gConference.idx)"
            self.lbl_group.text = gConference.cohort
        }
        
        self.participantList.delegate = self
        self.participantList.dataSource = self
        
        // Example of public variables to change the conference behavior.
        VoxeetSDK.shared.notification.push.type = .none
        VoxeetSDK.shared.conference.defaultBuiltInSpeaker = true
        VoxeetSDK.shared.conference.defaultVideo = false
        VoxeetSDK.shared.conference.audio3D = true
        
        // Conference delegates.
        VoxeetSDK.shared.conference.delegate = self
        /* VoxeetSDK.shared.conference.cryptoDelegate = self */
        // Command delegate.
        VoxeetSDK.shared.command.delegate = self
        // File presentation delegate.
        VoxeetSDK.shared.filePresentation.delegate = self
        // Video presentation delegate.
        VoxeetSDK.shared.videoPresentation.delegate = self
        
        self.videoView.contentFill = false
        
        var tap = UITapGestureRecognizer(target: self, action: #selector(toggleVideoView))
        self.videoView.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(playOwnVideoView))
        self.ownVideoView.addGestureRecognizer(tap)
        
        // Conference destroy observer.
        NotificationCenter.default.addObserver(self, selector: #selector(conferenceDestroyed), name: .VTConferenceDestroyed, object: nil)
        
        // Force the device screen to never going to sleep mode.
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Conference login
        let myParticipantInfo = VTParticipantInfo(externalID: String(thisUser.idx) + String(thisUser.idx), name: thisUser.name, avatarURL: thisUser.photo_url)

        // Connect a session with participant information.
        VoxeetSDK.shared.session.open(info: myParticipantInfo) { error in
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
    
    deinit {
        player?.pause()
        player = nil
        
        // Remove observers.
        NotificationCenter.default.removeObserver(self)
        // Reset: Force the device screen to never going to sleep mode.
        UIApplication.shared.isIdleTimerDisabled = false
        
        // Debug.
        print("[Sample] \(String(describing: self)).\(#function).\(#line)")
    }
    
    @objc func toggleVideoView(){
        if self.videoView.contentFill {
            self.videoView.contentFill(false, animated: true)
            self.lbl_conf_name.textColor = .white
            self.lbl_group.textColor = .white
        }else {
            self.videoView.contentFill(true, animated: true)
            self.lbl_conf_name.textColor = .systemPink
            self.lbl_group.textColor = .systemPink
        }
    }
    
    @objc func playOwnVideoView(){
        if self.ownParticipant != nil {
            // Update renderer's stream.
            if let stream = self.ownParticipant.streams.first(where: { $0.type == .Camera }), !stream.videoTracks.isEmpty {
                self.videoView.attach(participant: self.ownParticipant, stream: stream)
                self.videoView.isHidden = false
                self.ic_live.isHidden = true
                if self.adminParticipant != nil{
                    self.btn_live.isHidden = false
                }
                if self.selectedCell != nil {
                    self.selectedCell.video_user.layer.borderWidth = 0
                    self.selectedCell.video_user.layer.borderColor = UIColor.clear.cgColor
                }
            }
        }
    }
    
    @IBAction func openAdminLive(_ sender: Any) {
        if self.adminParticipant != nil {
            // Update renderer's stream.
            if let stream = self.adminParticipant.streams.first(where: { $0.type == .Camera }), !stream.videoTracks.isEmpty {
                self.videoView.attach(participant: self.adminParticipant, stream: stream)
                self.videoView.isHidden = false
                self.ic_live.isHidden = true
                self.btn_live.isHidden = true
                if self.selectedCell != nil {
                    self.selectedCell.video_user.layer.borderWidth = 0
                    self.selectedCell.video_user.layer.borderColor = UIColor.clear.cgColor
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
        print("Tapped on Participants button1")
        if self.loadingView.isAnimating {
            return
        }
        
        print("Tapped on Participants button2")
        
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
//            let joinOptions = VTJoinOptions()
//            joinOptions.constraints.video = true
            print("Conference Joined!!!")
            return
            VoxeetSDK.shared.conference.join(conference: conference, options: nil, success: { conference in
                if self.loadingView.isAnimating { self.dismissLoadingView() }
                VoxeetSDK.shared.conference.startVideo() { _ in
                    print("Started video!!!")
                }
            }, fail: { error in
                if self.loadingView.isAnimating { self.dismissLoadingView() }
                self.errorPopUp(error: error)
            })
            
            // Invite other participants if the conference is just created.
//            if conference.isNew {
//                VoxeetSDK.shared.notification.invite(conference: conference, participantInfos: self.participants, completion: nil)
//            }
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
    
    @objc func conferenceDestroyed(notification: NSNotification) {
        if let conference = notification.userInfo?["conference"] as? VTConference {
            if conference.id == VoxeetSDK.shared.conference.current?.id {
//                self.dismiss(animated: true, completion: nil)
                print("Dismissing...")
            }
        }
    }
    
    func activeParticipants() -> [VTParticipant] {
        let participants = VoxeetSDK.shared.conference.current?.participants
            .filter({ $0.id != VoxeetSDK.shared.session.participant?.id })
            .filter({ $0.info.externalID != self.adminParticipantID })
        print("Participants: \(participants?.count ?? 0)")
        return participants ?? [VTParticipant]()
    }
    
    func closeVideoConference() {
//        guard VoxeetSDK.shared.conference.current == nil else { return }
        VoxeetSDK.shared.conference.stopVideo() { _ in
            VoxeetSDK.shared.conference.leave { error in
                self.dismissViewController()
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activeParticipants().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:LiveParticipantCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LiveParticipantCell", for: indexPath) as! LiveParticipantCell
        
        self.participantList.backgroundColor = .clear
        cell.backgroundColor = .clear
        
        // Getting the current participant.
        let participants = activeParticipants()
        guard participants.count != 0 && indexPath.row <= participants.count else { return cell }
        let participant = participants[indexPath.row]
        
        cell.video_user.layer.borderWidth = 0
        cell.video_user.layer.borderColor = UIColor.clear.cgColor
        
        // Setting up the cell.
        cell.setUp(participant: participant)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell:LiveParticipantCell = collectionView.cellForItem(at: indexPath) as! LiveParticipantCell
        
        // Getting the current participant.
        let participants = activeParticipants()
        let participant = participants[indexPath.row]
        // Update renderer's stream.
        if let stream = participant.streams.first(where: { $0.type == .Camera }), !stream.videoTracks.isEmpty {
            self.videoView.attach(participant: participant, stream: stream)
            self.videoView.isHidden = false
            self.ic_live.isHidden = true
        }
        
        cell.video_user.layer.borderWidth = 2
        cell.video_user.layer.borderColor = primaryColor.cgColor
        
        self.btn_live.isHidden = false
        
        self.selectedCell = cell
    }
    
}


/*
 *  MARK: - Conference delegate
 */

extension LiveVideoConfViewController: VTConferenceDelegate {
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
                    //refresh
                    print("my stream added")
                    self.ownVideoView.attach(participant: participant, stream: stream)
                    self.ownVideoView.isHidden = false
//                    self.ic_live.isHidden = true
                    self.ownParticipant = participant
                }
            } else if participant.info.externalID == self.adminParticipantID {
                // Attaching admin participant's video stream to the renderer.
                if !stream.videoTracks.isEmpty {
                    //refresh
                    print("admin stream added")
                    self.videoView.attach(participant: participant, stream: stream)
                    self.videoView.isHidden = false
                    self.ic_live.isHidden = true
                    self.adminParticipant = participant
                }
            }else if activeParticipants().contains(where: { $0.id == participant.id }) {
                participantList.reloadData()
                print("user stream updated")
            }else {
                //refresh
                print("user stream added")
                participantList.reloadData()
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
                //refresh
                print("my stream updated")
                self.ownVideoView.attach(participant: participant, stream: stream)
                self.ownVideoView.isHidden = false
//                self.ic_live.isHidden = true
                self.ownParticipant = participant
            }
            print("My Steam Updated: \(participant.id)")
        } else if participant.info.externalID == self.adminParticipantID {
            // Attaching admin participant's video stream to the renderer.
            if !stream.videoTracks.isEmpty {
                //refresh
                print("admin stream updated")
                self.videoView.attach(participant: participant, stream: stream)
                self.videoView.isHidden = false
                self.ic_live.isHidden = true
                self.btn_live.isHidden = true
                self.adminParticipant = participant
            }
        }else if activeParticipants().contains(where: { $0.id == participant.id }) {
            participantList.reloadData()
            print("user stream updated")
        }else {
            //refresh
            print("stream updated")
            participantList.reloadData()
        }
    }
    
    func streamRemoved(participant: VTParticipant, stream: MediaStream) {
        switch stream.type {
        case .Camera:
            //refresh
            if participant.info.externalID == self.adminParticipantID {
                //refresh
                print("admin stream removed")
                self.videoView.unattach()
                self.videoView.isHidden = true
                self.ic_live.isHidden = false
            }
            print("stream removed")
            participantList.reloadData()
        case .ScreenShare:
            // screenshareview alpha = 0
            print("stream removed")
        default:
            break
        }
    }
}


/*
 *  MARK: - Conference encryption delegate
 */

extension LiveVideoConfViewController: VTConferenceCryptoDelegate {
    func encrypt(type: Int, ssrc: Int, frame: UnsafePointer<UInt8>, frameSize: Int, encryptedFrame: UnsafeMutablePointer<UInt8>, encryptedFrameSize: Int) -> Int {
        let buffer = UnsafeBufferPointer(start: frame, count: frameSize)
        let encryptedBuffer = UnsafeMutableBufferPointer(start: encryptedFrame, count: encryptedFrameSize)
        
        // Without any cryptography.
        memcpy(encryptedBuffer.baseAddress, buffer.baseAddress, frameSize)
        
        return encryptedFrameSize
    }
    
    func getMaxCiphertextByteSize(type: Int, size: Int) -> Int {
        return size
    }
    
    func decrypt(type: Int, ssrc: Int, encryptedFrame: UnsafePointer<UInt8>, encryptedFrameSize: Int, frame: UnsafeMutablePointer<UInt8>, frameSize: Int) -> Int {
        let encryptedBuffer = UnsafeBufferPointer(start: encryptedFrame, count: encryptedFrameSize)
        let buffer = UnsafeMutableBufferPointer(start: frame, count: frameSize)
        
        // Without any cryptography.
        memcpy(buffer.baseAddress, encryptedBuffer.baseAddress, encryptedFrameSize)
        
        return frameSize
    }
    
    func getMaxPlaintextByteSize(type: Int, size: Int) -> Int {
        return size
    }
}

/*
 *  MARK: - Command delegate
 */

extension LiveVideoConfViewController: VTCommandDelegate {
    func received(participant: VTParticipant, message: String) {
//        broadcastMessageTextView.text = "\(participant.info.name ?? participant.id ?? ""): \(message)"
    }
}

/*
 *  MARK: - File presentation delegate
 */

extension LiveVideoConfViewController: VTFilePresentationDelegate {
    func converted(fileConverted: VTFileConverted) {}
    
    func started(filePresentation: VTFilePresentation) {
        updated(filePresentation: filePresentation)
    }
    
    func updated(filePresentation: VTFilePresentation) {
        let fileURL = VoxeetSDK.shared.filePresentation.image(page: filePresentation.position)
        
        if let url = fileURL {
            do {
                let data = try Data(contentsOf: url)
                let image = UIImage(data: data)
//                filePresentationImageView.image = image
//                filePresentationImageView.isHidden = false
            } catch {}
        }
    }
    
    func stopped(filePresentation: VTFilePresentation) {
//        filePresentationImageView.image = nil
//        filePresentationImageView.isHidden = true
    }
}

/*
 *  MARK: - Video presentation delegate
 */

extension LiveVideoConfViewController: VTVideoPresentationDelegate {
    func started(videoPresentation: VTVideoPresentation) {
        player = AVPlayer(url: videoPresentation.url)
        let playerLayer = AVPlayerLayer(player: player)
//        playerLayer.frame = videoPresentationView.bounds
//        playerLayer.backgroundColor = UIColor.black.cgColor
//        videoPresentationView.layer.addSublayer(playerLayer)
        
        player?.play()
        player?.seek(to: CMTimeMakeWithSeconds(videoPresentation.timestamp / 1000, preferredTimescale: 1000))
        
//        videoPresentationView.isHidden = false
    }
    
    func stopped(videoPresentation: VTVideoPresentation) {
        player?.pause()
        player = nil
//        videoPresentationView.isHidden = true
    }
    
    func played(videoPresentation: VTVideoPresentation) {
        player?.seek(to: CMTimeMakeWithSeconds(videoPresentation.timestamp / 1000, preferredTimescale: 1000))
        player?.play()
    }
    
    func paused(videoPresentation: VTVideoPresentation) {
        player?.pause()
        player?.seek(to: CMTimeMakeWithSeconds(videoPresentation.timestamp / 1000, preferredTimescale: 1000))
    }
    
    func sought(videoPresentation: VTVideoPresentation) {
        player?.seek(to: CMTimeMakeWithSeconds(videoPresentation.timestamp / 1000, preferredTimescale: 1000))
    }
}
