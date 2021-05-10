//
//  ConfCommentCell.swift
//  VaCay
//
//  Created by Andre on 7/31/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit

class ConfCommentCell: UITableViewCell {
    
    @IBOutlet weak var contentLayout: UIView!
    @IBOutlet weak var userLayout: UIView!
    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var userNameBox: UILabel!
    @IBOutlet weak var userCohortBox: UILabel!
    @IBOutlet weak var commentedTimeBox: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var commentBox: UITextView!
    @IBOutlet weak var imageBox: UIImageView!
    
    @IBOutlet weak var myContentLayout: UIView!
    @IBOutlet weak var myCommentBox: UITextView!
    @IBOutlet weak var myImageBox: UIImageView!
    @IBOutlet weak var myMenuButton: UIButton!
    @IBOutlet weak var myCommentedTimeBox: UILabel!
    @IBOutlet weak var view_user: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.menuButton.setImageTintColor(.lightGray)
        self.myMenuButton.setImageTintColor(.lightGray)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
