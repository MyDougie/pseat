

import Foundation

protocol BookmarkHomeModelProtocal: class {
    func bookmarkitemsdownloaded(items: NSMutableArray)
}


class BookmarkHomeModel: NSObject, NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate {
    
    //properties
    
    weak var delegate: BookmarkHomeModelProtocal!
    
    var data : NSMutableData = NSMutableData()
    
    let urlPath2: String = "http://220.67.128.35:8080/bookmarkload3.php" //this will be changed to the path where
    
    
    func downloadItems() {
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let islogged:Int = prefs.integerForKey("ISLOGGED") as Int
        var id = ""
        if (islogged == 1)
        {id = (prefs.valueForKey("ID") as? String)!}
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlPath2)!)
        print("received data from controller (id) : \(id)")
        let post:String = "id=\(id)"
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
        //print("parsing by JSON_2")
        var jsonElement: NSDictionary = NSDictionary()
        let bookmarks: NSMutableArray = NSMutableArray()
        print("json count : \(jsonResult.count)")
        for i in 0  ..< jsonResult.count
        {
            
            jsonElement = jsonResult[i] as! NSDictionary
            
            let bookmark = BookmarkModel()
            
            //the following insures none of the JsonElement values are nil through optional binding
            if let id = jsonElement["id"] as? String,
                let pNumber = jsonElement["pNumber"] as? String,
                let pName = jsonElement["pName"] as? String
            {
                bookmark.id = id
                bookmark.pNumber = pNumber
                bookmark.pName = pName
                print("id : \(id)")
                print("pNumber : \(pNumber)")
                
            } else{
                print("error occoured!!!!")
            }
            
            bookmarks.addObject(bookmark)
            
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.delegate.bookmarkitemsdownloaded(bookmarks)
            
        })
        print("parse End")
    }
}