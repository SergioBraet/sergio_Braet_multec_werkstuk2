//
//  ViewController.swift
//  Werkstuk2_Sergio_Braet
//
//  Created by student on 29/04/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    let urlRequest = URLRequest(url: URL(string: "https://api.jcdecaux.com/vls/v1/stations?apiKey=6d5071ed0d0b3b68462ad73df43fd9e5479b03d6&contract=Bruxelles-Capitale")!)
    let session = URLSession(configuration: URLSessionConfiguration.default)
    let managedContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet weak var lblUpdateTijd: UILabel!
    @IBAction func UpdateGegevens(_ sender: UIButton) {
        let alleAnnotations = mapview.annotations
        mapview.removeAnnotations(alleAnnotations)
        
        let fietsenFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Fietsenstalling")
        
        let opgehaaldeVillos:[Fietsenstalling]
        do{
            opgehaaldeVillos = try managedContext?.fetch(fietsenFetch) as! [Fietsenstalling]
            
            for villo in opgehaaldeVillos{
                managedContext?.delete(villo)
                try! managedContext?.save()
                
            }

            haalGegevensOp()
            
        } catch{
            fatalError("Failedtofetchemployees: \(error)")}
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        locationManager.requestAlwaysAuthorization()
        
        locationManager.startUpdatingLocation()
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if !launchedBefore{
            self.haalGegevensOp()
        }else{
            self.toonGegevens()
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: center, span: span)
        mapview.setRegion(region, animated: true)
    }
    
    
    func toonGegevens(){
        let fietsenFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Fietsenstalling")
        let opgehaaldeVillos:[Fietsenstalling]
        do{
            opgehaaldeVillos = try self.managedContext?.fetch(fietsenFetch) as! [Fietsenstalling]
            
            for villo in opgehaaldeVillos{
                
                let coordinate = CLLocationCoordinate2D(latitude: villo.lattitude, longitude: villo.longitude)
                let x = annotation(coordinate: coordinate,title: villo.naam!)
                self.mapview.addAnnotation(x)
                
            }
        } catch{
            fatalError("De gegevens konden niet worden opgehaald: \(error)")
        }

        
    }
    
    func haalGegevensOp(){
        let task = session.dataTask(with: urlRequest) {(data, response, error) in
            guard error == nil else{
                
                print("kon get functie niet aanroepen")
                print(error!)
                return
            }
            
            guard let responseData = data else {
                print("Error: geen data ontvangen")
                return
            }
            
            do{
                let villoData = try JSONSerialization.jsonObject(with: responseData, options: []) as? [AnyObject]

                for data in villoData! {
                    let positie = data["position"] as! NSDictionary
                    
                    let Fietsenstalling = NSEntityDescription.insertNewObject(forEntityName: "Fietsenstalling", into: self.managedContext!) as! Fietsenstalling
                    
                    Fietsenstalling.naam = data["name"] as? String
                    Fietsenstalling.adres = data["adress"] as? String
                    Fietsenstalling.longitude = positie["lng"] as! Double
                    Fietsenstalling.lattitude = positie["lat"] as! Double
                    Fietsenstalling.beschikbare_Fietsen = Int16(data["available_bikes"] as! Int)
                    Fietsenstalling.vrije_Plaatsen = Int16(data["available_bike_stands"] as! Int)
                    
                    do{
                        try self.managedContext?.save()
                    } catch{
                        fatalError("kon context niet opslaan: \(error)")
                    }
                }
                      self.toonGegevens()
                      self.updateTijd()
                
            } catch {
                print(error)
            }
            
            
        }
        task.resume()
  
        
    }
    
    func updateTijd(){
        var todaysDate:NSDate = NSDate()
        var dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let DateInFormat:String = dateFormatter.string(from: todaysDate as Date)
        self.lblUpdateTijd.text = "Gegevens geüpdated op \(DateInFormat)"
    }
    
}

