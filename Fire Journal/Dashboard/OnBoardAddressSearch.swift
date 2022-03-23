//
//  OnBoardAddressSearch.swift
//  StationCommand
//
//  Created by DuRand Jones on 7/19/21.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

protocol OnBoardAddressSearchDelegate: AnyObject {
    func addressHasBeenChosen(location: CLLocationCoordinate2D, address: String, tag: Int)
}

class OnBoardAddressSearch: UIViewController, MKLocalSearchCompleterDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var closeB: UIButton!
    @IBOutlet weak var submitB: UIButton!
    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var completionsContainer: UIView!
    @IBOutlet weak var headerBarV: UIView!
    
    
    var theAddress: String = ""
    var theCoordinate: CLLocationCoordinate2D!
    var theMapTag: Int!
    var type: IncidentTypes = .station
    
    private var cameraBoundary: MKCoordinateRegion? = nil
    var boundarys: MKCoordinateRegion? = nil {
        didSet {
            self.cameraBoundary = self.boundarys
        }
    }
    
    private var searchBoundary: MKCoordinateRegion? = nil
    var searches: MKCoordinateRegion? = nil {
        didSet {
            self.searchBoundary = self.searches
        }
    }
    
    private var fireStationBoundary: MKCoordinateRegion? = nil
    var stationBoundary: MKCoordinateRegion? = nil {
        didSet {
            self.fireStationBoundary = self.stationBoundary
        }
    }
    
    private var mapViewController: OnBoardMapVC?
    private var completionsViewController: OnBoardCompletionsVC?
    
    weak var delegate: OnBoardAddressSearchDelegate? = nil
    
    private let pointOfInterestFilter = MKPointOfInterestFilter(including: [.fireStation,.police])
    private let incidentPointOfInterestFilter = MKPointOfInterestFilter.includingAll
    private let streetAddressFilter = MKPointOfInterestFilter(including: [])
    
    private let searchCompleter = MKLocalSearchCompleter()
    private var search: MKLocalSearch?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        switch type {
        case .allIncidents:
            searchCompleter.pointOfInterestFilter = incidentPointOfInterestFilter
            searchCompleter.resultTypes = .pointOfInterest
            searchCompleter.region = cameraBoundary ?? MKCoordinateRegion(center: defaultLocation, latitudinalMeters: 100, longitudinalMeters: 80)
            searchCompleter.delegate = self
        case .journal:
            searchCompleter.pointOfInterestFilter = incidentPointOfInterestFilter
            searchCompleter.resultTypes = .pointOfInterest
            searchCompleter.region = cameraBoundary ?? MKCoordinateRegion(center: defaultLocation, latitudinalMeters: 100, longitudinalMeters: 80)
            searchCompleter.delegate = self
        case .station:
        searchCompleter.pointOfInterestFilter = pointOfInterestFilter
        searchCompleter.resultTypes = .pointOfInterest
        searchCompleter.region = cameraBoundary ?? MKCoordinateRegion(center: defaultLocation, latitudinalMeters: 100, longitudinalMeters: 80)
        searchCompleter.delegate = self
        case .deptMember:
//            searchCompleter.pointOfInterestFilter = streetAddressFilter
            searchCompleter.resultTypes = .address
            searchCompleter.region = cameraBoundary ?? MKCoordinateRegion(center: defaultLocation, latitudinalMeters: 100, longitudinalMeters: 80)
            searchCompleter.delegate = self
        default: break
        }
    }
    
    override func viewDidLoad() {
        switch type {
        case .station:
                searchBar.placeholder = "Search for firestations nearby type  your city firestation or use audio"
            headerBarV.backgroundColor = UIColor(named: "FJIconRed")
        case .deptMember:
            searchBar.placeholder = "Search for staff's address by typing or audio"
            headerBarV.backgroundColor = UIColor(named: "FJBlue")
        case .journal:
            searchBar.placeholder = "Search for staff's address by typing or audio"
            headerBarV.backgroundColor = UIColor(named: "FJBlue")
        case .allIncidents:
            searchBar.placeholder = "Search for address by typing in the search bar or use audio"
            headerBarV.backgroundColor = UIColor(named: "FJIconRed")
        default:
            searchBar.placeholder = "Search for firestations nearby type  your city firestation or use audio"
            headerBarV.backgroundColor = UIColor(named: "FJIconRed")
        }
        completionsContainer.isHidden = true
        mapViewController?.delegate = self
        mapViewController?.mapView.region = searchBoundary ?? MKCoordinateRegion(center: defaultLocation, latitudinalMeters: 2000, longitudinalMeters: 2000)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        searchCompleter.cancel()
        search?.cancel()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "MapEmbed":
            mapViewController = segue.destination as? OnBoardMapVC
            mapViewController?.type = self.type
        case "CompletionsViewEmbed":
            completionsViewController = segue.destination as? OnBoardCompletionsVC
            self.completionsViewController?.selectionHandler = { [weak self](completion) in
                self?.search(for: completion)
            }
        default:
            super.prepare(for: segue, sender: sender)
        }
    }
    
    @IBAction func closeTheMap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitTheMap(_ sender: Any) {
        
        if theAddress != "" {
            delegate?.addressHasBeenChosen(location: theCoordinate, address: theAddress, tag: theMapTag)
        }
        
    }
    
    private func search(for completion: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request(completion: completion)
        configureRequest(request)
        search(request)
    }
    
    private func configureRequest(_ request: MKLocalSearch.Request) {
        switch type {
        case .station:
            /*
             Apply the point of interest filter to include cafes, bakeries,
             nightlife and restaurants.
            */
            request.pointOfInterestFilter = pointOfInterestFilter

            /*
             For this feature, address results are not relevant. Limit
             the results to points of interest by setting the .pointOfInterest
             result type.
            */
            request.resultTypes = .pointOfInterest

            /*
             Provide the search engine with a hint of the region of interest. This
             constant is declared in Constants.swift.
            */
            request.region = searchBoundary ?? MKCoordinateRegion(center: defaultLocation,  latitudinalMeters: 2000, longitudinalMeters: 2000)
        case .deptMember, .journal:
            /*
             Apply the point of interest filter to include cafes, bakeries,
             nightlife and restaurants.
            */
//            request.pointOfInterestFilter = streetAddressFilter

            /*
             For this feature, address results are not relevant. Limit
             the results to points of interest by setting the .pointOfInterest
             result type.
            */
            request.resultTypes = .address

            /*
             Provide the search engine with a hint of the region of interest. This
             constant is declared in Constants.swift.
            */
            request.region = searchBoundary ?? MKCoordinateRegion(center: defaultLocation,  latitudinalMeters: 2000, longitudinalMeters: 2000)
        default: break
        }
    }
    
    private func search(_ request: MKLocalSearch.Request) {
        searchCompleter.cancel()
        completionsContainer.isHidden = true
        searchBar.resignFirstResponder()

        search = MKLocalSearch(request: request)
        search?.start { [weak self](response, error) in

            if let error = error {
                self?.handleSearchError(error)
            } else if let response = response {
                self?.mapViewController?.show(mapItems: response.mapItems)
            }

            self?.search = nil
        }
    }
    
    private func handleSearchError(_ error: Error) {
        let message = "\(error.localizedDescription)\n\nPlease try again later"
        let alert = UIAlertController(title: "An Error Occurred", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.completionsContainer.isHidden = false
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - MKLocalSearchCompleterDelegate

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completionsViewController?.searchCompletions = completer.results
        completionsContainer.isHidden = completer.results.isEmpty
    }

    // MARK: - UISearchBarDelegate

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if let completionsCount = completionsViewController?.searchCompletions.count {
            completionsContainer.isHidden = completionsCount <= 0
        }
        return true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count < searchCompleter.queryFragment.count {
            completionsViewController?.searchCompletions = [MKLocalSearchCompletion]()
        }

        if searchText.count >= 3 {
            searchCompleter.queryFragment = searchText
        } else {
            completionsContainer.isHidden = true
        }
    }
    
    private func search(for query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        configureRequest(request)
        search(request)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let query = searchBar.text {
            search(for: query)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()

        completionsContainer.isHidden = true
        completionsViewController?.searchCompletions = [MKLocalSearchCompletion]()

        searchCompleter.queryFragment = ""
        searchCompleter.cancel()
        search?.cancel()
    }
    

}

extension OnBoardAddressSearch: OnBoardMapDelegate {
    
    func theMapPointHasBeenChosen(_ theCoordinate: CLLocationCoordinate2D, _ address: String) {
        self.theAddress = address
        self.theCoordinate = theCoordinate
    }
    
}
