//
//  NearbyMenuViewController.swift
//  VaCay
//
//  Created by Andre on 8/21/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit
import MapKit

class NearbyMenuViewController: BaseViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var manager = CLLocationManager()
    var thisUserLocation:CLLocationCoordinate2D? = nil
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var view_searchbar: UIView!
    @IBOutlet weak var edt_search: UITextField!
    @IBOutlet weak var btn_search: UIButton!
    @IBOutlet weak var menuList: UITableView!
    @IBOutlet weak var searchResult: UITableView!
    
    var matchingItems:[MKMapItem] = []
    let locationManager = CLLocationManager()
    
    let attrs: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: "Helvetica", size: 17.0)!,
        .foregroundColor: UIColor.lightGray
    ]
    
    var items = Places().items.filter({!$0.contains("...")})

    override func viewDidLoad() {
        super.viewDidLoad()

        view_searchbar.isHidden = true
        edt_search.attributedPlaceholder = NSAttributedString(string: "Search for nearby places...",
            attributes: attrs)
        
        edt_search.textColor = .white
        edt_search.autocapitalizationType = .words
        
        edt_search.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        view_searchbar.layer.cornerRadius = view_searchbar.frame.height / 2
        view_searchbar.backgroundColor = UIColor(rgb: 0xffffff, alpha: 0.15)
        
        self.menuList.delegate = self
        self.menuList.dataSource = self
        
        searchResult.delegate = self
        searchResult.dataSource = self
        
        self.menuList.reloadData()
        
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        // locationManager.allowDeferredLocationUpdates(untilTraveled: 0, timeout: 0)
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
            // manager.startUpdatingHeading()
        }
    }
    
    @IBAction func tap_search(_ sender: Any) {
        if view_searchbar.isHidden{
            view_searchbar.isHidden = false
            btn_search.setImage(cancel, for: .normal)
            lbl_title.isHidden = true
            edt_search.becomeFirstResponder()
            
        }else{
            view_searchbar.isHidden = true
            btn_search.setImage(search, for: .normal)
            lbl_title.isHidden = false
            self.edt_search.text = ""
            edt_search.resignFirstResponder()
            self.searchResult.isHidden = true
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.menuList {
            if items.count % 2 == 0{
                return items.count/2
            }else{
                return items.count/2 + 1
            }
        }
        
        return self.matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.menuList {
            return 80.0
        }
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        if tableView == self.menuList {
            let cell:NearbyMenuCell = (tableView.dequeueReusableCell(withIdentifier: "NearbyMenuCell", for: indexPath) as! NearbyMenuCell)
            menuList.backgroundColor = UIColor.clear
            cell.backgroundColor = UIColor.clear
                
            let index:Int = indexPath.row * 2
            let item = items[index]
                
            if items.indices.contains(index) {
                    
                cell.btn1.backgroundColor = .random
                if (cell.btn1.backgroundColor?.isLight())! {
                    cell.btn1.setTitleColor(.black, for: .normal)
                }else {
                    cell.btn1.setTitleColor(.white, for: .normal)
                }
                cell.btn1.setTitle(item, for: .normal)
                    
                cell.btn1.tag = index
                cell.btn1.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
                    
                    
            }else{
                cell.btn1.isHidden = true
            }
                
            let index2:Int = indexPath.row * 2 + 1
            let item2 = items[index2]
                
            if items.indices.contains(index2){
                
                cell.btn2.backgroundColor = .random
                if (cell.btn2.backgroundColor?.isLight())! {
                    cell.btn2.setTitleColor(.black, for: .normal)
                }else {
                    cell.btn2.setTitleColor(.white, for: .normal)
                }
                cell.btn2.setTitle(item2, for: .normal)
                    
                cell.btn2.tag = index2
                cell.btn2.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
                    
            }else{
                cell.btn2.isHidden = true
            }
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        if tableView == self.menuList {
            
        }else if tableView == self.searchResult {
            self.searchResult.isHidden = true
            self.edt_search.text = ""
            self.edt_search.resignFirstResponder()
            let vc:DetailedVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailedVC")
            vc.mapData = matchingItems[indexPath.row]
            self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
        }
        
    }
    
    @objc func tappedButton(sender:UIButton) {
        if let index = sender.tag as? Int {
            print("INDEX!!! \(index)")
            self.updateSearchResultsToShowOnMap(keyword: items[index])
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0{
            let userLocation = locations.last!
            print("locations = \(locations)")
            let center = CLLocationCoordinate2D(latitude: (userLocation.coordinate.latitude), longitude: (userLocation.coordinate.longitude))
            
            thisUserLocation = center
        }
        
    }
    
    //Formats Address to Display
    func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
    func updateSearchResults(keyword:String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = keyword
        request.region.center = thisUserLocation!
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            print("Items Count: \(self.matchingItems.count)")
            if self.matchingItems.count > 0{
                self.searchResult.isHidden = false
            }else {
                self.searchResult.isHidden = true
            }
            self.searchResult.reloadData()
        }
    }
    
    func updateSearchResultsToShowOnMap(keyword:String) {
        self.showLoadingView()
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = keyword
        request.region.center = thisUserLocation!
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                self.dismissLoadingView()
                return
            }
            self.matchingItems = response.mapItems
            print("Items Count: \(self.matchingItems.count)")
            
            self.dismissLoadingView()
            
            let vc:NearbyMapViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "NearbyMapViewController")
            vc.matchingItems = self.matchingItems
            vc.ttl = "Nearby " + keyword
            self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
            
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        edt_search.attributedText = NSAttributedString(string: edt_search.text!,
        attributes: attrs)
        if (textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count)! > 0{
            updateSearchResults(keyword: textField.text!)
        }else {
            self.searchResult.isHidden = true
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}


extension CGFloat {
    static var random: CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random, green: .random, blue: .random, alpha: 1.0)
    }
    func isLight() -> Bool {
        guard let components = cgColor.components, components.count > 2 else {return false}
        let brightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000
        return (brightness > 0.5)
    }
}
