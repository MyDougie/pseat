//
//  LocationSearchTable.swift
//  pseat3
//
//  Created by  UNO on 8/9/16.
//  Copyright © 2016  UNO. All rights reserved.
//


import UIKit
import MapKit

class LocationSearchTable : UITableViewController {
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    /*
     matchingItems: You will use this later on to stash search results for easy access.
     mapView: Search queries rely on a map region to prioritize local results. The mapView variable is a handle to the map from the previous screen. You’ll wire this up in the next step.
     */
    
    var handleMapSearchDelegate:HandleMapSearch? = nil
    
    
    
    //주소표기방법
    func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.locality != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
            
        )
        return addressLine
    }
    
   
}

extension LocationSearchTable : UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
    /*
     MKLocalSearchRequest: A search request is comprised of a search string, and a map region that provides location context. The search string comes from the search bar text, and the map region comes from the mapView.
     MKLocalSearch performs the actual search on the request object. startWithCompletionHandler() executes the search query and returns a MKLocalSearchResponse object which contains an array of mapItems. You stash these mapItems inside matchingItems, and then reload the table.
     */
}


extension LocationSearchTable {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem)
        return cell
    }
    
    /*
     This extension groups all the UITableViewDataSource methods together.
     The matchingItems array determines the number of table rows.
     Each cell was configured with an identifier of cell in a previous section. The cell’s built-in textLabel is set to the placemark name of the Map Item.
     The cell’s detailTextLabel is set to an empty string for now. You will populate this with the address later on. */
}

extension LocationSearchTable {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(selectedItem)
        dismissViewControllerAnimated(true, completion: nil)
    }
}