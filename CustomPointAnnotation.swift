//
//  CustomPointAnnotation.swift
//  pseat3
//
//  Created by Tae Gyu Park on 10/27/16.
//  Copyright © 2016  UNO. All rights reserved.
//

import Foundation
import MapKit

class CustomPointAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var imageName: String!
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}