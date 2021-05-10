//
//  ConfUserCell.swift
//  VaCay
//
//  Created by Andre on 8/1/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit

class ConfUserCell: UITableViewCell {
    
    @IBOutlet weak var view_content: UIView!
    @IBOutlet weak var img_user: UIImageView!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_cohort: UILabel!
    @IBOutlet weak var lbl_status: UILabel!
    @IBOutlet weak var btn_menu: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lbl_status.layer.cornerRadius = lbl_status.frame.height / 2
        lbl_status.layer.masksToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
