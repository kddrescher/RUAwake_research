//
//  NewChartViewController.swift
//  
//
//  Created by Kent Drescher on 8/5/17.
//
//

import UIKit
import Foundation
import Charts


class NewChartViewController: UIViewController {

    var incomingDates = [String]()
    var incomingScores = [Double]()
    var incomingName: String = ""
    
    var months: [String]!
    var unitsSold = [Double]()
    weak var axisFormatDelegate: IAxisValueFormatter?
    
    @IBOutlet weak var viewForChart: LineChartView!
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()        // Do any additional setup after loading the view, typically from a nib.
        
        print("CHRT = \(incomingDates)")
        print("CHRT = \(incomingScores)")
        print("CHRT = \(incomingName)")
        
        axisFormatDelegate = self as IAxisValueFormatter
        
        setChart(dataEntryX: incomingDates, dataEntryY: incomingScores)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setChart(dataEntryX forX:[String],dataEntryY forY: [Double]) {
        viewForChart.noDataText = "You need to provide data for the chart."
        viewForChart.chartDescription?.text = ""
        var dataEntries:[ChartDataEntry] = []
        
        for i in 0..<forX.count{
            
            let dataEntry = ChartDataEntry(x: Double(i), y: Double(forY[i]) , data: incomingDates as AnyObject?)
            
            print("count = \(forX.count)")
            
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = LineChartDataSet(values: dataEntries, label: incomingName)
        let chartData = LineChartData(dataSet: chartDataSet)
        viewForChart.data = chartData
        viewForChart.xAxis.setLabelCount(incomingDates.count, force: true)

        let xAxisValue = viewForChart.xAxis
        xAxisValue.valueFormatter = axisFormatDelegate
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        navItem.title = incomingName
    }

    
    
}

extension NewChartViewController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return incomingDates[Int(value)]
    }
}

