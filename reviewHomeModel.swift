//
//  reviewHomeModel.swift
//  pseat3
//
//  Created by 최리아 on 11/17/16.
//  Copyright © 2016  UNO. All rights reserved.
//


import Foundation

protocol reviewHomeModelProtocal: class {
    func reviewitemsDownloaded(items: NSMutableArray)
}


class reviewHomeModel:  NSObject, NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate {
    
    
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    //properties
    
    weak var delegate: reviewHomeModelProtocal!
    
    var data : NSMutableData = NSMutableData()

    
    let urlPath: String = "http://220.67.128.35:8080/reviewload2.php" //this will be changed to the path where test.php lives
    
    
    func downloadItems() {
        
        let pNumber: NSString = prefs.valueForKey("PC") as! String
        // print(pNumber)
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlPath)!)
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
        
        if (data.length != 5)
        {
        do{
            jsonResult = try NSJSONSerialization.JSONObjectWithData(self.data, options:NSJSONReadingOptions.AllowFragments) as! NSMutableArray
            //jsonResult = try NSJSONSerialization.JSONObjectWithData(self.data, options:NSJSONReadingOptions.AllowFragments) as! NSArray
            //jsonResult = try NSJSONSerialization.JSONObjectWithData(self.data, options: []) as? [[String : AnyObject]]
            
        } catch let error as NSError {
            print(error)
            
        }
        }
        print("parsing by JSON_2")
        var jsonElement: NSDictionary = NSDictionary()
        let reviews: NSMutableArray = NSMutableArray()
        
        for i in 0  ..< jsonResult.count
        {
            
            jsonElement = jsonResult[i] as! NSDictionary
            
            let reviewmodel = ReviewModel()
            
            //the following insures none of the JsonElement values are nil through optional binding
            if let pNumber = jsonElement["pNumber"] as? String,
                let id = jsonElement["id"] as? String,
                let rate = jsonElement["rate"] as? String,
                let review = jsonElement["review"] as? String
            {
                
                reviewmodel.pNumber = pNumber
                reviewmodel.id = id
                reviewmodel.rate = rate
                reviewmodel.review = review
                
            }
            
            reviews.addObject(reviewmodel)
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.delegate.reviewitemsDownloaded(reviews)
            
        })
    }
}
