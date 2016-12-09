
//
    //  BookmarkController.swift
    //  pseat3
    //
    //  Created by Tae Gyu Park on 11/5/16.
    //  Copyright © 2016  UNO. All rights reserved.
    //
    
    import UIKit
    
    class BookmarkController: UIViewController, UITableViewDelegate,  UITableViewDataSource,  NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate, BookmarkHomeModelProtocal {

        @IBOutlet weak var menuButton: UIBarButtonItem!
       
        @IBOutlet weak var listTableView: UITableView!
        
        var pName:String!
        var bookMarkArray:NSMutableArray = NSMutableArray()
        
        var valueToPassName:String!
        var valueToPassNumber:String!
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            self.navigationController!.navigationBar.tintColor = UIColor.blackColor();
            self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor();

            
            if self.revealViewController() != nil {
                menuButton.target = revealViewController()
                menuButton.action = "revealToggle:"
                view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            }
            
            self.listTableView.dataSource = self
            self.listTableView.delegate = self
            
            print(bookMarkArray.count)
            
            let bookmarkHM = BookmarkHomeModel()
            bookmarkHM.delegate = self
            bookmarkHM.downloadItems()
            
            print(bookMarkArray.count)
            
            bookmarkitemsdownloaded(bookMarkArray)
            // self.listTableView.reloadData()
        }
        
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }
        
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // Return the number of feed items
            print(bookMarkArray.count)
            return bookMarkArray.count
        }
        
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            //pNumber이 prefs값과 같으면!추가해야됨
            let cellIdentifier: String = "bookmarkcell"
            let myCell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
            let item: BookmarkModel = bookMarkArray[indexPath.row] as! BookmarkModel
            print(item.id)
            print(item.pNumber)
            print(item.pName)
            myCell.textLabel!.text = item.pName
            /*
             let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
             var id = "no"
             id = (prefs.valueForKey("ID") as? String)!
             
             if id == item.id{
             print(item.pNumber)
             print(item.pName)
             
             }
             */
            
            return myCell
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            
            let indexPath = tableView.indexPathForSelectedRow!;
            let currentCell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell!;
            
            
            let item: BookmarkModel = bookMarkArray[indexPath.row] as! BookmarkModel
            for index in 0..<bookMarkArray.count{
                if (item.pName == bookMarkArray[index].pName) &&
                    (item.pNumber == bookMarkArray[index].pNumber){
                    valueToPassName = item.pName
                    valueToPassNumber = item.pNumber
                }
            }
            
            performSegueWithIdentifier("showseats2", sender: self)
        }
        
        override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            //for tableView
            if segue.identifier == "showseats2"{
                let vc = segue.destinationViewController as! DetailViewController
                vc.navigationItem.title = valueToPassName + " 좌석"
                vc.sendPnum = valueToPassNumber
                //for mapView
            }
        }
        
        
        //for delete
        func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
        {
            return true
        }
        //for delete
        func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
        {
            if editingStyle == .Delete
            {
                
                //
                let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                var id = ""
                let islogged:Int = prefs.integerForKey("ISLOGGED") as Int
                
                if (islogged == 1)
                {id = (prefs.valueForKey("ID") as? String)!}
         
                let item: BookmarkModel = bookMarkArray[indexPath.row] as! BookmarkModel
                let pNumber = item.pNumber
                print("pN!! :", pNumber)
                /*
                let urlPath: String = "http://220.67.128.35:8080/bookmarkdelete.php" //this will be changed to the path where
                
                let request = NSMutableURLRequest(URL: NSURL(string: urlPath)!)
                print("received data from controller (id , pNumber) : \(id) \(pNumber)")
                let post:String = "id=\(id)&pNumber=\(pNumber)"
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
 */
                print("xx")
                
                
                
                bookMarkArray.removeObjectAtIndex(indexPath.row)
                
                bookmarkdelete(pNumber, id: id)
                
                self.listTableView.reloadData()
            }
            
            
        }
        
        func bookmarkdelete(pNumber : String!, id : String!){
            
            let urlPath: String = "http://220.67.128.35:8080/bookmarkdelete.php" //this will be changed to the path where test.php lives
            let request = NSMutableURLRequest(URL: NSURL(string: urlPath)!)
            let post:String = "id=\(id)&pNumber=\(pNumber)"
            request.HTTPMethod = "POST"
            let postString:NSData = post.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
            request.HTTPBody = postString
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            print("post string : \(postString)")
            
            let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
            
            let session = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue:nil)
            
            let task = session.dataTaskWithRequest(request)
            
            task.resume()
        }
        
        //######################   DATA BASE   #########################
        func bookmarkitemsdownloaded(items: NSMutableArray) {
            bookMarkArray = items
            self.listTableView.reloadData()
        }
        
        
        
}






    