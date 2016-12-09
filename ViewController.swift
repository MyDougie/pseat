//
//  ViewController.swift
//  MapLocator
//
//  Created by Malek T. on 10/3/15.
//  Copyright © 2015 Medigarage Studios LTD. All rights reserved.
//

import Darwin
import UIKit
import MapKit
import CoreLocation

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}


class ViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate,  UITableViewDataSource, HomeModelProtocal, RatingHomeModelProtocal  {
    
    
    @IBOutlet weak var usernameLabel: UILabel!
    
   // @IBOutlet weak var logoutButton: UIButton!
    //for sending selected cell to another viewController
    var SecondArray:String!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    var selectedAnnotation: MKPointAnnotation!
    
    //send PC info for tableView
    var valueToPassName:String!
    var valueToPassAddr:String!
    var valueToPassPnum:String!
    
    var feedItems: NSArray = NSArray()
    var distItems: [Double] = []//각 (PC방 경도,위도 - 사용자 경도, 위도) 의 절대값의 합을 저장할 배열
    var distIndex = -1;
    var ratingfeedItems: NSArray = NSArray()
    var ratingItems: [Double] = []//평균 점수를 저장할 배열
    var score: [Double] = [] // 평균평점과 (5-거리점수)를 5:5 비율로 합산한 배열.
   // var score2: [Double] = []
    
    
    //사용자의 마지막 위치정보
    var last_user_lati: Double = Double()
    var last_user_long: Double = Double()
    
    var selectedLocation : LocationModel = LocationModel()
    
    var resultSearchController:UISearchController? = nil
    var pcSearchController:UISearchController? = nil
    
    var selectedPin:MKPlacemark? = nil
    
    //Temp LocationSearchInfo
    var willRemoveAnnotation: CustomPointAnnotation? = nil
    
    @IBOutlet weak var listTableView: UITableView!
    
    

    @IBAction func showPCSearchBar(sender: AnyObject) {
        let pcSearchTable = storyboard!.instantiateViewControllerWithIdentifier("PcSearchTable") as! PcSearchTable
        pcSearchController = UISearchController(searchResultsController: pcSearchTable)
        pcSearchController?.searchResultsUpdater = pcSearchTable
        
        let searchBar = pcSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "피시방 검색"
        navigationItem.titleView = pcSearchController?.searchBar
        
        pcSearchController?.hidesNavigationBarDuringPresentation = false
        pcSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        pcSearchTable.mapView = mapView
        pcSearchTable.itemsDownloaded(feedItems)
        pcSearchTable.handleMapSearchDelegate = self
    }
    
    @IBAction func showSearchBar(sender: AnyObject) {
        
        let locationSearchTable = storyboard!.instantiateViewControllerWithIdentifier("LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "지역 검색"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        
        locationSearchTable.handleMapSearchDelegate = self
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    /*
     override func viewDidLoad() {
     super.viewDidLoad()
     // self.view.frame = CGRectMake(0, 0, 320, 322);
     }*/
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ratingHM = RatingHomeModel()
        ratingHM.delegate = self
        ratingHM.downloadItems()
        sleep(1);
        
        self.listTableView.delegate = self
        self.listTableView.dataSource = self
        
        let homeModel = HomeModel()
        homeModel.delegate = self
        homeModel.downloadItems()
        
        
       //
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest //유저의 위치와 가장 높은 유사도
        self.locationManager.requestWhenInUseAuthorization()    //어플리케이션 실행 중에만 위치정보 사용(백그라운드에서 사용 안함)
        self.locationManager.startUpdatingLocation()    //locationManager실행
        self.mapView.showsUserLocation = true
        //
        
        //side-menubar
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            //side-menubar width
            self.revealViewController().rearViewRevealWidth = 170
        }
        
        mapView.delegate = self
   
        view.bringSubviewToFront(usernameLabel)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGED") as Int
        //feedItems를 어떻게 전송할것인가
       // prefs.setObject(feedItems, forKey: "feed")
        
        //print(isLoggedIn)
        if (isLoggedIn == 1) {
            self.usernameLabel.text = prefs.valueForKey("ID") as? String
            //logoutButton.setTitle("로그아웃", forState: .Normal)
        } else if (isLoggedIn == 2) {
           // logoutButton.setTitle("로그인", forState: .Normal)
            
        } else {
            self.performSegueWithIdentifier("goto_login", sender: self)
            
        }
    }
    /*
    @IBAction func logouttapped(sender: UIButton) {
        
        sender.setTitle("로그인", forState: .Normal)
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        
        self.performSegueWithIdentifier("goto_login", sender: self)
    }
    */
    @IBAction func currnetLocationButtonClicked(sender: UIBarButtonItem) {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest //유저의 위치와 가장 높은 유사도
        self.locationManager.requestWhenInUseAuthorization()    //어플리케이션 실행 중에만 위치정보 사용(백그라운드에서 사용 안함)
        self.locationManager.startUpdatingLocation()    //locationManager실행
        self.mapView.showsUserLocation = true
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last //위의 startUpdating 메서드가 실행 된 뒤에 계속해서 함수 호출되며 로케이션 위치가 쌓이는데,
        // 그 중 가장 마지막 위치가 사용자의 위치일 것이므로 last를 사용한다.
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude,
                                            longitude: location!.coordinate.longitude)
        
        last_user_lati = location!.coordinate.latitude
        last_user_long = location!.coordinate.longitude
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))//1은 원의 크기
        self.mapView.setRegion(region, animated: true)  //mapView를 보여줌 zooming animation
        self.locationManager.stopUpdatingLocation()
    }
    
    
    //######################   DATA BASE   #########################
    func itemsDownloaded(items: NSArray) {
        feedItems = items
        self.listTableView.reloadData()
    }
    
    func ratingitemsDownloaded(items: NSMutableArray){
        ratingfeedItems = items
        print("rate feed : ", ratingfeedItems.count)
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of feed items
        print(" v feed:",feedItems.count)
        return feedItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Retrieve cell
        let cellIdentifier: String = "BasicCell"
        let myCell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
        // Get the location to be shown
        let item: LocationModel = feedItems[indexPath.row] as! LocationModel
        // Get references to labels of cell
        myCell.textLabel!.text = item.pName
        
        let lati = Double(item.pLati!)
        let long = Double(item.pLong!)
        
        addPin(item.pName!, Addr: item.pAddr!, Lati: lati!, Long: long!, pNumber: item.pNumber!)

        
        
        return myCell
    }
    
    
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // println("You selected cell #\(indexPath.row)!")
        
        // Get Cell Label
        let indexPath = tableView.indexPathForSelectedRow!;
        let currentCell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell!;
        
        valueToPassName = currentCell.textLabel!.text
        valueToPassAddr = feedItems[indexPath.row].pAddr
        valueToPassPnum = feedItems[indexPath.row].pNumber
        
         let item: LocationModel = feedItems[indexPath.row] as! LocationModel
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        prefs.setObject(item.pNumber!, forKey: "PC") //Int로 바꾸기
        prefs.synchronize()
        
        performSegueWithIdentifier("showseats", sender: self)
        
    }
   
    //Pin
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        //User Location Pin
        if (annotation is MKUserLocation){
            return nil
        }
            
            //PC Pin
        else if !(annotation is CustomPointAnnotation) {
            let annotationIdentifier = "test"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(annotationIdentifier) as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
                annotationView?.animatesDrop = false
                annotationView?.canShowCallout = true
                annotationView?.draggable = true
                
                //Button
                let rightButton: AnyObject! = UIButton(type: UIButtonType.DetailDisclosure)
                annotationView?.rightCalloutAccessoryView = rightButton as? UIView
            }else{
                annotationView?.annotation = annotation
            }
            return annotationView
            
            //Location Pin
        }else{
            let annotationIdentifier = "test"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(annotationIdentifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
                annotationView?.canShowCallout = true
                
                let pinImage = UIImage(named: "customer_pin.png")
                let size = CGSize(width: 25, height: 25)
                UIGraphicsBeginImageContext(size)
                pinImage!.drawInRect(CGRectMake(0, 0, size.width, size.height))
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                annotationView?.image = resizedImage
            }else{
                annotationView?.annotation = annotation
            }
            return annotationView
        }
    }

    //##############################################################
    //pin zoom
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        // get the particular pin that was tapped
        let pinToZoomOn = view.annotation
        
        // optionally you can set your own boundaries of the zoom
        let span = MKCoordinateSpanMake(0.001, 0.001)
        
        // or use the current map zoom and just center the map
        // let span = mapView.region.span
        
        // now move the map
        let region = MKCoordinateRegion(center: pinToZoomOn!.coordinate, span: span)
        // Get Cell Label
        
        mapView.setRegion(region, animated: true)
    }
    //pin추가
    func addPin(Name:String, Addr:String, Lati:Double, Long:Double, pNumber: String){
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(Lati ,Long);
        annotation.title = Name;
        annotation.subtitle = Addr;
        annotation.accessibilityLabel = pNumber;
        mapView.addAnnotation(annotation);
        
        let x = last_user_lati - Lati;
        let y = last_user_long - Long;
        let value = sqrt((x*x)+(y*y))
        //사용자 위치로부터 PC방 일직선 거리 계산. distItems의 값이 작을수록 가깝다.
        distItems.append(value*280);//100m차이가 평점 0.3점 정도 차이나도록 설정 (거리점수 5점(만점) 가정)
        //1.5km이내에 피시방범위 내에서 추천. 사용자와 1.5km 정도 차이가 dist 5점 정도 차이남.
        //따라서 5 - dist 를 총점에 더해서 계산하기 때문에 1.5km보다 더 먼 거리에 있는 피시방들은 총점에 오히려 -가 됨.
 
         //rate
         //RatingHomeModel에 보낼 Pnumber값 set.
         let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
         prefs.setObject(pNumber, forKey: "PC2")
        
         // print(ratingfeedItems.count)
         print("pnum : ",pNumber)
         var sum: Double = Double()
         sum = 0.0
        var count: Double = Double()
        count = 0.0
         for i in 0..<ratingfeedItems.count{
            let item: ReviewModel = ratingfeedItems[i] as! ReviewModel
            if item.pNumber == pNumber{
                let r : Double = (item.rate! as NSString).doubleValue
                print("r : ", r)
                sum += Double(r)
                count += 1
            }
         }
        if count == 0{
            ratingItems.append(0)
        }else{
            ratingItems.append(sum/count)
        }
        
        distIndex += 1;
        //두 배열의 합산 점수
        let sum2 = (5.0-distItems[distIndex]) + ratingItems[distIndex]
        score.append(sum2)
        
        
        print(Name," distItems[",(distIndex),"] :", distItems[distIndex])
        print(Name," ratingItems[",(distIndex),"] :", ratingItems[distIndex])
        print(Name," score[",(distIndex),"] :", score[distIndex])
        
       
        
        /*
        score.sortInPlace { $0 > $1 } //합산점수가 내림차순 정렬됨.
        for x in 0..<score.count{
            print(score[x]," ")
        }
         */
        
        prefs.setObject(score, forKey: "score")
        
    }
    //핀 정보 보기
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            selectedAnnotation = view.annotation as? MKPointAnnotation
        
            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            prefs.setObject(selectedAnnotation.accessibilityLabel, forKey: "PC") //Int로 바꾸기
            prefs.synchronize()
    
            performSegueWithIdentifier("showseat", sender: self)
        }
    }




    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //for tableView
        if segue.identifier == "showseats"{
            let vc = segue.destinationViewController as! DetailViewController
            vc.navigationItem.title = valueToPassName + " 좌석"
            vc.sendName = valueToPassName
            vc.sendAddr = valueToPassAddr
            vc.sendPnum = valueToPassPnum
        //for mapView
        }else if segue.identifier == "showseat"{
            let vc = segue.destinationViewController as! DetailViewController
            vc.navigationItem.title =  selectedAnnotation.title! + " 좌석"
            vc.sendName = selectedAnnotation.title!
            vc.sendAddr = selectedAnnotation.subtitle!
            vc.sendPnum = selectedAnnotation.accessibilityLabel!
        }
    }


    
    // MARK: - Navigation
    
    @IBAction func didReturnToMapViewController(segue: UIStoryboardSegue) {
        print(#function)
    }
   
    /*
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //I don't know how to convert this if condition to swift 1.2 but you can remove it since you don't have any other button in the annotation view
        if (control as? UIButton)?.buttonType == UIButtonType.DetailDisclosure {
            mapView.deselectAnnotation(view.annotation, animated: false)
            performSegueWithIdentifier("you're segue Id to detail vc", sender: view)
        }
    }
 */
}



extension ViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        let loc_annotation = CustomPointAnnotation(coordinate: placemark.coordinate, title: placemark.name!, subtitle: "\(placemark.locality) \(placemark.administrativeArea)")
        loc_annotation.imageName = "customer_pin.png"
        // add pin
        mapView.addAnnotation(loc_annotation)
        
        // remove pin
        if willRemoveAnnotation != nil{
            mapView.removeAnnotation(willRemoveAnnotation!)
        }
        willRemoveAnnotation = loc_annotation
        
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}

/*
 This extension implements the dropPinZoomIn() method in order to adopt the HandleMapSearch protocol.
 The incoming placemark is cached in the selectedPin variable. This will be useful later when you create the callout button.
 removeAnnotations() clears the map of any existing annotations. This step is to ensure we’re only dealing with one annotation pin on the map at a time.
 MKPointAnnotation is a map pin that contains a coordinate, title, and subtitle. The placemark has similar information like a coordinate and address information. Here you populate the title and subtitle with information that makes sense.
 mapView.addAnnotation() adds the above annotation to the map.
 setRegion() zooms the map to the coordinate. You create a span to specify a zoom level, just like you did in a previous section. */