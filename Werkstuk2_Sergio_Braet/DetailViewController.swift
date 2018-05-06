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
    @IBOutlet weak var lblVrijePlaatsen: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let preferredLanguage = NSLocale.preferredLanguages[0]

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let nummerFiestenstalling = naamFiestenstalling?.components(separatedBy: " ").first
    
        let fietsenFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Fietsenstalling")
        //bron contains: https://stackoverflow.com/questions/24176605/using-predicate-in-swift?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
        fietsenFetch.predicate = NSPredicate(format: "naam contains %@", nummerFiestenstalling!)
 
        let opgehaaldeVillos:[Fietsenstalling]
        
        do{
            opgehaaldeVillos = try managedContext.fetch(fietsenFetch) as! [Fietsenstalling]
            
            self.lblStationsnaam.text = naamFiestenstalling
            self.lblBeschikbaar.text =  self.lblBeschikbaar.text! + " " + String(opgehaaldeVillos[0].beschikbare_Fietsen)
            self.lblVrijePlaatsen.text = self.lblVrijePlaatsen.text! + " " + String(opgehaaldeVillos[0].vrije_Plaatsen)
            
            if preferredLanguage.contains("nl"){
                if opgehaaldeVillos[0].status! == "OPEN"{
                    self.lblStatus.text = self.lblStatus.text! + " " + "open"
                }else if opgehaaldeVillos[0].status! == "CLOSED" {
                    self.lblStatus.text = self.lblStatus.text! + " " + "gesloten"
                }
            } else if preferredLanguage.contains("fr"){
                if opgehaaldeVillos[0].status! == "OPEN"{
                    self.lblStatus.text = self.lblStatus.text! + " " + "ouvert"
                }else if opgehaaldeVillos[0].status! == "CLOSED" {
                    self.lblStatus.text = self.lblStatus.text! + " " + "fermé"
                }
            }
            
        } catch{
            fatalError("Failedtofetchemployees: \(error)")
        }
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
