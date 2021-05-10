//
//  DailyForecastData.swift
//  VaCay
//
//  Created by Andre on 8/17/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import Foundation

struct DailyForecastData: Codable {
    
    struct Weathers: Codable {
        let dt: Int
        let sunrise: Double
        let sunset: Double
        
        struct TempData: Codable {
            let day: Float
            let min: Float
            let max: Float
            let night: Float
            let eve: Float
            let morn: Float
        }
        
        struct WeatherConditions: Codable {
            let id: Int
            let main: String
            let description: String
            let icon: String
        }
        
        let temp: TempData
        let pressure: Int
        let humidity: Float
        let weather: [WeatherConditions]
        let speed: Float
        let deg: Float?
        let clouds: Int
        // let pop: Float
//        let rain: String
    }
    
    struct CityData: Codable {
        let name: String
        let country: String
    }
    
    let city: CityData
    let list: [Weathers]

}
