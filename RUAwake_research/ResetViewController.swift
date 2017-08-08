//
//  ResetViewController.swift
//  RUAwake
//
//  Created by Kent Drescher on 10/24/16.
//  Copyright © 2016 Kent_Drescher. All rights reserved.
//

import UIKit
import CoreData


class ResetViewController: UIViewController {
    
    var coreReset = false
    
    @IBOutlet weak var passTextField: UITextField!
    
    @IBAction func backPress(_ sender: Any) {
    
        if !coreReset {
            dismiss(animated: true, completion: nil)
        }
    
    }
    
    @IBAction func resetButtonPress(_ sender: Any) {

        //Check Password
        
        if passTextField.text == "NCPTSD2016" {
            
            let alertController = UIAlertController(title: "Password Correct", message: "Are you sure you want to reset the Invite Code and ALL Data? This action is permanent!", preferredStyle: .alert)
            
            let actionYes = UIAlertAction(title: "Yes", style: .default) { (action:UIAlertAction) in
                print("You've pressed the Yes button");
                
                //Clear Invite Code from NSUserDefaults
                UserDefaults.standard.removeObject(forKey: "INVITE_CODE")
                
                //Clear Core Data
                
                self.deleteData()
                print("Password Correct")
                self.coreReset = true
                
                self.passTextField.text = ""
                
            }
            
            let actionNo = UIAlertAction(title: "No", style: .default) { (action:UIAlertAction) in
                print("You've pressed No button");
            }
            
            alertController.addAction(actionYes)
            alertController.addAction(actionNo)
            self.present(alertController, animated: true, completion:nil)
            
            
        } else {
            
            print("Password Incorrect")
            let alertController = UIAlertController(title: "Error", message: "Password Incorrect", preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                print("You've pressed OK button");
            }
            
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion:nil)
            
        }
        
        
        
    
    }
        
    func deleteData() {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDel.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PVTScores")

        let result = try? context.fetch(fetchRequest)
            let resultData = result as! [PVTScores]
        
        for object in resultData {
            context.delete(object)
        }
        
        
        do {
            try context.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }


    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
