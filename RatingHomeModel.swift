

import Foundation

protocol RatingHomeModelProtocal: class {
    func ratingitemsDownloaded(items: NSMutableArray)
}


class RatingHomeModel:  NSObject, NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate {
    
    
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    //properties
    
    weak var delegate: RatingHomeModelProtocal!
    
    var data : NSMutableData = NSMutableData()
    
    
    let urlPath: String = "http://220.67.128.35:8080/ratingload.php" //this will be changed to the path where test.php lives
    
    func downloadItems() {
        
        let url: NSURL = NSURL(string: urlPath)!
        var session: NSURLSession!
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        
        session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        let task = session.dataTaskWithURL(url)
        
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
        print("Rating Model parse start")
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
            
            self.delegate.ratingitemsDownloaded(reviews)
            
        })
    }
}
