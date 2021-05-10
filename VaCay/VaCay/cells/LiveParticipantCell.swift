//
//  LiveParticipantCell.swift
//  VaCay
//
//  Created by Andre on 8/8/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit
import VoxeetSDK

class LiveParticipantCell: UICollectionViewCell {
    
    @IBOutlet weak var view_content: UIView!
    @IBOutlet weak var video_user: VTVideoView!
    @IBOutlet weak var img_user: UIImageView!
    @IBOutlet weak var lbl_name: UILabel!
    
    private var participant: VTParticipant!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        img_user.layer.cornerRadius = img_user.frame.height / 2
        img_user.layer.masksToBounds = true
        video_user.layer.cornerRadius = video_user.frame.height / 2
        video_user.layer.masksToBounds = true
        
        video_user.contentFill = true
        
    }
    
    func setUp(participant: VTParticipant) {
        self.participant = participant
        
        // Cell label.
        lbl_name.text = participant.info.name ?? participant.id
        
        // Cell avatar.
        if let photoURL = URL(string: participant.info.avatarURL ?? "") {
            let request = URLRequest(url: photoURL)
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let error = error {
                    // Debug.
                    print("[ERROR] \(#function) - Error: \(error.localizedDescription)")
                } else {
                    if let data = data {
                        DispatchQueue.main.async {
                            self.img_user.image = UIImage(data: data)
                        }
                    }
                }
            })
            task.resume()
        }
        
        // Update renderer's stream.
        if let stream = participant.streams.first(where: { $0.type == .Camera }), !stream.videoTracks.isEmpty {
            video_user.attach(participant: participant, stream: stream)
            video_user.isHidden = false
        } else {
            video_user.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Unattach the old stream before reusing the cell.
        if let stream = participant.streams.first(where: { $0.type == .Camera }), !stream.videoTracks.isEmpty {
            video_user.unattach()
        }
    }
    
}
