//
//  AddLocationViewController.swift
//  VaCay
//
//  Created by Andre on 7/19/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import AddressBookUI

extension UITextField {
    // Next step here
    func underlined(){
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}

class AddLocationViewController: BaseViewController, CLLocationManagerDelegate, GMSMapViewDelegate{
    
    var manager = CLLocationManager()
    var map = GMSMapView()
    @IBOutlet weak var viewForGMap: UIView!
    var marker:GMSMarker? = nil
    var myMarker:GMSMarker? = nil
    var circle:GMSCircle? = nil
    var camera: GMSCameraPosition? = nil
    var thisUserLocation:CLLocationCoordinate2D? = nil
    @IBOutlet weak var view_search: UIView!
    @IBOutlet weak var edt_search: UITextField!
    @IBOutlet weak var btn_ok: UIButton!
    
    @IBOutlet weak var btn_location: UIButton!
    var selectedLocation:CLLocationCoordinate2D? = nil
    var startF:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setRoundShadowButton(button: btn_location, corner: 3)
        setRoundShadowButton(button: btn_ok, corner: 25)
        setRoundShadowView(view: view_search, corner: 5)
        edt_search.underlined()
        edt_search.returnKeyType = .search
        
        // User Location
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        // locationManager.allowDeferredLocationUpdates(untilTraveled: 0, timeout: 0)
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
            // manager.startUpdatingHeading()
        }
        
    }
    
    func showHint(){
        let alert = UIAlertController(title: "HINT", message: "Please select correct location.\nYou can type the address to search or your can click on the map to select correct location.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel){(ACTION) in
            
        }
        alert.addAction(okAction)
        self.present(alert, animated:true, completion:nil);
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
            self.forwardGeocoding(address: (textField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!)
        }
        return false
    }
    
    @IBAction func showMyLocation(_ sender: Any) {
        camera = GMSCameraPosition.camera(withLatitude: (thisUserLocation!.latitude), longitude: (thisUserLocation!.longitude), zoom: 20.0, bearing: 30, viewingAngle: 30)
        //  map.camera = camera!
        map.animate(to: camera!)
        self.selectedLocation = thisUserLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0{
            let userLocation = locations.last!
            print("locations = \(locations)")
            let center = CLLocationCoordinate2D(latitude: (userLocation.coordinate.latitude), longitude: (userLocation.coordinate.longitude))
            
            if thisUserLocation == nil{
                camera = GMSCameraPosition.camera(withLatitude: (userLocation.coordinate.latitude), longitude: (userLocation.coordinate.longitude), zoom: 20.0, bearing: 30, viewingAngle: 30)
                map = GMSMapView.map(withFrame: self.viewForGMap.frame, camera: camera!)
                map.animate(to: camera!)
                map.delegate = self
                self.viewForGMap.addSubview(map)
                map.isMyLocationEnabled = false
                map.isBuildingsEnabled = true
                if self.myMarker == nil{
                    //   Creates a marker in the center of the map.
                    self.myMarker = GMSMarker()
                    self.myMarker!.position = center
                    self.myMarker!.title = "Me"
                    self.myMarker!.map = map
                    self.myMarker!.icon = UIImage(named: "mylocationmarker")
                }
                map.mapType = gMapType
                print("Map type+++\(gMapType.rawValue)")
            }else{
                let currentZoom = self.map.camera.zoom;
                camera = GMSCameraPosition.camera(withLatitude: (userLocation.coordinate.latitude), longitude: (userLocation.coordinate.longitude), zoom: currentZoom, bearing: 30, viewingAngle: 30)
                if gMapCameraMoveF == true{
                    map.camera = camera!
                }
                if self.myMarker != nil{
                    self.myMarker!.position = center
                }
            }
            
            thisUserLocation = center
            drawCircle(center:center)
            
            self.selectedLocation = center
        }
        
        if !startF{
            startF = true
            showHint()
        }
        
        //        let address = "San Francisco, USA"
        //        if dealLoc == nil{
        //            forwardGeocoding(address: address)
        //        }
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        //        if marker == nil{
        //            map = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        //            map.camera = camera
        //            view = map
        //            // Creates a marker in the center of the map.
        //            marker = GMSMarker()
        //            marker!.position = center
        //            marker!.title = "Me"
        //            marker!.map = map
        //            marker!.icon = UIImage(named: "mylocationmarker")
        //
        //            map.isMyLocationEnabled = false
        //            map.isBuildingsEnabled = true
        ////            map.settings.myLocationButton = true
        //            map.mapType = .hybrid
        //        }else{
        //            let currentZoom = self.map.camera.zoom;
        //            camera = GMSCameraPosition.camera(withLatitude: (userLocation!.coordinate.latitude), longitude: (userLocation!.coordinate.longitude), zoom: currentZoom, bearing: 30, viewingAngle: 30)
        //            if mapCameraMoveF == true{
        //                map.camera = camera
        //            }
        //            marker!.position = center
        //        }
        //        drawCircle(center:center)
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        //        manager.stopUpdatingLocation()
        
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("Tapped on Map at \(coordinate)")
        reverseGeocoding(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    func drawCircle(center:CLLocationCoordinate2D){
        if circle == nil{
            circle = GMSCircle(position: center, radius: CLLocationDistance(RADIUS))
            circle?.fillColor = UIColor(red: 204, green: 220, blue: 255, alpha: 0.3) // 204, 220, 255
            circle?.strokeColor = UIColor(red: 128, green: 168, blue: 255, alpha: 0.8)  //  128, 168, 255
            circle?.strokeWidth = 1
            circle?.map = map
        }else{
            circle?.position = center
        }
    }
    
    func showDealLocationFromAddress(address:String){
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                    // handle no location found
                    return
            }
            // Use your location
            self.camera = GMSCameraPosition.camera(withLatitude: (location.coordinate.latitude), longitude: (location.coordinate.longitude), zoom: 20.0, bearing: 30, viewingAngle: 30)
            self.marker = GMSMarker()
            self.marker?.position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            self.marker?.title = "10% OFF"
            self.marker!.map = self.map
            self.marker!.icon = UIImage(named: "marker")
            self.map.animate(to: self.camera!)
            self.selectedLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    func forwardGeocoding(address: String) {
        self.selectedLocation = nil
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if error != nil {
                print(error as Any)
                return
            }
            if (placemarks?.count)! > 0 {
                let placemark = placemarks?[0]
                let location = placemark?.location
                let coordinate = location?.coordinate
                let placename = placemark?.name
                print("\nlat: \(coordinate!.latitude), long: \(coordinate!.longitude)")
                if self.marker != nil{
                    self.marker!.map = nil
                }
                self.camera = GMSCameraPosition.camera(withLatitude: (coordinate!.latitude), longitude: (coordinate!.longitude), zoom: 20.0, bearing: 30, viewingAngle: 30)
                self.marker = GMSMarker()
                self.marker?.position = CLLocationCoordinate2D(latitude: coordinate!.latitude, longitude: coordinate!.longitude)
                self.marker?.title = placename
                self.marker!.map = self.map
//                self.marker!.icon = UIImage(named: "marker")
                self.map.animate(to: self.camera!)
                self.selectedLocation = CLLocationCoordinate2D(latitude: coordinate!.latitude, longitude: coordinate!.longitude)
            }
        })
    }
    
    @IBAction func search_by_audio(_ sender: Any) {
        
    }
    
    @IBAction func ok_loc(_ sender: Any) {
        
        if self.selectedLocation == nil{
            showToast(msg: "Please pick your location.")
            return
        }
        
        reverseGeocoding(latitude: self.selectedLocation!.latitude, longitude: self.selectedLocation!.longitude)
        return
        
    }
    
    
    func reverseGeocoding(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        self.edt_search.text = ""
        if self.marker != nil{
            self.marker!.map = nil
        }
        self.camera = GMSCameraPosition.camera(withLatitude: (location.coordinate.latitude), longitude: (location.coordinate.longitude), zoom: 20.0, bearing: 30, viewingAngle: 30)
        self.marker = GMSMarker()
        self.marker?.position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        self.marker?.title = addressString
//        self.marker!.snippet = addressString
        self.marker!.map = self.map
        // self.marker!.icon = UIImage(named: "marker")
        self.map.animate(to: self.camera!)
        
        self.selectedLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Custom Location Error+++\(error as Any)")
                return
            }
            else if (placemarks?.count)! > 0 {
                let pm = placemarks![0]
                
                var city = ""
                
                var addArray:[String] = []
                
                if let name = pm.name {
                    addArray.append(name)
                }
//                if let thoroughfare = pm.thoroughfare {
//                    addArray.append(thoroughfare)
//                }
//                if let subLocality = pm.subLocality {
//                    addArray.append(subLocality)
//                }
                if let locality = pm.locality {
                    addArray.append(locality)
                    city = locality
                }
                
                if let postalCode = pm.postalCode {
                    addArray.append(postalCode)
                }
//                if let subAdministrativeArea = pm.subAdministrativeArea {
//                    addArray.append(subAdministrativeArea)
//                }
                if let administrativeArea = pm.administrativeArea {
                    addArray.append(administrativeArea)
                }
                if let country = pm.country {
                    addArray.append(country)
                }
                
                let addressString = addArray.joined(separator: ",\n")
                let address = addArray.joined(separator: ", ")
                
                print(addressString)
                
//                self.edt_search.text = addressString
                self.marker?.title = address
                self.showAlertDialog(addressStr: addressString, address:address, city: city, lat: String(latitude), lng: String(longitude))
            }
        })
    }
    
    func showAlertDialog(addressStr:String, address:String, city:String, lat:String, lng:String){
        let alert = UIAlertController(title: "Location Info", message: addressStr, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action : UIAlertAction!) -> Void in })
        let regAction = UIAlertAction(title: "Register", style: .destructive, handler: { alert -> Void in
            self.addLocation(member_id: thisUser.idx, address: address, city: city, lat: lat, lng: lng)
        })
        
        alert.addAction(regAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func addLocation(member_id:Int64, address:String, city:String, lat:String, lng:String)
    {
        showLoadingView()
        APIs.addLocation(member_id: member_id, address: address, city: city, lat: lat, lng: lng, handleCallback:{
            user, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                thisUser = user!
                UserDefaults.standard.set(thisUser.email, forKey: "email")
                UserDefaults.standard.set(thisUser.password, forKey: "password")
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController")
                vc.modalPresentationStyle = .fullScreen
                self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
            }else if result_code == "1" {
                thisUser.idx = 0
                self.showToast(msg: "This user doesn'\t exist.")
            }else{
                self.showToast(msg: "Something wrong")
            }
        })
    }
    
}
