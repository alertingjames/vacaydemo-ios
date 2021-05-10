//
//  WeatherDetailViewController.swift
//  VaCay
//
//  Created by Andre on 8/18/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit

class WeatherDetailViewController: BaseViewController {

    @IBOutlet weak var lbl_city: UILabel!
    @IBOutlet weak var lbl_weekday: UILabel!
    @IBOutlet weak var img_weather: UIImageView!
    @IBOutlet weak var lbl_main_desc: UILabel!
    @IBOutlet weak var lbl_temp: UILabel!
    @IBOutlet weak var lbl_desc: UILabel!
    @IBOutlet weak var lbl_time: UILabel!
    @IBOutlet weak var lbl_sun_rise: UILabel!
    @IBOutlet weak var lbl_sun_set: UILabel!
    @IBOutlet weak var lbl_clouds: UILabel!
    @IBOutlet weak var lbl_humidity: UILabel!
    @IBOutlet weak var lbl_pressure: UILabel!
    @IBOutlet weak var lbl_wind_speed: UILabel!
    @IBOutlet weak var lbl_wind_direction: UILabel!
    @IBOutlet weak var ic_wind_direction: UIImageView!
    @IBOutlet weak var lbl_temps: UILabel!
    
    @IBOutlet weak var ic_alert: UIImageView!
    @IBOutlet weak var ic_alert_temp: UIImageView!
    @IBOutlet weak var ic_alert_wind: UIImageView!
    @IBOutlet weak var ic_alert_pressure: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ic_alert.image = ic_alert.image?.imageWithColor(color1: UIColor.orange)
        ic_alert.visibilityh = .gone
        
        ic_alert_temp.image = ic_alert_temp.image?.imageWithColor(color1: UIColor.orange)
        ic_alert_temp.visibilityh = .gone
        
        ic_alert_wind.image = ic_alert_wind.image?.imageWithColor(color1: UIColor.orange)
        ic_alert_wind.visibilityh = .gone
        
        ic_alert_pressure.image = ic_alert_pressure.image?.imageWithColor(color1: UIColor.orange)
        ic_alert_pressure.visibilityh = .gone
        
        let iconSet:[WeatherIcon] = gWeatherViewController.iconSet

        if gForecastWeatherData != nil {
            lbl_city.text = gWeatherViewController.headerController.lbl_location.text
            lbl_weekday.text = gWeatherViewController.getWeekday(timeStamp: Double(gForecastWeatherData.dt))
            lbl_time.text = "Day-Time " + gWeatherViewController.getTimeFromTimeStamp(timeStamp: Double(gForecastWeatherData.dt))
            lbl_main_desc.text = gForecastWeatherData.weather[0].main.capitalized
            lbl_desc.text = gForecastWeatherData.weather[0].description.capitalized
            lbl_temp.text = String(gForecastWeatherData.main.temp) + " \(gWeatherViewController.hourlyForecastController.scale.symbolForScale())"
            lbl_temps.text = String(gForecastWeatherData.main.temp_min) + " \(gWeatherViewController.hourlyForecastController.scale.symbolForScale())" + " ~ " + String(gForecastWeatherData.main.temp_max) + " \(gWeatherViewController.hourlyForecastController.scale.symbolForScale())"
            lbl_clouds.text = String(gForecastWeatherData.clouds.all) + " %"
            lbl_wind_speed.text = String(gForecastWeatherData.wind.speed) + " mps"
            lbl_wind_direction.text = String(gForecastWeatherData.wind.deg!) + " °"
            ic_wind_direction.transform = ic_wind_direction.transform.rotated(by: .pi * CGFloat(gForecastWeatherData.wind.deg!) / 180)
            lbl_humidity.text = String(gForecastWeatherData.main.humidity) + " %"
            lbl_pressure.text = String(gForecastWeatherData.main.pressure) + " hPa"
            lbl_sun_rise.text = gWeatherViewController.getTimeFromTimeStamp(timeStamp: gWeatherViewController.hourlyForecastController.data.city.sunrise)
            lbl_sun_set.text = gWeatherViewController.getTimeFromTimeStamp(timeStamp: gWeatherViewController.hourlyForecastController.data.city.sunset)
            
            if gWeatherViewController.hourlyForecastController.data != nil {
                if iconSet.contains(where: {gForecastWeatherData.weather[0].description.lowercased() == $0.desc.lowercased() && $0.time == gWeatherViewController.hourlyForecastController.getDayTime(timeStamp: Double(gForecastWeatherData.dt))}){
                    self.img_weather.image = UIImage(systemName: iconSet.filter{
                        icon in return gForecastWeatherData.weather[0].description.lowercased() == icon.desc.lowercased() && icon.time == gWeatherViewController.hourlyForecastController.getDayTime(timeStamp: Double(gForecastWeatherData.dt))
                    }[0].icon)
                
                }else{
                    if iconSet.contains(where: {$0.desc.lowercased().contains(gForecastWeatherData.weather[0].main.lowercased()) && $0.time == gWeatherViewController.hourlyForecastController.getDayTime(timeStamp: Double(gForecastWeatherData.dt))}){
                        self.img_weather.image = UIImage(systemName: iconSet.filter{
                            icon in return icon.desc.lowercased().contains(gForecastWeatherData.weather[0].main.lowercased()) && icon.time == gWeatherViewController.hourlyForecastController.getDayTime(timeStamp: Double(gForecastWeatherData.dt))
                        }[0].icon)
                    }
                }
            }
            self.warn(weather: gForecastWeatherData)
            
        } else if gDailyForecastWeatherData != nil {
            lbl_city.text = gWeatherViewController.headerController.lbl_location.text
            lbl_weekday.text = gWeatherViewController.getWeekday(timeStamp: Double(gDailyForecastWeatherData.dt))
            lbl_time.text = "Day-Time " + gWeatherViewController.getTimeFromTimeStamp(timeStamp: Double(gDailyForecastWeatherData.dt))
            lbl_main_desc.text = gDailyForecastWeatherData.weather[0].main.capitalized
            lbl_desc.text = gDailyForecastWeatherData.weather[0].description.capitalized
            lbl_temp.text = String(gDailyForecastWeatherData.temp.day) + " \(gWeatherViewController.dailyForecastController.scale.symbolForScale())"
            lbl_temps.text = String(gDailyForecastWeatherData.temp.min) + " \(gWeatherViewController.dailyForecastController.scale.symbolForScale())" + " ~ " + String(gDailyForecastWeatherData.temp.max) + " \(gWeatherViewController.dailyForecastController.scale.symbolForScale())"
            lbl_clouds.text = String(gDailyForecastWeatherData.clouds) + " %"
            lbl_wind_speed.text = String(gDailyForecastWeatherData.speed) + " mps"
            lbl_wind_direction.text = String(gDailyForecastWeatherData.deg!) + " °"
            ic_wind_direction.transform = ic_wind_direction.transform.rotated(by: .pi + .pi * CGFloat(gDailyForecastWeatherData.deg!) / 180)
            lbl_humidity.text = String(gDailyForecastWeatherData.humidity) + " %"
            lbl_pressure.text = String(gDailyForecastWeatherData.pressure) + " hPa"
            lbl_sun_rise.text = gWeatherViewController.getTimeFromTimeStamp(timeStamp: gDailyForecastWeatherData.sunrise)
            lbl_sun_set.text = gWeatherViewController.getTimeFromTimeStamp(timeStamp: gDailyForecastWeatherData.sunset)
            
            if gWeatherViewController.dailyForecastController.data != nil {
                if iconSet.contains(where: {gDailyForecastWeatherData.weather[0].description.lowercased() == $0.desc.lowercased() && $0.time == gWeatherViewController.dailyForecastController.getDayTime(timeStamp: Double(gDailyForecastWeatherData.dt))}){
                    self.img_weather.image = UIImage(systemName: iconSet.filter{
                        icon in return gDailyForecastWeatherData.weather[0].description.lowercased() == icon.desc.lowercased() && icon.time == gWeatherViewController.dailyForecastController.getDayTime(timeStamp: Double(gDailyForecastWeatherData.dt))
                    }[0].icon)
                
                }else{
                    if iconSet.contains(where: {$0.desc.lowercased().contains(gDailyForecastWeatherData.weather[0].main.lowercased()) && $0.time == gWeatherViewController.dailyForecastController.getDayTime(timeStamp: Double(gDailyForecastWeatherData.dt))}){
                        self.img_weather.image = UIImage(systemName: iconSet.filter{
                            icon in return icon.desc.lowercased().contains(gDailyForecastWeatherData.weather[0].main.lowercased()) && icon.time == gWeatherViewController.dailyForecastController.getDayTime(timeStamp: Double(gDailyForecastWeatherData.dt))
                        }[0].icon)
                    }
                }
            }
            self.warn2(weather: gDailyForecastWeatherData)
        }
        
    }
    
    func warn(weather:ForecastData.Weathers) {
        if weather.weather[0].description.contains("thunderstorm")
            || weather.weather[0].description.contains("rain")
            || weather.weather[0].description.contains("snow")
            || weather.weather[0].description.contains("volcanic ash")
            || weather.weather[0].description.contains("tornado")
            || weather.weather[0].description.contains("shower")
            || weather.weather[0].description.contains("snow")
        {
            self.ic_alert.visibilityh = .visible
        }
        if gWeatherViewController.isDangerousTemperature(temp_max: weather.main.temp_max, temp_min: weather.main.temp_min) {
            self.ic_alert_temp.visibilityh = .visible
        }
        if weather.wind.speed > 20 {
            self.ic_alert_wind.visibilityh = .visible
        }
        if weather.main.pressure < 950 {
            self.ic_alert_pressure.visibilityh = .visible
        }
    }
    
    func warn2(weather:DailyForecastData.Weathers) {
        if weather.weather[0].description.contains("thunderstorm")
            || weather.weather[0].description.contains("rain")
            || weather.weather[0].description.contains("snow")
            || weather.weather[0].description.contains("volcanic ash")
            || weather.weather[0].description.contains("tornado")
            || weather.weather[0].description.contains("shower")
            || weather.weather[0].description.contains("snow")
        {
            self.ic_alert.visibilityh = .visible
        }
        if gWeatherViewController.isDangerousTemperature(temp_max: weather.temp.max, temp_min: weather.temp.min) {
            self.ic_alert_temp.visibilityh = .visible
        }
        if weather.speed > 20 {
            self.ic_alert_wind.visibilityh = .visible
        }
        if weather.pressure < 950 {
            self.ic_alert_pressure.visibilityh = .visible
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
