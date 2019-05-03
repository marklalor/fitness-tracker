//
//  ViewController.swift
//  FitnessTracker
//
//  Created by Jenny Zhao on 4/24/19.
//  Copyright © 2019 Jenny Zhao. All rights reserved.
//

import UIKit
import Charts

class VisualizationsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var model: DataModel!
    
    @IBOutlet weak var exerciseNamePicker: UIPickerView!
    @IBOutlet weak var categoryPicker: UISegmentedControl!
    @IBOutlet weak var toDatePicker: UIDatePicker!
    @IBOutlet weak var fromDatePicker: UIDatePicker!
    @IBOutlet weak var weightOverTime: UIButton!
    @IBOutlet weak var strengthTrainingExerciseDistribution: UIButton!
    @IBOutlet weak var durationOverTime: UIButton!
    @IBOutlet weak var cardioExerciseDistribution: UIButton!
    
    @IBAction func categoryChanged(_ sender: Any) {
        let selectedString = categoryPicker.titleForSegment(at: categoryPicker.selectedSegmentIndex)
        
        let isStrength = selectedString == "Strength Training"
        
        weightOverTime.isEnabled = isStrength
        strengthTrainingExerciseDistribution.isEnabled = isStrength
        durationOverTime.isEnabled = !isStrength
        cardioExerciseDistribution.isEnabled = !isStrength
        self.exerciseNamePicker.reloadAllComponents();
    }
    
    func isStrength() -> Bool {
        return categoryPicker.titleForSegment(at: categoryPicker.selectedSegmentIndex) == "Strength Training"
    }
    
    func exercisesForCurrentCategory() -> [String] {
        if (isStrength()) {
            return self.model!.strengthTrainingExercises.sorted()
        } else {
            return self.model!.cardioExercises.sorted()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return exercisesForCurrentCategory().count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return exercisesForCurrentCategory()[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fromDatePicker.maximumDate = Date()
        self.toDatePicker.maximumDate = Date()
        fromDatePicker.addTarget(self, action: #selector(datePickerChanged(picker:)), for: .valueChanged)
        self.exerciseNamePicker.delegate = self
        self.exerciseNamePicker.dataSource = self
    }
    
    @objc func datePickerChanged(picker: UIDatePicker) {
        self.toDatePicker.minimumDate = fromDatePicker.date
    }
    
    func getMode(sender: UIButton) -> String {
        if (sender == weightOverTime) {
            return "weightOverTime"
        } else if (sender == strengthTrainingExerciseDistribution) {
            return "strengthTrainingExerciseDistribution"
        } else if (sender == durationOverTime) {
            return "durationOverTime"
        } else {
            return "cardioExerciseDistribution"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let chartController = segue.destination as? LineChartController {
            chartController.model = self.model
            let exercises = self.exercisesForCurrentCategory()
            chartController.exerciseName = exercises[self.exerciseNamePicker.selectedRow(inComponent: 0)]
            chartController.mode = getMode(sender: sender as! UIButton)
            chartController.startDate = self.fromDatePicker.date
            chartController.endDate = self.toDatePicker.date
        } else if let chartController = segue.destination as? PieChartController {
            chartController.model = self.model
            let exercises = self.exercisesForCurrentCategory()
            chartController.exerciseName = exercises[self.exerciseNamePicker.selectedRow(inComponent: 0)]
            chartController.mode = getMode(sender: sender as! UIButton)
            chartController.startDate = self.fromDatePicker.date
            chartController.endDate = self.toDatePicker.date
        }
    }
}

class LineChartController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    var model: DataModel!
    var exerciseName: String!
    var mode: String!
    var startDate: Date!
    var endDate: Date!
    
    var dataEntries: [ChartDataEntry] = []
    
    func makeStrengthDataEntries() -> ([ChartDataEntry], [String], Date?, Date?) {
        self.model.sortEntriesByDate(ascending: true)
        return makeDataEntries(
            entries: self.model.strengthTrainingEntries,
            yGetter: {Double($0.weight!)},
            nameGetter: {$0.exerciseName!},
            dateGetter: {$0.date!})
    }
    
    func makeCardioDataEntries() -> ([ChartDataEntry], [String], Date?, Date?) {
        self.model.sortEntriesByDate(ascending: true)
        return makeDataEntries(
            entries: self.model.cardioEntries,
            yGetter: {Double($0.duration!)},
            nameGetter: {$0.exerciseName!},
            dateGetter: {$0.date!})
    }
    
    func makeDataEntries<T>(entries: [T], yGetter: (T) -> Double, nameGetter: (T) -> String, dateGetter: (T) -> Date) -> ([ChartDataEntry], [String], Date?, Date?) {
        let filteredEntries = entries
            .filter{nameGetter($0) == exerciseName}
            .filter{dateGetter($0) >= startDate}
            .filter{dateGetter($0) <= endDate}
        
        if filteredEntries.count == 0 {
            return ([], [], nil, nil)
        }
        
        let earliest = entries.map(dateGetter).min()!
        let latest = entries.map(dateGetter).max()!
        
        let numLabels = 6.0
        let timeDiff = latest.timeIntervalSince(earliest)
        let interval = timeDiff / numLabels
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM"
        
        let labels = stride(from: 0, through: timeDiff, by: interval).map{Date(timeInterval: $0, since: earliest)}.map{formatter.string(from: $0)}

        let dataEntries = filteredEntries
            .map{ChartDataEntry(x: dateGetter($0).timeIntervalSince(earliest), y: yGetter($0))}
        
        return (dataEntries, labels, earliest, latest)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lineChartView.noDataText = "No data"
        self.model.sortEntriesByDate(ascending: true)
//        var xvalues: [String] = [String]()

        var dataEntries: [ChartDataEntry]
        var labels: [String]
        var earliest: Date?
        var latest: Date?
        if (mode == "weightOverTime") {
            (dataEntries, labels, earliest, latest) = makeStrengthDataEntries()
        } else {
            (dataEntries, labels, earliest, latest) = makeCardioDataEntries()
        }
        
        if !dataEntries.isEmpty {
        let chartDataSet = LineChartDataSet(entries: dataEntries)
        
        let chartData = LineChartData(dataSet: chartDataSet)
        
        let xAxis = lineChartView.xAxis
            xAxis.labelPosition = .bothSided
            xAxis.axisMinimum = 0.0
            let secondsInDay = 86400.0
            xAxis.axisMaximum = latest!.timeIntervalSince(earliest!) + secondsInDay
            xAxis.granularity = 1.0
            
            lineChartView.leftAxis.enabled = false
            lineChartView.rightAxis.enabled = false
            lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
            
            lineChartView.xAxis.valueFormatter = DefaultAxisValueFormatter(formatter: IntervalToDateFormatter(date: earliest!))
            
            
            self.lineChartView.data = chartData
        }
    }
    
}

class IntervalToDateFormatter: NumberFormatter {
    
    var date: Date!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    init(date: Date) {
        self.date = date
        super.init()
    }
    
    override func string(from interval: NSNumber) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM"
        let generatedDate = Date(timeInterval: Double(truncating: interval), since: self.date)
        return formatter.string(from: generatedDate)
    }
//
//    static let sharedInstance = IntervalToDateFormatter()
}

class PieChartController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var pieChartView: PieChartView!
    var model: DataModel!
    var exerciseName: String!
    var mode: String!
    var startDate: Date!
    var endDate: Date!
    
    var dataEntries: [ChartDataEntry] = []
    
    func makeStrengthDataEntries() -> [ChartDataEntry] {
        return makeDataEntries(
            entries: self.model.strengthTrainingEntries,
            exercises:  self.model.strengthTrainingExercises.sorted(),
            nameGetter: {$0.exerciseName!},
            dateGetter: {$0.date!})
    }
    
    func makeCardioDataEntries() -> [ChartDataEntry] {
        return makeDataEntries(
            entries: self.model.cardioEntries,
            exercises:  self.model.cardioExercises.sorted(),
            nameGetter: {$0.exerciseName!},
            dateGetter: {$0.date!})
    }
    
    
    func makeDataEntries<T>(entries: [T], exercises: [String], nameGetter: @escaping (T) -> String, dateGetter: (T) -> Date) -> [ChartDataEntry] {
        self.model.sortEntriesByDate(ascending: true)
        
        let filteredEntries = entries
            .filter{dateGetter($0) >= startDate!}
            .filter{dateGetter($0) <= endDate!}
        
        func getEntries(withName exerciseName: String) -> Int {
            return filteredEntries.filter{exerciseName == nameGetter($0)}.count
        }
        
        return exercises
            .map{PieChartDataEntry(value: Double(getEntries(withName: $0)), label: $0)}
            .filter{$0.y > 0}
    }
    
    
    func random0to1() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
    }
    
    func randomColor() -> UIColor {
        return UIColor(red: random0to1(), green: random0to1(), blue: random0to1(), alpha: CGFloat(1.0))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pieChartView.noDataText = "No data"
        
        if (mode == "strengthTrainingExerciseDistribution") {
            self.dataEntries = makeStrengthDataEntries()
        } else {
            self.dataEntries = makeCardioDataEntries()
        }
        
        let colors = self.dataEntries.map{_ in randomColor()}
        
        let pieChartDataSet = PieChartDataSet(entries: self.dataEntries)
        pieChartDataSet.colors = colors
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        
        self.pieChartView.data = pieChartData
    }
    
}
