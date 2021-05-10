//
//  DailyForecastViewController.swift
//  VaCay
//
//  Created by Andre on 8/16/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit

class DailyForecastViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var weatherList: UITableView!

    var data:DailyForecastData!
    var weathers = [DailyForecastData.Weathers]()
    var scale:TemperatureScale!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        weatherList.delegate = self
        weatherList.dataSource = self
        
        weatherList.estimatedRowHeight = 80.0
        weatherList.rowHeight = UITableView.automaticDimension
        
        weatherList.reloadData()
        
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
           
           
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weathers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let iconSet:[WeatherIcon] = gWeatherViewController.iconSet
                
        let cell:WeatherCell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath) as! WeatherCell
        
        self.weatherList.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
                
        let index:Int = indexPath.row
                
        if self.weathers.indices.contains(index) {
            
            let weather = self.weathers[index]
            
            DispatchQueue.main.async {
                cell.lbl_time.text = self.getDateFromTimeStamp(timeStamp: Double(weather.dt))
                cell.lbl_desc.text = weather.weather[0].description.capitalized
                cell.lbl_temp.text = String(weather.temp.day) + " \(self.scale.symbolForScale())"
                cell.lbl_clouds.text = String(weather.clouds) + " %"
                cell.lbl_wind.text = String(weather.speed) + " mps"
                cell.lbl_humidity.text = String(weather.humidity) + " %"
                
                if self.data != nil {
                    if iconSet.contains(where: {weather.weather[0].description.lowercased() == $0.desc.lowercased() && $0.time == self.getDayTime(timeStamp: Double(weather.dt))}){
                        cell.img_weather.image = UIImage(systemName: iconSet.filter{
                        icon in return weather.weather[0].description.lowercased() == icon.desc.lowercased() && icon.time == self.getDayTime(timeStamp: Double(weather.dt))
                        }[0].icon)
                    
                    }else{
                        if iconSet.contains(where: {$0.desc.lowercased().contains(weather.weather[0].main.lowercased()) && $0.time == self.getDayTime(timeStamp: Double(weather.dt))}){
                            cell.img_weather.image = UIImage(systemName: iconSet.filter{
                                icon in return icon.desc.lowercased().contains(weather.weather[0].main.lowercased()) && icon.time == self.getDayTime(timeStamp: Double(weather.dt))
                            }[0].icon)
                        }
                    }
                }
                
                if self.warn(weather: weather){
                    cell.view_content.backgroundColor = .orange
                }else{
                    cell.view_content.backgroundColor = UIColor(rgb: 0x5A97D0, alpha: 1.0)
                }
            
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedView(gesture:)))
                cell.view_content.tag = index
                cell.view_content.addGestureRecognizer(tap)
                cell.view_content.isUserInteractionEnabled = true
                cell.view_content.layer.cornerRadius = 5
                        
            }
            
        }
        
        cell.view_content.sizeToFit()
        cell.view_content.layoutIfNeeded()
        
        return cell
            
            
    }
    
    @objc func tappedView(gesture:UITapGestureRecognizer) {
        let index = gesture.view?.tag
        let weather = self.weathers[index!]
        gDailyForecastWeatherData = weather
        gForecastWeatherData = nil
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WeatherDetailViewController")
        self.modalPresentationStyle = .fullScreen
        self.present(vc!, animated: true, completion: nil)
    }
    
    
    func getDayTime(timeStamp:Double) -> String {
        var daytime = "day"
        let date = NSDate(timeIntervalSince1970: timeStamp)
        var calendar = Calendar.current
        let hour = calendar.component(.hour, from: date as Date)
        if hour > 6 && hour < 18 {
            daytime = "day"
        }else {
            daytime = "night"
        }
        return daytime
    }
    
    
    func getTimeFromTimeStamp(timeStamp : Double) -> String {
            
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        
        let date = NSDate(timeIntervalSince1970: timeStamp)
            
        var calendar = Calendar.current
        
        let year = calendar.component(.year, from: date as Date)
        let month = calendar.component(.month, from: date as Date)
        let day = calendar.component(.day, from: date as Date)
        let hour = calendar.component(.hour, from: date as Date)
        let minute = calendar.component(.minute, from: date as Date)
        let second = calendar.component(.second, from: date as Date)
            
        var timeStr = convert(number: hour) + ":" + convert(number: minute) + " AM"
            
        if hour >= 12 {
            if hour > 12 {
                timeStr = convert(number: hour - 12) + ":" + convert(number: minute) + " PM"
            }else {
                timeStr = convert(number: hour) + ":" + convert(number: minute) + " PM"
            }
        }
            
        return months[month - 1] + " " + String(day) + " " + timeStr
    }
    
    func convert(number:Int) -> String{
        var formatted = String(number)
        if number < 10 {
            formatted = "0" + String(number)
        }
        return formatted
    }
    
    func getDateFromTimeStamp(timeStamp : Double) -> String {
        
        let date = NSDate(timeIntervalSince1970: timeStamp)
        
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "E dd MMM YY"
        // UnComment below to get only time
        //  dayTimePeriodFormatter.dateFormat = "hh:mm a"
        
        let dateString = dayTimePeriodFormatter.string(from: date as Date)
        return dateString
    }
    
    func warn(weather:DailyForecastData.Weathers) -> Bool {
        if weather.weather[0].description.contains("thunderstorm")
            || weather.weather[0].description.contains("rain")
            || weather.weather[0].description.contains("snow")
            || weather.weather[0].description.contains("volcanic ash")
            || weather.weather[0].description.contains("tornado")
            || weather.weather[0].description.contains("shower")
            || weather.weather[0].description.contains("snow")
            || weather.speed > 20
            || gWeatherViewController.isDangerousTemperature(temp_max: weather.temp.max, temp_min: weather.temp.min)
        {
            return true
        }
            
        return false
    }

}
