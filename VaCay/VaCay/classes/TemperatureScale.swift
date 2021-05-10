//
//  TemperatureScale.swift
//  VaCay
//
//  Created by Andre on 8/16/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import Foundation

enum TemperatureScale: String {
    case celsius = "metric"
    case kelvin = "kelvin"
    case fahrenheit = "imperial"
    
    func symbolForScale() -> String {
        switch(self) {
        case .celsius:
            return "℃"
        case .kelvin:
            return "K"
        case .fahrenheit:
            return "℉"
        }
    }
}
