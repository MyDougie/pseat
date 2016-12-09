//
//  FriendsListController.swift
//  pseat3
//
//  Created by Tae Gyu Park on 11/6/16.
//  Copyright © 2016  UNO. All rights reserved.
//

import UIKit

class RecommendController: UIViewController, UITableViewDelegate,  UITableViewDataSource, HomeModelProtocal  {
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var listTableView: UITableView!
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    var rank:[Int] = []
    
    var score:[Double] = []
    var feedItems: NSArray = NSArray()
    
    var valueToPassName: String!
    var valueToPassNumber: String!
    var index = 0
    var rankIndex = 0
    var rankIndex2 = 0

    
    func itemsDownloaded(items: NSArray) {
        feedItems = items
        
        
        self.listTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.tintColor = UIColor.blackColor();
        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor();
       
        self.listTableView.delegate = self
        self.listTableView.dataSource = self
        
        let homeModel = HomeModel()
        homeModel.delegate = self
        homeModel.downloadItems()
        
        print("bs")
        if self.revealViewController() != nil {
          
            menuButton.target = revealViewController()
            menuButton.action = "revealToggle:"
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        print("as")
        
        
       // feedItems = prefs.valueForKey("feed") as! NSArray
        print("feed : ",feedItems.count)
        
        score = prefs.valueForKey("score") as! [Double]
        var score2 = score
        
         score.sortInPlace { $0 > $1 } //합산점수가 내림차순 정렬됨.
         for x in 0..<score.count{
            print(score[x]," ")
         }
        for i in 0..<score.count{
            for j in 0..<score2.count{
                if score[i] == score2[j]{
                    rank.append(j)
                }
            }
        }
        
        for i in 0..<rank.count{
            print("rank : ", rank[i])
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of feed items
        print("feed::: ",feedItems.count)
        return feedItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //pNumber이 prefs값과 같으면!추가해야됨
        let cellIdentifier: String = "recommendcell"
        let myCell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
        
        for i in 0..<feedItems.count{
            let item: LocationModel = feedItems[i] as! LocationModel
            if String(rank[rankIndex]) == item.pNumber{
                myCell.textLabel!.text = "\(rankIndex+1). " + item.pName!
            }
        }
        rankIndex += 1;
        
        return myCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow!;
        let currentCell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell!;
        
        for i in 0..<feedItems.count{
            let item: LocationModel = feedItems[i] as! LocationModel
            if String(rank[indexPath.row]) == item.pNumber{
                valueToPassName = item.pName
                valueToPassNumber = item.pNumber
            }
        }

        performSegueWithIdentifier("showseats3", sender: self)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //for tableView
        if segue.identifier == "showseats3"{
            let vc = segue.destinationViewController as! DetailViewController
            vc.navigationItem.title = valueToPassName + " 좌석"
            vc.sendName = valueToPassName
            vc.sendPnum = valueToPassNumber
        }
    }
    
}