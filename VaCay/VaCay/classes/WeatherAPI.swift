//
//  WeatherAPI.swift
//  VaCay
//
//  Created by Andre on 8/16/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import Foundation
import SwiftyJSON

class WeatherAPI: NSObject {
    
    static let shared = WeatherAPI()
    
    func getCurrentWeatherByCityName(cityName: String, countryCode: String, tempScale: TemperatureScale, completionHandler: @escaping ((WeatherData) -> ())) {
        
        guard let sanitizedCityName = cityName.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else {
            print("Error: while sanitizing city name")
            return
        }
        
        guard let key = getAPIKey() else {
            print("Error: could not extract API key")
            return
        }
        
        // Set up the URL request
        let endpointString = "https://api.openweathermap.org/data/2.5/weather?q=\(sanitizedCityName),\(countryCode)&units=\(tempScale.rawValue)&APPID=\(key)"
        
        print("final request string:", endpointString)
        
        guard let url = URL(string: endpointString) else {
            print("error: URL NOT valid")
            return
        }
        
        print("final request string:", endpointString)
        let urlRequest = URLRequest(url: url)
        
        // Set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // Make the request
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // Check for any errors
            if let error = error {
                print("error calling GET on current weather:", error.localizedDescription)
                return
            }
            
            // Make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            do {
                guard let jsonData = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                    print("Error trying to convert data to JSON")
                    return
                }
                print(jsonData)
                
                // Parse the result as JSON, since that's what the API provides
                let decoder = JSONDecoder()
                let weatherData = try decoder.decode(WeatherData.self, from: responseData)
                completionHandler(weatherData)
            } catch {
                print("Error: conversion to JSON")
            }
        }
        
        task.resume()
    }
    
    
    func getCurrentWeatherByCoordinates(lat: Double, lon: Double, tempScale: TemperatureScale, completionHandler: @escaping ((WeatherData) -> ())) {
        
        guard let key = getAPIKey() else {
            print("Error: could not extract API key")
            return
        }
        
        // Set up the URL request
        let endpointString = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&units=\(tempScale.rawValue)&APPID=\(key)"
        
        print("final request string:", endpointString)
        
        guard let url = URL(string: endpointString) else {
            print("error: URL NOT valid")
            self.dismissLoadingView()
            return
        }
        
        print("final request string:", endpointString)
        let urlRequest = URLRequest(url: url)
        
        // Set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // Make the request
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // Check for any errors
            if let error = error {
                print("error calling GET on current weather:", error.localizedDescription)
                self.dismissLoadingView()
                return
            }
            
            // Make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                self.dismissLoadingView()
                return
            }
            
            do {
                guard let jsonData = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                    print("Error trying to convert data to JSON")
                    self.dismissLoadingView()
                    return
                }
                print(jsonData)
//                print(JSON(jsonData)["name"].stringValue)
//                let dataArray = JSON(jsonData)["weather"].arrayObject as! [[String: Any]]
//                print("Weather: \(dataArray[0]["main"] as! String)")
                
                // Parse the result as JSON, since that's what the API provides
                let decoder = JSONDecoder()
                let weatherData = try decoder.decode(WeatherData.self, from: responseData)
                completionHandler(weatherData)
            } catch {
                print("Error: conversion to JSON")
                self.dismissLoadingView()
            }
        }
        
        task.resume()
    }
    
    func getForecastByCoordinates(lat: Double, lon: Double, tempScale: TemperatureScale, completionHandler: @escaping ((ForecastData) -> ())) {
            
        guard let key = getAPIKey() else {
            print("Error: could not extract API key")
            return
        }
            
        // Set up the URL request
        let endpointString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&units=\(tempScale.rawValue)&APPID=\(key)"
            
        print("final request string:", endpointString)
            
        guard let url = URL(string: endpointString) else {
            print("error: URL NOT valid")
            return
        }
            
        print("final request string:", endpointString)
        let urlRequest = URLRequest(url: url)
            
        // Set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
            
        // Make the request
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // Check for any errors
            if let error = error {
                print("error calling GET on current weather:", error.localizedDescription)
                return
            }
                
            // Make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
                
            do {
                guard let jsonData = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                    print("Error trying to convert data to JSON")
                    return
                }
                print(jsonData)
    //          print(JSON(jsonData)["name"].stringValue)
    //          let dataArray = JSON(jsonData)["weather"].arrayObject as! [[String: Any]]
    //          print("Weather: \(dataArray[0]["main"] as! String)")
                    
                // Parse the result as JSON, since that's what the API provides
                let decoder = JSONDecoder()
                let forecastData = try decoder.decode(ForecastData.self, from: responseData)
                completionHandler(forecastData)
            } catch {
                print("Error: conversion to JSON")
            }
        }
            
        task.resume()
    }
    
    func getDailyForecastByCoordinates(lat: Double, lon: Double, tempScale: TemperatureScale, completionHandler: @escaping ((DailyForecastData) -> ())) {
            
        guard let key = getAPIKey() else {
            print("Error: could not extract API key")
            return
        }
            
        // Set up the URL request
        let endpointString = "https://api.openweathermap.org/data/2.5/forecast/daily?lat=\(lat)&lon=\(lon)&units=\(tempScale.rawValue)&cnt=16&APPID=\(key)"
            
        print("final request string:", endpointString)
            
        guard let url = URL(string: endpointString) else {
            print("error: URL NOT valid")
            return
        }
            
        print("final request string:", endpointString)
        let urlRequest = URLRequest(url: url)
            
        // Set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
            
        // Make the request
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // Check for any errors
            if let error = error {
                print("error calling GET on current weather:", error.localizedDescription)
                return
            }
                
            // Make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
                
            do {
                guard let jsonData = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                    print("Error trying to convert data to JSON")
                    return
                }
                print(jsonData)
    //          print(JSON(jsonData)["name"].stringValue)
                let dataArray = JSON(jsonData)["list"].arrayObject as! [[String: Any]]
                print("Sunrise: \(dataArray[0]["sunrise"])")
                    
                // Parse the result as JSON, since that's what the API provides
                let decoder = JSONDecoder()
                let dailyForecastData = try decoder.decode(DailyForecastData.self, from: responseData)
                completionHandler(dailyForecastData)
            } catch {
                print("Error: conversion to JSON")
            }
        }
            
        task.resume()
    }
    
    func getCurrentWeatherByCityNameOnly(cityName: String, tempScale: TemperatureScale, completionHandler: @escaping ((WeatherData) -> ())) {
        
        guard let sanitizedCityName = cityName.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else {
            print("Error: while sanitizing city name")
            return
        }
        
        guard let key = getAPIKey() else {
            print("Error: could not extract API key")
            return
        }
        
        // Set up the URL request
        let endpointString = "https://api.openweathermap.org/data/2.5/weather?q=\(sanitizedCityName)&units=\(tempScale.rawValue)&APPID=\(key)"
        
        print("final request string:", endpointString)
        
        guard let url = URL(string: endpointString) else {
            print("error: URL NOT valid")
            return
        }
        
        print("final request string:", endpointString)
        let urlRequest = URLRequest(url: url)
        
        // Set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // Make the request
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // Check for any errors
            if let error = error {
                print("error calling GET on current weather:", error.localizedDescription)
                return
            }
            
            // Make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            do {
                guard let jsonData = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                    print("Error trying to convert data to JSON")
                    return
                }
                print(jsonData)
                
                // Parse the result as JSON, since that's what the API provides
                let decoder = JSONDecoder()
                let weatherData = try decoder.decode(WeatherData.self, from: responseData)
                completionHandler(weatherData)
            } catch {
                print("Error: conversion to JSON")
            }
        }
        
        task.resume()
    }
    
    func getForecastByCityNameOnly(cityName: String, tempScale: TemperatureScale, completionHandler: @escaping ((ForecastData) -> ())) {
        
        guard let sanitizedCityName = cityName.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else {
            print("Error: while sanitizing city name")
            return
        }
        
        guard let key = getAPIKey() else {
            print("Error: could not extract API key")
            return
        }
        
        // Set up the URL request
        let endpointString = "https://api.openweathermap.org/data/2.5/forecast?q=\(sanitizedCityName)&units=\(tempScale.rawValue)&APPID=\(key)"
        
        print("final request string:", endpointString)
        
        guard let url = URL(string: endpointString) else {
            print("error: URL NOT valid")
            return
        }
        
        print("final request string:", endpointString)
        let urlRequest = URLRequest(url: url)
        
        // Set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // Make the request
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // Check for any errors
            if let error = error {
                print("error calling GET on current weather:", error.localizedDescription)
                return
            }
            
            // Make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            do {
                guard let jsonData = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                    print("Error trying to convert data to JSON")
                    return
                }
                print(jsonData)
                
                // Parse the result as JSON, since that's what the API provides
                let decoder = JSONDecoder()
                let forecastData = try decoder.decode(ForecastData.self, from: responseData)
                completionHandler(forecastData)
            } catch {
                print("Error: conversion to JSON")
            }
        }
        
        task.resume()
    }
    
    func getDailyForecastByCityNameOnly(cityName: String, tempScale: TemperatureScale, completionHandler: @escaping ((DailyForecastData) -> ())) {
        
        guard let sanitizedCityName = cityName.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else {
            print("Error: while sanitizing city name")
            return
        }
        
        guard let key = getAPIKey() else {
            print("Error: could not extract API key")
            return
        }
        
        // Set up the URL request
        let endpointString = "https://api.openweathermap.org/data/2.5/forecast/daily?q=\(sanitizedCityName)&units=\(tempScale.rawValue)&cnt=16&APPID=\(key)"
        
        print("final request string:", endpointString)
        
        guard let url = URL(string: endpointString) else {
            print("error: URL NOT valid")
            return
        }
        
        print("final request string:", endpointString)
        let urlRequest = URLRequest(url: url)
        
        // Set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // Make the request
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // Check for any errors
            if let error = error {
                print("error calling GET on current weather:", error.localizedDescription)
                return
            }
            
            // Make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            do {
                guard let jsonData = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                    print("Error trying to convert data to JSON")
                    return
                }
                print(jsonData)
                
                // Parse the result as JSON, since that's what the API provides
                let decoder = JSONDecoder()
                let dailyForecastData = try decoder.decode(DailyForecastData.self, from: responseData)
                completionHandler(dailyForecastData)
            } catch {
                print("Error: conversion to JSON")
            }
        }
        
        task.resume()
    }
    
    
    func getAPIKey() -> String? {
        return "705d108da607f99257eca12a61f7e0db"
    }
    
    func dismissLoadingView() {
        if gWeatherViewController != nil {
            gWeatherViewController.dismissLoadingView()
        }
    }
    
}
