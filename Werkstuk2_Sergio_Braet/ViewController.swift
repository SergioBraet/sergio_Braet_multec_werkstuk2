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
    

    @IBOutlet weak var mapview: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://api.jcdecaux.com/vls/v1/stations?apiKey=6d5071ed0d0b3b68462ad73df43fd9e5479b03d6&contract=Bruxelles-Capitale")
        let urlRequest = URLRequest(url: url!)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let locationManager = CLLocationManager()
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let task = session.dataTask(with: urlRequest) {(data, response, error) in
            guard error == nil else{
                
                print("error calling GET")
                print(error!)
                return
            }
            
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            do{
                let villoData = try JSONSerialization.jsonObject(with: responseData, options: []) as? [AnyObject]
                
                print(villoData)
                
                
              for data in villoData! {
                    let positie = data["position"] as! NSDictionary
                    
                    let Fietsenstalling = NSEntityDescription.insertNewObject(forEntityName: "Fietsenstalling", into: managedContext) as! Fietsenstalling
                    
                    Fietsenstalling.naam = data["name"] as? String
                    Fietsenstalling.adres = data["adress"] as? String
                    Fietsenstalling.longitude = positie["lng"] as! Double
                    Fietsenstalling.lattitude = positie["lat"] as! Double
                    Fietsenstalling.beschikbare_Fietsen = Int16(data["available_bikes"] as! Int)
                    Fietsenstalling.vrije_Plaatsen = Int16(data["available_bike_stands"] as! Int)
                    
                    do{
                        try managedContext.save()
                    } catch{
                        fatalError("Failure tosave context: \(error)")
                    }
                }
                

                //!launchedbefore
                let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
                if launchedBefore  {
                  let fietsenFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Fietsenstalling")
                   let opgehaaldeVillos:[Fietsenstalling]
                    do{
                        opgehaaldeVillos = try managedContext.fetch(fietsenFetch) as! [Fietsenstalling]
                        print(opgehaaldeVillos[0].naam!)
                        
                        for villo in opgehaaldeVillos{
                            let coordinate = CLLocationCoordinate2D(latitude:
                                villo.lattitude, longitude: villo.longitude)
                            let x = annotation(coordinate: coordinate,title: villo.naam!)
                            self.mapview.addAnnotation(x)
                            
                        }
                    } catch{
                        fatalError("Failedtofetchemployees: \(error)")}
                }
                
              
                
                DispatchQueue.main.async{
                  //  self.lblTest.text = title?[0] as! String?
                }
                
            } catch {
                print(error)
            }
            
            
                   }
        task.resume()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
    }

}

