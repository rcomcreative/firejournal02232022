//
//  NewIncidentMapVC.swift
//  ARCForm
//
//  Created by DuRand Jones on 11/3/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


protocol NewIncidentMapDelegate: AnyObject {

    func theMapLocationHasBeenChosen(location:CLLocation)
    func theMapCancelButtonTapped()
}

class NewIncidentMapVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var newIncidentMap: MKMapView!
    var locationManager:CLLocationManager!
    
    private var currentLocation: CLLocation?
    
    weak var delegate: NewIncidentMapDelegate? = nil
    
    var pointAnnotation:NewIncidentMapAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    var city:String = ""
    var state:String = ""
    var streetNum:String = ""
    var streetName:String = ""
    var zip:String = ""
    var mapType:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(addNewIncident(_:)))
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelNewIncident(_:)))
        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItem = cancel
        
        let backgroundImage = UIImage(named: "headerBar2")
        self.navigationController?.navigationBar.setBackgroundImage(backgroundImage, for: .default)
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor.white
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        
        
        newIncidentMap.showsUserLocation = false
        newIncidentMap.isZoomEnabled = true
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        determineLocation()
    }
    
    func determineLocation() {
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        currentLocation = userLocation
        manager.stopUpdatingLocation()
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude:userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span:MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
        newIncidentMap.setRegion(region, animated: true)
        
        
        pointAnnotation = NewIncidentMapAnnotation()
        pointAnnotation.coordinate = center
        CLGeocoder().reverseGeocodeLocation(userLocation, completionHandler: {(placemarks, error) -> Void in
            print(userLocation)
            
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if placemarks?.count != 0 {
                let pm = placemarks![0]
                print(pm.locality!)
                self.city = "\(pm.locality!)"
                self.streetNum = "\(pm.subThoroughfare!)"
                self.streetName = "\(pm.thoroughfare!)"
                self.state = "\(pm.administrativeArea!)"
                self.zip = "\(pm.postalCode!)"
                
                self.pointAnnotation.title = "\(self.streetNum) \(self.streetName),\(self.city) \(self.state) \(self.zip)"
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
        
        
        pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "pin")
        newIncidentMap.addAnnotation(pointAnnotation)
        
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
            annotationView!.isEnabled = true
            annotationView!.isDraggable = true
            
        }
        else {
            annotationView!.annotation = annotation
        }
        
        let pinImage = UIImage(named: "fireWhitePin")
        let size = CGSize(width: 60, height: 60)
        UIGraphicsBeginImageContext(size)
        let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        pinImage!.draw(in: frame)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        annotationView?.image = resizedImage
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        
        if newState == MKAnnotationView.DragState.ending {
            let ann = view.annotation
            let center = CLLocationCoordinate2D(latitude: (ann?.coordinate.latitude)!, longitude:(ann?.coordinate.longitude)!)
            let userLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
            currentLocation = userLocation
            
            CLGeocoder().reverseGeocodeLocation(userLocation, completionHandler: {(placemarks, error) -> Void in
                print(userLocation)
                
                if error != nil {
                    print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                    return
                }
                
                if placemarks?.count != 0 {
                    let pm = placemarks![0]
                    print(pm.locality!)
                    self.city = "\(pm.locality!)"
                    self.streetNum = "\(pm.subThoroughfare!)"
                    self.streetName = "\(pm.thoroughfare!)"
                    self.state = "\(pm.administrativeArea!)"
                    self.zip = "\(pm.postalCode!)"
                    
                    self.pointAnnotation.title = "\(self.streetNum) \(self.streetName),\(self.city) \(self.state) \(self.zip)"
                }
                else {
                    print("Problem with the data received from geocoder")
                }
            })
        }
    }
    
    @objc func addNewIncident(_ sender:Any) {
        delegate?.theMapLocationHasBeenChosen(location: currentLocation!)
        print("map printing \(currentLocation!)")
        performSegue(withIdentifier: "unwindSegueToVC1", sender: self)
    }
    
    @objc func cancelNewIncident(_ sender:Any) {
        if mapType == "" {
            performSegue(withIdentifier: "unwindSegueToVC1", sender: self)
        } else if mapType == "ARCForm" {
            delegate?.theMapCancelButtonTapped()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
