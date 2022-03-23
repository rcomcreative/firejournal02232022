//
//  MapVC.swift
//  dashboard
//
//  Created by DuRand Jones on 9/14/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import CoreLocation
import CoreData


protocol MapVCDelegate: AnyObject {

    func mapTapped()
}



class MapVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    //    MARK: -PROPERTIES
    weak var delegate:MapVCDelegate? = nil
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var titleName:String = ""
    private let vcLaunch = VCLaunch()
    private let buildButtons = BuildButtons()
    private var launchNC: LaunchNotifications!
    var controllerName:String = ""
    var myShift:MenuItems! = nil
    var firstLoad:Bool = true
    
    // MARK: -OBJECTS
    @IBOutlet weak var mapV: MKMapView!
    var locationManager:CLLocationManager!
    private var currentLocation: CLLocation?
    var pointAnnotation:NewIncidentMapAnnotation!
    var selectedAnnotation:NewIncidentMapAnnotation?
    var pinAnnotationView:MKPinAnnotationView!
    var city:String = ""
    var state:String = ""
    var streetNum:String = ""
    var streetName:String = ""
    var zip:String = ""
    @IBOutlet weak var useAddressB: UIButton!
    @IBOutlet weak var countOfIncidentTF: UITextField!
    @IBOutlet weak var allIncidentB: UIButton!
    @IBOutlet weak var fireIncidentsB: UIButton!
    @IBOutlet weak var emsIncidentsB: UIButton!
    @IBOutlet weak var rescueIncidentB: UIButton!
    @IBOutlet weak var ics214B: UIButton!
    @IBOutlet weak var arcFormB: UIButton!
    @IBOutlet weak var myLocationB: UIButton!
    @IBOutlet weak var myFireStationLocation: UIButton!
    @IBOutlet weak var satelliteB: UIButton!
    @IBOutlet weak var hybredB: UIButton!
    @IBOutlet weak var streetB: UIButton!
    var incidentType:IncidentTypes = .allIncidents
    var objectID:NSManagedObjectID!
    var fetched:Array<Incident>!
    var ics214Fetched:Array<ICS214Form>!
    var ccrFetched:Array<ARCrossForm>!
    var fetchedUser:Array<FireJournalUser>!
    var locations = [NewIncidentMapAnnotation]()
    var mapLocations = [NewIncidentMapAnnotation]()
    var mapAnnotationViews = [MKPinAnnotationView]()
    var allLocations = [CLLocation]()
    var annotationClicked:Bool = false
    let nc = NotificationCenter.default
    var mapType:MKMapType = .satellite
    var fju:FireJournalUser!
    var theCrew: TheCrew!
    var address = ""
    var theType: IncidentTypes = .fire
    var incident:Incident!
    var fireStationAddress: String = ""
    var userLocationPicked: Bool = false
    @IBOutlet weak var mapVCB: UIButton!
    var alertUp: Bool = false
    @IBOutlet weak var mapDirectionalV: UIView!
    @IBOutlet weak var mapDirectionalB: UIButton!
    @IBOutlet weak var mapFireStationB: UIButton!
    @IBOutlet weak var mapFilterB: UIButton!
    @IBOutlet weak var mapInfoB: UIButton!
    
    let incidentSegue: String = MapVCToMapIncidentSegue
    let ics214Segue: String = MapVCToMapICS214Segue
    let arcSegue: String = MapVCToMapARCSegue
    var segue: String = ""
    
    func roundViews() {
        self.mapDirectionalV.layer.cornerRadius = 6
        self.mapDirectionalV.clipsToBounds = true
        self.mapDirectionalV.layer.borderColor = UIColor.white.cgColor
        self.mapDirectionalV.layer.borderWidth = 2
        self.countOfIncidentTF.layer.borderColor = UIColor.white.cgColor
        self.countOfIncidentTF.layer.borderWidth = 2
        self.countOfIncidentTF.layer.cornerRadius = 6
        self.countOfIncidentTF.clipsToBounds = true
    }

    
    @IBAction func mapVCBTapped(_ sender: Any) {
        presentAlert()
    }
    
    func presentAlert() {
        let title: InfoBodyText = .mapSupportNotesSubject
        let message: InfoBodyText = .mapSupportNotes
        let alert = UIAlertController.init(title: title.rawValue , message: message.rawValue, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func satelliteBTapped(_ sender: Any) {
        mapV.mapType = .satellite
        mapType = .satellite
        mapV.setNeedsLayout()
    }
    @IBAction func hybredBTapped(_ sender: Any) {
        mapV.mapType = .hybrid
        mapType = .hybrid
        mapV.setNeedsLayout()
    }
    @IBAction func streetBTapped(_ sender: Any) {
        mapV.mapType = .standard
        mapType = .standard
        mapV.setNeedsLayout()
    }
    @IBAction func allincidentsBTapped(_ sender: Any) {
        annotationClicked = false
        incidentType = .allIncidents
        theType = IncidentTypes.allIncidents
        if userLocationPicked {
            currentLocation = nil
        }
        getAllMapLocations(type: incidentType,entity: "Incident")
        DispatchQueue.main.async {
            self.nc.post(name: Notification.Name(rawValue: FJkTHEMAPTYPECHANGED),
                         object: nil, userInfo: ["shift":MenuItems.incidents])
        }
    }
    @IBAction func allFiresBTapped(_ sender: Any) {
        annotationClicked = false
        incidentType = .fire
        theType = IncidentTypes.fire
        if userLocationPicked {
            currentLocation = nil
        }
        getAllMapLocations(type: incidentType,entity: "Incident")
        DispatchQueue.main.async {
            self.nc.post(name: Notification.Name(rawValue: FJkTHEMAPTYPECHANGED),
                         object: nil, userInfo: ["shift":MenuItems.fire])
        }
    }
    @IBAction func allEmsBTapped(_ sender: Any) {
        annotationClicked = false
        incidentType = .ems
        theType = IncidentTypes.ems
        if userLocationPicked {
            currentLocation = nil
        }
        getAllMapLocations(type: incidentType,entity: "Incident")
        DispatchQueue.main.async {
            self.nc.post(name: Notification.Name(rawValue: FJkTHEMAPTYPECHANGED),
                         object: nil, userInfo: ["shift":MenuItems.ems])
        }
    }
    @IBAction func allrescueBTapped(_ sender: Any) {
        annotationClicked = false
        incidentType = .rescue
        theType = IncidentTypes.rescue
        if userLocationPicked {
            currentLocation = nil
        }
        getAllMapLocations(type: incidentType,entity: "Incident")
        DispatchQueue.main.async {
            self.nc.post(name: Notification.Name(rawValue: FJkTHEMAPTYPECHANGED),
                         object: nil, userInfo: ["shift":MenuItems.rescue])
        }
    }
    @IBAction func allics214BTapped(_ sender: Any) {
        annotationClicked = false
        incidentType = .ics214Form
        theType = IncidentTypes.ics214Form
        if userLocationPicked {
            currentLocation = nil
        }
        getAllMapLocations(type: incidentType,entity: "ICS214Form")
        DispatchQueue.main.async {
            self.nc.post(name: Notification.Name(rawValue: FJkTHEMAPTYPECHANGED),
                         object: nil, userInfo: ["shift":MenuItems.ics214])
        }
    }
    @IBAction func allARCFormBTapped(_ sender: Any) {
        annotationClicked = false
        incidentType = .arcForm
        theType = IncidentTypes.arcForm
        if userLocationPicked {
            currentLocation = nil
        }
        getAllMapLocations(type: incidentType,entity: "ARCrossForm")
        DispatchQueue.main.async {
            self.nc.post(name: Notification.Name(rawValue: FJkTHEMAPTYPECHANGED),
                         object: nil, userInfo: ["shift":MenuItems.arcForm])
        }
    }
    @IBAction func showLocationBTapped(_ sender: Any) {
        annotationClicked = false
        incidentType = .allIncidents
        theType = IncidentTypes.allIncidents
        currentLocation = nil
        userLocationPicked = true
        getAllMapLocations(type: incidentType,entity: "Incident")
        DispatchQueue.main.async {
            self.nc.post(name: Notification.Name(rawValue: FJkTHEMAPTYPECHANGED),
                         object: nil, userInfo: ["shift":MenuItems.incidents])
        }
    }
    
    @IBAction func showMyFireStationLocatin(_ sender: Any) {
        annotationClicked = false
        incidentType = IncidentTypes.myFireStation
        theType = IncidentTypes.myFireStation
        currentLocation = nil
        userLocationPicked = false
        getTheFireStationLocation()
    }
    
    @IBAction func showTheFiltersBTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MapInfo", bundle: nil)
        let editVC  = storyboard.instantiateViewController(identifier: "MapInfoVC") as! MapInfoVC
        editVC.delegate = self
        switch mapType {
            case .satellite:
                editVC.type = 0
            case .hybrid:
                editVC.type = 1
            case .standard:
                editVC.type = 2
            default:
                break
        }
        present(editVC, animated: true )
    }
    
    private func getTheUser(userGuid: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FireJournalUser" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@", "userGuid", "")
        let sectionSortDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20
        
        do {
            self.fetchedUser = try context.fetch(fetchRequest) as? [FireJournalUser]
            self.fju = self.fetchedUser.last
        } catch let error as NSError {
            print("MapKit line 136 Error: \(error.localizedDescription)")
        }
    }
    
    private func getTheFireStationLocation() {
        if let streetNum = fju.fireStationStreetNumber {
            address = streetNum
        }
        if let streetName = fju.fireStationStreetName {
            address = "\(address) \(streetName)"
        }
        if let city = fju.fireStationCity {
            address = "\(address) \(city)"
        }
        if let state = fju.fireStationState {
            address = "\(address) \(state)"
        }
        if let zip = fju.fireStationZipCode {
            address = "\(address) \(zip)"
        }
        
        let geocoder = CLGeocoder()
        
        fireStationAddress = address
        
        geocoder.geocodeAddressString(address) {
            placemarks, error in
            let placemark = placemarks?.first
            if let location = placemark?.location {
                self.currentLocation = location
                self.plotTheFireStation()
                self.viewWillLayoutSubviews()
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roundViews()
        self.title = titleName
        getTheUser(userGuid: "")
        //        getTheFireStationLocation()
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        getTheFireStationLocation()
        switch incidentType {
        case .fire:
            getAllMapLocations(type: incidentType,entity: "Incident")
            DispatchQueue.main.async {
                self.nc.post(name: Notification.Name(rawValue: FJkTHEMAPTYPECHANGED),
                             object: nil, userInfo: ["shift":MenuItems.fire])
            }
        case .ems:
            getAllMapLocations(type: incidentType,entity: "Incident")
            DispatchQueue.main.async {
                self.nc.post(name: Notification.Name(rawValue: FJkTHEMAPTYPECHANGED),
                             object: nil, userInfo: ["shift":MenuItems.ems])
            }
        case .rescue:
            getAllMapLocations(type: incidentType,entity: "Incident")
            DispatchQueue.main.async {
                self.nc.post(name: Notification.Name(rawValue: FJkTHEMAPTYPECHANGED),
                             object: nil, userInfo: ["shift":MenuItems.rescue])
            }
        case .ics214Form:
            theType = IncidentTypes.ics214Form
            getAllMapLocations(type: incidentType, entity: "ICS214Form")
            DispatchQueue.main.async {
                self.nc.post(name: Notification.Name(rawValue: FJkTHEMAPTYPECHANGED),
                             object: nil, userInfo: ["shift":MenuItems.ics214])
            }
        case .arcForm:
            theType = IncidentTypes.arcForm
            getAllMapLocations(type: incidentType, entity: "ARCrossForm")
            DispatchQueue.main.async {
                self.nc.post(name: Notification.Name(rawValue: FJkTHEMAPTYPECHANGED),
                             object: nil, userInfo: ["shift":MenuItems.arcForm])
            }
        default:
            incidentType = .allIncidents
            getAllMapLocations(type: incidentType,entity: "Incident")
        }
        
        //        MARK: - INCIDENT,FIRE,EMS,RESCUE PIN TO OPEN
        nc.addObserver(self, selector:#selector(incidentChosenForDisplay(notification:)),name:NSNotification.Name(rawValue: FJkINCIDENTCHOSENFORMAP), object: nil)
        
        //        MARK: - ICS214 PIN TO OPEN
        nc.addObserver(self, selector:#selector(incidentChosenForDisplay(notification:)),name:NSNotification.Name(rawValue: FJkICS214CHOSENFORMAP), object: nil)
        
        //        MARK: - ARCFORM PIN TO OPEN
        nc.addObserver(self, selector:#selector(incidentChosenForDisplay(notification:)),name:NSNotification.Name(rawValue: FJkARCFORMCHOSENFORMAP), object: nil)
        
        
    }
    
    override func viewWillLayoutSubviews() {
        mapV.showsUserLocation = true
        mapV.isZoomEnabled = true
        mapV.mapType = mapType
        mapV.delegate = self
        
//        satelliteB.setBackgroundImage(ButtonsForFJ092018.imageOfBackgroundBlueGradient, for: .normal)
//        satelliteB.layer.cornerRadius = 3
//        satelliteB.layer.masksToBounds = true
//
//        hybredB.setBackgroundImage(ButtonsForFJ092018.imageOfBackgroundBlueGradient, for: .normal)
//        hybredB.layer.cornerRadius = 3
//        hybredB.layer.masksToBounds = true
//
//        streetB.setBackgroundImage(ButtonsForFJ092018.imageOfBackgroundBlueGradient, for: .normal)
//        streetB.layer.cornerRadius = 3
//        streetB.layer.masksToBounds = true
        
//        allIncidentB.setBackgroundImage(BuildButtons.allIncidentsIcon, for: .normal)
//        fireIncidentsB.setBackgroundImage(BuildButtons.fireIncidentsIcon, for: .normal)
//        emsIncidentsB.setBackgroundImage(BuildButtons.emsIncidentsIcon, for: .normal)
//        rescueIncidentB.setBackgroundImage(BuildButtons.rescueIncidentsIcon, for: .normal)
//        ics214B.setBackgroundImage(BuildButtons.ics214Icon, for: .normal)
//        arcFormB.setBackgroundImage(BuildButtons.ARCFormIcon, for: .normal)
//        myFireStationLocation.setBackgroundImage(BuildButtons.YourFireStationLocationIcon, for: .normal)
//        myLocationB.setBackgroundImage(BuildButtons.YourLocationIcon, for: .normal)
        determineLocation()
    }
    
    @objc func incidentChosenForDisplay(notification: Notification) {
        if let userInfo = notification.userInfo as! [String: Any]?
        {
            if let id = userInfo["objectID"] as? NSManagedObjectID {
                for annotationView:MKPinAnnotationView in mapAnnotationViews {
                    let pinannotation:NewIncidentMapAnnotation = annotationView.annotation as! NewIncidentMapAnnotation
                    let pinObjectID = pinannotation.objectID
                    if id == pinObjectID {
                        mapV.selectAnnotation(pinannotation, animated: true)
                    }
                }
            }
        }
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.selectedAnnotation = view.annotation as? NewIncidentMapAnnotation
        let center = self.selectedAnnotation?.coordinate
        let defaultL = CLLocationCoordinate2D(latitude: (currentLocation?.coordinate.latitude)!, longitude:(currentLocation?.coordinate.longitude)!)

               let region = MKCoordinateRegion(center: center ?? defaultL, span:MKCoordinateSpan(latitudeDelta: 0.001225, longitudeDelta: 0.001123))

        //        mapV.setCenter(center!, animated: true)
        mapV.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //        if !userLocationPicked {
        //            getTheFireStationLocation()
        //        }
        
        if !annotationClicked {
            
            let userLocation:CLLocation!
            
            if currentLocation != nil {
                userLocation = currentLocation
            } else {
                userLocation = locations[0] as CLLocation
                currentLocation = userLocation
            }
            //locations[0] as CLLocation
            //            currentLocation = userLocation
            locationManager.stopUpdatingLocation()
            
            let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude:userLocation.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span:MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
            mapV.setRegion(region, animated: true)
            
            
            switch theType {
            case .fire, .ems, .rescue, .allIncidents:
                plotTheIncident()
            case .ics214Form:
                plotTheICS214()
            case .arcForm:
                plotTheArcForm()
            case .myFireStation:
                plotTheFireStation()
            default: break
            }
            
            annotationClicked = true
            //            print(mapAnnotationViews)
        }
    }
    
    func plotTheFireStation() {
        let location: CLLocation = currentLocation!
        pointAnnotation = NewIncidentMapAnnotation()
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude:location.coordinate.longitude)
        pointAnnotation.coordinate = coordinate
        let type:kAnnotationType = .annotationFireStation
        pointAnnotation.type = type
        pointAnnotation.title = fireStationAddress
        pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "AnnotationIdentifier")
        pointAnnotation.title = address
        mapLocations.append(pointAnnotation)
        self.mapAnnotationViews.append(pinAnnotationView)
        mapV.addAnnotation(pointAnnotation)
    }
    
    func plotTheIncident() {
        for incident in self.fetched {
            if incident.incidentLocationSC != nil {
                if let location = incident.incidentLocationSC {
                    guard let  archivedData = location as? Data else { return }
                    do {
                        guard let unarchivedLocation = try NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self , from: archivedData) else { return }
                        let location:CLLocation = unarchivedLocation
                        self.allLocations.append(location)
                        
                        pointAnnotation = NewIncidentMapAnnotation()
                        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude:location.coordinate.longitude)
                        pointAnnotation.coordinate = coordinate
                        let pinType = incident.situationIncidentImage
                        var type:kAnnotationType = .annotationFire
                        if pinType == "Fire" {
                            type = .annotationFire
                        } else if pinType == "EMS" {
                            type = .annotationEMS
                        } else if pinType == "Rescue" {
                            type = .annotationRescue
                        }
                        pointAnnotation.type = type
                        let objectID = incident.objectID
                        pointAnnotation.objectID = objectID
                        var address:String = ""
                        var sub:String = ""
                        let incidentAddress:IncidentAddress = incident.incidentAddressDetails!
                        if let number = incidentAddress.streetNumber {
                            self.streetNum = number
                            address = self.streetNum
                        }
                        if let name = incidentAddress.streetHighway {
                            self.streetName = name
                            address = address+" \(self.streetName)"
                        }
                        if let cityName = incidentAddress.city {
                            self.city = cityName
                            address = address+" \(self.city)"
                        }
                        if let zipCode = incidentAddress.zip {
                            self.zip = zipCode
                            address = address+" \(self.zip)"
                        }
                        if let number = incident.incidentNumber {
                            sub = "Incident #\(number)"
                        }
                        let theModDate:Date = incident.incidentModDate ?? Date()
                        let fullyFormattedDate = FullDateFormat.init(date:theModDate)
                        let incidentDate:String = fullyFormattedDate.formatFullyTheDate()
                        sub = sub+" \(incidentDate)"
                        var incidentType:String = "Fire"
                        if let iType = incident.situationIncidentImage {
                            incidentType = iType
                            sub = sub+" \(incidentType)"
                        }
                        var emergencyIncident:String = ""
                        if let emergency = incident.incidentType {
                            emergencyIncident = emergency
                            sub = sub+" \(emergencyIncident)"
                        }
                        
                        
                        pointAnnotation.title = address
                        pointAnnotation.subtitle = sub
                        pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "AnnotationIdentifier")
                        pointAnnotation.title = address
                        mapLocations.append(pointAnnotation)
                        self.mapAnnotationViews.append(pinAnnotationView)
                        mapV.addAnnotation(pointAnnotation)
                    } catch {
                        print("something's going on here")
                    }
                }
                
            }
        }
    }
    
    func plotTheICS214() {
        for ics214 in self.ics214Fetched {
            var location:CLLocation!
            
            /// arcLocation unarchived from secureCodeing
            if ics214.ics214LocationSC != nil {
                if let theLocation = ics214.ics214LocationSC {
                    guard let  archivedData = theLocation as? Data else { return }
                    do {
                        guard let unarchivedLocation = try NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self , from: archivedData) else { return  }
                        location = unarchivedLocation
                        self.allLocations.append(location)
                        pointAnnotation = NewIncidentMapAnnotation()
                        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude:location.coordinate.longitude)
                        pointAnnotation.coordinate = coordinate
                        let type:kAnnotationType = .annotationICS214
                        let objectID = ics214.objectID
                        pointAnnotation.objectID = objectID
                        pointAnnotation.incidentType = incidentType
                        pointAnnotation.type = type
                        var address:String = ""
                        var sub:String = ""
                        sub = getTheAddress(location: location)
                        if let name = ics214.ics214IncidentName {
                            address = "Incident Name: \(name)"
                        }
                        if let fromDate = ics214.ics214FromTime {
                            let fullyFormattedDate = FullDateFormat.init(date:fromDate)
                            let theFromDateTime:String = fullyFormattedDate.formatFullyTheDate()
                            address = address+" From Time: \(theFromDateTime)"
                        }
                        if let toDate = ics214.ics214ToTime {
                            let fullyFormattedDate = FullDateFormat.init(date:toDate)
                            let theToDateTime:String = fullyFormattedDate.formatFullyTheDate()
                            address = address+" To Time: \(theToDateTime)"
                        }
                        
                        pointAnnotation.title = address
                        pointAnnotation.subtitle = sub
                        pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "AnnotationIdentifier")
                        mapLocations.append(pointAnnotation)
                        self.mapAnnotationViews.append(pinAnnotationView)
                        mapV.addAnnotation(pointAnnotation)
                    } catch {
                        print("boy there was an error here")
                    }
                }
                
            } else if ics214.incidentGuid != nil {
                if let guidString = ics214.incidentGuid {
                    getTheIncidentLocation(guid: guidString)
                    
                    /// arcLocation unarchived from secureCodeing
                    if incident.incidentLocationSC != nil {
                            if let theLocation = incident.incidentLocationSC {
                                guard let  archivedData = theLocation as? Data else { return }
                                do {
                                    guard let unarchivedLocation = try NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self , from: archivedData) else { return  }
                                    location = unarchivedLocation
                                    self.allLocations.append(location)
                                    pointAnnotation = NewIncidentMapAnnotation()
                                    let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude:location.coordinate.longitude)
                                    pointAnnotation.coordinate = coordinate
                                    let type:kAnnotationType = .annotationICS214
                                    let objectID = ics214.objectID
                                    pointAnnotation.objectID = objectID
                                    pointAnnotation.type = type
                                    var address:String = ""
                                    var sub:String = ""
                                    let incidentAddress:IncidentAddress = incident.incidentAddressDetails!
                                    if let number = incidentAddress.streetNumber {
                                        self.streetNum = number
                                        address = self.streetNum
                                    }
                                    if let name = incidentAddress.streetHighway {
                                        self.streetName = name
                                        address = address+" \(self.streetName)"
                                    }
                                    if let cityName = incidentAddress.city {
                                        self.city = cityName
                                        address = address+" \(self.city)"
                                    }
                                    if let zipCode = incidentAddress.zip {
                                        self.zip = zipCode
                                        address = address+" \(self.zip)"
                                    }
                                    if let number = incident.incidentNumber {
                                        sub = "Incident #\(number)"
                                    }
                                    let theModDate:Date = incident.incidentModDate ?? Date()
                                    let fullyFormattedDate = FullDateFormat.init(date:theModDate)
                                    let incidentDate:String = fullyFormattedDate.formatFullyTheDate()
                                    sub = sub+" \(incidentDate)"
                                    var incidentType:String = "Fire"
                                    if let iType = incident.situationIncidentImage {
                                        incidentType = iType
                                        sub = sub+" \(incidentType)"
                                    }
                                    var emergencyIncident:String = ""
                                    if let emergency = incident.incidentType {
                                        emergencyIncident = emergency
                                        sub = sub+" \(emergencyIncident)"
                                    }
                                    
                                    
                                    pointAnnotation.title = address
                                    pointAnnotation.subtitle = sub
                                    pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "AnnotationIdentifier")
                                    pointAnnotation.title = address
                                    mapLocations.append(pointAnnotation)
                                    self.mapAnnotationViews.append(pinAnnotationView)
                                    mapV.addAnnotation(pointAnnotation)
                                } catch {
                                    print("boy there was an error here")
                                }
                            }
                        
                    }
                }
            }
        }
    }
    
    func getTheIncidentLocation(guid: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Incident" )
        let predicate = NSPredicate(format: "%K == %@", "fjpIncGuidForReference", guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            let fetchIncident = try context.fetch(fetchRequest) as! [Incident]
            if fetchIncident.count != 0 {
                self.incident = fetchIncident.last
            }
        } catch let error as NSError {
            print("MapTVC line 491 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    func plotTheArcForm() {
        for arcForm in self.ccrFetched {
            var location:CLLocation!
            
            /// arcLocation unarchived from secureCodeing
            if arcForm.arcLocationSC != nil {
                if let theLocation = arcForm.arcLocationSC {
                    guard let  archivedData = theLocation as? Data else { return }
                    do {
                        guard let unarchivedLocation = try NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self , from: archivedData) else { return }
                        location = unarchivedLocation
                        self.allLocations.append(location)
                        pointAnnotation = NewIncidentMapAnnotation()
                        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude:location.coordinate.longitude)
                        pointAnnotation.coordinate = coordinate
                        let type:kAnnotationType = .annotationCRRForm
                        let objectID = arcForm.objectID
                        pointAnnotation.objectID = objectID
                        pointAnnotation.type = type
                        var address:String = ""
                        var sub:String = ""
                        sub = getTheAddress(location: location)
                        if let campaign = arcForm.campaignName {
                            address = "Campaign: \(campaign)"
                        }
                        if let start = arcForm.cStartDate {
                            let fullyFormattedDate = FullDateFormat.init(date:start)
                            let theStartDateTime:String = fullyFormattedDate.formatFullyTheDate()
                            address = address+" Started: \(theStartDateTime)"
                        }
                        if let end = arcForm.cEndDate {
                            let fullyFormattedDate = FullDateFormat.init(date:end)
                            let theEndDateTime:String = fullyFormattedDate.formatFullyTheDate()
                            address = address+" Started: \(theEndDateTime)"
                        }
                        if arcForm.campaignCount != 0 {
                            let count = arcForm.campaignCount
                            let campaignCount = String(count)
                            address = address+" Count: \(campaignCount)"
                        }
                        
                        pointAnnotation.title = address
                        pointAnnotation.subtitle = sub
                        pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "AnnotationIdentifier")
                        mapLocations.append(pointAnnotation)
                        self.mapAnnotationViews.append(pinAnnotationView)
                        mapV.addAnnotation(pointAnnotation)
                    } catch {
                        print("Unarchiver failed on arcLocation")
                    }
                }
                
                
            }
        }
    }
    
    func displayMarkers(location: CLLocation,type:kAnnotationType,id:NSManagedObjectID,completion: @escaping (_ annoation:NewIncidentMapAnnotation)->()) {
        
        var addressS:String = ","
        let annotation = NewIncidentMapAnnotation()
        annotation.type = type
        annotation.objectID = id
        
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error\n" + (error?.localizedDescription)!)
                return
            }
            
            if placemarks?.count != 0 {
                let pm = placemarks![0]
                //                print(pm.locality!)
                self.city = "\(pm.locality ?? "")"
                self.streetNum = "\(pm.subThoroughfare ?? "")"
                self.streetName = "\(pm.thoroughfare ?? "")"
                self.state = "\(pm.administrativeArea ?? "")"
                self.zip = "\(pm.postalCode!)"
                
                addressS = "\(self.streetNum) \(self.streetName),\(self.city) \(self.state) \(self.zip)"
                annotation.title = addressS
                completion(annotation)
            }
            else {
                print("Problem with the data received from geocoder")
            }
            
            //            handler(addressS)
        })
        
    }
    
    func getTheAddress(location: CLLocation) -> String {
        
        var addressS:String = ""
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error\n" + (error?.localizedDescription)!)
                return
            }
            
            if placemarks?.count != 0 {
                let pm = placemarks![0]
                //                print(pm.locality!)
                self.city = "\(pm.locality ?? "")"
                self.streetNum = "\(pm.subThoroughfare ?? "")"
                self.streetName = "\(pm.thoroughfare ?? "")"
                self.state = "\(pm.administrativeArea ?? "")"
                self.zip = "\(pm.postalCode ?? "")"
                
                addressS = "\(self.streetNum) \(self.streetName),\(self.city) \(self.state) \(self.zip)"
                //                print("here is the address \(addressS)")
            }
            else {
                print("Problem with the data received from geocoder")
            }
            
            //            handler(addressS)
        })
        return addressS
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            let lBtn = UIButton(type: .detailDisclosure)
            annotationView?.leftCalloutAccessoryView = lBtn
            annotationView?.canShowCallout = true
            annotationView?.isEnabled = true
            annotationView?.isDraggable = false
            
        } else {
            annotationView!.annotation = annotation
        }
        
        let customPointAnnotation = annotation as! NewIncidentMapAnnotation
        let pinImage = customPointAnnotation.imageForMapPin(type:customPointAnnotation.type)
        
        annotationView?.image = pinImage
        //            UIImage(named: customPointAnnotation.pinCustomImageName)
        
        return annotationView
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let mapAnnotation = annotationView.annotation as! NewIncidentMapAnnotation
        objectID = mapAnnotation.objectID
//        print("here is objectID \(objectID) and here is the type \(theType)")
        switch theType {
        case .fire, .ems, .rescue,.allIncidents:
            segue = incidentSegue
        case .ics214Form:
           segue = ics214Segue
        case .arcForm:
            segue = arcSegue
        default: break
        }
        performSegue(withIdentifier: segue, sender: self)
    }
    
    @IBAction func useAddressBTapped(_ sender: Any) {
        delegate?.mapTapped()
        //        if currentLocation != nil {
        ////            delegate?.theAddressHasBeenChosen(addressStreetNum: streetNum, addressStreetName: streetName, addressCity: city, addressState: state, addressZip: zip, location: currentLocation!)
        //        } else {
        //            delegate?.mapTapped()
        //        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
//        launchNC.removeNC()
    }
    
    private func getAllMapLocations(type: IncidentTypes,entity: String) {
        allLocations.removeAll()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        var typeOfIncident:String = "All Incidents Total:"
        switch type {
        case .fire:
            typeOfIncident = "Fire Incidents Total:"
            let predicate = NSPredicate(format: "%K == %@", "situationIncidentImage", "Fire")
            let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
            fetchRequest.predicate = predicateCan
            let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: false)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
        case .ems:
            typeOfIncident = "EMS Incidents Total:"
            let predicate = NSPredicate(format: "%K == %@", "situationIncidentImage", "EMS")
            let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
            fetchRequest.predicate = predicateCan
            let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: false)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
        case .rescue:
            typeOfIncident = "Rescue Incidents Total:"
            let predicate = NSPredicate(format: "%K == %@", "situationIncidentImage", "Rescue")
            let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
            fetchRequest.predicate = predicateCan
            let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: false)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
        case .allIncidents:
            let predicate1 = NSPredicate(format: "%K == %@ || %K == %@ || %K == %@", "situationIncidentImage", "Fire","situationIncidentImage", "Rescue","situationIncidentImage", "EMS")
            let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate1])
            fetchRequest.predicate = predicateCan
            let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: false)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
        case .ics214Form:
            typeOfIncident = "ICS 214 Total:"
            let predicate = NSPredicate(format: "%K == %@", "ics214EffortMaster",  NSNumber(value: true))
            let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
            fetchRequest.predicate = predicateCan
            let sectionSortDescriptor = NSSortDescriptor(key: "ics214FromTime", ascending: false)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
        case .arcForm:
            typeOfIncident = "CRR Form Total:"
            let predicate = NSPredicate(format: "%K == %@", "arcMaster",  NSNumber(value: true))
            let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
            fetchRequest.predicate = predicateCan
            let sectionSortDescriptor = NSSortDescriptor(key: "arcCreationDate", ascending: false)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
        case .userLocation:break
        default:break
        }
        
        
        fetchRequest.fetchBatchSize = 20
        
        switch type {
        case .fire, .ems, .rescue, .allIncidents:
            do {
                self.fetched = try context.fetch(fetchRequest) as? [Incident]
            } catch let error as NSError {
                print("MapTVC line 491 Fetch Error: \(error.localizedDescription)")
            }
            countOfIncidentTF.text = "\(typeOfIncident) \(self.fetched.count)"
            countOfIncidentTF.setNeedsDisplay()
        case .ics214Form:
            do {
                self.ics214Fetched = try context.fetch(fetchRequest) as? [ICS214Form]
            } catch let error as NSError {
                print("MapTVC line 539 Fetch Error: \(error.localizedDescription)")
            }
            countOfIncidentTF.text = "\(typeOfIncident) \(self.ics214Fetched.count)"
            countOfIncidentTF.setNeedsDisplay()
        case .arcForm:
            do {
                self.ccrFetched = try context.fetch(fetchRequest) as? [ARCrossForm]
            } catch let error as NSError {
                print("MapTVC line 545 Fetch Error: \(error.localizedDescription)")
            }
            countOfIncidentTF.text = "\(typeOfIncident) \(self.ccrFetched.count)"
            countOfIncidentTF.setNeedsDisplay()
        default:
            break
        }
        
        
        if firstLoad {
            firstLoad = false
        } else {
            removeAllAnnotations()
            locationManager.startUpdatingLocation()
        }
        
    }
    
    private func removeAllAnnotations() ->Void {
        for annotation in mapV.annotations {
            mapV.removeAnnotation(annotation)
        }
        if userLocationPicked {
            currentLocation = nil
        } else {
            plotTheFireStation()
        }
    }
    
    
    
}

extension MapVC {
    
    @IBAction func unwindToMapVC(segue:UIStoryboardSegue) {
        print("here")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == incidentSegue {
            let formTVC = segue.destination as! IncidentTVC
            formTVC.objectID = objectID
            formTVC.id = objectID
            formTVC.fromMap = true
            formTVC.myShift = .incidents
            formTVC.incidentType = incidentType
            formTVC.delegate = self
        } else if segue.identifier == arcSegue {
            let formTVC = segue.destination as! ARC_FormTVC
            formTVC.objectID = objectID
            formTVC.fromMap = true
            formTVC.delegate = self
        } else if segue.identifier == ics214Segue {
            let formTVC = segue.destination as! NewICS214DetailTVC
            formTVC.objectID = objectID
            formTVC.fromMap = true
            formTVC.delegate = self
        }
    }
}

extension MapVC: IncidentTVCDelegate {

    


    func incidentTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension MapVC: NewICS214DetailTVCDelegate {
    func theCampaignHasChanged() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension MapVC: ARC_FormDelegate {
    func theFormHasCancelled() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func theFormHasBeenSaved() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func theFormWantsNewForm() {
//        <#code#>
    }
    
    
}

extension MapVC: MapInfoVCDelegate {
    func mapInfoCancelTapped() {
        self.dismiss(animated: true, completion:nil)
    }
    func segmentChosen(type: Int) {
        switch type {
            case 0:
                satelliteBTapped(self)
            case 1:
                hybredBTapped(self)
            case 2:
                streetBTapped(self)
            default: break
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func allIncidentsTapped() {
        allincidentsBTapped(self)
        self.dismiss(animated: true, completion: nil)
    }
    
    func fireIncidentsTapped() {
        allFiresBTapped(self)
        self.dismiss(animated: true, completion: nil)
    }
    
    func emsIncidentsTapped() {
        allEmsBTapped(self)
        self.dismiss(animated: true, completion: nil)
    }
    
    func rescueIncidentsTapped() {
        allrescueBTapped(self)
        self.dismiss(animated: true, completion: nil)
    }
    
    func ics214Tapped() {
        allics214BTapped(self)
        self.dismiss(animated: true, completion: nil)
    }
    
    func arcFormsTapped() {
        allARCFormBTapped(self)
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
