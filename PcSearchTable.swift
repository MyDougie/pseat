//
//  PcSearchTable.swift
//  pseat3
//
//  Created by 최리아 on 11/8/16.
//  Copyright © 2016  UNO. All rights reserved.
//

import UIKit
import MapKit

class PcSearchTable: UITableViewController{
    
    var FilteredPCList: NSArray = NSArray()
    var PCList: NSArray = NSArray()
    
    var handleMapSearchDelegate:HandleMapSearch? = nil
    
    var mapView: MKMapView? = nil
    
    
}
extension PcSearchTable : UISearchResultsUpdating,HomeModelProtocal  {
    
    
    func itemsDownloaded(items: NSArray) {
        PCList = items
        self.tableView.reloadData()
    }
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        let searchText = searchController.searchBar.text
        let searchPredicate = NSPredicate(format: "SELF.pName CONTAINS[c] %@", searchText!)
        
        self.FilteredPCList = PCList.filteredArrayUsingPredicate(searchPredicate)
        self.tableView.reloadData()
        
    }
    
}

extension PcSearchTable {
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if ((self.searchDisplayController?.active) != nil) {
            return self.FilteredPCList.count
        } else {
            return self.PCList.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cellIdentifier: String = "pccell"
        let Cellpc: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
        // Get the location to be shown
        
        let item_filter: LocationModel
        
        if ((self.searchDisplayController?.active) != nil) {
            item_filter = FilteredPCList[indexPath.row] as! LocationModel
        } else {
            item_filter = PCList[indexPath.row] as! LocationModel
        }
        
        Cellpc.textLabel!.text = item_filter.pName
        Cellpc.detailTextLabel!.text = item_filter.pAddr
        
        return Cellpc
    }
    
    
}
extension PcSearchTable {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item2: LocationModel
        item2 = FilteredPCList[indexPath.row] as! LocationModel
        let lati = Double(item2.pLati!)
        let long = Double(item2.pLong!)
        let center = CLLocationCoordinate2D(latitude: lati!, longitude: long!)
        let span = MKCoordinateSpanMake(0.001, 0.001)
        
        // let selectedItem = CLLocation(latitude: lati!, longitude: long!)
        let region = MKCoordinateRegion(center: center, span: span)//1은 원의 크기
        mapView!.setRegion(region, animated: true)
        // handleMapSearchDelegate?.dropPinZoomIn(selectedItem)
        dismissViewControllerAnimated(true, completion: nil)
    }
}



