//
//  reviewViewController.swift
//  pseat3
//
//  Created by 최리아 on 11/16/16.
//  Copyright © 2016  UNO. All rights reserved.
//

import UIKit



class reviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate, reviewHomeModelProtocal {
    
    @IBOutlet weak var reviewTableView: UITableView!
    
    var feedReviews: NSMutableArray = NSMutableArray()
    var items: NSArray = NSArray()
    


    @IBOutlet weak var reviewtext: UITextField!
    var kbHeight: CGFloat!
    
    @IBOutlet weak var h1: UIButton!
    @IBOutlet weak var h2: UIButton!
    @IBOutlet weak var h3: UIButton!
    @IBOutlet weak var h4: UIButton!
    @IBOutlet weak var h5: UIButton!
    
    let hfill : UIImage = UIImage(named: "heart_fill")!
    let hEmpty : UIImage = UIImage(named: "heart_none")!
    var rating = 0
    var rate : Int = 0 {
        willSet {
            let hearts = [h1, h2, h3, h4, h5]
            
            for (i, heart) in EnumerateSequence(hearts){

                    heart?.selected = i < newValue
                
                
            }
            //rateLbl.text = "\(newValue)"
        }
    }
    
    @IBAction func h1(sender: AnyObject) {
        switch rate {
        case 1 :
            rate = 0
        default:
            rate = 1
        }
    }
    @IBAction func h2(sender: AnyObject) {
        rate=2
    }
    @IBAction func h3(sender: AnyObject) {
        rate=3
    }
    @IBAction func h4(sender: AnyObject) {
        rate=4
    }
    @IBAction func h5(sender: AnyObject) {
        rate=5
    }
    
    @IBAction func savereview(sender: AnyObject) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.tintColor = UIColor.blackColor();
        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor();
        
        let hearts = [h1, h2, h3, h4, h5]
        for heart in hearts {
            heart?.setImage(hEmpty, forState: .Normal)
            heart?.setImage(hfill, forState: .Selected)
        }
 
        self.reviewTableView.delegate = self
        self.reviewTableView.dataSource = self
        
        let reviewhomeModel = reviewHomeModel()
        reviewhomeModel.delegate = self
        reviewhomeModel.downloadItems()
        
        reviewtext.delegate = self
        //self.reviewTableView.reloadData()
    }

 
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                kbHeight = keyboardSize.height
                self.animateTextField(true)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.animateTextField(false)
    }
    
    
    func animateTextField(up: Bool) {
        var movement = (up ? -kbHeight : kbHeight)
        
        UIView.animateWithDuration(0.3, animations: {
            self.view.frame = CGRectOffset(self.view.frame, 0, movement)
        })
    }

    
    func imageForRating(rating:Double) -> UIImage? {
        switch rating {
        case 1:
            return UIImage(named: "h1")
        case 2:
            return UIImage(named: "h2")
        case 3:
            return UIImage(named: "h3")
        case 4:
            return UIImage(named: "h4")
        case 5:
            return UIImage(named: "h5")
        default:
            return nil
        }
    }

    
    func reviewitemsDownloaded(items: NSMutableArray) {
        feedReviews = items
        self.reviewTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of feed items
        return feedReviews.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //pNumber이 prefs값과 같으면!추가해야됨
        
        
        let cellIdentifier: String = "reviewcell"
        let myCell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!

        let item: ReviewModel = feedReviews[indexPath.row] as! ReviewModel
        let rating = Double(item.rate!)
   
        if let idLabel = myCell.viewWithTag(100) as? UILabel { //3
            idLabel.text = item.id
            idLabel.sizeToFit()
        }
        if let commentLabel = myCell.viewWithTag(101) as? UILabel {
            commentLabel.text = item.review
            commentLabel.sizeToFit()
        }
        
        if let ratingImageView = myCell.viewWithTag(102) as? UIImageView {
            ratingImageView.image = self.imageForRating(rating!)
        }
        return myCell
    }
    
    ////delete////
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
            
            let item: ReviewModel = feedReviews[indexPath.row] as! ReviewModel
            let pNumber = item.pNumber
            print("pN!! :", pNumber)
                       print("xx")
            
            if (id == item.id){
            
                feedReviews.removeObjectAtIndex(indexPath.row)
            
                reviewdelete(pNumber, id: id)
            }else {
                
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "평점 삭제 실패"
                alertView.message = "본인의 평점만 삭제할 수 있습니다"
                alertView.delegate = self
                alertView.addButtonWithTitle("확인")
                alertView.show()
            }
            self.reviewTableView.reloadData()
        }
        
        
    }
    
    func reviewdelete(pNumber : String!, id : String!){
        
        let urlPath: String = "http://220.67.128.35:8080/reviewdelete.php" //this will be changed to the path where test.php lives
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
    
    //////
    
    @IBAction func registerTapped(sender: UIButton) {
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var id = ""
        
        let islogged:Int = prefs.integerForKey("ISLOGGED") as Int
        
        if (islogged == 1)
        {id = (prefs.valueForKey("ID") as? String)!}
   
        let pNumber = prefs.valueForKey("PC") as! String
        print(pNumber)
        
        let review:NSString = reviewtext.text!
        
        if (review.isEqualToString("")) {
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "평점 등록 실패"
            alertView.message = "리뷰를 남겨주세요"
            alertView.delegate = self
            alertView.addButtonWithTitle("확인")
            alertView.show()
        }else if (rate == 0) {
            print(rate)
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "평점 등록 실패"
            alertView.message = "하트를 눌러 평점을 매겨주세요"
            alertView.delegate = self
            alertView.addButtonWithTitle("확인")
            alertView.show()
        }else if (id == ""){
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "평점 등록 실패"
            alertView.message = "로그인 해주세요"
            alertView.delegate = self
            alertView.addButtonWithTitle("확인")
            alertView.show()
            
        }else {
            
            
            do {
                
                let post:NSString = "pNumber=\(pNumber)&id=\(id)&rate=\(rate)&review=\(review)"
                
                NSLog("PostData: %@",post);
                
                let url:NSURL = NSURL(string: "http://220.67.128.35:8080/reviewcomment.php")!
                
                let postData:NSData = post.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
                
                let postLength:NSString = String( postData.length )
                
                let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
                request.HTTPMethod = "POST"
                request.HTTPBody = postData
                request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                
                
                var reponseError: NSError?
                var response: NSURLResponse?
                
                var urlData: NSData?
                do {
                    urlData = try NSURLConnection.sendSynchronousRequest(request, returningResponse:&response)
                } catch let error as NSError {
                    reponseError = error
                    urlData = nil
                }
                
                if ( urlData != nil ) {
                    let res = response as! NSHTTPURLResponse!;
                    
                    NSLog("Response code: %ld", res.statusCode);
                    
                    if (res.statusCode >= 200 && res.statusCode < 300)
                    {
                        let responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                        
                        NSLog("Response ==> %@", responseData);
                        
                        //var error: NSError?
                        
                        let jsonData:NSDictionary = try NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers ) as! NSDictionary
                        
                        
                        let success:NSInteger = jsonData.valueForKey("success") as! NSInteger
                        
                        //[jsonData[@"success"] integerValue];
                        
                        NSLog("Success: %ld", success);
                        
                        if(success == 1)
                        {
                            NSLog("평점등록완료");
                            let alertView:UIAlertView = UIAlertView()
                            alertView.title = "평점 등록 완료"
                            alertView.delegate = self
                            alertView.addButtonWithTitle("확인")
                            alertView.show()
                            
                            rate=0
                            //reviewitemsDownloaded(reviewArray)
                            /*
                            dispatch_async(dispatch_get_main_queue(),{
                                print("yes")
                                //self.reviewitemsDownloaded(self.items)
                                //self.reviewTableView.reloadData()
                            })
                            */
                            sleep(2)
                            self.viewDidLoad()
                            
                        } else {
                            var error_msg:NSString
                            
                            if jsonData["error_message"] as? NSString != nil {
                                error_msg = jsonData["error_message"] as! NSString
                            } else {
                                error_msg = "Unknown Error"
                            }
                            let alertView:UIAlertView = UIAlertView()
                            alertView.title = "평점 등록 실패"
                            alertView.message = error_msg as String
                            alertView.delegate = self
                            alertView.addButtonWithTitle("확인")
                            alertView.show()
                            
                        }
                        
                    } else {
                        let alertView:UIAlertView = UIAlertView()
                        alertView.title = "평점 등록 실패"
                        alertView.message = "Connection Failed"
                        alertView.delegate = self
                        alertView.addButtonWithTitle("확인")
                        alertView.show()
                    }
                } else {
                    let alertView:UIAlertView = UIAlertView()
                    alertView.title = "평점 등록 실패"
                    alertView.message = "Connection Failure"
                    if let error = reponseError {
                        alertView.message = (error.localizedDescription)
                    }
                    alertView.delegate = self
                    alertView.addButtonWithTitle("확인")
                    alertView.show()
                }
            } catch {
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "평점 등록 실패"
                alertView.message = "서버 에러"
                alertView.delegate = self
                alertView.addButtonWithTitle("확인")
                alertView.show()
            }
        }
        
        reviewtext.text! = ""
        
        

       
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }

    
    /*
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Retrieve cell
        let cellIdentifier: String = "reviewcell"
        let myCell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
        // Get the location to be shown
        let item: LocationModel = feedReviews[indexPath.row] as! LocationModel
        // Get references to labels of cell
        myCell.textLabel!.text = item.ID
        myCell.detailTextLabel!.text = item.comment
        
       
        return myCell
    }
*/
}
