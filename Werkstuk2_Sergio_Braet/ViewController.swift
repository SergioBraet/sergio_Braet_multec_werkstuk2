//
//  ViewController.swift
//  Werkstuk2_Sergio_Braet
//
//  Created by student on 29/04/18.
//  Copyright © 2018 student. All rights reserved.
//  bron cornerRadius in DetailviewController (storyboard): https://www.youtube.com/watch?v=wz7UYNKLSZs
//
/*
 
 */
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

    @IBAction func update(_ sender: UIButton) {
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
            fatalError("kon gegevens niet ophalen: \(error)")
        }
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
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: center, span: span)
        mapview.setRegion(region, animated: true)
    }
    
    //bron: http://swiftdeveloperblog.com/code-examples/mkannotationview-display-custom-pin-image/
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotation")
        
        if annotationView == nil{
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "fietsenstalling")
            annotationView?.image = UIImage(named: "fietsIcon")
            let calloutButton = UIButton(type: .infoDark)
            annotationView!.rightCalloutAccessoryView = calloutButton
            annotationView!.sizeToFit()
        }
        
        if let title = annotation.title, title == "Ma position" || title == "My Location" || title == "Mijn locatie" {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "gebruiker")
            annotationView?.image = UIImage(named: "userIcon")
        }
        
        annotationView?.canShowCallout = true
        
        return annotationView
        
    }
    
    //Bron: https://stackoverflow.com/questions/15270085/pass-data-between-view-controllers-without-segues
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let detailViewConroller = self.storyboard?.instantiateViewController(withIdentifier: "detailViewControllerID") as! DetailViewController
            detailViewConroller.naamFiestenstalling = (view.annotation?.title)!
            self.navigationController?.pushViewController(detailViewConroller, animated: true)
            
        }
    }
    
    
    
    
    func toonGegevens(){
        DispatchQueue.main.async {
            let fietsenFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Fietsenstalling")
            let opgehaaldeVillos:[Fietsenstalling]
            do{
                opgehaaldeVillos = try self.managedContext?.fetch(fietsenFetch) as! [Fietsenstalling]
                
                for villo in opgehaaldeVillos{
                    var naamJuisteTaal = ""
                    let preferredLanguage = NSLocale.preferredLanguages[0]
                    
                    let splitsOpNummer = villo.naam?.components(separatedBy: "-")
                    let splitsOpNaam = splitsOpNummer?[1].components(separatedBy: "/")
                
                    if preferredLanguage.contains("nl"){
                        if (splitsOpNaam?.count)!>=2{
                             naamJuisteTaal = (splitsOpNummer?[0])! + " " + (splitsOpNaam?[1])!
                        }else{
                            naamJuisteTaal = (splitsOpNummer?[0])! + " " + (splitsOpNaam?[0])!
                        }
                    
                     } else if preferredLanguage.contains("fr"){
                        naamJuisteTaal = (splitsOpNummer?[0])! + " " + (splitsOpNaam?[0])!
                    }else{
                        naamJuisteTaal = (splitsOpNummer?[0])! + " " + (splitsOpNaam?[0])!
                    }
                    
                
                    let coordinate = CLLocationCoordinate2D(latitude: villo.lattitude, longitude: villo.longitude)
                    let x = annotation(coordinate: coordinate,title: naamJuisteTaal.components(separatedBy: "(").first!)
                    self.mapview.addAnnotation(x)
                    
                }
            } catch{
                fatalError("De gegevens konden niet worden opgehaald: \(error)")
            }
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
                    DispatchQueue.main.async {
                        let positie = data["position"] as! NSDictionary
                        
                        let Fietsenstalling = NSEntityDescription.insertNewObject(forEntityName: "Fietsenstalling", into: self.managedContext!) as! Fietsenstalling
                        
                        Fietsenstalling.naam = data["name"] as? String
                        Fietsenstalling.status = data["status"] as? String
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
        DispatchQueue.main.async {
            //bron: https://ios8programminginswift.wordpress.com/2014/08/16/get-current-date-and-time-quickcode/
            let todaysDate:NSDate = NSDate()
            let dateFormatter:DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
            let DateInFormat:String = dateFormatter.string(from: todaysDate as Date)
            //self.lblUpdateTijd.text = "Gegevens geüpdated op \(DateInFormat)"
            self.lblUpdateTijd.text = NSLocalizedString("gewijzigdeGegevens", comment: "") + DateInFormat
        }

    }
    
}
