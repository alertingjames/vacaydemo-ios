//
//  WeatherViewController.swift
//  VaCay
//
//  Created by Andre on 8/16/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit
import SJSegmentedScrollView
import MapKit
import Kingfisher

class WeatherViewController: SJSegmentedViewController {
    
    var loadingView:UIActivityIndicatorView = UIActivityIndicatorView()
    
    var headerController:HeaderViewController!
    var hourlyForecastController:HourlyForecastViewController!
    var dailyForecastController:DailyForecastViewController!
    
    var selectedSegment: SJSegmentTab?
    let locationManager = CLLocationManager()
    var weatherData: WeatherData?
    
    let iconSet:[WeatherIcon] = WeatherIconSet().initialize()
    var newCityName:String = ""
    var newLocation:CLLocation!
    
    var inputDialog:InputDialog!

    override func viewDidLoad() {
        
        if let storyboard = self.storyboard {
            
            gWeatherViewController = self

            headerController = storyboard
                .instantiateViewController(withIdentifier: "HeaderViewController") as? HeaderViewController

            hourlyForecastController = storyboard
                .instantiateViewController(withIdentifier: "HourlyForecastViewController") as? HourlyForecastViewController
            hourlyForecastController.title = "Hourly Forecast"

            dailyForecastController = storyboard
                .instantiateViewController(withIdentifier: "DailyForecastViewController") as? DailyForecastViewController
            dailyForecastController.title = "Daily Forecast"

            headerViewController = headerController
            segmentControllers = [
                hourlyForecastController,
                dailyForecastController
            ]
            
            headerViewHeight = 500
            segmentViewHeight = 60.0
            selectedSegmentViewHeight = 2.0
//            headerViewOffsetHeight = 50.0
            segmentBackgroundColor = UIColor(rgb: 0x607D8B, alpha: 1.0)
            segmentTitleColor = .lightGray
            segmentTitleFont = UIFont.systemFont(ofSize: 17.0)
            selectedSegment?.titleFont(UIFont.systemFont(ofSize: 19.0))
            segmentSelectedTitleColor = .white
            selectedSegmentViewColor = .white
            segmentShadow = SJShadow.light()
            showsHorizontalScrollIndicator = false
            showsVerticalScrollIndicator = false
            segmentBounces = false

            delegate = self
        }

        title = "Weather"
        
        super.viewDidLoad()
        
        self.headerController.lbl_location.text = ""
        self.headerController.lbl_weekday.text = ""
        self.headerController.lbl_dt.text = ""
        self.headerController.lbl_temp.text = ""
        self.headerController.lbl_temp.text = ""
        self.headerController.lbl_main_desc.text =  ""
        self.headerController.lbl_desc.text =  ""
        self.headerController.lbl_clouds.text = ""
        self.headerController.lbl_temp_range.text =  ""
        self.headerController.lbl_wind_speed.text = ""
        self.headerController.lbl_pressure.text = ""
        self.headerController.lbl_humidity.text = ""
        self.headerController.lbl_sunrise.text =  ""
        self.headerController.lbl_sunset.text =  ""
        
        getCurrentUserLocation()
        
    }
    
    func getWeatherData(cityName: String, countryCode: String, scale: TemperatureScale) {
        WeatherAPI.shared.getCurrentWeatherByCityName(cityName: cityName, countryCode: countryCode, tempScale: scale) { (data) in
            self.updateUI(weatherData: data, scale: scale)
        }
    }
    
    func getWeatherData2(lat: Double, lon: Double, scale: TemperatureScale) {
        WeatherAPI.shared.getCurrentWeatherByCoordinates(lat: lat, lon: lon, tempScale: scale) { (data) in
            self.dismissLoadingView()
            self.updateUI(weatherData: data, scale: scale)
        }
        
        WeatherAPI.shared.getForecastByCoordinates(lat: lat, lon: lon, tempScale: scale) { (data) in
            self.dismissLoadingView()
            self.hourlyForecastController.data = data
            self.hourlyForecastController.weathers = data.list
            self.hourlyForecastController.scale = scale
            
            DispatchQueue.main.async {
                self.hourlyForecastController.weatherList.reloadData()
            }
        }
        
        WeatherAPI.shared.getDailyForecastByCoordinates(lat: lat, lon: lon, tempScale: scale) { (data) in
            self.dismissLoadingView()
            self.dailyForecastController.data = data
            self.dailyForecastController.weathers = data.list
            self.dailyForecastController.scale = scale
            
            DispatchQueue.main.async {
                self.dailyForecastController.weatherList.reloadData()
            }
        }
    }
    
    func updateUI(weatherData: WeatherData, scale: TemperatureScale) {
        DispatchQueue.main.async {
            self.headerController.lbl_location.text = weatherData.name + "," + weatherData.sys.country
            self.headerController.lbl_weekday.text = self.getWeekday(timeStamp: Double(weatherData.dt))
            self.headerController.lbl_dt.text = self.getTimeFromTimeStamp(timeStamp: Double(weatherData.dt))
            self.headerController.lbl_temp.text = String(weatherData.main.temp) + " \(scale.symbolForScale())"
            self.headerController.lbl_main_desc.text = weatherData.weather[0].main
            self.headerController.lbl_desc.text = weatherData.weather[0].description.capitalized
            self.headerController.lbl_clouds.text = "Cloud Coverage: " + String(weatherData.clouds.all) + " %"
            self.headerController.lbl_temp_range.text = String(weatherData.main.temp_min) + " \(scale.symbolForScale())" + " ~ " + String(weatherData.main.temp_max) + " \(scale.symbolForScale())"
            self.headerController.lbl_wind_speed.text = "Wind: " + String(weatherData.wind.speed) + " mps"
            self.headerController.ic_wind_direction.isHidden = false
            self.headerController.ic_wind_direction.transform = self.headerController.ic_wind_direction.transform.rotated(by: .pi + .pi * CGFloat(weatherData.wind.deg!) / 180)
            self.headerController.lbl_pressure.text = "Pressure: " + String(weatherData.main.pressure) + " kPa"
            self.headerController.lbl_humidity.text = "Humidity: " + String(weatherData.main.humidity) + " %"
            self.headerController.ic_sunrise.isHidden = false
            self.headerController.ic_sunset.isHidden = false
            self.headerController.lbl_sunrise.text = self.getTimeFromTimeStamp(timeStamp: weatherData.sys.sunrise)
            self.headerController.lbl_sunset.text = self.getTimeFromTimeStamp(timeStamp: weatherData.sys.sunset)
            
            if self.iconSet.contains(where: {weatherData.weather[0].description.lowercased() == $0.desc.lowercased() && $0.time == self.getDayTime(now: Double(weatherData.dt), sunrise: weatherData.sys.sunrise, sunset: weatherData.sys.sunset)}){
                self.headerController.img_weather.image = UIImage(systemName: self.iconSet.filter{
                icon in return weatherData.weather[0].description.lowercased() == icon.desc.lowercased() && icon.time == self.getDayTime(now: Double(weatherData.dt), sunrise: weatherData.sys.sunrise, sunset: weatherData.sys.sunset)
                }[0].icon)
            }else{
                if self.iconSet.contains(where: {$0.desc.lowercased().contains(weatherData.weather[0].main.lowercased()) && $0.time == self.getDayTime(now: Double(weatherData.dt), sunrise: weatherData.sys.sunrise, sunset: weatherData.sys.sunset)}){
                    self.headerController.img_weather.image = UIImage(systemName: self.iconSet.filter{
                        icon in return icon.desc.lowercased().contains(weatherData.weather[0].main.lowercased()) && icon.time == self.getDayTime(now: Double(weatherData.dt), sunrise: weatherData.sys.sunrise, sunset: weatherData.sys.sunset)
                    }[0].icon)
                }
            }
            
            self.warn(weather: weatherData)
            
            self.weatherData = weatherData
            
        }
    }
    
    func getDayTime(now:Double, sunrise:Double, sunset:Double) -> String {
        var daytime = "day"
        if now >= sunrise && now <= sunset {
            daytime = "day"
        }else {
            daytime = "night"
        }
        return daytime
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getTimeFromTimeStamp(timeStamp : Double) -> String {
        
        let date = NSDate(timeIntervalSince1970: timeStamp)
        
        var calendar = Calendar.current
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
        
        return timeStr
    }
    
    func convert(number:Int) -> String{
        var formatted = String(number)
        if number < 10 {
            formatted = "0" + String(number)
        }
        return formatted
    }
    
    func getWeekday(timeStamp:Double) -> String {
        let date = NSDate(timeIntervalSince1970: timeStamp)
        
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "EEEE"
        // UnComment below to get only time
        //  dayTimePeriodFormatter.dateFormat = "hh:mm a"
        
        let dateString = dayTimePeriodFormatter.string(from: date as Date)
        return dateString
    }
    
    func showLoadingView(){
        loadingView.center = self.view.center
        loadingView.hidesWhenStopped = true
        loadingView.style = UIActivityIndicatorView.Style.large
        loadingView.color = UIColor.orange
        view.addSubview(loadingView)
        loadingView.startAnimating()
    }
    
    func dismissLoadingView(){
        DispatchQueue.main.async {
            if self.loadingView.isAnimating {
                self.loadingView.stopAnimating()
            }
        }
    }
    
    func getWeatherData3(city:String, scale: TemperatureScale) {
        self.showLoadingView()
        WeatherAPI.shared.getCurrentWeatherByCityNameOnly(cityName:city, tempScale: scale) { (data) in
            self.dismissLoadingView()
            self.updateUI(weatherData: data, scale: scale)
        }
        
        WeatherAPI.shared.getForecastByCityNameOnly(cityName:city, tempScale: scale) { (data) in
            self.dismissLoadingView()
            self.hourlyForecastController.data = data
            self.hourlyForecastController.weathers = data.list
            self.hourlyForecastController.scale = scale
            
            DispatchQueue.main.async {
                self.hourlyForecastController.weatherList.reloadData()
            }
        }
        
        WeatherAPI.shared.getDailyForecastByCityNameOnly(cityName:city, tempScale: scale) { (data) in
            self.dismissLoadingView()
            self.dailyForecastController.data = data
            self.dailyForecastController.weathers = data.list
            self.dailyForecastController.scale = scale
            
            DispatchQueue.main.async {
                self.dailyForecastController.weatherList.reloadData()
            }
        }
    }
    
    func warn(weather:WeatherData) {
        if weather.weather[0].description.contains("thunderstorm")
            || weather.weather[0].description.contains("rain")
            || weather.weather[0].description.contains("snow")
            || weather.weather[0].description.contains("volcanic ash")
            || weather.weather[0].description.contains("tornado")
            || weather.weather[0].description.contains("shower")
            || weather.weather[0].description.contains("snow")
        {
            self.headerController.ic_alert.visibilityh = .visible
        }
        if self.isDangerousTemperature(temp_max: weather.main.temp_max, temp_min: weather.main.temp_min) {
            self.headerController.ic_alert_temp.visibilityh = .visible
        }
        if weather.wind.speed > 20 {
            self.headerController.ic_alert_wind.visibilityh = .visible
        }
        if weather.main.pressure < 950 {
            self.headerController.ic_alert_pressure.visibilityh = .visible
        }
    }
    
    func isDangerousTemperature(temp_max:Float, temp_min:Float) -> Bool {
        if self.getCurrentTemperatureScaleSelection() == .celsius {
            if temp_max > 35 || temp_min < -15 {
                return true
            }
        }else if self.getCurrentTemperatureScaleSelection() == .fahrenheit {
            if temp_max > 95 || temp_min < 5 {
                return true
            }
        }else if self.getCurrentTemperatureScaleSelection() == .kelvin {
            if temp_max > 308.15 || temp_min < 258.15 {
                return true
            }
        }
        return false
    }
    
    func showInputDialog(title:String, button_text:String, index:Int){
        inputDialog = self.storyboard!.instantiateViewController(withIdentifier: "InputDialog") as? InputDialog
        inputDialog.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        inputDialog.titleBox.text = title
        inputDialog.button.setTitle(button_text, for: .normal)
        inputDialog.index = index
        inputDialog.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        inputDialog.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.addChild(self.inputDialog)
        self.view.addSubview(self.inputDialog.view)
    }

}

extension WeatherViewController: SJSegmentedViewControllerDelegate {

    func didMoveToPage(_ controller: UIViewController, segment: SJSegmentTab?, index: Int) {

        if selectedSegment != nil {
            selectedSegment?.titleColor(.lightGray)
        }

        if segments.count > 0 {

            selectedSegment = segments[index]
            selectedSegment?.titleColor(.red)
        }
    }
}
