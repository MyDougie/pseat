//
//  HomeModel.swift
//  pseat3
//
//  Created by  UNO on 8/4/16.
//  Copyright © 2016  UNO. All rights reserved.
//

import Foundation

protocol HomeModelProtocal: class {
    func itemsDownloaded(items: NSArray)
}


class HomeModel: NSObject, NSURLSessionDataDelegate {
    
    //properties
    
    weak var delegate: HomeModelProtocal!
    
    var data : NSMutableData = NSMutableData()
    
    let urlPath: String = "http://220.67.128.35:8080/service.php" //this will be changed to the path where test.php lives
    
    
    func downloadItems() {
        
        let url: NSURL = NSURL(string: urlPath)!
        var session: NSURLSession!
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        
        session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        let task = session.dataTaskWithURL(url)
        
        task.resume()
        
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        self.data.appendData(data);
        print("home model data length : \(data.length)")
        
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?){
        if error != nil {
            print("Failed to download data")
        }else {
            print("Data downloaded")
            self.parseJSON()
        }
    }

    func parseJSON() {
        
        var jsonResult: NSMutableArray = NSMutableArray()
        //print("parsing by JSON_1")
        do{
            jsonResult = try NSJSONSerialization.JSONObjectWithData(self.data, options:NSJSONReadingOptions.AllowFragments) as! NSMutableArray
            
        } catch let error as NSError {
            print(error)
            
        }
        //print("parsing by JSON_2")
        var jsonElement: NSDictionary = NSDictionary()
        let locations: NSMutableArray = NSMutableArray()
        
        print("home json count : ",jsonResult.count)
        for i in 0  ..< jsonResult.count
        {
            
            jsonElement = jsonResult[i] as! NSDictionary
            
            let location = LocationModel()
            
            //the following insures none of the JsonElement values are nil through optional binding
            if let pName = jsonElement["pName"] as? String,
                let pAddr = jsonElement["pAddr"] as? String,
                let pLati = jsonElement["pLati"] as? String,
                let pLong = jsonElement["pLong"] as? String,
                let pNumber = jsonElement["pNumber"] as? String
            {
                
                location.pName = pName
                location.pAddr = pAddr
                location.pLati = pLati
                location.pLong = pLong
                location.pNumber = pNumber
                
            }
            
            locations.addObject(location)
            
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.delegate.itemsDownloaded(locations)
            
        })
    }
}