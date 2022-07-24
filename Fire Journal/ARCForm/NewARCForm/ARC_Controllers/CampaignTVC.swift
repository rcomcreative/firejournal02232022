//
//  CampaignTVC.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 8/25/20.
//  Copyright © 2020 com.purecommand.FireJournal. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol CampaignDelegate: AnyObject {
    func theCampaignHasBegun()
}

class CampaignTVC: UITableViewController {
    
    //    MARK: -Properties-
    weak var delegate: CampaignDelegate? = nil
    var masterForm: Bool = false
    var additionalForm: Bool = false
    var choiceMade: Bool = false
    var campaignName: String = ""
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let cloud = (UIApplication.shared.delegate as! AppDelegate).cloud
    var alertUp: Bool = false
    var theForm: ARCrossForm!
    var theResidence: Residence!
    var theLocalPartners: LocalPartners!
    var theNationalPartners: NationalPartners!
    
    let cellsForCampaign = NewARC_CampaignCells()
    var newTheCells = [ARC_CellStorage]()
    let dateFormatter = DateFormatter()
    let userDefaults = UserDefaults.standard
    let nc = NotificationCenter.default
    var fetched:Array<Any>!
    var objectID:NSManagedObjectID!
    var jObjectID: NSManagedObjectID!
    var networkAlert: NetworkAlert!
    var journal: Journal!
    var firejournaluser: FireJournalUser!
    var masterJournal: Journal!
    var masterJournalAvailable: Bool = false
    
    //    MARK: -NSFETCHRESULTS-
    var fetchedResultsController: NSFetchedResultsController<ARCrossForm>? = nil
    var _fetchedResultsController: NSFetchedResultsController<ARCrossForm> {
        if fetchedResultsController != nil {
            fetchedResultsController?.delegate = self
            return fetchedResultsController!
        }
        return fetchedResultsController!
    }
    
    var fetchedObjects: [ARCrossForm] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cloud.context = context
        if Device.IS_IPHONE {
            let frame = self.view.frame
            let height = frame.height - 44
            self.view.frame = CGRect(x: 0, y: 44, width: frame.width, height: height)
            self.tableView = UITableView.init(frame: self.view.frame, style: .grouped)
        }
        networkAlert = NetworkAlert.init(name: "Internet Activity")
        nc.addObserver(self, selector:#selector(noConnectionCalled(ns:)),name:NSNotification.Name(rawValue: kHAVENO_CONNECTIONALERT), object: nil)
        nc.addObserver(self, selector:#selector(alertDown(ns:)),name:NSNotification.Name(rawValue: FJkAlertISReleased), object: nil)
        self.title = "Campaign"
        registerTheCells()
        newTheCells = cellsForCampaign.cells
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
    
    // MARK: - Table view data source
    // MARK: - Table view data source// MARK: - Table View
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerV = Bundle.main.loadNibNamed("MapHeaderV", owner: self, options: nil)?.first as! MapHeaderV
        headerV.delegate = self
        headerV.addNewB.isHidden = true
        headerV.addNewB.isEnabled = false
        headerV.addNewB.alpha = 0.0
        return headerV
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return newTheCells.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let newCell = newTheCells[indexPath.row]
        let tag = newCell.tag
        switch tag {
        case 0:
            return 480
        case 1:
            if !choiceMade {
                return 350
            } else {
                return 0
            }
        case 2:
            if masterForm {
                return 350
            } else {
                return 0
            }
        case 3:
            if additionalForm {
                return 56
            } else {
                return 0
            }
        case 4:
            if additionalForm {
                if !fetchedObjects.isEmpty {
                    let height = 107
                    let float = CGFloat(height)
                    return float
                } else {
                    return 0
                }
            } else {
                return 0
            }
        default:
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newCell = newTheCells[indexPath.row]
        let tag = newCell.tag
        switch tag {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARC_ParagraphCell", for: indexPath) as!  ARC_ParagraphCell
            cell.tag = tag
            let paragraphsCell = configureARC_ParagraphCell(cell, at: indexPath, tag: tag)
            return paragraphsCell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARC_TwoButtonCell", for: indexPath) as!  ARC_TwoButtonCell
            cell.tag = tag
            let twoBCell = configureARC_TwoButtonCell(cell, at: indexPath, tag: tag)
            return twoBCell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARC_CampaignNameCell", for: indexPath) as!  ARC_CampaignNameCell
            cell.tag = tag
            let nameCell = configureARC_CampaignNameCell(cell, at: indexPath, tag: tag )
            return nameCell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARC_ChooseACampaignCell", for: indexPath) as!  ARC_ChooseACampaignCell
            cell.tag = tag
            let chooseCell = configureARC_ChooseACampaignCell(cell, at: indexPath, tag: tag)
            return chooseCell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARC_CampaignCell", for: indexPath) as!  ARC_CampaignCell
            cell.tag = tag
            let campCell = configureARC_CampaignCell(cell, at: indexPath, tag: tag, object: newCell as! ARCCampaign4 )
            return campCell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newCell = newTheCells[indexPath.row]
        let tag = newCell.tag
        switch tag {
        case 0, 1, 2, 3: break
        case 4:
            let cellSelected = tableView.cellForRow(at: indexPath) as! ARC_CampaignCell
            var address = ""
            var campaignName = ""
            var masterGuid = ""
            if cellSelected.campaignAddress != ""{
                address = cellSelected.campaignAddress
            }
            if cellSelected.campaignName != "" {
                campaignName = cellSelected.campaignName
            }
            if cellSelected.masterGuid != "" {
                masterGuid = cellSelected.masterGuid
            }
            if let object = cellSelected.object {
                objectID = object
            }
            
            buildAdditionalFormFromMaster(object: objectID, address: address, theCampaignName: campaignName, masterGuid: masterGuid )
        default: break
        }
    }
    
    
}

extension CampaignTVC: MapHeaderDelegate {
    
    func theBackButtonTapped() {
        self.dismiss(animated: true, completion: {
            self.delegate?.theCampaignHasBegun()
        })
    }
    
    func theNewFormTapped() {
        delegate?.theCampaignHasBegun()
    }
    
}
