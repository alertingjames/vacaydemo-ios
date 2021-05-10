//
//  NearbyCell.swift
//  VaCay
//
//  Created by Andre on 8/19/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit
import MapKit

class NearbyCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(responseResult: MKMapItem) {
       // cellTitle
    }

}
