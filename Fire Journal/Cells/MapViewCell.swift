//
//  MapViewCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/22/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

//class pinAnnotation:NSObject,MKAnnotation {
//    var title:String?
//    var subtitle: String?
//    var coordinate: CLLocationCoordinate2D
//    init(title:String,subtitle:String,coordinate:CLLocationCoordinate2D) {
//        self.title = title
//        self.subtitle = subtitle
//        self.coordinate = coordinate
//    }
//}

protocol MapViewCellDelegate: AnyObject {
    func theMapLocationHasBeenChosen(location:CLLocation)
    func theMapCancelButtonTapped()
    func theAddressHasBeenChosen(addressStreetNum:String,addressStreetName:String, addressCity: String, addressState: String, addressZip: String, location: CLLocation)
    func theMapCellInfoBTapped()
}

class MapViewCell: UITableViewCell, CLLocationManagerDelegate, MKMapViewDelegate {
    
    weak var delegate:MapViewCellDelegate? = nil
    @IBOutlet weak var mapV: MKMapView!
    var locationManager:CLLocationManager!
    var currentLocation: CLLocation?
    var pointAnnotation:NewIncidentMapAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    var city:String = ""
    var state:String = ""
    var streetNum:String = ""
    var streetName:String = ""
    var zip:String = ""
    var mapType:String = ""
    var incidentType:String = ""
    var mapShow: Bool = false
    @IBOutlet weak var useAddressB: UIButton!
    @IBOutlet weak var mapCellInfoB: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mapV.showsUserLocation = false
        mapV.isZoomEnabled = true
        determineLocation()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func reload() {
        let annotations = mapV.annotations
        mapV.removeAnnotations(annotations)
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        var userLocation:CLLocation = locations[0] as CLLocation
        if currentLocation != nil {
            userLocation = currentLocation!
        }
        manager.stopUpdatingLocation()
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude:userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span:MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
        mapV.setRegion(region, animated: true)
        
        
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
                if let pmCity = pm.locality {
                    self.city = "\(pmCity)"
                } else {
                    self.city = ""
                }
                if let pmSubThroughfare = pm.subThoroughfare {
                    self.streetNum = "\(pmSubThroughfare)"
                } else {
                    self.streetNum = ""
                }
                if let pmThoroughfare = pm.thoroughfare {
                    self.streetName = "\(pmThoroughfare)"
                } else {
                    self.streetName = ""
                }
                if let pmState = pm.administrativeArea {
                    self.state = "\(pmState)"
                } else {
                    self.state = ""
                }
                if let pmZip = pm.postalCode {
                    self.zip = "\(pmZip)"
                } else {
                    self.zip = ""
                }
                
                self.pointAnnotation.title = "\(self.streetNum) \(self.streetName),\(self.city) \(self.state) \(self.zip)"
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
        
        
        pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "pin")
        mapV.addAnnotation(pointAnnotation)
        
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
            
        } else {
            annotationView!.annotation = annotation
        }
        
        var pinImage:UIImage?
        
        if incidentType == "Fire" {
            pinImage = UIImage(named: "fireWhitePin")
        } else if incidentType == "EMS" {
            pinImage = UIImage(named: "emsWhitePin")
        } else if incidentType == "Rescue" {
            pinImage = UIImage(named: "rescueWhitePin")
        } else if incidentType == "Station" {
            pinImage = UIImage(named: "AdministrativePin")
        } else if incidentType == "Community" {
            pinImage = UIImage(named: "Community_Pin")
        } else if incidentType == "Members" {
            pinImage = UIImage(named: "MembersPin")
        } else if incidentType == "ICS214" {
            pinImage = UIImage(named: "ics214Pin")
        } else {
            pinImage = UIImage(named: "fireWhitePin")
        }
            
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
                    print("here is location \(pm.locality ?? "")")
                    self.city = "\(pm.locality ?? "")"
                    self.streetNum = "\(pm.subThoroughfare ?? "")"
                    self.streetName = "\(pm.thoroughfare ?? "")"
                    self.state = "\(pm.administrativeArea ?? "")"
                    self.zip = "\(pm.postalCode ?? "")"
                    
                    self.pointAnnotation.title = "\(self.streetNum) \(self.streetName),\(self.city) \(self.state) \(self.zip)"
                }
                else {
                    print("Problem with the data received from geocoder")
                }
            })
        }
    }
    
    @IBAction func useAddressBTapped(_ sender: Any) {
        if currentLocation != nil {
            delegate?.theAddressHasBeenChosen(addressStreetNum: streetNum, addressStreetName: streetName, addressCity: city, addressState: state, addressZip: zip, location: currentLocation!)
        } else {
            delegate?.theMapCancelButtonTapped()
        }
    }
    
    @IBAction func mapCellInfoBTapped(_ sender: Any) {
        delegate?.theMapCellInfoBTapped()
    }
    
}
