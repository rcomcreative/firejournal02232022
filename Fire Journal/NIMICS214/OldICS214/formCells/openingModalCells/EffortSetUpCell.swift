//
//  EffortSetUpCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/10/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import CoreLocation
import CoreData


protocol EffortSetUpCellDelegate: AnyObject {

    func effortHasBeenCreated(type: TypeOfForm, name1: String, name2: String, location:  CLLocation, streetNum: String, streetName: String, city: String, locationState: String, zip: String, latitude: String, longitude: String )
    func effortUnfinished(warning: String)
}

class EffortSetUpCell: UITableViewCell, CLLocationManagerDelegate, MKMapViewDelegate, NSFetchedResultsControllerDelegate, UITextFieldDelegate  {
    
    @IBOutlet weak var descriptionTV: UILabel!
    @IBOutlet weak var titleLabelOne: UILabel!
    @IBOutlet weak var questionOneL: UILabel!
    @IBOutlet weak var questionTwoL: UILabel!
    @IBOutlet weak var quesitonOneTF: UITextField!
    @IBOutlet weak var questionTwoTF: UITextField!
    @IBOutlet weak var titleLabelTwoL: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var continueB: UIButton!
    @IBOutlet weak var streetTF: UITextField!
    @IBOutlet weak var cityTF: UITextField!
    @IBOutlet weak var stateTF: UITextField!
    @IBOutlet weak var zipTF: UITextField!
    @IBOutlet weak var mapV: MKMapView!
    @IBOutlet weak var addressB: UIButton!
    @IBOutlet weak var longitudeTF: UITextField!
    @IBOutlet weak var latitudeTF: UITextField!
    
    var locationManager:CLLocationManager!
    private var currentLocation: CLLocation?
    var pointAnnotation:NewIncidentMapAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    var city:String = ""
    var state:String = ""
    var streetNum:String = ""
    var streetName:String = ""
    var latitude: String = ""
    var longitude: String = ""
    var zip:String = ""
    var q1: String = ""
    var q2: String = ""
    var alertUp: Bool = false
    var getAddress: Bool = false
    
    var type:TypeOfForm!
    var locationOrNot: Bool = false
    weak var delegate: EffortSetUpCellDelegate? = nil
    
    var incidentType:String = "ICS214"

    override func awakeFromNib() {
        super.awakeFromNib()
        continueB.layer.cornerRadius = 8.0
        mapV.showsUserLocation = false
        mapV.isZoomEnabled = true
        determineLocation()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func locationBTapped(_ sender: Any) {
        self.resignFirstResponder()
        getAddress = true
        determineLocation()
    }
    
    @IBAction func continueBTapped(_ sender: Any) {
        _ = textFieldShouldEndEditing(quesitonOneTF)
        _ = textFieldShouldEndEditing(questionTwoTF)
        self.resignFirstResponder()
        var form: String = ""
        var event: String = ""
        switch type {
        case .strikeForceForm?:
            form = "Strike Force"
            event = "Incident"
        case .femaTaskForceForm?:
            form = "FEMA Task Force"
            event = "Event"
        case .otherForm?:
            form = "Other Form"
            event = "Event"
        default: break
        }
        let locate: String = "A location needs to be assigned to this Master \(form) Form."
        if q1 == "" {
            let warning: String = "There is an issue. A \(form) name is needed for moving forward."
            delegate?.effortUnfinished(warning: warning)
        } else if q2 == "" {
            let warning: String = "There is an issue. A \(event) name is needed for moving forward."
            delegate?.effortUnfinished(warning: warning)
        } else if zipTF.text == "" {
            let warning: String = "There is an issue. \(locate)"
            delegate?.effortUnfinished(warning: warning)
        } else {
            delegate?.effortHasBeenCreated(type: type, name1: q1, name2: q2, location: currentLocation!, streetNum: streetNum, streetName: streetName, city: city, locationState: state, zip: zip, latitude: latitude, longitude: longitude )
        }
    }
    
    @IBAction func useAddressBTapped(_ sender: Any) {
        self.resignFirstResponder()
        if currentLocation != nil {
            cityTF.text = city
            streetTF.text = "\(streetNum) \(streetName)"
            stateTF.text = state
            zipTF.text = zip
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        let tag = textField.tag
        switch tag {
        case 1:
            q1 = text
        case 2:
            q2 = text
        default: break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        let tag = textField.tag
        switch tag {
        case 1:
            q1 = text
        case 2:
            q2 = text
        default: break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let text = textField.text ?? ""
        let tag = textField.tag
        switch tag {
        case 1:
            q1 = text
        case 2:
            q2 = text
        default: break
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let text = textField.text ?? ""
        let tag = textField.tag
        switch tag {
        case 1:
            q1 = text
        case 2:
            q2 = text
        default: break
        }
        return true
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
    
    func reload() {
        let annotations = mapV.annotations
        mapV.removeAnnotations(annotations)
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        currentLocation = userLocation
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
                
                self.city = "\(pm.locality ?? "")"
                self.cityTF.text = self.city
                self.streetNum = "\(pm.subThoroughfare ?? "")"
                self.streetName = "\(pm.thoroughfare ?? "")"
                self.streetTF.text = "\(self.streetNum) \(self.streetName)"
                self.state = "\(pm.administrativeArea ?? "")"
                self.stateTF.text = self.state
                self.zip = "\(pm.postalCode ?? "")"
                self.zipTF.text = self.zip
                self.longitude = String(userLocation.coordinate.latitude)
                self.latitude = String(userLocation.coordinate.longitude)
                self.longitudeTF.text = self.longitude
                self.latitudeTF.text = self.latitude
                
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
                    self.cityTF.text = self.city
                    self.streetNum = "\(pm.subThoroughfare ?? "")"
                    self.streetName = "\(pm.thoroughfare ?? "")"
                    self.streetTF.text = "\(self.streetNum) \(self.streetName)"
                    self.state = "\(pm.administrativeArea ?? "")"
                    self.stateTF.text = self.state
                    self.zip = "\(pm.postalCode ?? "")"
                    self.zipTF.text = self.zip
                    self.longitude = String(userLocation.coordinate.latitude)
                    self.latitude = String(userLocation.coordinate.longitude)
                    self.longitudeTF.text = self.longitude
                    self.latitudeTF.text = self.latitude
                    
                    
                    self.pointAnnotation.title = "\(self.streetNum) \(self.streetName),\(self.city) \(self.state) \(self.zip)"
                }
                else {
                    print("Problem with the data received from geocoder")
                }
            })
        }
    }
    
}
