//
//  LocationModel.swift
//  pseat3
//
//  Created by  UNO on 8/4/16.
//  Copyright © 2016  UNO. All rights reserved.
//

import Foundation

class SeatModel: NSObject {
    
    //properties
    
    var pNumber: String?
    var seatForm: String?
    var seat1: String?
    var seat2: String?
    var seat3: String?
    var seat4: String?
    
    
    //empty constructor
    
    override init()
    {
        
    }
    
    //construct with @name, @address, @latitude, and @longitude parameters
    
    init(pNumber: String, seatForm: String, seat1: String, seat2: String, seat3: String, seat4: String){
        
        self.pNumber = pNumber
        self.seatForm = seatForm
        self.seat1 = seat1
        self.seat2 = seat2
        self.seat3 = seat3
        self.seat4 = seat4
    }
    
    
    //prints object's current state
    
    override var description : String {
        return "pNumber: \(pNumber), seatForm: \(seatForm), seat1: \(seat1), seat2: \(seat2), seat3: \(seat3), seat4: \(seat4)"
        
    }
}