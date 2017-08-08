//
//  ViewController.swift
//  Reaction Time Task
//
//  Created by Kent Drescher on 7/1/16.
//  Copyright © 2016 Kent_Drescher. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import MessageUI

var DURATION = 3
var LOW_INTERVAL = 2
var HIGH_INTERVAL = 10
var TIMEOUT = 30.0


class ViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    var allTestResults  = [PVTScores]()
    
    var id = String()
    var lblStr = String()
    var hdrStr = String()
    
    var trialsArray = [TimeInterval]()
    var waitArray = [Double]()
    
    var countDown = 0
    
    var timer = Timer()
    let timeInt:TimeInterval = 0.005
    var timerEnd:TimeInterval = 10.0
    var timeCount:TimeInterval = 0.0
    var waitEnd:TimeInterval = 0.0
    var waitCount:TimeInterval = 0.0
    var respEnd:TimeInterval = 0.0
    var respCount:TimeInterval = 0.0
    var falseStart = 0
    var lapse = 0
    
    var isTiming = false
    var isWaiting = false
    var isShowingTime = false
    var isResponding = false
    var isTestComplete = false
    
    @IBOutlet weak var instructLabel: UILabel!
    
    @IBOutlet weak var responseButton: UIButton!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBAction func startTimer(_ sender: Any) {
        
        print("Start Pressed")
        timerEnd = Double(DURATION) * 60
        print("TimerEnd = \(timerEnd)")
        
        if (!timer.isValid) {
            isTiming = true
            
            timer = Timer.scheduledTimer(timeInterval: timeInt, target: self, selector: #selector(ViewController.increaseTimer), userInfo: nil, repeats: true)
            
            //print("timing start")
        }
        
        shareButton.isEnabled = false
        
        //setup for first trial
        instructLabel.font = UIFont.systemFont(ofSize: 30)
        instructLabel.textAlignment = NSTextAlignment.center
        instructLabel.text = ""
        
        //set and record next inter-trial interval
        var temp = Int(arc4random_uniform(UInt32((HIGH_INTERVAL * 100) - (LOW_INTERVAL * 100))))
        temp = temp + (LOW_INTERVAL * 100)
        waitEnd = Double(temp)/100
        print("Wait End = \(waitEnd) timeCount = \(timeCount)")
        waitArray.append(waitEnd)
        
        //start wait for first trial
        isWaiting = true
        startButton.isEnabled = false
        responseButton.isEnabled = true
    
    }

    
    func increaseTimer(){
        
        timeCount = timeCount + timeInt
        //print("TC = \(timeCount)")
        
        if timeCount >= timerEnd{  //test time completed
            
            print("Time Complete")
            timer.invalidate()
            isTestComplete = true
            instructLabel.textColor = UIColor.red
            instructLabel.text = "Test Complete"
            reportData()
            
        } else { //update the time on the clock if not reached
            
            if isWaiting {
                
                waitCount = waitCount + timeInt
                
                
                if (waitCount >= 1.0) && isShowingTime {
                    isShowingTime = false
                    instructLabel.textColor = UIColor.red
                    instructLabel.text = ""
                    responseButton.isEnabled = true
                }
                
                if waitCount >= waitEnd {
                    isWaiting = false
                    waitCount = 0.0
                    isResponding = true
                    
                }
            }
            
            if isResponding {
                
                respCount = respCount + timeInt
                instructLabel.text = "\(Int(respCount*1000))"
                
                if respCount >= TIMEOUT {
                    lblStr = "Timed Out"
                    isResponding = false
                    lapse+=1
                    recordTrial()
                }
            }
            
        }
        
    }
    
    @IBAction func respondPress(_ sender: Any) {
   
        //Check for False Start
        if (isWaiting) {
            falseStart+=1
            waitCount = 0.0
            lblStr = "FALSE START"
            //print("\(falseStart) False Start(s)")
        }
        //Check for < 100ms
        if respCount > 0.0 && respCount <= 0.1 {
            falseStart+=1
            lblStr = "FALSE START"
            //print("\(falseStart) False Start(s)")
            
        }
        
        //Check for Lapse <30sec
        if respCount > 0.500 {
            lapse+=1
            //print("\(lapse) Lapse(s) Recorded \(respCount)")
        }
        recordTrial()
        
    
    }
    
    
    func recordTrial() {
        
        if lblStr == "Timed Out" {
            playSound()
        }
        
        //Record Trial time
        trialsArray.append(respCount)
        print("Resp Time: \(Int(respCount*1000))")
        isResponding = false
        
        //setup for next trial
        instructLabel.font = UIFont.systemFont(ofSize: 30)
        instructLabel.textAlignment = NSTextAlignment.center
        
        //set and record next inter-trial interval
        var temp = Int(arc4random_uniform(UInt32((HIGH_INTERVAL * 100) - (LOW_INTERVAL * 100))))
        temp = temp + (LOW_INTERVAL * 100)
        waitEnd = Double(temp)/100
        print("Wait End = \(waitEnd) timeCount = \(timeCount)")
        waitArray.append(waitEnd)
 
        //start wait for next trial
        isWaiting = true
        isShowingTime = true
        instructLabel.textColor = UIColor.green
        if lblStr == "" {
            lblStr = "\(Int(respCount*1000))"
        }
        instructLabel.text = lblStr
        respCount = 0.0
        lblStr = ""
        
    }
    
    func reportData() {
        
        var median: Double
        var lapse: Int
        var falseSt: Int
        var lapsePR: Double
        var sumLFSt: Int
        var perfScr: Double
        var meanRT: Double
        var meanTrRT: Double
        var fastRT: Double
        var slowRT: Double
        var slapse: Int
        var meanSLapse: Double
        
        var filteredArray = [Double]()
        var lapseArray = [Double]()
        var slapseArray = [Double]()
        
        print("entering reportData")
        
        filteredArray = trialsArray.filter({$0 > 0.100})
        filteredArray.sort {
            return $0 < $1 }
        
        //Median RT (does this include False Starts?  Assuming No)
        let med = Int(filteredArray.count / 2)
        median = filteredArray[med-1]
        print("Median = \(median)")
        
        //Mean RT (does this include False Starts?  Assuming No)
        var sum = 0.0
        for tr in filteredArray {
            sum = sum+tr
            //print("sum = \(sum) tr \(tr)")
        }
        meanRT = sum / Double(filteredArray.count)
        print("meanRT = \(meanRT)")
        
        //Fastest 10% RT (is this Sum or Mean? Assuming mean)
        let tenth = Int(round(Double(filteredArray.count) / 10.0))
        
        print("tenth = \(tenth)")
        sum = 0.0
        for i in 0...tenth-1 {
            sum = sum + filteredArray[i]
            //print("i=\(i) = \(filteredArray[i]) sum = \(sum)")
        }
        fastRT = sum / Double(tenth)
        print("fastRT = \(fastRT)")
        
        
        //Mean 1/RT
        sum = 0.0
        for tr in filteredArray {
            sum = sum + (1.0 - (tr))
            print("1/RT \(1-(tr))")
        }
        meanTrRT = sum / Double(filteredArray.count)
        print("meanTrRT = \(meanTrRT)")
        
        // 10% 1/RT (is this Sum or Mean? Assuming mean)
        sum = 0.0
        
        for i in (filteredArray.count-1)-tenth+1...filteredArray.count-1 {
            sum = sum + (1.0 - filteredArray[i])
            print("i=\(i) = \(1.0 - filteredArray[i]) sum = \(sum)")
        }
        slowRT = sum / Double(tenth)
        print("slowRT = \(slowRT)")
        
        //Number of Lapses
        lapseArray = trialsArray.filter({$0 > 0.500})
        lapse = lapseArray.count
        print("lapse = \(lapse)")
        
        //Number and mean of supeLapses
        slapseArray = trialsArray.filter({$0 > 2.000})
        slapse = slapseArray.count
        
        sum = 0.0
        for sl in slapseArray {
            sum = sum + sl
            
        }
        if slapseArray.count > 0 {
            meanSLapse = sum / Double(slapseArray.count)
        } else {
            meanSLapse = 0.000000
        }
        
        print("superlapse = \(slapse) meanSL = \(meanSLapse)")
        
        //Lapse Probability (i.e., number of lapses divided by the number of valid stimuli, excluding false starts)
        lapsePR = Double(lapse) / Double(filteredArray.count)
        print("lapsePR = \(lapsePR)")
        
        //Number of false starts
        falseSt = trialsArray.count - filteredArray.count
        print("falseSt = \(falseSt)")
        
        //Sum of Lapses and False Starts
        sumLFSt = lapse + falseSt
        print("sumLFSt = \(sumLFSt)")
        
        //Performance Score (i.e. defined as 1 minus the number of lapses and false starts divided by the number of valid stimuli (including false starts)
        perfScr = 1.0 - (Double(sumLFSt) / Double(trialsArray.count))
        print("perfScr = \(perfScr)")
        
        
        hdrStr = "trials, median, meanRT, fastRT, mean1_RT, slow1_RT, lapse, lapsePR, falseSt, sumLFSt, perfScr, sLapse, meanSLapse"
        
        var outputStr = String(trialsArray.count) + ", \(median), \(meanRT), \(fastRT), \(meanTrRT), \(slowRT), \(lapse), \(lapsePR), \(falseSt), \(sumLFSt), \(perfScr), \(slapse),\(meanSLapse)"
        
        for i in 0...trialsArray.count-1 {
            outputStr = outputStr + ", " +  timeString(time: trialsArray[i]) + ", " +  waitString(time: waitArray[i])
            hdrStr = hdrStr + ", rt\(i+1)" + ", w\(i+1)"
            
        }
        
        hdrStr = hdrStr + "\n" + outputStr
        
        
        //Prepare to save test in Core Data
        let date = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let today = formatter.string(from: date as Date)
        formatter.dateFormat = "HH:mm"
        let curtime = formatter.string(from: date as Date)
        
        //Present Score and Save data to Core data the dismiss controller
        
        //1
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        //2
        //let pvtscore = PVTScores(context: context)
        let pvtscore = NSEntityDescription.insertNewObject(forEntityName: "PVTScores", into: context)
        
        //3
        pvtscore.setValue(today, forKey: "testDate")
        pvtscore.setValue(curtime, forKey: "testTime")
        pvtscore.setValue(median, forKey: "median")
        pvtscore.setValue(lapse, forKey: "lapse")
        pvtscore.setValue(falseSt, forKey: "falseSt")
        pvtscore.setValue(lapsePR, forKey: "lapsePR")
        pvtscore.setValue(sumLFSt, forKey: "sumLFSt")
        pvtscore.setValue(perfScr, forKey: "perfScr")
        pvtscore.setValue(meanRT, forKey: "meanRT")
        pvtscore.setValue(meanTrRT, forKey: "meanTrRT")
        pvtscore.setValue(fastRT, forKey: "fastRT")
        pvtscore.setValue(slowRT, forKey: "slowRT")
        pvtscore.setValue(slapse, forKey: "slapse")
        pvtscore.setValue(meanSLapse, forKey: "meanSLapse")
        pvtscore.setValue(outputStr, forKey: "pvtCSV")
        
        //4        appDelegate.saveContext()
        do {
            
            try context.save()
            
            print("Real Data Saved")
            
        } catch {
            
            print("There was an error")
            
        }
        
        //5
        allTestResults.append(pvtscore as! PVTScores)
        
        
        //Reset variables for next test
        responseButton.isEnabled = false
        timerEnd = 10.0
        timeCount = 0.0
        waitEnd = 0.0
        waitCount = 0.0
        respEnd = 0.0
        respCount = 0.0
        falseStart = 0
        lapse = 0
        isTiming = false
        isWaiting = false
        isShowingTime = false
        isResponding = false
        isTestComplete = false
        shareButton.isEnabled = true
        hdrStr = ""
        outputStr = ""
        
        startButton.isEnabled = true
        
        
    }
    
    func timeString(time:TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = time - Double(minutes) * 60
        let secondsFraction = seconds - Double(Int(seconds))
        return String(format:"%01i.%03i",Int(seconds),Int(secondsFraction * 1000.0))
    }
    
    func waitString(time:TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = time - Double(minutes) * 60
        let secondsFraction = seconds - Double(Int(seconds))
        return String(format:"%01i.%01i",Int(seconds),Int(secondsFraction * 10.0))
    }
    
    
    func getCurrentShortDate() -> String {
        let todaysDate = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let DateInFormat = dateFormatter.string(from: todaysDate as Date)
        
        return DateInFormat
    }
    
    
    func playSound() {
        
        let systemSoundID: SystemSoundID = 1053
        AudioServicesPlaySystemSound (systemSoundID)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(myInviteCode)
        
        //UIApplicationDidEnterBackgroundNotification
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(ViewController.didEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)

        
        
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDel.persistentContainer.viewContext
        
        //let pvtscore = PVTScores(context: context)
        
        
        do {
            let result =
                try context.fetch(PVTScores.fetchRequest())
            
            let pvtscores = result as! [PVTScores]
            print("Core Data has \(pvtscores.count) test records")
            print(pvtscores)
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        instructLabel.font = UIFont.systemFont(ofSize: 13)
        instructLabel.textAlignment = NSTextAlignment.left
        instructLabel.text = "INSTRUCTIONS: Press Red Start button to begin.  Each time you see red numbers in this white box, press the PRESS to RESPOND button as quickly as possible.  Make sure not to press before you see the red numbers."
        instructLabel.textColor = UIColor.red
        instructLabel.backgroundColor = UIColor.white
        
        responseButton.layer.cornerRadius = responseButton.bounds.height/20
        responseButton.layer.shadowRadius = 4
        responseButton.layer.shadowOpacity = 0.5
        responseButton.layer.shadowOffset = CGSize.zero
        
        startButton.layer.cornerRadius = startButton.bounds.height/10
        startButton.layer.shadowRadius = 4
        startButton.layer.shadowOpacity = 0.5
        startButton.layer.shadowOffset = CGSize.zero
        startButton.isEnabled = true
        
    }
    
    func didEnterBackground() {
        self.timer.invalidate()
        //Reset variables for next test
        responseButton.isEnabled = false
        timerEnd = 2.0
        timeCount = 0.0
        waitEnd = 0.0
        waitCount = 0.0
        respEnd = 0.0
        respCount = 0.0
        falseStart = 0
        lapse = 0
        isTiming = false
        isWaiting = false
        isShowingTime = false
        isResponding = false
        isTestComplete = false
        hdrStr = ""
        
        
        shareButton.isEnabled = true
        instructLabel.font = UIFont.systemFont(ofSize: 13)
        instructLabel.textAlignment = NSTextAlignment.left
        instructLabel.text = "INSTRUCTIONS: Press Red Start button to begin.  Each time you see red numbers in this white box, press the PRESS to RESPOND button as quickly as possible.  Make sure not to press before you see the red numbers."
        instructLabel.textColor = UIColor.red
        instructLabel.backgroundColor = UIColor.white
        
        startButton.isEnabled = false
        
        print("entered background and cleared data")
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        
        
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    
    
    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "outputSegue" {
            let vc = segue.destinationViewController as! UINavigationController
            
            
        }
        
    }*/
    
}

