//
//  ReviewModel.swift
//  pseat3
//
//  Created by 최리아 on 11/17/16.
//  Copyright © 2016  UNO. All rights reserved.
//

import Foundation

class ReviewModel: NSObject {
    
    //properties
    
    var pNumber: String?
    var id: String?
    var rate: String?
    var review: String?
    
    //empty constructor
    
    override init()
    {
        
    }
    
    //construct with @name, @address, @latitude, and @longitude parameters
    
    init(pNumber: String, id: String, rate: String, review: String) {
        
        self.pNumber = pNumber
        self.id = id
        self.rate = rate
        self.review = review
 
        
    }
    
    
    //prints object's current state
    
    override var description : String {
        return "pNumber: \(pNumber), id: \(id), rate: \(rate), review: \(review)"
    }
    
    
}