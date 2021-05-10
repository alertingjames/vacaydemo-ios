//
//  NotifiedUserCell.swift
//  VaCay
//
//  Created by Andre on 7/26/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit

class NotifiedUserCell: UITableViewCell {
    
    @IBOutlet weak var view_content: UIView!
    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userUsername: UILabel!
    @IBOutlet weak var userCohort: UILabel!
    @IBOutlet weak var userAddButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userAddButton.layer.cornerRadius = 3
        userAddButton.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
