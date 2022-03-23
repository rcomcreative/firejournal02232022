//
//  TypeTVC.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 9/15/20.
//  Copyright © 2020 com.purecommand.FJARCPlus. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol TypeTVCDelegate: AnyObject {
    func localPartnersSelected(selected: [String], type: EntityType, path: IndexPath )
    func typeLabelSelected(name: String, type: EntityType, path: IndexPath )
    func typeBackTapped()
}

class TypeTVC: UITableViewController {

    //    MARK: -PROPERTIES-
    weak var delegate: TypeTVCDelegate? = nil
    let nc = NotificationCenter.default
    var alertUp: Bool = false
    var networkAlert: NetworkAlert!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let cloud = (UIApplication.shared.delegate as! AppDelegate).cloud
    var fetchedObjects: Array<Any>!
    var selected = [String]()
    var rObjectID: NSManagedObjectID!
    var lpObjectID: NSManagedObjectID!
    var npObjectID: NSManagedObjectID!
    var fetched:Array<Any>!
    
    //    MARK: - presentation Delegate
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    
    let dateFormatter = DateFormatter()
    
    private var entityType: EntityType = .residence
    var theType: EntityType? {
        didSet {
            self.entityType = self.theType ?? .residence
        }
    }
    
    private var thePath = IndexPath(item: 0, section: 0)
    var path: IndexPath? {
        didSet {
            self.thePath = self.path ?? IndexPath(item: 0, section: 0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cloud.context = context
        registerTheCells()
        switch entityType {
        case .residence:
            getTheList(entity: "Residence", attribute: "residence" , type: .residence )
        case .localPartners:
            getTheList(entity: "LocalPartners", attribute: "localPartnerName" , type: .localPartners )
            tableView.allowsMultipleSelection = true
        case .nationalPartner:
            getTheList(entity: "NationalPartners", attribute: "partnerName" , type: .nationalPartner )
        }
        
        networkAlert = NetworkAlert.init(name: "Internet Activity")
        nc.addObserver(self, selector:#selector(noConnectionCalled(ns:)),name:NSNotification.Name(rawValue: kHAVENO_CONNECTIONALERT), object: nil)
        nc.addObserver(self, selector:#selector(alertDown(ns:)),name:NSNotification.Name(rawValue: FJkAlertISReleased), object: nil)
        
        
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
        let headerV = Bundle.main.loadNibNamed("CampaignTypeHeaderV", owner: self, options: nil)?.first as! CampaignTypeHeaderV
        headerV.delegate = self
        headerV.theType = entityType
        return headerV
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 130
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedObjects.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 60
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tag = indexPath.row
        var cell = tableView.dequeueReusableCell(withIdentifier: "ARC_LabelCell", for: indexPath) as!  ARC_LabelCell
        cell.tag = tag
        switch theType {
            case .residence:
                var residenceName: String = ""
                let residence = fetchedObjects[tag] as! Residence
                if let residenceN = residence.residence {
                    residenceName = residenceN
                }
                cell = configureARC_LabelCell( cell, indexPath: indexPath, tag: cell.tag , object: residence.objectID, type: EntityType.residence, name: residenceName)
            case .localPartners:
                var localPartnerName: String = ""
                let localPartners = fetchedObjects[tag] as! LocalPartners
                if let localpartnerN = localPartners.localPartnerName {
                    localPartnerName = localpartnerN
                }
                cell = configureARC_LabelCell( cell, indexPath: indexPath, tag: cell.tag , object: localPartners.objectID, type: EntityType.localPartners, name: localPartnerName)
                let result = selected.filter { $0 == localPartnerName }
                if !result.isEmpty {
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
            case .nationalPartner:
                var nationalPartnerName: String = ""
                let nationalPartners = fetchedObjects[tag] as! NationalPartners
                if let nationalpartnerN = nationalPartners.partnerName {
                    nationalPartnerName = nationalpartnerN
                }
                cell = configureARC_LabelCell( cell, indexPath: indexPath, tag: cell.tag , object: nationalPartners.objectID, type: EntityType.nationalPartner, name: nationalPartnerName)
            default: break
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! ARC_LabelCell
        let type = cell.entity
        switch type {
        case .localPartners:
            cell.isSelected = true
            let name = cell.label ?? ""
            let result = selected.filter { $0 == name}
            if result.isEmpty {
                selected.append(name)
            }
        case .residence:
            let name = cell.label ?? ""
            delegate?.typeLabelSelected(name: name, type: .residence, path: thePath )
        case .nationalPartner:
            let name = cell.label ?? ""
            delegate?.typeLabelSelected(name: name, type: .nationalPartner, path: thePath )
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if entityType == EntityType.localPartners {
             let cell = tableView.cellForRow(at: indexPath)! as! ARC_LabelCell
             cell.isSelected = false
            let name = cell.label
             selected = selected.filter { $0 != name }
        }
     }

}

extension TypeTVC: CampaignTypeHeaderVDelegate {
    
    func campaignTypeHeaderSaveTapped() {
        print(selected)
         if entityType == EntityType.localPartners {
            delegate?.localPartnersSelected(selected: selected, type: entityType, path: thePath )
        }
    }
    
    
    func campaignTypeHeaderBackTapped() {
        delegate?.typeBackTapped()
    }
    
    func campaignTypeHeaderAddTapped(residenceType: String, type: EntityType) {
        let creationDate = Date()
        switch type {
        case .residence:
            let residence = Residence(context: context)
            residence.residenceGuid = residence.guidForResidence(creationDate, dateFormatter: dateFormatter)
            residence.residence = residenceType
            let guid = residence.residenceGuid
            saveToCD( type: EntityType.residence, guid: guid! )
        case .nationalPartner:
            let nationalPartner = NationalPartners(context: context)
            nationalPartner.partnerGuid = nationalPartner.guidForNationalPartners(creationDate, dateFormatter: dateFormatter)
            nationalPartner.partnerName = residenceType
            nationalPartner.partnerCreationDate = creationDate
            let guid = nationalPartner.partnerGuid
            saveToCD( type: EntityType.nationalPartner, guid: guid! )
        case .localPartners:
            let localPartners = LocalPartners(context: context)
            localPartners.localPartnerGuid = localPartners.guidForLocalPartners(creationDate, dateFormatter: dateFormatter)
            localPartners.localPartnerName = residenceType
            localPartners.localPartnerCreationDate = creationDate
            let guid = localPartners.localPartnerGuid
            saveToCD( type: EntityType.localPartners, guid: guid! )
        }
        delegate?.typeLabelSelected(name: residenceType, type: entityType, path: thePath )
    }
    
    
}
