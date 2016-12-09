//
//  BookmarkModel.swift
//  pseat3
//
//  Created by Tae Gyu Park on 11/16/16.
//  Copyright © 2016  UNO. All rights reserved.
//


import Foundation

class BookmarkModel: NSObject {
    //properties
    var id: String?
    var pNumber: String?
    var pName: String?
    
    
    //empty constructor
    override init()
    {}
    
    //construct with @name, @address, @latitude, and @longitude parameters
    init(id: String, pNumber: String, pName: String) {
        self.id = id
        self.pNumber = pNumber
        self.pName = pName
    }
    
    
    //prints object's current state
    override var description : String {
        return "id: \(id), pNumber: \(pNumber), pName: \(pName)"
        
    }
    
}