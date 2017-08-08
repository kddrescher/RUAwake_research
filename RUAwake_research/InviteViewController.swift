//
//  InviteViewController.swift
//  RUAwake
//
//  Created by Kent Drescher on 10/19/16.
//  Copyright © 2016 Kent_Drescher. All rights reserved.
//

import UIKit

var myInviteCode = ""

class InviteViewController: UIViewController {
    
    static let inviteCode = "INVITE_CODE"
    
    
    @IBOutlet weak var inviteTextField: UITextField!
    
    @IBAction func saveInvite(_ sender: Any) {
        
        // Right now this only checks for a string > 0 length beforesaving the invite code into UserDefaults Ideally this would check the validity of the invite code by querying the Parse database and responf to errors appropriately.  
        
        if ((inviteTextField.text?.characters.count)! > 0)  {
            UserDefaults.standard.set(inviteTextField.text, forKey: InviteViewController.inviteCode)
            
            myInviteCode = inviteTextField.text!
            
            //
            print("Invite Code \(inviteTextField.text!) stored")
            
            
            let mainStoryBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let mainPage:ViewController = mainStoryBoard.instantiateViewController(withIdentifier: "mainScreen") as! ViewController
            
            let mainPageNav = UINavigationController(rootViewController: mainPage)
            
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            
            appDelegate.window?.rootViewController = mainPageNav
            
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
