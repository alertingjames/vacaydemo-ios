//
//  Conference.swift
//  VaCay
//
//  Created by Andre on 7/29/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import Foundation

class Conference {
    var idx:Int64 = 0
    var user_id:Int64 = 0
    var group_id:Int64 = 0
    var cohort:String = ""
    var name:String = ""
    var code:String = ""
    var type:String = ""
    var video_url:String = ""
    var participants:Int64 = 0
    var event_time:String = ""
    var created_time:String = ""
    var duration:String = ""
    var likes:Int64 = 0
    var group_name:String = ""
    var status:String = ""
    
}

var gConference:Conference = Conference()
