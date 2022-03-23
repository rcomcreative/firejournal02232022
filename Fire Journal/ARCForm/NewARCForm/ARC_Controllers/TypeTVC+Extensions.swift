//
//  TypeTVC+Extensions.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 9/15/20.
//  Copyright © 2020 com.purecommand.FJARCPlus. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension TypeTVC {
 
    //    MARK: -REGISTER_THE_CELLS-
    func registerTheCells() {
            tableView.register(UINib(nibName: "ARC_LabelCell", bundle: nil), forCellReuseIdentifier: "ARC_LabelCell")
    }
    
    func configureARC_LabelCell(_ cell: ARC_LabelCell, indexPath: IndexPath, tag: Int, object: NSManagedObjectID, type: EntityType, name: String) ->ARC_LabelCell {
        cell.object = object
        cell.path = indexPath
        cell.label = name
        cell.entity = type
        return cell
    }
    
    func getTheList(entity: String, attribute: String , type: EntityType){
        
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
            var predicate = NSPredicate.init()
            predicate =  NSPredicate(format: "%K != %@" , attribute , "")
            let sectionSortDescriptor = NSSortDescriptor(key: attribute , ascending: true)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
            
            fetchRequest.predicate = predicate
            fetchRequest.fetchBatchSize = 1
            
            do {
                switch type {
                case .residence:
                    fetchedObjects = try context.fetch(fetchRequest) as! [Residence]
                case .localPartners:
                    fetchedObjects = try context.fetch(fetchRequest) as! [LocalPartners]
                case .nationalPartner:
                    fetchedObjects = try context.fetch(fetchRequest) as! [NationalPartners]
                }
            } catch let error as NSError {
                print("TypeTVC+extensions line 46 Fetch Error: \(error.localizedDescription)")
                if !self.alertUp {
                    let error: String = "Error: \(error.localizedDescription) Try again later."
                    self.errorAlert(errorMessage: error)
                }
            }
    }
    
    func errorAlert(errorMessage: String) {
        let alert = UIAlertController.init(title: "Error", message: errorMessage, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    //    MARK: -SAVE THE FORM-
    func saveToCD( type: EntityType, guid: String ) {
        do {
            try context.save()
            print("here we go with the save")
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"TypeTVC merge that"])
                print("letting the context know we are updating")
            }
            switch type {
            case .residence:
                getTheLastResidenceSaved(guid: guid)
                if let object = self.rObjectID {
                    DispatchQueue.main.async {
                        self.nc.post(name: Notification.Name(rawValue: FJkNEWRESIDENCEForCloudKit), object: nil, userInfo: ["objectID": object])
                    }
                }
            case .localPartners:
                getTheLastLocalPartnersSaved(guid: guid)
                if let object = self.lpObjectID {
                    DispatchQueue.main.async {
                        self.nc.post(name: Notification.Name(rawValue: FJkNEWLOCALPARTNERSForCloudKit), object: nil, userInfo: ["objectID": object])
                    }
                }
            case .nationalPartner:
                getTheLastNationalPartnersSaved(guid: guid)
                if let object = self.npObjectID {
                    DispatchQueue.main.async {
                        self.nc.post(name: Notification.Name(rawValue: FJkNEWNATIONALPARTNERSForCloudKit), object: nil, userInfo: ["objectID": object])
                    }
                }
            }
        } catch let error as NSError {
            print("TypeTVC+Extensions line 78 Fetch Error: \(error.localizedDescription)")
            if !self.alertUp {
                let error: String = "Error: \(error.localizedDescription) Try again later."
                self.errorAlert(errorMessage: error)
            }
        }
    }
    
    private func getTheLastResidenceSaved(guid: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Residence" )
        var predicate = NSPredicate.init()
        predicate =  NSPredicate(format: "%K == %@" , "residenceGuid" , guid)
        let sectionSortDescriptor = NSSortDescriptor(key: "residenceCreationDate", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        
        do {
            self.fetched = try context.fetch(fetchRequest) as! [Residence]
                let residence = self.fetched.last as! Residence
                self.rObjectID = residence.objectID
        } catch let error as NSError {
            print("TypeTVC line 102 Fetch Error: \(error.localizedDescription)")
            if !self.alertUp {
                let error: String = "Error: \(error.localizedDescription) Try again later."
                self.errorAlert(errorMessage: error)
            }
        }
    }
    
    
    private func getTheLastLocalPartnersSaved(guid: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LocalPartners" )
        var predicate = NSPredicate.init()
        predicate =  NSPredicate(format: "%K == %@" , "localPartnerGuid" , guid)
        let sectionSortDescriptor = NSSortDescriptor(key: "localPartnerCreationDate", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        
        do {
            self.fetched = try context.fetch(fetchRequest) as! [LocalPartners]
                let localPartners = self.fetched.last as! LocalPartners
                self.lpObjectID = localPartners.objectID
        } catch let error as NSError {
            print("TypeTVC line 127 Fetch Error: \(error.localizedDescription)")
            if !self.alertUp {
                let error: String = "Error: \(error.localizedDescription) Try again later."
                self.errorAlert(errorMessage: error)
            }
        }
    }
    
    
    private func getTheLastNationalPartnersSaved(guid: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NationalPartners" )
        var predicate = NSPredicate.init()
        predicate =  NSPredicate(format: "%K == %@" , "partnerGuid" , guid)
        let sectionSortDescriptor = NSSortDescriptor(key: "partnerCreationDate", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        
        do {
            self.fetched = try context.fetch(fetchRequest) as! [NationalPartners]
                let nationalPartners = self.fetched.last as! NationalPartners
                self.npObjectID = nationalPartners.objectID
        } catch let error as NSError {
            print("TypeTVC line 152 Fetch Error: \(error.localizedDescription)")
            if !self.alertUp {
                let error: String = "Error: \(error.localizedDescription) Try again later."
                self.errorAlert(errorMessage: error)
            }
        }
    }
    
}
