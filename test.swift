//
//  test.swift
//  pseat3
//
//  Created by Tae Gyu Park on 11/6/16.
//  Copyright © 2016  UNO. All rights reserved.
//


import UIKit

class test: UIViewController {
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("a")
        if self.revealViewController() != nil {
            print("b")
            menuButton.target = revealViewController()
            menuButton.action = "revealToggle:"
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}