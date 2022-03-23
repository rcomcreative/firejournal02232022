//
//  OnBoardMapViewController.swift
//  StationCommand
//
//  Created by DuRand Jones on 7/19/21.
//

import Foundation
import MapKit
import CoreLocation

protocol OnBoardMapDelegate: AnyObject {
    func theMapPointHasBeenChosen(_ theCoordinate: CLLocationCoordinate2D, _ address: String )
}

class OnBoardMapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet  var mapView: MKMapView!
    
    weak var delegate: OnBoardMapDelegate? = nil
    
    private var annotations = [MKAnnotation]()
    var selectedAnnotation: MKAnnotation!
    var fireStationBoundary: MKCoordinateRegion? = nil
    var locationManager:CLLocationManager!
    var currentLocation: CLLocation?
    let nc = NotificationCenter.default
    let userDefaults = UserDefaults.standard
    var locationPermission: Bool = false
    var city:String = ""
    var state:String = ""
    var streetNum:String = ""
    var streetName:String = ""
    var zip:String = ""
    var pinAnnotationView:MKPinAnnotationView!
    var capturedCoordinate: CLLocationCoordinate2D!
    var address: String = ""
    var type: IncidentTypes = .station
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.mapType = .hybrid
        mapView.delegate = self
    }
    
    private func registerAnnotationViewClasses() {
        
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
            switch locationManager.authorizationStatus {
                
            case .notDetermined, .restricted, .denied:
                userDefaults.setValue(false, forKey: FConLocationPermission)
                locationPermission = false
            case .authorizedAlways, .authorizedWhenInUse:
                userDefaults.setValue(true, forKey: FConLocationPermission)
                locationPermission = true
                locationManager.startUpdatingLocation()
            @unknown default:
                userDefaults.setValue(false, forKey: FConLocationPermission)
                locationPermission = false
            }
            // userDefaults.synchronize()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        manager.stopUpdatingLocation()
        
    }
    
    func show(mapItems: [MKMapItem]) {
        mapView.removeAnnotations(annotations)

        if !mapItems.isEmpty {
            annotations = mapItems.map { mapItem in
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = mapItem.placemark.name
                annotation.subtitle = mapItem.placemark.title
                pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationIdentifier")
                _ = mapView(mapView, viewFor: annotation)
                let theCoordinate = mapItem.placemark.coordinate
                let theAddress: String = mapItem.placemark.title ?? ""
                delegate?.theMapPointHasBeenChosen(theCoordinate, theAddress )
            
                return annotation
            }

            mapView.addAnnotations(annotations)
            mapView.showAnnotations(annotations, animated: true)
            
        } else {
            annotations = []
        }
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
            annotationView!.isEnabled = true
            annotationView!.isDraggable = true
            switch type {
            case .station:
                annotationView!.image = UIImage(named: "mapPins07212021_stationPin")
            case .deptMember:
                annotationView!.image = UIImage(named: "mapPins07212021_memberPin")
            case .journal:
                annotationView!.image = UIImage(named: "mapPins11022021_stationPinBlue")
            case .allIncidents:
                annotationView!.image = UIImage(named: "mapPins07212021_stationPin")
            default: break
            }
            annotationView!.frame.size.height = 60
            annotationView!.frame.size.width = 60
            
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.selectedAnnotation = view.annotation
        let theCoordinate = self.selectedAnnotation.coordinate
        let theAddress: String = (self.selectedAnnotation.subtitle ?? "") ?? ""
        delegate?.theMapPointHasBeenChosen(theCoordinate, theAddress )
        let center = self.selectedAnnotation?.coordinate
        let region = MKCoordinateRegion(center: center ?? defaultLocation, span: MKCoordinateSpan(latitudeDelta: 0.001225, longitudeDelta: 0.001123))
        self.mapView.setRegion(region, animated: true)
    }
    
}
