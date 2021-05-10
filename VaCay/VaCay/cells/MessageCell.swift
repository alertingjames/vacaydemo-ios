//
//  MessageCell.swift
//  VaCay
//
//  Created by Andre on 7/27/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    
    @IBOutlet weak var view_content: UIView!
    @IBOutlet weak var img_sender: UIImageView!
    @IBOutlet weak var lbl_sender_name: UILabel!
    @IBOutlet weak var lbl_cohort: UILabel!
    @IBOutlet weak var lbl_messaged_time: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var txv_desc: UITextView!
    @IBOutlet weak var btn_new: UIButton!
    @IBOutlet weak var lbl_replied: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        btn_new.layer.cornerRadius = 3
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
