//
//  NearbyMapViewController.swift
//  VaCay
//
//  Created by Andre on 8/21/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit
import MapKit

class NearbyMapViewController: BaseViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btn_list: UIButton!
    
    var matchingItems:[MKMapItem] = []
    var ttl:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btn_list.setImageTintColor(.lightGray)
        lbl_title.text = ttl
        lbl_title.text = lbl_title.text?.capitalized
        
        // Track user location
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.follow
        
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        for item in matchingItems {
            self.dropPinZoomIn(placemark: item.placemark)
        }
    }

    @IBAction func back(_ sender: Any) {
        self.dismissViewController()
    }
    
    @IBAction func openList(_ sender: Any) {
        
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
        let index = mapView.annotations.firstIndex(where: {$0 === pinView!.annotation})
        button.tag = index!
        button.addTarget(self, action: #selector(self.getDirections0), for: .touchUpInside)
//        pinView?.leftCalloutAccessoryView = button
        pinView?.rightCalloutAccessoryView = button
//        let tap = UITapGestureRecognizer(target: self, action: #selector(getDirections))
//        pinView?.addGestureRecognizer(tap)
        return pinView
    }
    
    //Launches driving directions with AppleMaps
    @objc func getDirections0(sender:UIButton){
        if let index = sender.tag as? Int {
            let mapItem = MKMapItem(placemark: matchingItems[index].placemark)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
    //Launches driving directions with AppleMaps
    @objc func getDirections(gesture:UITapGestureRecognizer){
        if let pinView = gesture.view as? MKPinAnnotationView {
            if let index = mapView.annotations.firstIndex(where: {$0 === pinView.annotation}) {
                let mapItem = MKMapItem(placemark: matchingItems[index].placemark)
                let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                mapItem.openInMaps(launchOptions: launchOptions)
            }
        }
    }
    
}


//Drops Cutsom Pin Annotation In the mapView
extension NearbyMapViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
//        mapView.selectAnnotation(annotation, animated: true)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        mapView.fitMapViewToAnnotaionList()
    }
    
    
}


extension MKMapView {
    func fitMapViewToAnnotaionList() -> Void {
        let mapEdgePadding = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        var zoomRect:MKMapRect? = nil

        for index in 0..<self.annotations.count {
            let annotation = self.annotations[index]
            let aPoint:MKMapPoint = MKMapPoint(annotation.coordinate)
            let rect:MKMapRect = MKMapRect(x: aPoint.x, y: aPoint.y, width: 0.1, height: 0.1)

            if zoomRect == nil {
                zoomRect = rect
            } else {
                zoomRect = zoomRect!.union(rect)
            }
        }
        self.setVisibleMapRect(zoomRect!, edgePadding: mapEdgePadding, animated: true)
    }
}
