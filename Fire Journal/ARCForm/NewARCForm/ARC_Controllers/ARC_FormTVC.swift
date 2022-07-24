//
//  ARC_FormTVC.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 8/25/20.
//  Copyright © 2020 com.purecommand.FireJournal. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import MapKit
import T1Autograph

protocol ARC_FormDelegate: AnyObject {
    func theFormHasCancelled()
    func theFormHasBeenSaved()
    func theFormWantsNewForm()
}

class ARC_FormTVC: UITableViewController, CLLocationManagerDelegate {
    
    //    MARK: -PROPERTIES-
    weak var delegate: ARC_FormDelegate? = nil
    
    let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    
    var campaign: Bool = true
    var theForm: ARCrossForm!
    let cellsForForm = NewCells()
    var newTheCells = [ARC_CellStorage]()
    var objectID: NSManagedObjectID? = nil
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let cloud = (UIApplication.shared.delegate as! AppDelegate).cloud
    var autograph: T1Autograph = T1Autograph()
    var signatureImage:UIImage!
    let userDefaults = UserDefaults.standard
    let nc = NotificationCenter.default
    var showMap: Bool = false
    var currentLocation: CLLocation!
    var locationManager:CLLocationManager!
    var datePicker1: Bool = false
    var datePicker2: Bool = false
    var datePicker3: Bool = false
    var installerSignature: Bool = false
    var residentSignature: Bool = false
    var acknowledgementHeight: CGFloat = 110
    var administrativeHeight: CGFloat = 110
    let dateFormatter = DateFormatter()
    var alertUp: Bool = false
    var signatureTag: Int = 0
    var signaturePath: IndexPath = IndexPath.init(item: 0, section: 0)
    var signatureBool: Bool = false
    
    var networkAlert: NetworkAlert!
    var installerAlert: InstallerAlert!
    let segue: String = "ARC_FormTVCToResidenceTypeSegue"
    var entityType: EntityType!
    
    var theResidence: Residence!
    var theLocalPartners: LocalPartners!
    var theNationalPartners: NationalPartners!
    var fireJournalUser: FireJournalUser!
    var journal: Journal!
    var path: IndexPath!
    var selected = [String]()    
    var fetched:Array<Any>!
    var jObjectID: NSManagedObjectID!
    var installerName: String = ""
    var userSkipped: Bool = true
    var saveButton: UIBarButtonItem!
    var backButton: UIBarButtonItem!
    var singleOrCampaign: Bool = false
    var pdfLink: String = ""
    var arcFormToCloud: ARCFormToCloud!
    var firstForm: Bool = false
    
    var fromMap: Bool = false
    var incidentType: IncidentTypes = .arcForm
    
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cloud.context = context
        
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        
        if Device.IS_IPHONE {
            let frame = self.view.frame
            let height = frame.height - 44
            self.view.frame = CGRect(x: 0, y: 44, width: frame.width, height: height)
            self.tableView = UITableView.init(frame: self.view.frame, style: .grouped)
        }
        
        if firstForm {
            
        }
        networkAlert = NetworkAlert.init(name: "Internet Activity")
        installerAlert = InstallerAlert.init(name: "Installer Name")
        nc.addObserver(self, selector:#selector(noConnectionCalled(ns:)),name:NSNotification.Name(rawValue: kHAVENO_CONNECTIONALERT), object: nil)
        nc.addObserver(self, selector:#selector(alertDown(ns:)),name:NSNotification.Name(rawValue: FJkAlertISReleased), object: nil)
        if Device.IS_IPHONE {
            self.title = "CRR Form"
        } else {
        self.title = "SMOKE ALARM INSTALLATION FORM"
        }
        if campaign {
            print("This form is part of a campaign")
        } else {
            print("This form is a single alarm installation")
        }
        
        //        MARK: -BUILD THE CELLS
        if objectID != nil {
            buildWithObject()
        } else {
            buildNewSingleForm()
        }
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
        nc.addObserver(self, selector: #selector(userName(ns:)), name:NSNotification.Name(rawValue: FJkDefaultInstallerName), object: nil)
        
        nc.addObserver(self, selector: #selector(deliverTheShare(ns:)), name:NSNotification.Name(rawValue: FJkLINKFROMCLOUDFORARCROSSFORMTOSHARE), object: nil)
        
        //        MARK: -NAVIGATION-
        if !fromMap {
            saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTheForm(_:)))
            saveButton.tintColor = UIColor.white
            navigationItem.rightBarButtonItem = saveButton
            backButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(removeTheForm(_:)))
            backButton.tintColor = UIColor.white
            navigationItem.leftBarButtonItem = backButton
            _ = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action:nil)
        }
    }
    
    @objc func userName(ns: Notification) {
        if let userInfo = ns.userInfo as! [String: Any]?
        {
            let name = userInfo["name"] as? String
            if name != ""  {
                theForm.installerName = name
                let path = IndexPath(item: 22, section: 0)
                tableView.scrollToRow(at: path, at: .middle, animated: true)
                tableView.reloadRows(at: [path], with: .automatic)
            }
            
        }
    }
    
    func checkForDefaultInstallerName() {
        userSkipped = userDefaults.bool(forKey: FJkUSERSKIPPEDSIGNIN)
        if !userSkipped {
            let nameSaved = userDefaults.bool(forKey: FJkDefualtInstallerNameSaved)
            if nameSaved {
                installerName = userDefaults.string(forKey: FJkDefaultInstallerName) ?? ""
                theForm.installerName = installerName
            } else {
                if !alertUp {
                    var name = ""
                    if fireJournalUser != nil {
                        let first = fireJournalUser.firstName ?? ""
                        let last = fireJournalUser.lastName ?? ""
                        name = "\(first) \(last)"
                        if name != "" {
                            let alert = installerAlert.fjARCPlusInstallerNameAlert(theName: name)
                            alertUp = true
                            self.present(alert, animated:  true, completion:  nil )
                        }
                    }
                }
            }
        }
    }
    
    //    MARK: -CONNECTION ISSUE-
    @objc func noConnectionCalled(ns: Notification) {
        if !alertUp {
            let alert = networkAlert.networkUnavailable()
            alertUp = true
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func alertDown(ns: Notification) {
        alertUp = false
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    // MARK: - Table view data source
    // MARK: - Table view data source// MARK: - Table View
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerV = Bundle.main.loadNibNamed("MapFormHeaderV", owner: self, options: nil)?.first as! MapFormHeaderV
        headerV.incidentType = incidentType
        headerV.delegate = self
        return headerV
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if fromMap {
            if  Device.IS_IPAD {
                return 44
            } else {
                return 0
            }
        } else {
            if firstForm {
                if  Device.IS_IPAD {
                    return 44
                }
            } else {
            return 0
            }
        }
        return 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newTheCells.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let cell = newTheCells[indexPath.row]
        let tag = cell.tag
        switch tag {
        case 0:
            if singleOrCampaign {
                return 100
            } else {
            return 150
            }
        //            FJkHeadCell
        case 1:
            if theForm.campaignResidenceType == nil || theForm.campaignResidenceType != "" {
                return 100
            } else {
                return 72
            }
        //            ARC_CampaignResidenceTypeCell
        case 2:
            return 350
        //        FJkAddressCell
        case 3:
            if showMap {
                return 500
            } else {
                return 0
            }
        //         FJkARC_MapViewCell
        case 4, 26, 36:
            return 60
        //         FJkARC_LabelCell
        case 5, 6, 7, 9, 27, 28, 29, 30, 31, 32, 33, 34:
            return 105
        //            FJkARC_StepperTFCell
        case 8, 10, 39:
            return 100
        //            FJkLabelExtendedCell
        case 11, 12, 13, 14, 15, 43:
            return 100
        //            FJkARC_QuestionWSwitchCell
        case 16, 35:
            return 230
        //            FJkTextViewCell
        case 17:
            if acknowledgementHeight == 110 {
                acknowledgementHeight = getTheAcknowledgementHeight()
            }
            return acknowledgementHeight
        //            FJkARC_LabelTextViewCell
        case 18, 22, 40, 41, 44, 45, 46:
            return 85
        //            FJkLabelTextFieldCell
        case 19:
            if residentSignature {
                return 200
            } else {
                return 44
            }
        //            FJkSignatureCell
        case 20, 24:
            return 90
        //            FJkDateTimeCell
        case 21:
            if(datePicker1) {
                return  132
            } else {
                return 0
            }
        //            FJkDatePickerCell
        case 23:
            if installerSignature {
                return 200
            } else {
                return 44
            }
        //            FJkSignatureCell
        case 25:
            if(datePicker2) {
                return  132
            } else {
                return 0
            }
        //            FJkDatePickerCell
        case 37:
            if theForm.nationalPartner == nil || theForm.nationalPartner != "" {
                return 100
            } else {
                return 72
            }
        //            ARC_CampaignResidenceTypeCell
        case 38:
            if theForm.localPartner == nil || theForm.localPartner != "" {
                return 100
            } else {
                return 72
            }
        //            ARC_CampaignResidenceTypeCell
        case 42:
            return 100
        //            FJkLabelExtendedCell
        case 47:
            if administrativeHeight == 110 {
                administrativeHeight = getTheAdministrativeHeight()
            }
            return administrativeHeight
        //            FJkARC_LabelTextViewCell
        case 48:
            return 100
        //            FJkLabelExtendedTextField
        case 49:
            return 110
        //            FJkARC_DateTimeAdminCell
        case 50:
            if(datePicker3) {
                return  132
            } else {
                return 0
            }
        //            FJkDatePickerCell
        case 51:
            return 110
        //            FJKARC_AdminSegmentCell
        default:
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        MARK: -newTheCells tag used to build form-
        let newCell = newTheCells[indexPath.row]
        let tag = newCell.tag
        switch tag {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARC_HeadCell", for: indexPath) as!  ARC_HeadCell
            cell.tag = tag
            let headCell = configureARC_HeadCell(cell, at: indexPath, tag: tag)
            return headCell
        case 1, 37, 38:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARC_CampaignResidenceTypeCell", for: indexPath) as!  ARC_CampaignResidenceTypeCell
            cell.tag = tag
            let residenceCell = configureARC_CampaignResidenceTypeCell( cell, indexPath: indexPath, tag: tag )
            return residenceCell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARC_AddressFieldsButtonsCell", for: indexPath) as!  ARC_AddressFieldsButtonsCell
            cell.tag = tag
            let addressCell = configureARC_AddressFieldsButtonsCell(cell, at: indexPath, tag: tag)
            return addressCell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARC_MapViewCell", for: indexPath) as!  ARC_MapViewCell
            cell.tag = tag
            let mapCell = configureARC_MapViewCell(cell, at: indexPath, tag: tag)
            return mapCell
        case 4, 26, 36:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARC_LabelCell", for: indexPath) as!  ARC_LabelCell
            cell.tag = tag
            let ARC_LabelCell = configureARC_LabelCell(cell, at: indexPath, tag: tag)
            return ARC_LabelCell
        case 5, 6, 7, 9, 27, 28, 29, 30, 31, 32, 33, 34:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARC_StepperTFCell", for: indexPath) as!  ARC_StepperTFCell
            cell.tag = tag
            print("tag - \(tag)\n")
            let stepperCell = configureARC_StepperTFCell(cell, at: indexPath, tag: tag)
            return stepperCell
        case 8, 10, 39:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARC_LabelExpandedCell", for: indexPath) as!  ARC_LabelExpandedCell
            cell.tag = tag
            let expandedARC_LabelCell = configureARC_LabelExpandedCell(cell, at: indexPath, tag: tag)
            return expandedARC_LabelCell
        case 11, 12, 13, 14,15, 43:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARC_QuestionWSwitch", for: indexPath) as!  ARC_QuestionWSwitch
            cell.tag = tag
            let switchCell = configureARC_QuestionWSwitch(cell, at: indexPath, tag: tag)
            return switchCell
        case 16, 35:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARC_TextViewCell", for: indexPath) as!  ARC_TextViewCell
            cell.tag = tag
            let textViewCell = configureARC_TextViewCell(cell, at: indexPath, tag: tag)
            return textViewCell
        case 17, 47:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARC_LabelTextViewCell", for: indexPath) as!  ARC_LabelTextViewCell
            cell.tag = tag
            let textViewCell = configureARC_LabelTextViewCell(cell, at: indexPath, tag: tag)
            return textViewCell
        case 18, 22, 40, 41, 44, 45, 46:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARC_arcLabelTextFieldCell", for: indexPath) as!  ARC_arcLabelTextFieldCell
            cell.tag = tag
            let textFieldCell = configureARC_arcLabelTextFieldCell(cell, at: indexPath, tag: tag)
            return textFieldCell
        case 19:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARC_SignatureCell", for: indexPath) as!  ARC_SignatureCell
            cell.tag = tag
            let signatureCell = configureARC_SignatureCell(cell, at: indexPath, tag: tag)
            return signatureCell
        case 20, 24:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARC_DateTimeCell", for: indexPath) as!  ARC_DateTimeCell
            cell.tag = tag
            let dateTimeCell = configureARC_DateTimeCell(cell, at: indexPath, tag: tag)
            return dateTimeCell
        case 21:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARC_DatePickerCell", for: indexPath) as!  ARC_DatePickerCell
            cell.tag = tag
            let datePickerCell = configureARC_DatePickerCell(cell, at: indexPath, tag: tag)
            return datePickerCell
        case 23:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARC_SignatureCell", for: indexPath) as!  ARC_SignatureCell
            cell.tag = tag
            let signatureCell = configureARC_SignatureCell(cell, at: indexPath, tag: tag)
            return signatureCell
        case 25:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARC_DatePickerCell", for: indexPath) as!  ARC_DatePickerCell
            cell.tag = tag
            let datePickerCell = configureARC_DatePickerCell(cell, at: indexPath, tag: tag)
            return datePickerCell
        case 42:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARC_LabelExpandedCell", for: indexPath) as!  ARC_LabelExpandedCell
            cell.tag = tag
            let expandedARC_LabelCell = configureARC_LabelExpandedCell(cell, at: indexPath, tag: tag)
            return expandedARC_LabelCell
        case 48:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARC_LabelExtendedTextFieldCell", for: indexPath) as!  ARC_LabelExtendedTextFieldCell
            cell.tag = tag
            let extendedARC_LabelCell = configureARC_LabelExtendedTextFieldCell(cell, at: indexPath, tag: tag)
            return extendedARC_LabelCell
        case 49:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARC_DateTimeAdminCell", for: indexPath) as!  ARC_DateTimeAdminCell
            cell.tag = tag
            let expandedARC_LabelCell = configureARC_DateTimeAdminCell(cell, at: indexPath, tag: tag)
            return expandedARC_LabelCell
        case 50:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARC_DatePickerCell", for: indexPath) as!  ARC_DatePickerCell
            cell.tag = tag
            let datePickerCell = configureARC_DatePickerCell(cell, at: indexPath, tag: tag)
            return datePickerCell
        case 51:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARC_AdminSegmentCell", for: indexPath) as!  ARC_AdminSegmentCell
            cell.tag = tag
            let segmentCell = configureARC_AdminSegmentCell(cell, at: indexPath, tag: tag)
            return segmentCell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        switch row {
        case 1:
            let cell = tableView.cellForRow(at: indexPath)! as! ARC_CampaignResidenceTypeCell
            entityType = cell.entityType
            path = indexPath
            presentModal(path: path, title: "Residence")
        case 37:
            let cell = tableView.cellForRow(at: indexPath)! as! ARC_CampaignResidenceTypeCell
            entityType = cell.entityType
            path = indexPath
            presentModal(path: path, title: "National Partners")
        case 38:
            let cell = tableView.cellForRow(at: indexPath)! as! ARC_CampaignResidenceTypeCell
            entityType = cell.entityType
            path = indexPath
            presentModal(path: path, title: "Local Partners")
        default: break
        }
        
    }
    
}
