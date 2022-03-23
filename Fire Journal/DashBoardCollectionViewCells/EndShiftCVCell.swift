//
//  EndShiftCVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/5/19.
//  Copyright © 2019 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CoreLocation

class EndShiftCVCell: UICollectionViewCell, NSFetchedResultsControllerDelegate {
    
    //    MARK: -Objects-
    @IBOutlet weak var dashboardLastShiftGradient: UIImageView!
    @IBOutlet weak var lastShiftIconIV: UIImageView!
    @IBOutlet weak var lastShiftSubjectL: UILabel!
    @IBOutlet weak var endShiftDateSubjectL: UILabel!
    @IBOutlet weak var endShiftDateL: UILabel!
    @IBOutlet weak var endShiftTimeSubjectL: UILabel!
    @IBOutlet weak var endShiftTimeL: UILabel!
    @IBOutlet weak var endShiftIncidentSubjectL: UILabel!
    @IBOutlet weak var endShiftIncidentCountL: UILabel!
    @IBOutlet weak var shiftStatusL: UILabel!
    @IBOutlet weak var shiftStatusSubjectL: UILabel!
    
    
    //    MARK: -Properties
    var resources = [UserFDResource]()
    var fetchedResources: [UserFDResources]!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fdResources = [UserFDResources]()
    let userDefaults = UserDefaults.standard
    var fjUserTime:UserTime!
    let calendar = Calendar.current
    var firstDate: Date!
    var lastDate: Date!
    var months: YearOfMonths!
    var month: Int!
    var fire: Int!
    var ems: Int!
    var rescue: Int!
    private var theAgreement: Bool = false
    var agreementAccepted: Bool = false {
        didSet {
            self.theAgreement = self.agreementAccepted
        }
    }
    
    var endShiftData: TodayEndShiftData! {
        didSet {
            self.endShiftIncidentCountL.text = self.endShiftData.shiftIncidentCout ?? ""
            self.shiftStatusL.text = self.endShiftData.shiftStatusName ?? ""
            self.endShiftDateL.text = self.endShiftData.shiftEndDate ?? ""
            self.endShiftTimeL.text = self.endShiftData.shiftEndTime ?? ""
        }
    }
    
    private var fetchedResultsController: NSFetchedResultsController<Incident>? = nil
    var _fetchedResultsController: NSFetchedResultsController<Incident> {
        if fetchedResultsController != nil {
            fetchedResultsController?.delegate = self
            return fetchedResultsController!
        }
        return fetchedResultsController!
    }
    
    var fetchedObjects: [Incident] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    private func theUserTimeCount(entity: String, guid: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", "userTimeGuid", guid)
        fetchRequest.predicate = predicate
        do {
            let userFetched = try context.fetch(fetchRequest) as! [UserTime]
            if userFetched.isEmpty {
                
            } else {
                fjUserTime = userFetched.last!
            }
        } catch let error as NSError {
            print("UpdateShiftCVC THEUSERTIMECOUNT line 57 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    private func getTheDaysIncidents() {
        let date = fjUserTime.userStartShiftTime ?? Date()
        let componentMonth = calendar.dateComponents([.month], from: date )
        let m: Int = componentMonth.month ?? 0
        let componentYear = calendar.dateComponents([.year], from: date)
        let y: Int = componentYear.year ?? 0
        let componentDate = calendar.dateComponents([.day], from: date)
        let d: Int = componentDate.day ?? 0
        var mo = ""
        if m < 10 {
            mo = "0\(m)"
        } else {
            mo = String(m)
        }
        var day = ""
        if d < 10 {
            day = "0\(d)"
        } else {
            day = String(d)
        }
        let year = String(y)
        let firstDay = "\(year)-\(mo)-\(day)T0:0:00+0000"
        let lastDay = "\(year)-\(mo)-\(day)T0:11:59+0000"
        let dateFormatter = ISO8601DateFormatter()
        firstDate = dateFormatter.date(from:firstDay)
        lastDate = dateFormatter.date(from:lastDay)
        let fDate: NSDate = firstDate! as NSDate
        let lDate: NSDate = lastDate! as NSDate
        let fetchRequest: NSFetchRequest<Incident> = Incident.fetchRequest()
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@","incidentDateSearch","")
        var predicate1 = NSPredicate.init()
        predicate1 = NSPredicate(format: "%K >= %@ && %K <= %@", "incidentCreationDate", fDate ,"incidentCreationDate",lDate)
         let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, predicate1])
        fetchRequest.predicate = predicateCan
        fetchRequest.fetchBatchSize = 20
        
        let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        fetchedResultsController = aFetchedResultsController
        do {
            try fetchedResultsController?.performFetch()
        } catch let error as NSError {
            print("CrewModalDataTVC line 178 Fetch Error: \(error.localizedDescription)")
        }
        
        if fetchedObjects.isEmpty {
            month = 0
            fire = 0
            ems = 0
            rescue = 0
        } else {
            months.totalIncidents = fetchedObjects
            months.totalFireIncidents = fetchedObjects.filter { $0.situationIncidentImage == "Fire" }
            months.totalEMSIncidents  = fetchedObjects.filter { $0.situationIncidentImage == "EMS" }
            months.totalRescueIncidents = fetchedObjects.filter { $0.situationIncidentImage == "Rescue" }
            
            month = months.totalIncidents.count
            fire = months.totalFireIncidents.count
            ems = months.totalEMSIncidents.count
            rescue = months.totalRescueIncidents.count
        }
    }
    
    func buildTheStatus() {
       let utGuid = userDefaults.string(forKey: FJkUSERTIMEGUID)
        theUserTimeCount(entity: "UserTime", guid: utGuid ?? "")
       if utGuid == fjUserTime.userTimeGuid {
           if let time = fjUserTime.userUpdateShiftTime {
               let dateFormatter = DateFormatter()
               dateFormatter.dateFormat = "EEEE MMM dd,YYYY"
               let stringDate = dateFormatter.string(from: time )
               endShiftDateL.text = stringDate
               dateFormatter.dateFormat = "HH:mm"
               let stringTime = dateFormatter.string(from: time )
               endShiftTimeL.text = "\(stringTime) HRs"
           }
           }
       }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        months = YearOfMonths.init(theYear: 2020, lastYear: 2019)
        roundViews()
//        if theAgreement {
//            buildTheStatus()
//            getTheDaysIncidents()
//            endShiftIncidentCountL.text = String(month)
//        }
        }
        
        func roundViews() {
            self.contentView.layer.cornerRadius = 6
            self.contentView.clipsToBounds = true
            self.contentView.layer.borderColor = UIColor.systemRed.cgColor
            self.contentView.layer.borderWidth = 2
        }

}
