//
//  HomeModel.swift
//  pseat3
//
//  Created by  UNO on 8/4/16.
//  Copyright © 2016  UNO. All rights reserved.
//

import Foundation

protocol SeatHomeModelProtocal: class {
    func seatItemsDownloaded(items: NSMutableArray)
}


class SeatHomeModel: NSObject, NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate {
    
    //properties
    
    weak var delegate: SeatHomeModelProtocal!
    
    var data : NSMutableData = NSMutableData()
    
    let urlPath: String = "http://220.67.128.35:8080/test1.php" //this will be changed to the path where test.php lives
    let urlPath2: String = "http://220.67.128.35:8080/service2.php" //this will be changed to the path where
    let urlPath3: String = "http://220.67.128.35:8080/service3.php" //this will be changed to the path where
    
    func downloadItems() {
        
        let url: NSURL = NSURL(string: urlPath)!
        var session: NSURLSession!
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        
        session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        let task = session.dataTaskWithURL(url)
        
        print("downloadItems Start")
        
        task.resume()
        
    }
    
    func downloadItems(pNumber: String) {
        let request = NSMutableURLRequest(URL: NSURL(string: urlPath2)!)
        print("received data from controller (pNumber) : \(pNumber)")
        let post:String = "pNumber=\(pNumber)"
        request.HTTPMethod = "POST"
        let postString:NSData = post.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        request.HTTPBody = postString
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        print("post string : \(postString)")
        
        var sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        var session = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue:nil)
        
        let task = session.dataTaskWithRequest(request)
        
        task.resume()
        
        print("downloadItems End")
    }
    
    func postItems(pNumber: String){
        let request = NSMutableURLRequest(URL: NSURL(string: urlPath3)!)
        print("received data from controller (pNumber) : \(pNumber)")
        let post:String = "pNumber=\(pNumber)"
        request.HTTPMethod = "POST"
        let postString:NSData = post.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        request.HTTPBody = postString
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        print("post string : \(postString)")
        
        var sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        var session = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue:nil)
        
        let task = session.dataTaskWithRequest(request)
        
        task.resume()
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        completionHandler(NSURLSessionResponseDisposition.Allow) //.Cancel,If you want to stop the download
        print("??")
        //     self.data.appendData(data);
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        print("received data length : \(data.length)")
        self.data.appendData(data);
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
        print("House Model parse start")
        var jsonResult: NSMutableArray = NSMutableArray()
        // var jsonResult: NSArray = NSArray()
        //print("parsing by JSON_1")
        do{
            jsonResult = try NSJSONSerialization.JSONObjectWithData(self.data, options:NSJSONReadingOptions.AllowFragments) as! NSMutableArray
            //jsonResult = try NSJSONSerialization.JSONObjectWithData(self.data, options:NSJSONReadingOptions.AllowFragments) as! NSArray
            //jsonResult = try NSJSONSerialization.JSONObjectWithData(self.data, options: []) as? [[String : AnyObject]]
            
        } catch let error as NSError {
            print(error)
            
        }
        //print("parsing by JSON_2")
        var jsonElement: NSDictionary = NSDictionary()
        let seatinfo: NSMutableArray = NSMutableArray()
        print("json count : \(jsonResult.count)")
        for i in 0  ..< jsonResult.count
        {
            
            jsonElement = jsonResult[i] as! NSDictionary
            
            let seat = SeatModel()
            
            //the following insures none of the JsonElement values are nil through optional binding
            if let pNumber = jsonElement["pNumber"] as? String,
                let seatForm = jsonElement["seatForm"] as? String,
                let seat1 = jsonElement["seat1"] as? String,
                let seat2 = jsonElement["seat2"] as? String,
                let seat3 = jsonElement["seat3"] as? String,
                let seat4 = jsonElement["seat4"] as? String
            {
                seat.pNumber = pNumber
                seat.seatForm = seatForm
                seat.seat1 = seat1
                seat.seat2 = seat2
                seat.seat3 = seat3
                seat.seat4 = seat4
                print("pNumber : \(pNumber)")
                print("seatForm : \(seatForm)")
                
            } else{
                print("error occoured!!!!")
            }
            
            seatinfo.addObject(seat)
            
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.delegate.seatItemsDownloaded(seatinfo)
            
        })
        print("parse End")
    }
}