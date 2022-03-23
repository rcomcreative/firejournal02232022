//
//  ARCFormDetailTVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/1/18.
//  Copyright © 2018 PureCommandLLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import Contacts
import ContactsUI
import T1Autograph
import MapKit
import CoreLocation

protocol ARCFormDetailTVCDelegate:class {
    func arcFormCancelled()
}

class ARCFormDetailTVC: UITableViewController  {
    
    var myShift:MenuItems = .arcForm
    weak var delegate:ARCFormDetailTVCDelegate? = nil
    var titleName:String = ""
    var aForm: Form!
    var cells = [CellBody]()
    var residentSigImage:UIImage?
    var installerSigImage:UIImage?
    var objectID: NSManagedObjectID? = nil
    var arcForm: ARCrossForm!
    var searchARCForm: ARCrossForm!
    var locationManager:CLLocationManager!
    var fju:FireJournalUser!
    var city:String = ""
    var state:String = ""
    var streetNum:String = ""
    var streetName:String = ""
    var zip:String = ""
    var showPicker:Bool = false
    
    let nc = NotificationCenter.default
    //    TODO: -autograph needs to be reintroduced
    var autographR: T1Autograph = T1Autograph()
    var outputImageR:UIImage?
    var residentData:Data?
    //    TODO: -AUTOGRAPH needs to be reintroduced
    var autographI: T1Autograph = T1Autograph()
    var outputImageI:UIImage?
    var installerData:Data?
    var installerSig:Bool = false
    var residentSig:Bool = false
    var installerDate:Date = Date()
    var residentDate:Date = Date()
    var signatureType:String = ""
    var arcGuid:String = ""
    var campaignOnOff: Bool = true
    var campaignStartEndText: String = ""
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var id = NSManagedObjectID()
    var sizeTrait: SizeTrait = .regular
    var arc: ARCFormData!
    var alertUp: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ""
        
        if Device.IS_IPHONE {
            let listButton = UIBarButtonItem(title: "CRR", style: .plain, target: self, action: #selector(returnToList(_:)))
            navigationItem.leftBarButtonItem = listButton
             navigationItem.setLeftBarButtonItems([listButton], animated: true)
            navigationItem.leftItemsSupplementBackButton = false
        }
        
        aForm = Form.init()
        residentSigImage = nil
        installerSigImage = nil
        buildTheCells()
        registerTheCells()
        
        //      MARK: -navigation buttons-
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveARCForm(_:)))
        navigationItem.rightBarButtonItem = saveButton
        _ = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action:nil)
        
        
        
        if (Device.IS_IPHONE){
            self.navigationController?.navigationBar.backgroundColor = UIColor.white
            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.tintColor = UIColor.black
        } else {
            let backgroundImage = UIImage(named: "headerBar2")
            self.navigationController?.navigationBar.setBackgroundImage(backgroundImage, for: .default)
            
            self.navigationController?.navigationBar.tintColor = UIColor.white
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        }
        
        nc.addObserver(self, selector:#selector(newARCFormSaved), name: NSNotification.Name(rawValue: notificationKeyARCLAST), object: nil)
        nc.addObserver(self, selector:#selector(mapCalled), name:NSNotification.Name(rawValue: notificationKeyICS9), object: nil)
        nc.addObserver(self, selector:#selector(dashboardCalled), name:NSNotification.Name(rawValue: FJkDASHBOARD_FROMNFIRSBASIC1), object: nil)

        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
    }
        
    //    MARK: -RETURN TO THE LIST
        @objc private func returnToList(_ sender:Any) {
            closeItUp()
        }
        
        func closeItUp() {
            if  Device.IS_IPHONE {
                DispatchQueue.main.async {
                    self.nc.post(name:Notification.Name(rawValue:FJkARCFORMLISTCALLED),
                                 object: nil,
                                 userInfo: nil)
                }
            }
        }
        
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    //    MARK: -ERROR ALERT
    @objc func errorInDataBaseLaunch(ns:Notification) -> Void {
        var errorString: String = ""
        if let userInfo = ns.userInfo as! [String: Any]?
        {
            errorString = userInfo["errorMessage"] as? String ?? "There is no error to report."
        }
        let title:String = "Database Error"
        let alert = UIAlertController.init(title: title, message: errorString, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Thanks for the info", style: .default, handler: {_ in
            
        })
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func mapCalled(notification:Notification) -> Void {

    }
    @objc func dashboardCalled(notification:Notification) -> Void {
        
    }
    
    @objc func newARCFormSaved(notification:Notification) -> Void {
        if  let userInfo = notification.userInfo {
            objectID  = userInfo["objectID"] as? NSManagedObjectID
            arcGuid = (userInfo["arcGuid"] as? String)!
        }
        cells.removeAll()
        buildTheCells()        
    }
    
    @objc func saveARCForm(_ sender:Any) {
        saveToCD()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cells.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(indexPath.row == 0) {
            cell.contentView.backgroundColor = UIColor(patternImage: UIImage(named:"header")!)
        }
        cell.selectionStyle = .none
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let type:CellBody = cells[indexPath.row]
        let cellType:CellType = type.type["type"]!
        switch cellType {
        case .header:
            return 100
        case .textField:
            return 71
        case .campaignSwitch:
            return 100
        case .textArea:
            return 245
        case .textLocation:
            return 220
        case .datePicker:
            if(showPicker) {
                return  215
                
            } else {
                return 0
            }
        case .signature:
            return 300
        case .label:
            return 60
        case .questionSwitch:
            return 88
        case .textFieldWDate:
            return 88
        case .stepper:
            return 88
        default:
            return 0
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type:CellBody = cells[indexPath.row]
        let cellType:CellType = type.type["type"]!
        let section:Sections = type.cellAttributes["value1"]!
        let value1:String = type.fType["fValue1"]!;
        var value2:String = type.fType["fValue2"] ?? "";
        var value5:String = type.fType["fValue5"] ?? "";
        if let test2:String = type.fType["fValue2"] {
            value2 = test2
        }
        var value3 = ""
        if let test3:String = type.fType["fValue3"] {
            value3 = test3
        }
        var value4 = ""
        if let test4:String = type.fType["fValue4"] {
            value4 = test4
        }
        if let test5:String = type.fType["fValue5"] {
            value5 = test5
        }
        print("\(value2) \(value5)")
        var value6 = ""
        if let test6:String = type.fType["fValue6"] {
            value6 = test6
        }
//        var cellDate:Date = Date()
//        if let date1 = type.dType["Date"] {
//            cellDate = date1
//        }
//        var cellDate2:Date = Date()
//        if let date2 = type.dType["Date2"] {
//            cellDate2 = date2
//        }
        switch cellType {
        case .header:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FormHeaderCell", for: indexPath) as! FormHeaderCell
            cell.formTitleL.text = "CRR Smoke Alarm Inspection Form"
            if arc.campaignCount > 0 {
                let count = Int(exactly:arc.campaignCount)!
                cell.formNameL.text = "\(arc.campaignName) - \(count)"
            } else {
                cell.formNameL.text = arc.campaignName
            }
            return cell
        case .textField:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FormQuestionTFCell", for: indexPath) as! FormQuestionTFCell
            cell.delegate = self
            cell.questionL.text = value1
            cell.section = section
            cell.cellType = cellType
            cell.aForm = "ARCForm"
            cell.completed = arc.cComplete
            cell.answerTF.text = ""
                switch section {
                case .DescHazard:
                        cell.answerTF.text = arc.hazard
                case .NationalPartner:
                        cell.answerTF.text = arc.nationalPartner
                case .LocalPartner:
                        cell.answerTF.text = arc.localPartner
                case .Option1:
                        cell.answerTF.text = arc.option1
                case .Option2:
                        cell.answerTF.text = arc.option2
                case .ResidentCellNum:
                        cell.answerTF.text = arc.residentCellNum
                case .ResidentEmail:
                        cell.answerTF.text = arc.residentEmail
                case .ResidentOtherPhone:
                        cell.answerTF.text = arc.residentOtherPhone
                case .AdminName:
                        cell.answerTF.text = arc.adminName
                default: break
                }
            return cell
        case .stepper:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StepperTFCell", for: indexPath) as! StepperTFCell
            cell.indexPath = indexPath
            cell.delegate = self
            cell.questionL.text = value1
            cell.section = section
            cell.completed = arc.cComplete
            cell.answerTF.text = ""
                switch section {
                case .NumNewSA:
                    cell.answerTF.text = arc.numNewSA
                    print(arc.numNewSA)
                    cell.count = Double(arc.numNewSA)!
                case .NumBellShaker:
                        cell.answerTF.text = arc.numBedShaker
                        cell.count = Double(arc.numBedShaker)!
                case .NumBatteriesReplaced:
                        cell.answerTF.text = arc.numBatteries
                        cell.count = Double(arc.numBatteries)!
                case .IANumPeople:
                        cell.answerTF.text = arc.iaNumPeople
                        cell.count = Double(arc.iaNumPeople)!
                case .IA17Under:
                        cell.answerTF.text = arc.ia17Under
                        cell.count = Double(arc.ia17Under)!
                case .IA65Over:
                        cell.answerTF.text = arc.ia65Over
                        cell.count = Double(arc.ia65Over)!
                case .IADisability:
                        cell.answerTF.text = arc.iaDisability
                        cell.count = Double(arc.iaDisability)!
                case .IAVets:
                        cell.answerTF.text = arc.iaVets
                        cell.count = Double(arc.iaVets)!
                case .IAPrexistingSA:
                        cell.answerTF.text = arc.iaPrexistingSA
                        cell.count = Double(arc.iaPrexistingSA)!
                case .IAWorkingSA:
                        cell.answerTF.text = arc.iaWorkingSA
                        cell.count = Double(arc.iaWorkingSA)!
                default: break
                }
            return cell
        case .questionSwitch:
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionWSwitch", for: indexPath) as! QuestionWSwitch
            cell.questionL.text = value1
            cell.delegate = self
            cell.section = section
            cell.completed = arc.cComplete
            if arc.cComplete {} else {
                cell.yesNoSwitch.isEnabled = false
            }
            if searchARCForm != nil {
                switch section {
                case .CreateFEP:
                    cell.switchState = arc.createFEPlan
                    cell.yesNoSwitch.setOn(arc.createFEPlan, animated: true)
                case .ReviewChecklist:
                    cell.switchState = arc.reviewFEPlan
                    cell.yesNoSwitch.setOn(arc.reviewFEPlan, animated: true)
                case .LocalHazard:
                    cell.switchState = arc.localHazard
                    cell.yesNoSwitch.setOn(arc.localHazard, animated: true)
                case .ContactInfo:
                    cell.switchState = arc.residentContactInfo
                    cell.yesNoSwitch.setOn(arc.residentContactInfo, animated: true)
                default:
                    print("")
                }
            }
            return cell
        case .campaignSwitch:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CampaignCell", for: indexPath) as! CampaignCell
            cell.delegate = self
            let test = "No Campaign Name Set"
            cell.campaignTitleTF.text = ""
            if arc.campaignName != "" {
                cell.campaignTitleTF.text = arc.campaignName
                cell.campaignTitleTF.isEnabled = false;
                cell.campaignTitleTF.isUserInteractionEnabled = false;
            } else {
                cell.campaignTitleTF.placeholder = test
                cell.campaignTitleTF.isEnabled = true;
                cell.campaignTitleTF.isUserInteractionEnabled = true;
            }
            cell.campaignSwitch.isOn = arc.cComplete
            let text = arc.buildEndStartTimeText()
            cell.campaignStartEndTF.text = text
            return cell
        case .textArea:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARCTextViewCell", for: indexPath) as! ARCTextViewCell
            cell.completed = arc.cComplete
            if arc.cComplete {} else {
                cell.notesTV.isEditable = false
            }
            switch section {
            case .SignaturesTextArea:
                cell.titleL.text = "Declaration"
                cell.notesTV.text = FJkARCCrossDECLARATION
            default:
                cell.titleL.text = value1
                cell.notesTV.text = ""
                cell.notesTV.text = arc.iaNotes
                cell.section = section
                cell.delegate = self
                let color = UIColor.fjColor.lineGray.cgColor
                cell.notesTV.layer.borderColor = color
                cell.notesTV.layer.borderWidth = 2
                cell.notesTV.layer.cornerRadius = 8.0
                cell.notesTV.setNeedsDisplay()
            }
            return cell
        case .textLocation:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
            cell.delegate = self
            cell.cellType = cellType
            cell.section = section
            cell.streetAddressTF.text = ""
            cell.cityTF.text = ""
            cell.stateTF.text = ""
            cell.zipTF.text = ""
            cell.apartSuiteTF.text = ""
            cell.streetAddressTF.text = arc.arcLocationAddress
            cell.cityTF.text = arc.arcLocationCity
            cell.stateTF.text = arc.arcLocaitonState
            cell.zipTF.text = arc.arcLocationZip
            cell.apartSuiteTF.text = arc.arcLocationAptMobile
            cell.complete = arc.cComplete
            return cell
        case .datePicker:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FormDatePickerCell", for: indexPath) as! FormDatePickerCell
            cell.delegate = self
            cell.activity = ""
            cell.type = false
            if(showPicker) {
                let frame = CGRect(
                    origin: CGPoint(x: 0, y: 0),
                    size: CGSize(width: tableView.frame.size.width, height: 216)
                )
                cell.dateHolderV.frame = frame
            } else {
                let frame = CGRect(
                    origin: CGPoint(x: 0, y: 0),
                    size: CGSize(width: tableView.frame.size.width, height: 0)
                )
                cell.dateHolderV.frame = frame
            }
            return cell
        case .signature:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DoubleSignatureCell", for: indexPath) as! DoubleSignatureCell
            cell.delegate = self
            cell.complete = arc.cComplete
            cell.residentNameL.text = value1
            cell.residentNameTF.text = arc.residentName
            cell.residentDateL.text = value3
            cell.installerNameL.text = value4
            cell.installerNameTF.text = arc.installerName
            cell.installerDateL.text = value6
            cell.residentSigIV.image = nil
            cell.residentSigB.isHidden = false
            cell.residentSigB.alpha = 1.0
            cell.installerDateTF.text = ""
            cell.installerSigIV.image = nil
            cell.installerSigB.isHidden = false
            cell.installerSigB.alpha = 1.0
                if arc.residentSigned {
                    cell.residentDateTF.text = arc.residentSigDateString
                    cell.residentSigIV.image = outputImageR
                    cell.residentSigB.alpha = 0.0
                }
                if arc.installerSigend {
                    cell.installerDateTF.text = arc.installerDateString
                    cell.installerSigIV.image = outputImageI
                    cell.installerSigB.alpha = 0.0
                }
            return cell
        case .label:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SectionLabelCell", for: indexPath) as! SectionLabelCell
            cell.titleL.text = value1
            switch section {
            case .AdministrativeSection:
                cell.titleBackgroundV.backgroundColor = UIColor.fjColor.incidentRed
            default:
                cell.titleBackgroundV.backgroundColor = UIColor.fjColor.emsBlue
            }
            return cell
        case .textFieldWDate:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdminDateCell", for: indexPath) as! AdminDateCell
            cell.questionL.text = value1
            cell.delegate = self
            cell.mmL.text = arc.adminDateM
            cell.ddL.text = arc.adminDateD
            cell.yyyyL.text = arc.adminDateY
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            return cell
        }
    }
    
}
