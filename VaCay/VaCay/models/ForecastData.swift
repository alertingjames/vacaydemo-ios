//
//  ForecastData.swift
//  VaCay
//
//  Created by Andre on 8/17/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import Foundation

struct ForecastData: Codable {
    
    struct Weathers: Codable {
        let dt: Int
        
        struct MainData: Codable {
            let temp: Float
            let pressure: Int
            let humidity: Float
            let temp_min: Float
            let temp_max: Float
        }
        
        struct WeatherConditions: Codable {
            let id: Int
            let main: String
            let description: String
            let icon: String
        }
        
        struct Wind: Codable {
            let speed: Float
            let deg: Float?
        }
        
        struct Clouds: Codable {
            let all: Float
        }
        
        let main: MainData
        let weather: [WeatherConditions]
        let wind: Wind
        let clouds: Clouds
    }
    
    struct CityData: Codable {
        let name: String
        let country: String
        let sunrise: Double
        let sunset: Double
    }
    
    let list: [Weathers]
    let city: CityData

}
