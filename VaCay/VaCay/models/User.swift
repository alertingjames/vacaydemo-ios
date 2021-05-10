//
//  User.swift
//  VaCay
//
//  Created by Andre on 7/15/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import Foundation

class User{
    var idx:Int64 = 0
    var admin_id:Int64 = 0
    var name:String = ""
    var email:String = ""
    var password:String = ""
    var photo_url:String = ""
    var phone_number:String = ""
    var city:String = ""
    var address:String = ""
    var lat:String = ""
    var lng:String = ""
    var cohort:String = ""
    var registered_time:String = ""
    var fcm_token:String = ""
    var username:String = ""
    var status:String = ""
    var status2:String = ""
    
    var key:String = ""
}

var thisUser:User = User()
var gUser:User = User()
var gAdmin:User = User()
