//
//  WeatherIconSet.swift
//  VaCay
//
//  Created by Andre on 8/17/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import Foundation

class WeatherIconSet{
    
    var wIconList = [WeatherIcon]()
    
    func initialize() -> [WeatherIcon]{
        let descs:[String] = [
            "clear sky",
            "few clouds",
            "scattered clouds",
            "broken clouds",
            "overcast clouds",
            "rain",
            "shower rain",
            "light rain",
            "freezing rain",
            "thunderstorm",
            "snow",
            "light snow",
            "mist",
            "drizzle",
            "sleet",
            "smoke",
            "haze",
            "dust",
            "fog",
            "tornado",
            "volcanic ash"
        ]
        
        let icon1:[String] = [
            "sun.max",
            "cloud.sun",
            "smoke",
            "smoke",
            "cloud",
            "cloud.rain",
            "cloud.heavyrain",
            "cloud.sun.rain",
            "snow",
            "cloud.bolt.rain",
            "snow",
            "cloud.snow",
            "cloud.fog",
            "cloud.drizzle",
            "cloud.sleet",
            "smoke",
            "sun.haze",
            "sun.dust",
            "cloud.fog",
            "tornado",
            "cloud.fog"
        ]
        
        let icon2:[String] = [
            "moon",
            "cloud.moon",
            "smoke",
            "smoke",
            "cloud",
            "cloud.rain",
            "cloud.heavyrain",
            "cloud.moon.rain",
            "snow",
            "cloud.bolt.rain",
            "snow",
            "cloud.snow",
            "cloud.fog",
            "cloud.drizzle",
            "cloud.sleet",
            "smoke",
            "sun.haze",
            "sun.dust",
            "cloud.fog",
            "tornado",
            "cloud.fog"
        ]
        
        for i in 0..<descs.count {
            let wIcon = WeatherIcon()
            wIcon.desc = descs[i]
            wIcon.time = "day"
            wIcon.icon = icon1[i]
            wIconList.append(wIcon)
            
            let wIcon2 = WeatherIcon()
            wIcon2.desc = descs[i]
            wIcon2.time = "night"
            wIcon2.icon = icon2[i]
            wIconList.append(wIcon2)
        }
        
        return wIconList
    }
}
