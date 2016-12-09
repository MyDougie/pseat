//
//  LocationModel.swift
//  pseat3
//
//  Created by  UNO on 8/4/16.
//  Copyright © 2016  UNO. All rights reserved.
//

import Foundation

class LocationModel: NSObject {
    
    //properties
    
    var pName: String?
    var pAddr: String?
    var pLati: String?
    var pLong: String?
    var pNumber: String?
    
    
    //empty constructor
    
    override init()
    {
        
    }
    
    //construct with @name, @address, @latitude, and @longitude parameters
    
    init(pName: String, pAddr: String, pLati: String, pLong: String, pNumber: String) {
        
        self.pName = pName
        self.pAddr = pAddr
        self.pLati = pLati
        self.pLong = pLong
        self.pNumber = pNumber
        
    }
    
    
    //prints object's current state
    
    override var description : String {
        return "pName: \(pName), pAddr: \(pAddr), pLati: \(pLati), pLong: \(pLong), pNumber: \(pNumber)"
        
    }
    
    
}