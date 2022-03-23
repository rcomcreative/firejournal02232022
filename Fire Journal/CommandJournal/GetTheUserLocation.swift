    //
    //  GetTheUserLocation.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 7/7/21.
    //

import Foundation
import UIKit
import MapKit
import CoreLocation
import CoreData
import CloudKit

class GetTheUserLocation: NSObject {
    
    var locationManager:CLLocationManager!
    var currentLocation: CLLocation?
    var theCenter: CLLocationCoordinate2D?
    var fireJournalUser: FireJournalUser?
    var location: FCLocation?
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let nc = NotificationCenter.default
    let userDefaults = UserDefaults.standard
    var locationPermission: Bool = false
    var cameraBoundary: MKCoordinateRegion?
    var searchBoundary: MKCoordinateRegion?
    var mapBoundary: MKCoordinateRegion?
    
    
    lazy var theUserProvider: FireJournalUserProvider = {
        let provider = FireJournalUserProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theUserContext: NSManagedObjectContext!
    
    override init() {
        super.init()
        self.checkDefaultsForEmpty()
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        getTheUser()
    }
    
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func getTheUser() {
        theUserContext = theUserProvider.persistentContainer.newBackgroundContext()
        guard let users = theUserProvider.getTheUser(theUserContext) else {
            let errorMessage = "There is no user associated with this end shift"
            print(errorMessage)
            return
        }
        let aUser = users.last
        if let id = aUser?.objectID {
            fireJournalUser = context.object(with: id) as? FireJournalUser
        }
    }
    
}

extension GetTheUserLocation: CLLocationManagerDelegate {
    
    func checkDefaultsForEmpty() {
        if self.userDefaults.bool(forKey: FJkFirstRun ) {
            locationPermission = userDefaults.bool(forKey: FConLocationPermission)
            if locationPermission {
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
                        self.determineLocation()
                    @unknown default:
                        userDefaults.setValue(false, forKey: FConLocationPermission)
                        locationPermission = false
                    }
                    // userDefaults.synchronize()
                }
            }  else {
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
                        self.determineLocation()
                    @unknown default:
                        userDefaults.setValue(false, forKey: FConLocationPermission)
                        locationPermission = false
                    }
                    // userDefaults.synchronize()
                }
            }
        }
    }
    
    func determineLocation() {
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
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
        currentLocation = userLocation
        manager.stopUpdatingLocation()
        theCenter = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude:userLocation.coordinate.longitude)
        cameraBoundary = MKCoordinateRegion(center: theCenter!,
                                                       latitudinalMeters: 100, longitudinalMeters: 80)
        searchBoundary = MKCoordinateRegion(center: theCenter!,
                                            latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapBoundary = MKCoordinateRegion(center: theCenter!, latitudinalMeters: 500, longitudinalMeters: 500)
        if self.userDefaults.bool(forKey: FJkFirstRun ) {
        CLGeocoder().reverseGeocodeLocation(userLocation, completionHandler: {(placemarks, error) -> Void in
            print(userLocation)
            
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if placemarks?.count != 0 {
                    //                let pm = placemarks![0]
                guard let pm = placemarks?[0] else { return }
                if pm.thoroughfare != nil {
                    self.location?.latitude = userLocation.coordinate.latitude
                    self.location?.longitude = userLocation.coordinate.longitude
                    self.location?.location = userLocation
                    self.location?.zip = "\(pm.postalCode ?? "")"
                    if self.fireJournalUser != nil {
                        self.location?.fireJournalUser = self.fireJournalUser
                    }
                    let bckgroundContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
                    do {
                        try bckgroundContext.save()
                        DispatchQueue.main.async {
                            self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"GetTheUserLocation merge that"])
                        }
                    } catch let error as NSError {
                        let theError: String = error.localizedDescription
                        let error = "There was an error in saving " + theError
                        print(error)
                    }
                }
            }
            else {
                let error: String = "Problem with the data received from geocoder. Try again later."
                print(error)
            }
        })
        }
    }
    
    
}

