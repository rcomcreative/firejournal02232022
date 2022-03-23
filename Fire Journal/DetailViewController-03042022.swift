//
//  DetailViewController.swift
//  dashboard
//  Fire Journal
//
//  Created by DuRand Jones on 4/13/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//


import UIKit
import AVFoundation
import Foundation
import CoreData
import CoreLocation
import StoreKit

class DetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    //    , UISplitViewControllerDelegate
    
    var shift: Shift = .end
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var detailCollectionView: UICollectionView!
    let nc = NotificationCenter.default
    let userDefaults = UserDefaults.standard
    
    var orientation: Int?
    var displayMode: Int?
    var layout = PinterestLayout.init()
    var columns: Int = 0
    var compact: SizeTrait = .regular
    var frame: CGRect = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
    var menuItem: MenuItems = .myShift
    var visible = false
    var display: Int = 0
    var weatherTemperature: String = ""
    var weatherHumidity: String = ""
    var weatherWindSpeed: String = ""
    var menuCall: Bool = false
    
    //    MARK: - Date stuctures
    var incidentStructure: IncidentData!
    var journalStructure: JournalData!
    var startShiftStructure: StartShiftData!
    var updateShiftStructure: UpdateShiftData!
    var endShiftStructure: EndShiftData!
    var timeCount: Int = 0
    var fjUserTimeCD:UserTime!
    
    //    MARK - BOOLEANS
    var formModalCalled: Bool = false
    var incidentModalCalled: Bool = false
    var personalModalCalled: Bool = false
    var alertUp:Bool = false
    var shiftExists: Bool = false
    var startEndShift: Bool = false
    
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    let device = (UIApplication.shared.delegate as? AppDelegate)?.device
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var myShift: MenuItems = .journal
    var theCompactShift: MenuItems = .journal
    var fireJournalUser:FireJournalUserOnboard!
    var fju:FireJournalUser!
    var fetched:Array<Any>!
    var fireStationLocation: CLLocation!
    var fireStationAddress: String = ""
    var cellCount: Int = 7
    
    
    let vcLaunch = VCLaunch()
    var launchNC: LaunchNotifications!
    var agreementAccepted:Bool = false
    var entity:String = ""
    var attribute:String = ""
    var sortAttribute:String = ""
    var todaysIncidents: TodaysIncidentsForDashboard!
    var todaysCount: TodaysIncidentCount!
    var allOfTodaysIncidents = [TodayIncident]()
    var incidentTotalCounts: IncidentMonthTotalsForDashboard!
    var todayShiftForDashboard: TodayShiftForDashboard!
    var todayShiftData: TodayShiftData!
    var updateShiftData: UpdateShiftDashbaordData!
    var updateShiftForDashboard: TheUpdateShiftForDashboard!
    var endShiftData: TodayEndShiftData!
    var endShiftForDashboard: EndShiftForDashboard!
    let calendar = Calendar.current
    var thisYear: Int!
    var totalsForYears = [ Int : [(Int,[Int])] ]()
    var theYears = [Int]()
    var primaryMonth = 0
    var primaryMonthCount = [(Int,Int)]()
    var monthsTotalWithYearCounts =  [EachMonthsTotal]()
    var startEndGuid = ""
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    var startEnd:StartEnd!
    var firstRun: Bool = true
    var child: SpinnerViewController!
    var childAdded: Bool = false
    var incidentCounted: Bool = false
    var incidentsTotaled: Int = 0
    var versionControlled: Bool = false
    var todayCountsEmpty: Bool = false
    var locationMovedToLocationsSC: Bool = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    fileprivate func presentAgreement() {
        let userItemsLoad = LoadUserItems.init(context)
        userItemsLoad.runTheOperations()
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let openingScrollVC = storyBoard.instantiateViewController(withIdentifier: "OpenModalScrollVC") as! OpenModalScrollVC
        openingScrollVC.delegate = self
        openingScrollVC.fromMaster = false
        openingScrollVC.transitioningDelegate = slideInTransitioningDelgate
        openingScrollVC.modalPresentationStyle = .custom
        self.present(openingScrollVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout.widthOfParent = detailCollectionView.frame.size.width
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        agreementAccepted = userDefaults.bool(forKey: FJkUserAgreementAgreed)
        if !agreementAccepted {
            myShift = .endShift
        }
        
        nc.addObserver(self,selector: #selector(detectVisible(ns:)),name:NSNotification.Name(rawValue: FJkSPVDISPLAYMODEDIDCHANGE), object:nil)
        
        nc.addObserver(self,selector: #selector(orientationChanged(ns:)),name:NSNotification.Name(rawValue: FJkORIENTATIONDIDCHANGE), object:nil)
        
        
        
        registerNotifications()
        
        switch menuItem {
        case .settings:
            menuCall = true
            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
            let settingsTVC  = storyboard.instantiateViewController(identifier: "SettingsTVC") as! SettingsTVC
            settingsTVC.delegate = self
            settingsTVC.title = ""
            let navigator = UINavigationController.init(rootViewController: settingsTVC)
            navigator.navigationItem.leftItemsSupplementBackButton = true
            navigator.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            self.splitViewController?.showDetailViewController(navigator, sender:self)
        case .myShift:
            menuCall = false
            layout.delegate = self
            detailCollectionView.collectionViewLayout = layout
            detailCollectionView.dataSource = self
            detailCollectionView.delegate = self
            detailCollectionView.backgroundColor = .clear
            detailCollectionView.contentInset = UIEdgeInsets(top: 23, left: 16, bottom: 10, right: 16)
            self.title = ""
            registerTheCells()
        default: break
        }
        
        if agreementAccepted {
            buildifAgreementAccepted()
            versionControlled = userDefaults.bool(forKey: FJkVERSIONCONTROL)
            
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:(FJkCALLVERSIONCONTROL)), object: nil, userInfo: nil)
            }
        } else {
            presentAgreement()
            userDefaults.set(false, forKey: FJkDONTSHOWSTARTSHIFTALERTAGAIN)
            userDefaults.synchronize()
        }
        
        self.nc.post(name:Notification.Name(rawValue:(FJkChangeTheLocationsTOLOCATIONSSC)), object: nil, userInfo: nil)
        
        let location = userDefaults.bool(forKey: FJkLOCATION)
        
        weatherTemperature = userDefaults.string(forKey: FJkTEMPERATURE) ?? ""
        weatherHumidity = userDefaults.string(forKey:FJkHUMIDITY) ?? ""
        weatherWindSpeed = userDefaults.string(forKey:FJkWINDSPEEDDIRECTION) ?? ""
        
        if location {
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:FJkOPENWEATHER_UPDATENow),object: nil)
            }
        }
        
        if formModalCalled {
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:(FJkLOADFORMMODAL)), object: nil, userInfo: nil)
            }
        }
        
        if personalModalCalled {
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:(FJkLOADPERSONALMODAL)), object: nil, userInfo: nil)
            }
        }
        
        if incidentModalCalled {
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:(FJkFireJournalNeedsFirstIncident)), object: nil, userInfo: nil)
            }
            
        }
        
    }
    
    @objc func checkOnTheVersion(ns: Notification) {
        if agreementAccepted {
            if Device.IS_IPAD {
                versionControlled = userDefaults.bool(forKey: FJkVERSIONCONTROL)
                if versionControlled {} else {
                    nc.addObserver(self,selector: #selector(versionControlYouShouldChange(ns:)),name:NSNotification.Name(rawValue: FJkVERSIONCONTROL), object:nil)
                    userDefaults.set(true, forKey: FJkVERSIONCONTROL)
                    userDefaults.synchronize()
                }
            }
        }
    }
    
    @objc func changeTheLocationsToSC(ns: Notification) {
        
        if agreementAccepted {
            if Device.IS_IPAD {
                locationMovedToLocationsSC = userDefaults.bool(forKey: FJkMoveTheLocationsToLocationsSC)
                
                if !locationMovedToLocationsSC {
                    ///notify cloudkitmanager need to run operation
                    ///FJkNEXTLOCATIONUPDATE
                    DispatchQueue.main.async {
                        self.nc.post(name:Notification.Name(rawValue:(FJkNEXTLOCATIONUPDATE)), object: nil, userInfo: ["MenuItems": MenuItems.arcForm])
                    }
                    ///listen for completion remove spinner
                    nc.addObserver(self,selector: #selector(removeSpinnerUpdate(ns:)),name:NSNotification.Name(rawValue: FJkLocationsAllUpdatedToSC), object:nil)
                    ///spinner alert
                    updateLocationDataToSC()
                }
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        if todayCountsEmpty {
            self.buildTheData()
            self.todayCountsEmpty.toggle()
        }
    }
    
    @objc func loadTheFormModal(ns: Notification) {
        myShift = .forms
        presentModal(menuType: myShift, title: "Choose a Form Type")
    }
    
    func buildifAgreementAccepted() {
        let incidentTotal = IncidentTotal.init(theDate: Date())
        incidentsTotaled = incidentTotal.getIncidentCount()
        if incidentsTotaled > 0 {
            incidentCounted = true
        } else {
            incidentCounted = false
        }
        if let guid = userDefaults.string(forKey: FJkUSERTIMEGUID) {
            if guid != "" {
                theUserTimeCount(entity: "UserTime", guid: guid)
            } else {
                theUserTimeLast(entity: "UserTime")
            }
        }
        if self.fjUserTimeCD == nil && incidentCounted {
            shift = .start
            myShift = .startShift
            let theStartDate = Date()
            startEnd = StartEnd.init(date: theStartDate)
            let fjuUserTime = UserTime.init(entity: NSEntityDescription.entity(forEntityName: "UserTime", in: context)!, insertInto: context)
            fjuUserTime.userTimeGuid = startEnd.sTuserTimeGuid
            fjuUserTime.userStartShiftTime = theStartDate
            let cal = NSCalendar.current
            let dayOfYear = cal.ordinality(of: .day, in: .year, for: theStartDate)
            fjuUserTime.userTimeDayOfYear = "\(dayOfYear ?? 0)"
            userDefaults.set(startEnd.sTuserTimeGuid, forKey: FJkUSERTIMEGUID)
            fjUserTimeCD = fjuUserTime
            userDefaults.synchronize()
            saveToCD()
            self.shift = .end
            self.userDefaults.set(2, forKey: FJkSTARTUPDATEENDSHIFT)
            self.userDefaults.set(false, forKey: FJkSTARTSHIFTENDSHIFTBOOL)
            
            self.userDefaults.synchronize()
            buildTheData()
        } else {
            buildTheData()
        }
    }
    
    private func buildTheData() {
        if firstRun {
            fdResourcesPointOfTruthFirstTime()
            firstRun = false
        }
        if incidentCounted {
            todaysIncidents = TodaysIncidentsForDashboard.init(userTime: fjUserTimeCD)
            todaysCount = todaysIncidents.buildTodaysIncidentCount()
            if todaysCount.totalCount == "0" {
                todaysCount = todaysIncidents.getTheLastIncidentDate()
            }
            allOfTodaysIncidents = todaysIncidents.buildTodaysIncidents()
            let componentYear = calendar.dateComponents([.year], from: Date())
            thisYear = componentYear.year!
            incidentTotalCounts = IncidentMonthTotalsForDashboard.init(theYear:thisYear)
            theYears = incidentTotalCounts.getTheYearArray()
            totalsForYears = incidentTotalCounts.getTheIncidents()
            primaryMonth = incidentTotalCounts.getPrimaryMonth()
            primaryMonthCount = incidentTotalCounts.getPrimaryMonthCounts()
            monthsTotalWithYearCounts = incidentTotalCounts.getTheYearBuilt()
            getTheUser()
            
            /// location saved as Data with secureCodeing
            if let location: NSObject = fju.fjuLocationSC {
                guard let  archivedData = location as? Data else { return }
                do {
                    guard let unarchivedLocation = try NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self , from: archivedData) else { return }
                    fireStationLocation = unarchivedLocation
                    userDefaults.set(true, forKey: FJkLOCATION)
                    userDefaults.synchronize()
                } catch {
                    print("Unarchiver failed on arcLocation")
                }
            }
            if let streetNum = fju.fireStationStreetNumber {
                fireStationAddress = streetNum
            }
            if let streetName = fju.fireStationStreetName {
                fireStationAddress = "\(fireStationAddress) \(streetName)"
            }
            if let city = fju.fireStationCity {
                fireStationAddress = "\(fireStationAddress) \(city)"
            }
            if let state = fju.fireStationState {
                fireStationAddress = "\(fireStationAddress) \(state)"
            }
            if let zip = fju.fireStationZipCode {
                fireStationAddress = "\(fireStationAddress) \(zip)"
            }
            
            todayShiftForDashboard = TodayShiftForDashboard.init(thisDay: Date())
            todayShiftData = todayShiftForDashboard.buildShiftForDashboard()
            updateShiftForDashboard = TheUpdateShiftForDashboard.init(thisDay: Date())
            updateShiftData = updateShiftForDashboard.buildShiftForDashboard()
            endShiftForDashboard = EndShiftForDashboard.init(theDate: Date())
            endShiftData = endShiftForDashboard.buildTheEndShift()
            
            
            weatherTemperature = userDefaults.string(forKey: FJkTEMPERATURE) ?? ""
            weatherHumidity = userDefaults.string(forKey:FJkHUMIDITY) ?? ""
            weatherWindSpeed = userDefaults.string(forKey:FJkWINDSPEEDDIRECTION) ?? ""
            
            if weatherTemperature == "" {
                DispatchQueue.main.async {
                    self.nc.post(name:Notification.Name(rawValue:FJkOPENWEATHER_UPDATENow),object: nil)
                }
            }
        }
        
        if firstRun {
            self.processCollectionViewAfterDownload()
        }
        
    }
    
    @objc func versionControlYouShouldChange(ns: Notification ) {
        if let userInfo = ns.userInfo as! [String: Any]?
        {
            let version = userInfo["versionControl"] as? Bool ?? false
            if version {
                if !alertUp {
                    let title: InfoBodyText = .versionChangeSubject
                    let message: InfoBodyText = .versionChange
                    let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
                    let okAction = UIAlertAction.init(title: "Get It", style: .default, handler: {_ in
                        self.alertUp = false
                        self.openStoreProductWithiTunesItemIdentifier(identifier: "587192813")
                    })
                    alert.addAction(okAction)
                    let dismissAction = UIAlertAction.init(title: "Dismiss", style: .default, handler: {_ in
                        self.alertUp = false
                    })
                    alert.addAction(dismissAction)
                    alertUp = true
                    self.present(alert, animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    func openStoreProductWithiTunesItemIdentifier(identifier: String) {
        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self
        let parameters = [ SKStoreProductParameterITunesItemIdentifier : identifier]
        storeViewController.loadProduct(withParameters: parameters) { [weak self] (loaded, error) -> Void in
            if loaded {
                // Parent class of self is UIViewContorller
                self?.present(storeViewController, animated: true, completion: nil)
            }
        }
    }
    
    //    587192813
    
    @objc func orientationChanged(ns: Notification) {
        if let userInfo = ns.userInfo as! [String: Any]? {
            orientation = userInfo["orientation"] as? Int ?? 0
        }
    }
    
    @objc func detectVisible(ns: Notification) {
        
        if let userInfo = ns.userInfo as! [String: Any]? {
            visible = userInfo["visible"] as? Bool ?? false
            if visible {
                columns = 1
                layout.numberOfColumns = 1
            } else {
                if orientation == 3  {
                    columns = 1
                    layout.numberOfColumns = 1
                } else {
                    columns = 1
                    layout.numberOfColumns = 1
                }
            }
            print("this is the columns \(columns)")
            frame = userInfo["frame"] as? CGRect ?? detailCollectionView.bounds
            if self.isViewLoaded {
                detailCollectionView.bounds = frame
                layout.contentWidth = frame.size.width
                layout.numberOfColumns = columns
                layout.cache.removeAll()
                detailCollectionView.setCollectionViewLayout(layout, animated: false)
                detailCollectionView.reloadData()
                detailCollectionView.performBatchUpdates({
                    detailCollectionView.collectionViewLayout.invalidateLayout()
                } , completion: nil )
            }
        }
    }
    
    @objc func compactOrRegular(ns: Notification) {
        if let userInfo = ns.userInfo as! [String: Any]? {
            compact = userInfo["compact"] as? SizeTrait ?? .regular
            frame = userInfo["frame"] as? CGRect ?? detailCollectionView.bounds
            columns = userInfo["columns"] as? Int ?? 0
            switch compact {
            case .compact:
                print("compact")
                if self.isViewLoaded {
                    detailCollectionView.bounds = frame
                    layout.contentWidth = frame.size.width
                    layout.numberOfColumns = columns
                    layout.cache.removeAll()
                    detailCollectionView.setCollectionViewLayout(layout, animated: false)
                    detailCollectionView.reloadData()
                    detailCollectionView.performBatchUpdates({
                        detailCollectionView.collectionViewLayout.invalidateLayout()
                    } , completion: nil )
                }
            case .regular:
                print("regular")
                if self.isViewLoaded {
                    detailCollectionView.bounds = frame
                    layout.contentWidth = frame.size.width
                    layout.numberOfColumns = columns
                    layout.cache.removeAll()
                    detailCollectionView.setCollectionViewLayout(layout, animated: false)
                    detailCollectionView.reloadData()
                    detailCollectionView.performBatchUpdates({
                        detailCollectionView.collectionViewLayout.invalidateLayout()
                    } , completion: nil )
                }
                
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if todaysCount == nil {
            buildTheData()
        }
        if columns == 0 {
            if Device.IS_IPAD {
                if orientation == nil {
                    orientation = 0
                }
                switch orientation {
                case 1, 2, 0:
                    if visible {
                        columns = 1
                    } else {
                        //                            columns = 2
                        columns = 1
                    }
                case 3, 4:
                    //                        columns = 2
                    columns = 1
                default: break
                }
            } else {
                columns = 1
            }
        }
        let inset: CGFloat = 32.0
        let cvWidth: CGFloat = detailCollectionView.bounds.width
        let contentWidth = cvWidth - inset
        layout.contentWidth = contentWidth
        layout.visible = visible
        layout.numberOfColumns = columns
        layout.cache.removeAll()
        detailCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func getDisplayMode() -> Int {
        return (self.splitViewController?.displayMode)!.rawValue
    }
    
    //    private func getOrientation() ->
    
    fileprivate func getOrientation(_ orientation: inout Int?) {
        if UIDevice.current.orientation.isPortrait {
            layout.orientation = 1
            orientation = 1
        } else if UIDevice.current.orientation.isLandscape {
            orientation = 3
        } else if UIDevice.current.orientation.isFlat {
            if orientation == nil {
                orientation = 1
            } else {
                print("what orientation")
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        display = (self.splitViewController?.displayMode)!.rawValue
        //            if let layout = detailCollectionView?.collectionViewLayout as? PinterestLayout {
        layout.contentWidth = size.width
        layout.visible = visible
        layout.numberOfColumns = columns
        
        getOrientation(&orientation)
        layout.cache.removeAll()
        //            }
        detailCollectionView.collectionViewLayout.invalidateLayout()
        
    }
    
    
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
//    MARK: -BUILD THE COLLECTION VIEW-
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isViewLoaded {
            if agreementAccepted && incidentCounted {
                cellCount = 6
                return 6
            } else {
                cellCount = 2
                return 2
            }
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let row = indexPath.row
        switch  row {
        case 0:
            return configureNewShifts(collectionView, indexPath)
        case 1:
            return configureNewFormsCell(collectionView, indexPath)
        case 2:
            return configureShifts(collectionView, indexPath)
        case 3:
            return configureTodaysIncidentCell(collectionView, indexPath)
        case 4:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: incidentMonthTotalsCVCellIdentifer, for: indexPath) as! IncidentMonthTotalsCVCell
            if agreementAccepted {
                cell.primaryYear = thisYear
                cell.years = theYears
                cell.yearOfCounts = totalsForYears
                cell.primaryMonth = primaryMonth
                cell.thePrimaryMonthCounts = primaryMonthCount
                cell.monthsTotalWithYearCounts = monthsTotalWithYearCounts
            }
            return cell
        case 5:
            return configureWeather(collectionView, indexPath)
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: weatherCVCellIdentifier, for: indexPath as IndexPath) as! WeatherCVCell
            return cell
        }
    }
    
}
