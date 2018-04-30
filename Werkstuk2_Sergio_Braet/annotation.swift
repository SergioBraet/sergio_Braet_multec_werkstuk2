//
//  annotation.swift
//  Werkstuk2_Sergio_Braet
//
//  Created by student on 30/04/18.
//  Copyright © 2018 student. All rights reserved.
//

import MapKit

class annotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    init(coordinate: CLLocationCoordinate2D, title: String)
    {
        self.coordinate = coordinate
        self.title = title
    }
}
