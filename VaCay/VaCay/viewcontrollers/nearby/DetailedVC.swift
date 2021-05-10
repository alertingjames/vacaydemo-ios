//
//  DetailedVC.swift
//  VaCay
//
//  Created by Andre on 8/19/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class DetailedVC: BaseViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var detailedMapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var restaurantsBtn: UIButton!
    @IBOutlet weak var loungeBarBtn: UIButton!
    @IBOutlet weak var coffeeBtn: UIButton!
    @IBOutlet weak var view_nearby: UIView!
    
    var handleMapSearchDelegate:HandleMapSearch? = nil
    
    var mapData: MKMapItem!
    var selectedPin:MKPlacemark? = nil
    var responseResult : [MKMapItem]! = nil
    let locationManager = CLLocationManager()
    @IBOutlet weak var stv_buttons: UIStackView!
    
    var buttons = [UIButton]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view_nearby.roundCorners(corners: [.topLeft, .topRight], radius: 15)
        // Track user location
        detailedMapView.delegate = self
        detailedMapView.userTrackingMode = MKUserTrackingMode.follow
        detailedMapView.showsUserLocation = true
        //Get data from segue and drop custom pin on MKplacemark object
        let customPlacemark = mapData.placemark
        dropPinZoomIn(placemark: customPlacemark)
        //setting delegate for tableView
        tableView.delegate = self
        tableView.dataSource = self
        //custom cell class for tableView cell
        self.tableView.register(NearbyCell.self, forCellReuseIdentifier: "NearbyCell")
        
        let items = Places().items.filter({!$0.contains("...")})
        for item in items {
            let button = UIButton(type: .system)
            button.setTitle(item, for: .normal)
            button.backgroundColor = primaryColor
            button.titleLabel?.font = UIFont(name: "Avenir Medium", size: 14.0)
            button.setTitleColor(.white, for: .normal)
            button.frame.size.height = 22
            button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
            button.layer.cornerRadius = button.frame.height / 2
            button.layer.masksToBounds = true
            button.setContentHuggingPriority(.required, for: .horizontal)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            button.addTarget(self, action: #selector(getData), for: .touchDown)
            
            stv_buttons.alignment = .center
            stv_buttons.distribution = .fill
            stv_buttons.spacing = 8
            stv_buttons.addArrangedSubview(button)
            
            buttons.append(button)
        }
        
        //Fetch Initial data for tableView
        fetchLocalData(category: items[0])
        buttons[0].backgroundColor = .red
    }
    
    func resetButtonsUI(){
        for button in buttons {
            button.backgroundColor = primaryColor
        }
    }
    
    @objc func getData(sender:UIButton) {
        resetButtonsUI()
        sender.backgroundColor = .red
        fetchLocalData(category: (sender.titleLabel?.text)!)
    }
    
    //creates a custom MKLocalSearchRequest and gets MKLocalSearchResponse
    func fetchLocalData(category: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = category
        request.region = detailedMapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("There was an error searching for: \(String(describing: request.naturalLanguageQuery)) error: \(String(describing: error))")
                return
            }
            self.responseResult = response.mapItems
            self.tableView.reloadData()
        }
        return
    }
    //itterate the data inside the tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "NearbyCell")!
        tableCell.textLabel?.numberOfLines = 0
        tableCell.textLabel?.lineBreakMode = .byWordWrapping
        tableCell.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        let eachResponse = responseResult[indexPath.row]
        var customAddress:String? = ""
        if((eachResponse.name) != nil){
            customAddress = customAddress! + eachResponse.name!
        }
        if(eachResponse.phoneNumber != nil){
            customAddress = customAddress! + "\n" + "\(eachResponse.phoneNumber!)"
        }
        if(eachResponse.url != nil){
            customAddress = customAddress! + "\n" + "\(eachResponse.url!)"
        }
        tableCell.textLabel?.text = customAddress
        return tableCell
    }
    //returns number of rows for the tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(self.responseResult)
        if(self.responseResult != nil){
            return self.responseResult!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        let eachResponse = responseResult[indexPath.row]
        self.dropPinZoomIn(placemark: eachResponse.placemark)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
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
    
    @objc func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

//Drops Cutsom Pin Annotation In the mapView
extension DetailedVC: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        detailedMapView.removeAnnotations(detailedMapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        detailedMapView.addAnnotation(annotation)
        detailedMapView.selectAnnotation(annotation, animated: true)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        detailedMapView.setRegion(region, animated: true)
        
    }
}

