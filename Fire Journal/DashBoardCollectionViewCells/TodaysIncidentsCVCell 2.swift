//
//  TodaysIncidentsCVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/6/19.
//  Copyright © 2019 PureCommand, LLC. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class TodaysIncidentsCVCell: UICollectionViewCell, CLLocationManagerDelegate, MKMapViewDelegate {
    
    //    MARK: -OBJECTS-
    @IBOutlet weak var headerGradientIV: UIImageView!
    @IBOutlet weak var incidentIconIV: UIImageView!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var lastIncidentSubjectL: UILabel!
    @IBOutlet weak var lastIncidentB: UIButton!
    @IBOutlet weak var incidentNumberL: UILabel!
    @IBOutlet weak var lastIncidentIconIV: UIImageView!
    @IBOutlet weak var lastIncidentStreetAddressL: UILabel!
    @IBOutlet weak var lastIncidentCityStateL: UILabel!
    @IBOutlet weak var lastIncidentAlarmL: UILabel!
    @IBOutlet weak var lastIncidentAlertL: UILabel!
    @IBOutlet weak var lastIncidentControlledL: UILabel!
    @IBOutlet weak var lastIncidentLastUnitL: UILabel!
    @IBOutlet weak var lastIncidentResourcesL: UILabel!
    @IBOutlet weak var todaysIncidentL: UILabel!
    @IBOutlet weak var todaysFireL: UILabel!
    @IBOutlet weak var todaysEMSL: UILabel!
    @IBOutlet weak var todaysRescueL: UILabel!
    @IBOutlet weak var todaysFireIconIV: UIImageView!
    @IBOutlet weak var todaysEMSIconIV: UIImageView!
    @IBOutlet weak var todaysRescueIconIV: UIImageView!
    @IBOutlet weak var todayFireIncidentTotalL: UILabel!
    @IBOutlet weak var todaysEMSIncidentTotalL: UILabel!
    @IBOutlet weak var todaysRescueIncidentTotalL: UILabel!
//    @IBOutlet weak var todaysIncidentMap: MKMapView!
    @IBOutlet weak var pastMonthArrowB: UIButton!
    @IBOutlet weak var forwardMonthArrowB: UIButton!
    
    @IBOutlet weak var monthTotalsSubjectL: UILabel!
    @IBOutlet weak var monthFireL: UILabel!
    @IBOutlet weak var monthEMSL: UILabel!
    @IBOutlet weak var monthRescueL: UILabel!
    @IBOutlet weak var monthFireIconIV: UIImageView!
    @IBOutlet weak var monthEMSIconIV: UIImageView!
    @IBOutlet weak var monthRescueIconIV: UIImageView!
    @IBOutlet weak var monthFireTotalL: UILabel!
    @IBOutlet weak var monthEMSTotalL: UILabel!
    @IBOutlet weak var monthRescueTotalL: UILabel!
    @IBOutlet weak var incidentForwardB: UIButton!
    @IBOutlet weak var incidentPreviousB: UIButton!
    var incrementCount: Int = 0
    var buttonCount: Int = 0
    var totalCount: String = "" {
        didSet {
            if self.totalCount == "0" {
                self.lastIncidentSubjectL.text = "0 Incidents for today"
                incidentForwardB.isHidden = true
                incidentPreviousB.isHidden = true
            } else {
                let count = self.totalCount
                self.incrementCount = Int(count) ?? 0
                self.buttonCount = Int(count) ?? 0
                if self.buttonCount > 0 {
                    self.buttonCount -= 1
                }
                if count == "1" {
                    self.lastIncidentSubjectL.text = "\(count) Incident for"
                    incidentPreviousB.isHidden = true
                    incidentPreviousB.isEnabled = false
                    incidentPreviousB.alpha = 0.0
                    incidentForwardB.isHidden = true
                    incidentForwardB.isEnabled = false
                    incidentForwardB.alpha = 0.0
                } else {
                    self.lastIncidentSubjectL.text = "\(count) Incidents for"
                }
            }
        }
    }
    private var theIncidentDate: String = ""
    var incidentDate: String = "" {
        didSet {
            self.theIncidentDate = self.incidentDate
        }
    }
    var fireCount: String = "" {
        didSet {
            self.todayFireIncidentTotalL.text = self.fireCount
        }
    }
    var emsCount: String = "" {
        didSet {
            self.todaysEMSIncidentTotalL.text = self.emsCount
        }
    }
    var rescueCount: String = "" {
        didSet {
            self.todaysRescueIncidentTotalL.text = self.rescueCount
        }
    }
    var fireStationAddress: String = ""
    var fsAddress: String = "" {
        didSet {
            self.fireStationAddress = self.fsAddress
        }
    }
    private var fireStationLocation: CLLocation!
    var location: CLLocation? = nil {
        didSet {
            self.fireStationLocation = self.location
        }
    }
    var situationIncidentImage: String!
    var annotationAddress: String!
    var allOfTodaysIncidents: [TodayIncident] = [TodayIncident]() {
        didSet {
            if !self.allOfTodaysIncidents.isEmpty {
            let incident = self.allOfTodaysIncidents.last
            self.lastIncidentIconIV.image = incident?.incidentImage
            self.situationIncidentImage = incident?.situationIncidentImage
            self.incidentNumberL.text = incident?.incidentNumber
            self.lastIncidentStreetAddressL.text = incident?.streetAddress
            self.lastIncidentCityStateL.text = incident?.cityStateZip
            self.lastIncidentAlarmL.text = incident?.alarmTime
            if incident?.theIncidentDate != "" {
                self.incidentDate = (incident?.theIncidentDate)!
                let text = self.lastIncidentSubjectL.text ?? ""
                let dateLine = "\(text) \(self.incidentDate)"
                self.lastIncidentSubjectL.text = dateLine
            }
            if incident?.arrivalTime == "" {
                self.lastIncidentAlertL.text = "No Arrival Time Set"
            } else {
                self.lastIncidentAlertL.text = incident?.arrivalTime
            }
            if incident?.controlledTime == "" {
                self.lastIncidentControlledL.text = "No Controlled Time Set"
            } else {
                self.lastIncidentControlledL.text = incident?.controlledTime
            }
            if incident?.lastUnitTime == "" {
                self.lastIncidentLastUnitL.text = "No Last Unit Time Set"
            } else {
                self.lastIncidentLastUnitL.text = incident?.lastUnitTime
            }
            self.lastIncidentResourcesL.text = incident?.incidentResources
            self.incidentForwardB.isHidden = true
            self.incidentPreviousB.isHidden = false
            }
        }
    }
    
    //    MARK: -MAP-
    var userLocationPicked: Bool = false
    var locationManager:CLLocationManager!
    private var currentLocation: CLLocation?
    var pointAnnotation:NewIncidentMapAnnotation!
    var selectedAnnotation:NewIncidentMapAnnotation?
    var pinAnnotationView:MKPinAnnotationView!
    var locations = [NewIncidentMapAnnotation]()
    var mapLocations = [NewIncidentMapAnnotation]()
    var mapAnnotationViews = [MKPinAnnotationView]()
    var allLocations = [CLLocation]()
    var annotationClicked:Bool = false
    var mapType:MKMapType = .satellite
    var fireStationAddressS: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        roundViews()
//        removeAllAnnotations()
//        determineLocation()
        
//        todaysIncidentMap.showsUserLocation = true
//        todaysIncidentMap.isZoomEnabled = true
//        todaysIncidentMap.mapType = mapType
//        todaysIncidentMap.delegate = self
    }
    
    func roundViews() {
        self.contentView.layer.cornerRadius = 6
        self.contentView.clipsToBounds = true
        self.contentView.layer.borderColor = UIColor.systemRed.cgColor
        self.contentView.layer.borderWidth = 2
    }
    
    //    MARK: -BUTTON ACTIONS-
    
    
    @IBAction func forwardIncidentBTapped(_ sender: Any) {
        buttonCount += 1
        incidentPreviousB.isHidden = false
        var incident: TodayIncident
        if buttonCount == incrementCount - 1 {
            incidentForwardB.isHidden = true
        }
        incident = allOfTodaysIncidents[buttonCount]
        self.lastIncidentIconIV.image = incident.incidentImage
        self.incidentNumberL.text = incident.incidentNumber
        self.lastIncidentStreetAddressL.text = incident.streetAddress
        self.lastIncidentCityStateL.text = incident.cityStateZip
        self.lastIncidentAlarmL.text = incident.alarmTime
        if incident.arrivalTime == "" {
            self.lastIncidentAlertL.text = "No Arrival Time Set"
        } else {
            self.lastIncidentAlertL.text = incident.arrivalTime
        }
        if incident.controlledTime == "" {
            self.lastIncidentControlledL.text = "No Controlled Time Set"
        } else {
            self.lastIncidentControlledL.text = incident.controlledTime
        }
        if incident.lastUnitTime == "" {
            self.lastIncidentLastUnitL.text = "No Last Unit Time Set"
        } else {
            self.lastIncidentLastUnitL.text = incident.lastUnitTime
        }
        self.lastIncidentResourcesL.text = incident.incidentResources
    }
    
    @IBAction func previousIncidentBTapped(_ sender: Any) {
        buttonCount -= 1
        incidentForwardB.isHidden = false
        var incident: TodayIncident
        if buttonCount == 0 {
            incidentPreviousB.isHidden = true
        }
        incident = allOfTodaysIncidents[buttonCount]
        self.lastIncidentIconIV.image = incident.incidentImage
        self.incidentNumberL.text = incident.incidentNumber
        self.lastIncidentStreetAddressL.text = incident.streetAddress
        self.lastIncidentCityStateL.text = incident.cityStateZip
        self.lastIncidentAlarmL.text = incident.alarmTime
        if incident.arrivalTime == "" {
            self.lastIncidentAlertL.text = "No Arrival Time Set"
        } else {
            self.lastIncidentAlertL.text = incident.arrivalTime
        }
        if incident.controlledTime == "" {
            self.lastIncidentControlledL.text = "No Controlled Time Set"
        } else {
            self.lastIncidentControlledL.text = incident.controlledTime
        }
        if incident.lastUnitTime == "" {
            self.lastIncidentLastUnitL.text = "No Last Unit Time Set"
        } else {
            self.lastIncidentLastUnitL.text = incident.lastUnitTime
        }
        self.lastIncidentResourcesL.text = incident.incidentResources
    }
    
    
}

extension TodaysIncidentsCVCell {
    
//    private func removeAllAnnotations() ->Void {
//        for annotation in todaysIncidentMap.annotations {
//            todaysIncidentMap.removeAnnotation(annotation)
//        }
//        if userLocationPicked {
//            currentLocation = nil
//        } else {
//            if fireStationLocation != nil {
//                plotTheFireStation()
//            } else {
//                if fireStationAddress != "" {
//                    getTheFireStationLocation()
//                }
//            }
//        }
//    }
//    
//    func plotTheFireStation() {
//            let location: CLLocation = fireStationLocation
//            pointAnnotation = NewIncidentMapAnnotation()
//            let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude:location.coordinate.longitude)
//            pointAnnotation.coordinate = coordinate
//            let type:kAnnotationType = .annotationFireStation
//            pointAnnotation.type = type
//            pointAnnotation.title = fireStationAddress
//            pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "AnnotationIdentifier")
//            pointAnnotation.title = fireStationAddressS
//            mapLocations.append(pointAnnotation)
//            self.mapAnnotationViews.append(pinAnnotationView)
//            todaysIncidentMap.addAnnotation(pointAnnotation)
//    }
//    
//    private func getTheFireStationLocation() {
//        
//        let geocoder = CLGeocoder()
//        
//        geocoder.geocodeAddressString(fireStationAddress) {
//            placemarks, error in
//            let placemark = placemarks?.first
//            if let location = placemark?.location {
//                self.fireStationLocation = location
//                self.plotTheFireStation()
//            }
//        }
//    }
//    
//    func determineLocation() {
//        if (CLLocationManager.locationServicesEnabled()) {
//            locationManager = CLLocationManager()
//            locationManager.delegate = self
//            locationManager.desiredAccuracy = kCLLocationAccuracyBest
//            locationManager.requestAlwaysAuthorization()
//            locationManager.requestWhenInUseAuthorization()
//        }
//        
//        locationManager.requestWhenInUseAuthorization()
//        if CLLocationManager.locationServicesEnabled() {
//            locationManager.startUpdatingLocation()
//        }
//    }
//    
//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        self.selectedAnnotation = view.annotation as? NewIncidentMapAnnotation
//        let center = self.selectedAnnotation?.coordinate
//        let defaultL = CLLocationCoordinate2D(latitude: (currentLocation?.coordinate.latitude)!, longitude:(currentLocation?.coordinate.longitude)!)
//        let region = MKCoordinateRegion(center: center ?? defaultL, span:MKCoordinateSpan(latitudeDelta: 0.001225, longitudeDelta: 0.001123))
//        todaysIncidentMap.setRegion(region, animated: true)
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//       
//        let userLocation:CLLocation!
//            
//            if fireStationLocation != nil {
//                userLocation = fireStationLocation
//                currentLocation = fireStationLocation
//            } else {
//                userLocation = locations[0] as CLLocation
//                currentLocation = userLocation
//            }
//            
//            locationManager.stopUpdatingLocation()
//            
//            let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude:userLocation.coordinate.longitude)
//            let region = MKCoordinateRegion(center: center, span:MKCoordinateSpan(latitudeDelta: 0.0045, longitudeDelta: 0.0045))
//            todaysIncidentMap.setRegion(region, animated: true)
//             plotTheIncident()
//    }
//    
//    func plotTheIncident() {
//        for incident in allOfTodaysIncidents {
//            if incident.incidentLocation != nil {
//                
//                let location:CLLocation = incident.incidentLocation
//                self.allLocations.append(location)
//                pointAnnotation = NewIncidentMapAnnotation()
//                let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude:location.coordinate.longitude)
//                pointAnnotation.coordinate = coordinate
//                let pinType = incident.situationIncidentImage
//                var type:kAnnotationType = .annotationFire
//                if pinType == "Fire" {
//                    type = .annotationFire
//                } else if pinType == "EMS" {
//                    type = .annotationEMS
//                } else if pinType == "Rescue" {
//                    type = .annotationRescue
//                }
//                pointAnnotation.type = type
//                var address:String = ""
//                if incident.incidentAnnotationAddress != "" {
//                    address = incident.incidentAnnotationAddress
//                }
//                var sub:String = ""
//                let number = incident.incidentNumber
//                sub = "Incident #\(number)"
//                
//                var incidentType:String = "Fire"
//                if let iType = incident.situationIncidentImage {
//                    incidentType = iType
//                    sub = sub+" \(incidentType)"
//                }
//                
//                
//                pointAnnotation.title = address
//                pointAnnotation.subtitle = sub
//                pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "AnnotationIdentifier")
//                pointAnnotation.title = address
//                mapLocations.append(pointAnnotation)
//                self.mapAnnotationViews.append(pinAnnotationView)
//                todaysIncidentMap.addAnnotation(pointAnnotation)
//                
//            }
//        }
//    }
    
}
