//
//  NotiCell.swift
//  VaCay
//
//  Created by Andre on 8/4/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit

class NotiCell: UITableViewCell {
    
    @IBOutlet weak var img_sender: UIImageView!
    @IBOutlet weak var lbl_sender_name: UILabel!
    @IBOutlet weak var lbl_cohort: UILabel!
    @IBOutlet weak var lbl_time: UILabel!
    @IBOutlet weak var lbl_body: UILabel!
    @IBOutlet weak var btn_menu: UIButton!
    @IBOutlet weak var view_content: UIView!   
    @IBOutlet weak var lbl_mark: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
