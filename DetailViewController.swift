//
//  DetailViewController.swift
//  pseat3
//
//  Created by 최리아 on 10/24/16.
//  Copyright © 2016  UNO. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

protocol DetailViewControllerDelegate {
    func didFetchContacts(contacts: [CNContact])
}

class DetailViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, CNContactPickerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, NSURLSessionDelegate, SeatHomeModelProtocal, reviewHomeModelProtocal
{
    
    
    @IBOutlet weak var averagerate: UILabel!

    
    @IBOutlet weak var hb1: UIButton!
    @IBOutlet weak var hb2: UIButton!
    @IBOutlet weak var hb3: UIButton!
    @IBOutlet weak var hb4: UIButton!
    @IBOutlet weak var hb5: UIButton!
    
    
    let hfill : UIImage = UIImage(named: "heart_fill")!
    let hEmpty : UIImage = UIImage(named: "heart_none")!
    
    var feedReviews: NSArray = NSArray()
    
    var contacts = [CNContact]()
    
    var currentlySelectedMonthIndex = 1
    
    var delegate: DetailViewControllerDelegate!
    
    var index_for_draw:Int = 0
    
    var start_new_line:Int = 1
    var index_for_seat = 1
    var index_of_map = 0
    var temp_for_map = 0
    var count:Int = 0 //모든 좌석 개수
    
    var timer:NSTimer = NSTimer.init()
    
    var temp_count = 0
    
    var count_of_all_cell = 0
    
    func showContacts(sender: AnyObject) {
        let contactPickerViewController = CNContactPickerViewController()
        
        contactPickerViewController.delegate = self
        
        presentViewController(contactPickerViewController, animated: true, completion: nil)
    }
    
    var sendName:String!
    var sendAddr:String!
    var sendPnum:String!
    var sendLogState:Bool!
    var item:SeatModel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    //let appleProducts = ["1", "2", "3", "4"]
    
    let imageArray = [UIImage(named: "off"), UIImage(named: "on"), UIImage(named: "book"), UIImage(named: "notExist")]
    
    var max:Int = 0     //pc방 좌석의 모양중 가장 긴 줄의 길이를 저장하는 int형 변수
    var seats = [Int]() //pc방 좌석의 on or off-line 상태를 저장하는 int형 array
    var map = [Int]()   //pc방 좌석의 모양을 한줄마다 저장하는 int형 array
    var temp_map = [Int]()
    var feedItems2: NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.lightGrayColor()
        self.collectionView.backgroundColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.tintColor = UIColor.blackColor();
        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor();
        
        super.viewDidLoad()
        
        let seatHomeModel = SeatHomeModel()
        seatHomeModel.delegate = self
        seatHomeModel.downloadItems(sendPnum)
        
        let reviewhomeModel = reviewHomeModel()
        reviewhomeModel.delegate = self
        reviewhomeModel.downloadItems()
        
        index_for_draw = 0
        start_new_line = 1
        index_for_seat = 1
        index_of_map = 0
        temp_for_map = 0
        temp_count = 0
        count = 0
        
        //timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        //print("(self.view.frame.size.width) : \(self.view.frame.size.width)")
    }
    
    func update(){
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!update1!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        map.removeAll()
        seats.removeAll()
        print("REMOVE ALL!")
        print(seats.count)
        self.viewDidLoad()
    }
    func update1(){
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!update2!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        map.removeAll()
        seats.removeAll()
        print("REMOVE ALL!")
        print(seats.count)
        self.viewDidLoad()
    }
    
    
    func seatItemsDownloaded(items: NSMutableArray) {
        feedItems2 = items
        self.collectionView.reloadData()
        print("seat items download complete!")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        let reviewhomeModel = reviewHomeModel()
        reviewhomeModel.delegate = self
        reviewhomeModel.downloadItems()
        
    
    }

    ///////////평점////////////
    func reviewitemsDownloaded(items: NSMutableArray) {
        feedReviews = items
        if (calculateaverage() > 0){
            averagerate.text = "\(calculateaverage())"
            imageForRating(calculateaverage())
        }else {
            averagerate.text = "0"
            imageForRating(calculateaverage())
            
        }
    }
    
    func calculateaverage() -> Double{
        var sum: Double = 0
        var num: Double = 0
        for i in 0..<feedReviews.count{
            let item: ReviewModel = feedReviews[i] as! ReviewModel
            
            let r : Double = (item.rate! as NSString).doubleValue
            print("r : ", r)
            sum += Double(r)
            num += 1
            count += 1
        }
        
        let numberOfPlaces = 2.0
        let multiplier = pow(10.0, numberOfPlaces)
        var average: Double = sum / num
        let rounded = round(average * multiplier) / multiplier
        print(rounded)
        
        
        print("average : \(rounded)")
        return rounded
    }
    
    func imageForRating(rating:Double) {
        
        if (rating==0){
            
        }else {
        if (rating>0){
            hb1.setImage(hfill, forState: .Normal)
        }
        if (rating>1.5){
            hb2.setImage(hfill, forState: .Normal)
        }
        
        if (rating>2.5){
            hb3.setImage(hfill, forState: .Normal)
        }
        
        if (rating>3.5){
            hb4.setImage(hfill, forState: .Normal)
        }
        
        if (rating>4.5){
            hb5.setImage(hfill, forState: .Normal)
        }
        }
    }
    //////////////////////////////////////////
    
    
    //이 함수에서 return하는 수 만큼 cell을 그려준다.
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //print("collectionView1 Start")
        let count_f = feedItems2.count
        if(count_f == 0){
            print("feed item count : \(feedItems2.count)")
            return 0
        } else{
            //   print("feed item count : \(feedItems2.count)")
            item = feedItems2[0] as! SeatModel
            //  let item: SeatModel = feedItems[0] as! SeatModel
            let pNumber = item.pNumber!
            let seatForm = item.seatForm!
            let seat1 = item.seat1!
            let seat2 = item.seat2!
            let seat3 = item.seat3!
            let seat4 = item.seat4!
            let length:Int = seatForm.characters.count  //seatForm은 string형태로 저장되어있다. length는 이 string의 길이를 저장한다.
            //이 부분에서는 그림을 그려줄 좌석의 개수를 계산한다
            //예를들어 좌석이 5, 5, 5, 8개씩 일렬로 놓였다고 하면
            //이중 최대 개수인 8개를 기준으로 4행씩, 즉 8 * 4 = 32개만큼의 좌석을 그려준다.
            //이중 max값은 실제로 좌석을 그려주는 부분에서 다시 사용되므로 전역변수로 지정하였다.
            temp_count = 0
            var temp:Int
            count = 0
            for i in 0..<length{
                var index = seatForm.startIndex.advancedBy(i)
                temp = Int(String(seatForm[index]))! // returns Character, change to Int
                map.append(temp)
                if temp > max{
                    max = temp
                }
                self.count += temp
            }
            /*
             print("-------------------------------DOWNLOADED DATA FROM DATABASE-------------------------------")
             print("P Number : \(pNumber)")
             print("seat form : \(seatForm)")
             print("seat1 : \(seat1)")
             print("seat2 : \(seat2)")
             print("seat3 : \(seat3)")
             print("seat4 : \(seat4)")
             print("-------------------------------------------------------------------------------------------")
             
             print("map: \(map)")
             print("max: \(max)")
             print("count: \(count)")*/
            
            
            //이곳은 실제 좌석의 state를 받아온다.
            //즉 각 좌석에 대하여 해당 좌석이 on-line상태인지 off-line상태인지를
            //int형 배열에 순서대로 저장해놓고
            //후에 좌석을 그려줄때 이 배열의 index를 좌석의 번호로 간주하여 참고하도록 한다.
            if count < 64{
                for j in 0..<64{
                    var index = seat1.startIndex.advancedBy(64-j-1)
                    temp = Int(String(seat1[index]))!
                    seats.append(temp)
                }
            } else if count >= 64 && count < 128{
                let seat1 = item.seat1!
                let seat2 = item.seat2!
                for j in 0..<64{
                    var index = seat1.startIndex.advancedBy(64-j-1)
                    temp = Int(String(seat1[index]))!
                    seats.append(temp)
                }
                for j in 0..<64{
                    var index = seat2.startIndex.advancedBy(64-j-1)
                    temp = Int(String(seat2[index]))!
                    seats.append(temp)
                }
            } else if count >= 128 && count < 196{
                let seat1 = item.seat1!
                let seat2 = item.seat2!
                let seat3 = item.seat3!
                for j in 0..<64{
                    var index = seat1.startIndex.advancedBy(64-j-1)
                    temp = Int(String(seat1[index]))!
                    seats.append(temp)
                }
                for j in 0..<64{
                    var index = seat2.startIndex.advancedBy(64-j-1)
                    temp = Int(String(seat2[index]))!
                    seats.append(temp)
                }
                for j in 0..<64{
                    var index = seat3.startIndex.advancedBy(64-j-1)
                    temp = Int(String(seat3[index]))!
                    seats.append(temp)
                }
                
            }
            //    print("seats : \(seats)")
            //    print("max * length = \(max*length)")
            count_of_all_cell = max * length
            return (max * length)
        }
    }
    
    //이 함수는 cell을 한개 그릴때 마다 호출되는 함수이다. 해당 cell에 어떤 label을 넣을지,
    //그리고 어떤 image를 넣을지 판단한다.
    //좌석의 유무를 판단하는 check_state_of_seat()함수는 후술되어있다.
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //print("index ")
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
            as! CollectionViewCell
        let count_f = feedItems2.count
        if(count_f == 0 || temp_count >= self.count_of_all_cell){
            print("count is 0 or index is out of range!")
            return cell
        } else {
            if index_for_draw > self.count-1{
                index_for_draw = 0
            }
            //print("index for draw : \(index_for_draw)")
            let state = check_state_of_seat()
            //let index = indexPath.row
            
            if state == 1 {  //state that seat is exist
                cell.titleLabel!.text = String(index_for_draw+1)    //draw label, using index number
                if seats[index_for_draw] == 0{
                    cell.imageView!.image = self.imageArray[0]  //means USING
                } else if seats[index_for_draw] == 1{
                    cell.imageView!.image = self.imageArray[1]  //means EMPTY
                } else{
                    cell.imageView!.image = self.imageArray[2]  //means BOOKED
                }
                index_for_draw += 1
                
            } else{ //state that seat is not exist
                cell.titleLabel!.text = ""    //draw label, using index number
                cell.imageView!.image = self.imageArray[3]  //means NOT EXIST
            }
            
            return cell
        }
        temp_count += 1
    }
    
    
    //func check_state_of_seat()->Int{}
    //좌석의 draw는 좌석의 max값에 기반한다. 예를들어 좌석이 5개인 line이 있고 8개인 line이 있다면
    //화면상에 5개인 line의 좌석을 제외한 나머지 3개의 cell은 '빈칸'으로 표시되어야 한다.
    //
    //이 함수는 이러한 '빈칸'을 판단하는 함수이다. '빈칸'인지, 혹은 실제 존재하는 좌석인지의 여부를
    //state라는 변수로 나타내었다. 1을 return하면 좌석이 있다는 뜻이고, 반대로 0은 '빈칸'이라는 뜻이다.
    
    func check_state_of_seat()->Int{
        var state:Int = 0
        if start_new_line == 1{
            start_new_line = 0
            temp_for_map = map[index_of_map]
            index_for_seat = 1
            index_of_map += 1
        }
        
        if index_for_seat <= temp_for_map{
            state = 1   //means EXIST
        } else{
            state = 0   //means NOT EXIST
        }
        
        if index_for_seat >= max{
            start_new_line = 1
        } else{
            index_for_seat += 1
        }
        return state
    }
    
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //self.timer.invalidate()
        let index = seats[indexPath.row]
        let selectedCell = collectionView.cellForItemAtIndexPath(indexPath)! as! CollectionViewCell
        let seatNumber:Int = Int(selectedCell.titleLabel.text!)!
        
        print("selected seat number: \(seatNumber)")
        print("seat state: \(index)")
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        //print("###")
        var id = "no"
        var isLoged = 2
        isLoged = (prefs.valueForKey("ISLOGGED") as? Int)!
        if isLoged != 2{
            id = (prefs.valueForKey("ID") as? String)!
            print("id : \(id)")
        }
        //print("@@@")
        
        //var temp = Int(String(seatForm[index]))!
        if index == 1{ //자리가 이미 사용중일때
            print("d")
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "예약 불가"
            alertView.message = "이미 사용중인 자리입니다"
            alertView.delegate = self
            alertView.addButtonWithTitle("확인")
            alertView.show()
        } else if index == 2{   //자리가 예약중인 상태일때
            let check = checkIsSelf(self.sendPnum, id: id, seatNum: seatNumber)
            if check == false || isLoged == 2{ //예약한 사람이 자신이 아니거나 로그인 상태가 아닐때
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "예약 불가"
                alertView.message = "이미 예약된 자리입니다"
                alertView.delegate = self
                alertView.addButtonWithTitle("확인")
                alertView.show()
            } else{   //예약한 사람이 자신일때
                var myAlert = UIAlertController(title: "예약 취소 확인", message: "\(String(seatNumber))번 자리의 예약을 취소하시겠습니까?", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.Default){(ACTION) in
                    self.postForCancelBook(self.sendPnum, seatNum: seatNumber)
                    //                    self.collectionView.reloadData()
                    print("cancel book confirm")
                }
                let cancelAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.Default){(ACTION) in
                    print("cancel book deny")
                }
                myAlert.addAction(okAction)
                myAlert.addAction(cancelAction)
                self.presentViewController(myAlert, animated: true, completion: nil)
            }
        } else{ //자리가 비었을 때
            if isLoged == 2{   //로그인 상태가 아닐때
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "예약 불가"
                alertView.message = "로그인 후 이용해주세요!"
                alertView.delegate = self
                alertView.addButtonWithTitle("확인")
                alertView.show()
            } else{ //로그인 상태일때
                let checkAlready:Bool = self.checkAlreadyBooked(id)
                if checkAlready == false {
                    var myAlert = UIAlertController(title: "예약 확인", message: "\(String(seatNumber))번 자리를 예약 하시겠습니까?", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    let okAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.Default){(ACTION) in
                        self.postForBook(self.sendPnum, id: id, seatNum: seatNumber)
                        //self.collectionView.reloadData()
                        print("book confirm")
                    }
                    
                    let cancelAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.Default){(ACTION) in
                        print("book deny")
                    }
                    
                    myAlert.addAction(okAction)
                    myAlert.addAction(cancelAction)
                    
                    self.presentViewController(myAlert, animated: true, completion: nil)
                } else{ //이미 예약한 자리가 있을때
                    let alertView:UIAlertView = UIAlertView()
                    alertView.title = "예약 불가"
                    alertView.message = "이미 예약한 자리가 있습니다!"
                    alertView.delegate = self
                    alertView.addButtonWithTitle("확인")
                    alertView.show()
                }
            }
        }
    }
    
    func replace(myString: String, _ index: Int, _ newChar: Character) -> String {
        var chars = Array(myString.characters)     // gets an array of characters
        chars[index] = newChar
        let modifiedString = String(chars)
        return modifiedString
    }
    
    func postForBook(Pnum: String, id: String, seatNum: Int){
        item = feedItems2[0] as! SeatModel
        let seat1 = item.seat1!
        
        let currentTime = NSDate()
        
        var formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = NSTimeZone(abbreviation: "UTC")
        let utcTimeZoneStr = formatter.stringFromDate(currentTime)
        
        let resultString:String = replace(seat1, 63-seatNum+1, "2")
        //print("result string : \(resultString)")
        let urlPath: String = "http://220.67.128.35:8080/postForBook.php" //this will be changed to the path where test.php lives
        let request = NSMutableURLRequest(URL: NSURL(string: urlPath)!)
        //print("received data from controller (pNumber) : \(pNumber)")
        let post:String = "pNumber=\(Pnum)&id=\(id)&seatNum=\(String(seatNum))&newSeat=\(resultString)&time=\(utcTimeZoneStr)"
        print("BOOK INFO :: PNUMBER : \(Pnum), ID : \(id), SEAT NUMBER : \(String(seatNum)), TIME : \(utcTimeZoneStr)")
        request.HTTPMethod = "POST"
        let postString:NSData = post.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        request.HTTPBody = postString
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        //print("post string : \(postString)")
        
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        let session = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue:nil)
        
        let task = session.dataTaskWithRequest(request)
        
        task.resume()
        
        sleep(3)
        self.update1()
    }
    
    func postForCancelBook(Pnum: String, seatNum: Int){
        item = feedItems2[0] as! SeatModel
        let seat1 = item.seat1!
        
        let resultString:String = replace(seat1, 63-seatNum+1, "0")
        
        let urlPath: String = "http://220.67.128.35:8080/postForCancelBook.php" //this will be changed to the path where test.php lives
        let request = NSMutableURLRequest(URL: NSURL(string: urlPath)!)
        //print("received data from controller (pNumber) : \(pNumber)")
        let post:String = "pNumber=\(Pnum)&seatNum=\(String(seatNum))&newSeat=\(resultString)"
        print("BOOK CANCEL INFO :: PNUMBER : \(Pnum), SEAT NUMBER : \(String(seatNum))")
        request.HTTPMethod = "POST"
        let postString:NSData = post.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        request.HTTPBody = postString
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        //print("post string : \(postString)")
        
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        let session = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue:nil)
        
        let task = session.dataTaskWithRequest(request)
        
        task.resume()
        
        sleep(3)
        self.update1()
    }
    
    func checkIsSelf(Pnum: String, id: String, seatNum: Int)->Bool{
        var THERESULT:Bool = false
        let urlPath: String = "http://220.67.128.35:8080/checkIsSelf.php" //this will be changed to the path where test.php lives
        let request = NSMutableURLRequest(URL: NSURL(string: urlPath)!)
        let post:String = "pNumber=\(Pnum)&id=\(id)&seatNum=\(seatNum)"
        print("BOOK CHECK INFO :: PNUMBER : \(Pnum), ID : \(id), SEAT NUMBER : \(String(seatNum))")
        request.HTTPMethod = "POST"
        let postString:NSData = post.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        request.HTTPBody = postString
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
            
            if (res.statusCode >= 200 && res.statusCode < 300) {
                let responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                
                NSLog("Response ==> %@", responseData);
                
                //var error: NSError?
                do{
                    let jsonData:NSDictionary = try NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers ) as! NSDictionary
                    let success:NSInteger = jsonData.valueForKey("success") as! NSInteger
                    
                    NSLog("Success: %ld", success);
                    
                    if(success == 1){
                        THERESULT = true
                    } else {
                        THERESULT = false
                    }
                }
                catch {
                    let alertView:UIAlertView = UIAlertView()
                    alertView.title = "실패"
                    alertView.message = "서버 에러"
                    alertView.delegate = self
                    alertView.addButtonWithTitle("확인")
                    alertView.show()
                }
            }
        }
        return THERESULT
    }
    
    func checkAlreadyBooked(id: String)->Bool{
        var THERESULT:Bool = false
        let urlPath: String = "http://220.67.128.35:8080/checkAlreadyBooked.php" //this will be changed to the path where test.php lives
        let request = NSMutableURLRequest(URL: NSURL(string: urlPath)!)
        //print("received data from controller (pNumber) : \(pNumber)")
        let post:String = "id=\(id)"
        request.HTTPMethod = "POST"
        let postString:NSData = post.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        request.HTTPBody = postString
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
            
            if (res.statusCode >= 200 && res.statusCode < 300) {
                let responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                
                NSLog("Response ==> %@", responseData);
                
                //var error: NSError?
                do{
                    let jsonData:NSDictionary = try NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers ) as! NSDictionary
                    
                    
                    let success:NSInteger = jsonData.valueForKey("success") as! NSInteger
                    
                    //[jsonData[@"success"] integerValue];
                    
                    NSLog("Success: %ld", success);
                    
                    if(success == 1){
                        THERESULT = true
                    } else {
                        THERESULT = false
                    }
                }
                catch {
                    let alertView:UIAlertView = UIAlertView()
                    alertView.title = "실패"
                    alertView.message = "서버 에러"
                    alertView.delegate = self
                    alertView.addButtonWithTitle("확인")
                    alertView.show()
                }
            }
        }
        return THERESULT
    }
    
    
    //max값에 따라 cell의 크기를 지정하여 화면의 크기에 맞추기 위한 함수
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if max < 6{
            let width = (self.view.frame.size.width)/(CGFloat(max)+1.4) //some width
            let height = CGFloat(75) //ratio
            return CGSize(width: width, height: height);
        } else{
            let width = (self.view.frame.size.width)/(CGFloat(max)+2.0) //some width
            let height = CGFloat(75) //ratio
            return CGSize(width: width, height: height);
        }
        
    }
    
    @IBAction func bookMarkButtonClicked(sender: AnyObject) {
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var id = ""
        
        let islogged:Int = prefs.integerForKey("ISLOGGED") as Int
        
        if (islogged == 1)
        {id = (prefs.valueForKey("ID") as? String)!}
        let pNumber = sendPnum
        
        print(id)
        print(pNumber)
        print(sendName)
        let pName = sendName
        
        if (id == ""){
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "즐겨찾기 등록 실패"
            alertView.message = "로그인 해주세요"
            alertView.delegate = self
            alertView.addButtonWithTitle("확인")
            alertView.show()
            
        }else {
            do {
                
                let post:NSString = "id=\(id)&pNumber=\(pNumber)&pName=\(pName)"
                
                NSLog("PostData: %@",post);
                
                
                let url:NSURL = NSURL(string: "http://220.67.128.35:8080/bookmarkadd.php")!
                
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
                            NSLog("즐겨찾기등록완료");
                            let alertView:UIAlertView = UIAlertView()
                            alertView.title = "즐겨찾기 등록 완료"
                            alertView.delegate = self
                            alertView.addButtonWithTitle("확인")
                            alertView.show()
                            
                            dispatch_async(dispatch_get_main_queue(),{
                            })
                            
                        } else {
                            var error_msg:NSString
                            
                            if jsonData["error_message"] as? NSString != nil {
                                error_msg = jsonData["error_message"] as! NSString
                            } else {
                                error_msg = "Unknown Error"
                            }
                            let alertView:UIAlertView = UIAlertView()
                            alertView.title = "즐겨찾기 등록 실패"
                            alertView.message = error_msg as String
                            alertView.delegate = self
                            alertView.addButtonWithTitle("확인")
                            alertView.show()
                        }
                        
                    } else {
                        let alertView:UIAlertView = UIAlertView()
                        alertView.title = "즐겨찾기 등록 실패"
                        alertView.message = "Connection Failed"
                        alertView.delegate = self
                        alertView.addButtonWithTitle("확인")
                        alertView.show()
                    }
                } else {
                    let alertView:UIAlertView = UIAlertView()
                    alertView.title = "즐겨찾기 등록 실패"
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
                alertView.title = "즐겨찾기 등록 실패"
                alertView.message = "서버 에러"
                alertView.delegate = self
                alertView.addButtonWithTitle("확인")
                alertView.show()
            }
        }
    }

    @IBAction func sendButtonClicked(sender: AnyObject) {
        performSegueWithIdentifier("sendPC", sender: self)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //for tableView
        if segue.identifier == "sendPC"{
            let vc = segue.destinationViewController as! SendController
            vc.pName = sendName
            vc.pAddr = sendAddr
            
        }
    }
    
}