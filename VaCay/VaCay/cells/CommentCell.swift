//
//  CommentCell.swift
//  VaCay
//
//  Created by Andre on 7/24/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var contentLayout: UIView!
    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var userNameBox: UILabel!
    @IBOutlet weak var userCohortBox: UILabel!
    @IBOutlet weak var commentedTimeBox: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var commentBox: UITextView!
    @IBOutlet weak var imageBox: UIImageView!    
    @IBOutlet weak var commentBoxWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
