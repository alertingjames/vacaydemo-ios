//
//  PostCell.swift
//  VaCay
//
//  Created by Andre on 7/23/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
    
    @IBOutlet weak var view_content: UIView!
    @IBOutlet weak var img_poster: UIImageView!
    @IBOutlet weak var lbl_poster_name: UILabel!
    @IBOutlet weak var lbl_cohort: UILabel!
    @IBOutlet weak var lbl_post_title: UILabel!
    @IBOutlet weak var lbl_category: UILabel!
    @IBOutlet weak var lbl_posted_time: UILabel!
    @IBOutlet weak var img_post_picture: UIImageView!
    @IBOutlet weak var lbl_likes: UILabel!
    @IBOutlet weak var lbl_comments: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var txv_desc: UITextView!
    @IBOutlet weak var lbl_pics: UILabel!
    @IBOutlet weak var detailButton: UIButton!
    
    @IBOutlet weak var postImageHeight: NSLayoutConstraint!
    @IBOutlet weak var postDescHeight: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
