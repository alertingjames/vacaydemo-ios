//
//  HomeUserCell.swift
//  VaCay
//
//  Created by Andre on 7/21/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit

class HomeUserCell: UITableViewCell {
    
    @IBOutlet weak var img_photo1: UIImageView!
    @IBOutlet weak var lbl_name1: UILabel!
    @IBOutlet weak var btn_add1: UIButton!
    @IBOutlet weak var img_photo2: UIImageView!
    @IBOutlet weak var lbl_name2: UILabel!
    @IBOutlet weak var btn_add2: UIButton!
    @IBOutlet weak var view_item1: UIView!
    @IBOutlet weak var view_item2: UIView!
    @IBOutlet weak var lbl_group1: UILabel!
    @IBOutlet weak var lbl_city1: UILabel!
    @IBOutlet weak var ic_loc1: UIImageView!
    @IBOutlet weak var lbl_group2: UILabel!
    @IBOutlet weak var ic_loc2: UIImageView!
    @IBOutlet weak var lbl_city2: UILabel!
    @IBOutlet weak var mes1: UIButton!
    @IBOutlet weak var mes2: UIButton!
    
    @IBOutlet weak var view_content: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        img_photo1.layer.cornerRadius = img_photo1.frame.width / 2
        img_photo2.layer.cornerRadius = img_photo2.frame.width / 2
        
        btn_add1.layer.cornerRadius = 3
        btn_add1.layer.masksToBounds = true
        
        btn_add2.layer.cornerRadius = 3
        btn_add2.layer.masksToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
