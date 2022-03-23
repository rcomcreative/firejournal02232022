//
//  YearOfMonths.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/10/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit

///
///    Collects the incident counts by the month for month totals, month Fire, month EMS, and month Rescue
/// - Parameter
///        - theYear: Int
///        - lastYear: Int)
///
/// - Note
///    collections of yearsOfMonths
///
struct YearOfMonths {
    
    //    MARK - JANUARY MONTH INCIDENT TYPES-
    var january = [Incident]()
    
    var januaryF: [Incident] {
        get {
            let fire = january.filter { $0.situationIncidentImage == "Fire" }
            return fire
        }
    }
    var januaryE: [Incident] {
        get {
            let ems = january.filter { $0.situationIncidentImage == "EMS" }
            return ems
        }
    }
    var januaryR: [Incident] {
        get {
            let ems = january.filter { $0.situationIncidentImage == "Rescue" }
            return ems
        }
    }
    
    /// Build February Incidents
    var february = [Incident]()
    var februaryF: [Incident] {
        get {
            let fire = february.filter { $0.situationIncidentImage == "Fire" }
            return fire
        }
    }
    var februaryE: [Incident] {
        get {
            let ems = february.filter { $0.situationIncidentImage == "EMS" }
            return ems
        }
    }
    var februaryR: [Incident] {
        get {
            let rescue = february.filter { $0.situationIncidentImage == "Rescue" }
            return rescue
        }
    }
    var march = [Incident]()
    var marchF: [Incident] {
        get {
            let fire = march.filter { $0.situationIncidentImage == "Fire" }
            return fire
        }
    }
    var marchE: [Incident] {
        get {
            let ems = march.filter { $0.situationIncidentImage == "EMS" }
            return ems
        }
    }
    var marchR: [Incident] {
        get {
            let rescue = march.filter { $0.situationIncidentImage == "Rescue" }
            return rescue
        }
    }
    var april = [Incident]()
    var aprilF: [Incident] {
        get {
            let fire = april.filter { $0.situationIncidentImage == "Fire" }
            return fire
        }
    }
    var aprilE: [Incident] {
        get {
            let ems = april.filter { $0.situationIncidentImage == "EMS" }
            return ems
        }
    }
    var aprilR: [Incident] {
        get {
            let rescue = april.filter { $0.situationIncidentImage == "Rescue" }
            return rescue
        }
    }
    var may = [Incident]()
    var mayF: [Incident] {
        get {
            let fire = may.filter { $0.situationIncidentImage == "Fire" }
            return fire
        }
    }
    var mayE: [Incident] {
        get {
            let ems = may.filter { $0.situationIncidentImage == "EMS" }
            return ems
        }
    }
    var mayR: [Incident] {
        get {
            let rescue = may.filter { $0.situationIncidentImage == "Rescue" }
            return rescue
        }
    }
    var june = [Incident]()
    var juneF: [Incident] {
        get {
            let fire = june.filter { $0.situationIncidentImage == "Fire" }
            return fire
        }
    }
    var juneE: [Incident] {
        get {
            let ems = june.filter { $0.situationIncidentImage == "EMS" }
            return ems
        }
    }
    var juneR: [Incident] {
        get {
            let rescue = june.filter { $0.situationIncidentImage == "Rescue" }
            return rescue
        }
    }
    var july = [Incident]()
    var julyF: [Incident] {
        get {
            let fire = july.filter { $0.situationIncidentImage == "Fire" }
            return fire
        }
    }
    var julyE: [Incident] {
        get {
            let ems = july.filter { $0.situationIncidentImage == "EMS" }
            return ems
        }
    }
    var julyR: [Incident] {
        get {
            let rescue = july.filter { $0.situationIncidentImage == "Rescue" }
            return rescue
        }
    }
    var august = [Incident]()
    var augustF: [Incident] {
        get {
            let fire = august.filter { $0.situationIncidentImage == "Fire" }
            return fire
        }
    }
    var augustE: [Incident] {
        get {
            let ems = august.filter { $0.situationIncidentImage == "EMS" }
            return ems
        }
    }
    var augustR: [Incident] {
        get {
            let rescue = august.filter { $0.situationIncidentImage == "Rescue" }
            return rescue
        }
    }
    var september = [Incident]()
    var septemberF: [Incident] {
        get {
            let fire = september.filter { $0.situationIncidentImage == "Fire" }
            return fire
        }
    }
    var septemberE: [Incident] {
        get {
            let ems = september.filter { $0.situationIncidentImage == "EMS" }
            return ems
        }
    }
    var septemberR: [Incident] {
        get {
            let rescue = september.filter { $0.situationIncidentImage == "Rescue" }
            return rescue
        }
    }
    var october = [Incident]()
    var octoberF: [Incident] {
        get {
            let fire = october.filter { $0.situationIncidentImage == "Fire" }
            return fire
        }
    }
    var octoberE: [Incident] {
        get {
            let ems = october.filter { $0.situationIncidentImage == "EMS" }
            return ems
        }
    }
    var octoberR: [Incident] {
        get {
            let rescue = october.filter { $0.situationIncidentImage == "Rescue" }
            return rescue
        }
    }
    var november = [Incident]()
    var novemberF: [Incident] {
        get {
            let fire = november.filter { $0.situationIncidentImage == "Fire" }
            return fire
        }
    }
    var novemberE: [Incident] {
        get {
            let ems = november.filter { $0.situationIncidentImage == "EMS" }
            return ems
        }
    }
    var novemberR: [Incident] {
        get {
            let rescue = november.filter { $0.situationIncidentImage == "Rescue" }
            return rescue
        }
    }
    var december = [Incident]()
    var decemberF: [Incident] {
        get {
            let fire = december.filter { $0.situationIncidentImage == "Fire" }
            return fire
        }
    }
    var decemberE: [Incident] {
        get {
            let ems = december.filter { $0.situationIncidentImage == "EMS" }
            return ems
        }
    }
    var decemberR: [Incident] {
        get {
            let rescue = december.filter { $0.situationIncidentImage == "Rescue" }
            return rescue
        }
    }
    var year: Int!
    var lastYear: Int!
    var totalIncidents = [Incident]()
    var totalFireIncidents = [Incident]()
    var totalEMSIncidents = [Incident]()
    var totalRescueIncidents = [Incident]()
    let calendar = Calendar.current
    var yearOfMonths: [[Incident]] {
        get {
            let arrayOfMonths = [ january, february, march, april, may, june, july, august, september, october, november, december]
            return arrayOfMonths
        }
    }
    var yearForMonth: Int = 0
    
    var yearAndCounts: [(Int, [Int])] {
        mutating get {
            let year: Int = yearForMonth
            var yearJ: Int!
            var monthJ: Int!
            var yearArrays = [(Int, [Int])]()
            for month in yearOfMonths {
                
                let sortedMonth = month.sorted(by: { ($0.incidentDateSearch ?? "") < ($1.incidentDateSearch ?? "") })
                for incident in sortedMonth {
                    let componentYear = calendar.dateComponents([.year], from: incident.incidentCreationDate ?? Date())
                    yearJ = componentYear.year!
                    yearFromIncidents.append(yearJ)
                    let componentMonth = calendar.dateComponents([.month], from: incident.incidentCreationDate ?? Date())
                    monthJ = componentMonth.month!
                }
                if year == yearJ {
                    
                    let countA = counts(theMonth: monthJ ,month: month, fire: month, ems: month, rescue: month)
                    let yearIncident = (year, countA)
                    yearArrays.append(yearIncident)
                }
            }
            yearArrays = yearArrays.sorted(by:  { $0.0 < $1.0 })
            return yearArrays
        }
    }
    
    var yearAndMonths: [(Int, Incident)] {
        mutating get {
            let year: Int = yearForMonth
            var yearArrays = [(Int, Incident)]()
            for month in yearOfMonths {
                let sortedMonth = month.sorted(by: { ($0.incidentDateSearch ?? "") < ($1.incidentDateSearch ?? "") })
                for incident in sortedMonth {
                    let componentYear = calendar.dateComponents([.year], from: incident.incidentCreationDate ?? Date())
                    let yearJ: Int = componentYear.year!
                    yearFromIncidents.append(yearJ)
                    
                    
                    if year == yearJ {
                        
                        let yearIncident = (year, incident)
                        yearArrays.append(yearIncident)
                    }
                    
                }
            }
            yearArrays = yearArrays.sorted(by:  { $0.0 < $1.0 })
            return yearArrays
        }
    }
    var yearFromIncidents = [Int]()
    var yearsOfIncidents: [(Int, Incident)] {
        mutating get {
            var year: Int = 0
            var yearArrays = [(Int, Incident)]()
            for month in yearOfMonths {
                let sortedMonth = month.sorted(by: { ($0.incidentDateSearch ?? "") < ($1.incidentDateSearch ?? "") })
                for incident in sortedMonth {
                    let componentYear = calendar.dateComponents([.year], from: incident.incidentCreationDate ?? Date())
                    let yearJ: Int = componentYear.year!
                    yearFromIncidents.append(yearJ)
                    for y in years {
                        year = y
                        if year == yearJ {
                            
                            let yearIncident = (year, incident)
                            yearArrays.append(yearIncident)
                        }
                    }
                }
            }
            yearArrays = yearArrays.sorted(by:  { $0.0 < $1.0 })
            return yearArrays
        }
    }
    var yearCounts: [(Int, Int)] {
        mutating get {
            var count = [(Int, Int )]()
            let test = yearsOfIncidents.map( { $0.0  } )
            for y in years {
                var array = [Int]()
                for year in test {
                    if year == y {
                        array.append(year)
                    }
                }
                let countedYear = array.count
                let yearCount = (y,countedYear)
                count.append(yearCount)
            }
            return count
        }
    }
    var years = [Int]()
    
    init(theYear: Int, lastYear: Int) {
        self.year = theYear
        self.lastYear = lastYear
    }
    
    var janCounts: [Int] {
        get {
            let count = january.count
            let fcount = januaryF.count
            let ecount = januaryE.count
            let rcount = januaryR.count
            return [count,fcount,ecount,rcount]
        }
    }
    
    var febCounts: [Int] {
        get {
            let count = february.count
            let fcount = februaryF.count
            let ecount = februaryE.count
            let rcount = februaryR.count
            return [count,fcount,ecount,rcount]
        }
    }
    
    var marchCounts: [Int] {
        get {
            let count = march.count
            let fcount = marchF.count
            let ecount = marchE.count
            let rcount = marchR.count
            return [count,fcount,ecount,rcount]
        }
    }
    
    var aprilCounts: [Int] {
        get {
            let count = april.count
            let fcount = aprilF.count
            let ecount = aprilE.count
            let rcount = aprilR.count
            return [count,fcount,ecount,rcount]
        }
    }
    
    var mayCounts: [Int] {
        get {
            let count = may.count
            let fcount = mayF.count
            let ecount = mayE.count
            let rcount = mayR.count
            return [count,fcount,ecount,rcount]
        }
    }
    
    var juneCounts: [Int] {
        get {
            let count = june.count
            let fcount = juneF.count
            let ecount = juneE.count
            let rcount = juneR.count
            return [count,fcount,ecount,rcount]
        }
    }
    
    var julyCounts: [Int] {
        get {
            let count = july.count
            let fcount = julyF.count
            let ecount = julyE.count
            let rcount = julyR.count
            return [count,fcount,ecount,rcount]
        }
    }
    
    var augustCounts: [Int] {
        get {
            let count = august.count
            let fcount = augustF.count
            let ecount = augustE.count
            let rcount = augustR.count
            return [count,fcount,ecount,rcount]
        }
    }
    
    var septemberCounts: [Int] {
        get {
            let count = september.count
            let fcount = septemberF.count
            let ecount = septemberE.count
            let rcount = septemberR.count
            return [count,fcount,ecount,rcount]
        }
    }
    
    var octoberCounts: [Int] {
        get {
            let count = october.count
            let fcount = octoberF.count
            let ecount = octoberE.count
            let rcount = octoberR.count
            return [count,fcount,ecount,rcount]
        }
    }
    
    var novemberCounts: [Int] {
        get {
            let count = november.count
            let fcount = novemberF.count
            let ecount = novemberE.count
            let rcount = novemberR.count
            return [count,fcount,ecount,rcount]
        }
    }
    
    var decemberCounts: [Int] {
        get {
            let count = december.count
            let fcount = decemberF.count
            let ecount = decemberE.count
            let rcount = decemberR.count
            return [count,fcount,ecount,rcount]
        }
    }
    
    func buildTheYear() -> [(Int , [Int])] {
        var yearBuiltArray = [(01, janCounts), (02, febCounts), (03, marchCounts), (04, aprilCounts), (05, mayCounts), (06, juneCounts), (07, julyCounts), (08, augustCounts), (09, septemberCounts), (10, octoberCounts), (11, novemberCounts), (12, decemberCounts) ]
        yearBuiltArray = yearBuiltArray.sorted(by: { $0.0 < $1.0 } )
        return yearBuiltArray
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - theMonth: 01-12 and int for the month of the count
    ///   - month: collection of the month of incidents
    ///   - fire: collection of the month of incidents fires
    ///   - ems: collection of the month of incidents ems
    ///   - rescue: collection of the month of incidents rescue
    /// - Returns: 4 counts, month, month fire, month ems, month rescue
    func counts(theMonth: Int, month: [Incident], fire: [Incident], ems: [Incident], rescue: [Incident] ) -> [Int] {
        let count = month.count
        let fcount = fire.count
        let ecount = ems.count
        let rcount = rescue.count
        return [theMonth,count,fcount,ecount,rcount]
    }
    
    
}
