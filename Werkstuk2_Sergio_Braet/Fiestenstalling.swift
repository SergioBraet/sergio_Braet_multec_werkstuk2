//
//  Fiestenstalling.swift
//  Werkstuk2_Sergio_Braet
//
//  Created by student on 30/04/18.
//  Copyright © 2018 student. All rights reserved.
//

import Foundation

class Fiestenstalling{
    
    var naam: String
    var adres: String
    var lattitude: Double
    var longitude: Double
    var beschikbare_Fietsen: Int
    var vrije_Plaatsen: Int
    
    
    init(naam: String, adres: String, lattitude: Double, longitude: Double, beschikbare_Fietsen: Int, vrije_Plaatsen: Int) {
        self.naam = naam
        self.adres = adres
        self.lattitude = lattitude
        self.longitude = longitude
        self.beschikbare_Fietsen = beschikbare_Fietsen
        self.vrije_Plaatsen = vrije_Plaatsen
        
    }
}
