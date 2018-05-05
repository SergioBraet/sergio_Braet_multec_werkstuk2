//
//  DetailViewController.swift
//  Werkstuk2_Sergio_Braet
//
//  Created by student on 04/05/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    
    var naamFiestenstalling:String?
    
    @IBOutlet weak var lblStationsnaam: UILabel!
    @IBOutlet weak var lblBeschikbaar: UILabel!
    @IBOutlet weak var lblAdres: UILabel!
    @IBOutlet weak var lblVrijePlaatsen: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
       let nummerFiestenstalling = naamFiestenstalling?.components(separatedBy: " ").first
        
        print(nummerFiestenstalling)
    
      let fietsenFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Fietsenstalling")
        //bron contains: https://stackoverflow.com/questions/24176605/using-predicate-in-swift?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
         fietsenFetch.predicate = NSPredicate(format: "naam contains %@", nummerFiestenstalling!)
 
      let opgehaaldePersonen:[Fietsenstalling]
        do{
            opgehaaldePersonen = try managedContext.fetch(fietsenFetch) as! [Fietsenstalling]
            print(opgehaaldePersonen[0].adres!)
        } catch{
            fatalError("Failedtofetchemployees: \(error)")}
        /*
        
        let nummer = spiltStationOpNummerArray![0]
        let restNaam = spiltStationOpNummerArray![1]
        print("Nummer: \(nummer)")
        print("Rest station: \(restNaam)")
        
        let spiltStationOpTaalArray = spiltStationOpNummerArray![1].components(separatedBy: "/")
       print(spiltStationOpTaalArray)
       if spiltStationOpTaalArray.count>=2{
            let nederlands = spiltStationOpTaalArray[1]
            print("Nederlands: \(nederlands)")
        }else{
            let nederlands = spiltStationOpTaalArray[0]
            print("Nederlands: \(nederlands)")

        }
        let frans = spiltStationOpTaalArray[0]
               print("Frans: \(frans)")*/
        //
       // var myStringArr = stationNaam?.components(separatedBy: "-")

        //let preferredLanguage = NSLocale.preferredLanguages[0]
        
      /*  if preferredLanguage.contains("nl"){
            print("this is nl")
        } else if preferredLanguage.contains("fr"){
            print("this is fr")
        }*/
       // self.lblStationsnaam.text = myStringArr?[1]

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
