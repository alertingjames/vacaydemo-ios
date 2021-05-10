//
//  WeatherViewController+MapKit.swift
//  VaCay
//
//  Created by Andre on 8/16/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import Foundation

import UIKit
import MapKit

extension WeatherViewController: CLLocationManagerDelegate {
    
    func getCurrentUserLocation() {
        self.showLoadingView()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            // locationManager.allowDeferredLocationUpdates(untilTraveled: 0, timeout: 0)
            if CLLocationManager.locationServicesEnabled() {
                locationManager.startUpdatingLocation()
                // manager.startUpdatingHeading()
            }
        }
    }
    
    func getWeather(location: CLLocation) {
        self.newLocation = location
        self.newCityName = ""
        gWeatherViewController.getWeatherData2(lat: location.coordinate.latitude, lon: location.coordinate.longitude, scale: self.getCurrentTemperatureScaleSelection())
    }
    
    func fetchCityAndCountry(from location: CLLocation, completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            completion(placemarks?.first?.locality,
                       placemarks?.first?.isoCountryCode,
                       error)
        }
    }
    
    func getCurrentTemperatureScaleSelection() -> TemperatureScale {
        if let temp_scale = UserDefaults.standard.string(forKey: "temp_scale") {
            if temp_scale.count > 0 {
                if temp_scale == "fahrenheit"{
                    return .fahrenheit
                }else if temp_scale == "kelvin" {
                    return .kelvin
                }else {
                    return .celsius
                }
            }
        }        
        return .celsius
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else {
            print("Warning: location is nil")
            if thisUser.lat != "" && !isWeatherLocationChanged {
                getWeather(location: CLLocation(latitude: CLLocationDegrees(thisUser.lat)!, longitude: CLLocationDegrees(thisUser.lng)!))
            }else{
                self.dismissLoadingView()
            }
            return
        }
        print("locations count:", locations.count)
        if locations.count > 0{
            print("My Location: \(location.coordinate)")
        }
        if !isWeatherLocationChanged {
            getWeather(location: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        if thisUser.lat != "" && !isWeatherLocationChanged {
            getWeather(location: CLLocation(latitude: CLLocationDegrees(thisUser.lat)!, longitude: CLLocationDegrees(thisUser.lng)!))
        }else{
            self.dismissLoadingView()
        }
    }
    
}
