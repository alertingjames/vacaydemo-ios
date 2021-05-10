//
//  Post.swift
//  VaCay
//
//  Created by Andre on 7/23/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import Foundation

class Post{
    var idx:Int64 = 0
    var user:User!
    var title:String = ""
    var category:String = ""
    var content:String = ""
    var picture_url:String = ""
    var video_url:String = ""
    var link:String = ""
    var comments:Int64 = 0
    var posted_time:String = ""
    var likes:Int64 = 0
    var isLiked:Bool = false
    var pictures:Int = 0
    var status:String = ""
}

var gPost:Post = Post()
