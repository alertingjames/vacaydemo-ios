//
//  MainVC.swift
//  VaCay
//
//  Created by Andre on 8/19/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit
import MapKit

class MainVC: BaseViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate {
    var selectedPin:MKPlacemark? = nil
    @IBOutlet weak var mapView: MKMapView!
    var mapHasCenteredOnce = false
    var resultSearchController:UISearchController? = nil
    let thePicker = UIPickerView()
    var items = [String]()
    @IBOutlet weak var view_header: UIView!
    @IBOutlet weak var searchResult: UITableView!
    var matchingItems:[MKMapItem] = []
    
    @IBOutlet weak var view_nav: UIView!
    let locationManager = CLLocationManager()
    var searchActive : Bool = false
    var searchBar: UISearchBar!
    @IBOutlet weak var edt_search: UITextField!
    @IBOutlet weak var view_search: UIView!
    
    let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Helvetica", size: 17.0)!,
            .foregroundColor: UIColor.white,
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gNearbyViewController = self
        
        edt_search.attributedPlaceholder = NSAttributedString(string: "Search for nearby places...",
        attributes: attrs)
        view_search.layer.cornerRadius = view_search.frame.height / 2
        
        items = Places().items
        
        // Track user location
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.follow
        
        //Tap gesture to return to mapView when tapped on screen
        let singleTap = UITapGestureRecognizer(target:self, action:#selector(self.handleSingleTap(gesture:)))
        singleTap.numberOfTouchesRequired = 1
        singleTap.addTarget(self, action:#selector(self.handleSingleTap(gesture:)))
        mapView.isUserInteractionEnabled = true
        mapView.addGestureRecognizer(singleTap)
        
//        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
//        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
//        resultSearchController?.searchResultsUpdater = locationSearchTable as! UISearchResultsUpdating
        
//        searchBar = resultSearchController!.searchBar
//        searchBar = UISearchBar()
//        searchBar.sizeToFit()
//        searchBar.placeholder = "Search for nearby places"
        thePicker.delegate = self
        thePicker.backgroundColor = .white
        edt_search.inputView = thePicker
        
        edt_search.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
        for: UIControl.Event.editingChanged)
        
//        searchBar.searchTextField.inputView = thePicker
//        searchBar.delegate = self
//        view_nav.addSubview(searchBar)
//        navigationItem.titleView = resultSearchController?.searchBar
        
//        resultSearchController?.hidesNavigationBarDuringPresentation = false
//        resultSearchController?.dimsBackgroundDuringPresentation = true
//        definesPresentationContext = true
        
        searchResult.delegate = self
        searchResult.dataSource = self

        createToolbar()
        
//        locationSearchTable.mapView = mapView
//        locationSearchTable.handleMapSearchDelegate = self
    }
    
    //function called for Tap gesture
    @objc func handleSingleTap(gesture: UITapGestureRecognizer){
        view.endEditing(true)
    }
    //check the status for requestWhenInUseAuthorization
    override func viewDidAppear(_ animated: Bool) {
        locationAuthStatus()
    }
    //Request user Auth to use location services
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
    }
    //display user location(blue dot) in mapView
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
    // Center mapView on userLocation
    func centerMapOnLocation(location : CLLocation) {
        let coordinateRegion = MKCoordinateRegion.init(center:location.coordinate, latitudinalMeters:2000, longitudinalMeters:2000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    // checks mapHasCenteredOnce Flag
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let loc = userLocation.location {
            if !mapHasCenteredOnce {
                centerMapOnLocation(location: loc)
                mapHasCenteredOnce = true
            }
        }
    }
    //Creates custom AnnotationView when Clicked on the pin
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: .zero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), for: [])
        button.addTarget(self, action: #selector(MainVC.getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        let tap = UITapGestureRecognizer(target: self, action: #selector(getDirections))
        pinView?.addGestureRecognizer(tap)
        return pinView
    }
    //Launches driving directions with AppleMaps
    @objc func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    //itterate the data inside the tableView
    func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        return cell
    }
    
    func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        self.dropPinZoomIn(placemark: selectedItem)
        self.searchResult.isHidden = true
        self.edt_search.text = ""
        self.closePickerView()
        let vc:DetailedVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailedVC")
        vc.mapData = matchingItems[indexPath.row]
        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
        
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
        guard let mapView = mapView else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = keyword
        request.region = mapView.region
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
    
    @objc func textFieldDidChange(_ textField: UITextField) {        
        edt_search.attributedText = NSAttributedString(string: edt_search.text!,
        attributes: attrs)
        if textField.text!.count > 0{
            updateSearchResults(keyword: textField.text!)
        }else {
            self.searchResult.isHidden = true
            textField.resignFirstResponder()
            thePicker.selectRow(0, inComponent: 0, animated: true)
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        print("text cleared")
        self.searchResult.isHidden = true
        textField.resignFirstResponder()
        thePicker.selectRow(0, inComponent: 0, animated: true)
        return true
    }
    
    // MARK: UIPickerView Delegation
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row > 0 {
            edt_search.text = items[row]
            updateSearchResults(keyword: edt_search.text!)
        }else {
            edt_search.text = ""
            searchResult.isHidden = true
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[row]
    }
    
    @objc func closePickerView() {
        print("Picker closed")
        edt_search.resignFirstResponder()
        thePicker.selectRow(0, inComponent: 0, animated: true)
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50.0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label:UILabel
        
        if let v = view as? UILabel{
            label = v
        }
        else{
            label = UILabel()
        }
        
        if row > 0{
            label.textColor = .white
            label.backgroundColor = primaryColor
        }else{
            label.textColor = primaryColor
        }
        
        label.textAlignment = .center
        label.font = UIFont(name: "Helvetica", size: 20)
        label.text = items[row]
        
        return label
    }
    
    func createToolbar()
    {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.barStyle = UIBarStyle.default
        toolbar.isTranslucent = true
        toolbar.tintColor = primaryColor
        toolbar.barTintColor = .white
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(MainVC.closePickerView))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([spaceButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        edt_search.inputAccessoryView = toolbar
    }

}

//Drops Cutsom Pin Annotation In the mapView
extension MainVC: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    
}

