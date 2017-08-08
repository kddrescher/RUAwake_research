//
//  ScoresTableViewController.swift
//  RUAwake_research
//
//  Created by Kent Drescher on 8/4/17.
//  Copyright © 2017 Kent_Drescher. All rights reserved.
//

import UIKit
import CoreData
import Charts

class ScoresTableViewController: UITableViewController {

    var testNames = ["Average Speed", "Fastest Average", "Variable Speed", "Superlapses"]
    
    var testScores = ["meanTrRT", "fastRT", "sumLFSt", "slapse"]
    
    var scoreDesc = ["This score is the adjusted average of all reaction times. Research suggests this is one of the strongest indicators of problems focusing when acutely sleep-deprived, and is the best indicator of problems when one is chronically partially sleep-deprived.", "This score is the adjusted average of the fastest 10% of reaction times.  This is the second best indicator of concentration problems when one is chronically partially sleep-deprived.", "This score is the sum of all 'false starts' and of trials that are notably slow. Both of these are indications of difficulties in focusing on the task. The score is the best indicator of cognitive problems related to acute sleep-deprivation.", "This score is the sum of all reaction times that exceeded 2 seconds. If a person has given good effort to the test, superlapses are an indicator of potentially problematic functioning, which could be dangerous in settings (such as driving) where inattention could be harmful to self or others." ]
    
    var myDates = [String]()
    var myScores = [Double]()
    
    //var chartInfo = [chartDat]()

    @IBAction func backPress(_ sender: Any) {
   
        self.dismiss(animated: true, completion: nil)
    
    
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return testScores.count

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomCell
        
        // Configure the cell...
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        cell.cellTitle?.text = testNames[indexPath.row]
        cell.cellDesc?.text = scoreDesc[indexPath.row]
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("Row \(indexPath.row) \(testScores[indexPath.row])")
        print("Row \(indexPath.row) \(testNames[indexPath.row])")
 
        

        print("DS = \(myDates), \(myScores), \(testScores[indexPath.row])")

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "openChart" ,
            let nextScene = segue.destination as? NewChartViewController ,
            let indexPath = self.tableView.indexPathForSelectedRow {
            print("SCORE = \(myDates)")
            print("SCORE = \(myScores)")
            print("SCORE = \(testNames[indexPath.row])")
            
            // Load Test Scores from Core Data
            
            let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let context = appDel.persistentContainer.viewContext
            
            //let pvtscore = PVTScores(context: context)
            
            print("fetching results")
            do {
                let results =
                    try context.fetch(PVTScores.fetchRequest())
                
                if results.count > 0 {
                    for result in results as! [PVTScores] {
                        
                        if let date = result.value(forKey: "testTime") as? String {
                            myDates.append(date)
                            print("1 = \(myDates)")
                            
                            
                            if testScores[indexPath.row] == "lapse" || testScores[indexPath.row] == "falseSt" || testScores[indexPath.row] == "sumLFSt" || testScores[indexPath.row] == "slapse" {
                                
                                //Int Values
                                if let score = result.value(forKey: testScores[indexPath.row]) as? Int {
                                    myScores.append(Double(score))
                                    print("2 = \(myScores)")
                                    
                                }
                                
                            } else {
                                //Double Values
                                if let score = result.value(forKey: testScores[indexPath.row]) as? Double {
                                    myScores.append(score)
                                    print("3 = \(myScores)")
                                }
                                
                            }
                        }
                        
                    }
                }
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            
            nextScene.incomingDates = myDates
            nextScene.incomingScores = myScores
            nextScene.incomingName = testNames[indexPath.row]
            myDates = []
            myScores = []
        }
    }
}

