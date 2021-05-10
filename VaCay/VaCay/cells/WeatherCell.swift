//
//  WeatherCell.swift
//  VaCay
//
//  Created by Andre on 8/17/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit

class WeatherCell: UITableViewCell {
    
    @IBOutlet weak var view_content: UIView!
    @IBOutlet weak var img_weather: UIImageView!
    
    @IBOutlet weak var lbl_desc: UILabel!
    @IBOutlet weak var lbl_time: UILabel!
    @IBOutlet weak var lbl_temp: UILabel!
    @IBOutlet weak var lbl_clouds: UILabel!
    @IBOutlet weak var lbl_humidity: UILabel!
    @IBOutlet weak var lbl_wind: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
