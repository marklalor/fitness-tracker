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
        } else if let chartController = segue.destination as? PieChartController {
            chartController.model = self.model
            let exercises = self.exercisesForCurrentCategory()
            chartController.exerciseName = exercises[self.exerciseNamePicker.selectedRow(inComponent: 0)]
            chartController.mode = getMode(sender: sender as! UIButton)
        }
    }

}

class LineChartController: UIViewController, ChartViewDelegate {
    
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    var model: DataModel!
    var exerciseName: String!
    var mode: String!
    
    var dataEntries: [ChartDataEntry] = []
    
    func makeStrengthDataEntries() -> [ChartDataEntry] {
        return makeDataEntries(
            entries: self.model.strengthTrainingEntries,
            yGetter: {Double($0.weight!)},
            nameGetter: {$0.exerciseName!})
    }
    
    func makeCardioDataEntries() -> [ChartDataEntry] {
        return makeDataEntries(
            entries: self.model.cardioEntries,
            yGetter: {Double($0.duration!)},
            nameGetter: {$0.exerciseName!})
    }
    
    func makeDataEntries<T>(entries: [T], yGetter: (T) -> Double, nameGetter: (T) -> String) -> [ChartDataEntry] {
        self.model.sortEntriesByDate()
        
        return zip(entries.indices, entries)
            .filter{nameGetter($0.1) == exerciseName}
            .map{ChartDataEntry(x: Double($0.0), y: Double(yGetter($0.1)))}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lineChartView.noDataText = "No data"
        
        if (mode == "weightOverTime") {
            self.dataEntries = makeStrengthDataEntries()
        } else {
            self.dataEntries = makeCardioDataEntries()
        }
        
        let chartDataSet = LineChartDataSet(entries: self.dataEntries)
        
        let chartData = LineChartData(dataSet: chartDataSet)
        
        
        self.lineChartView.data = chartData
    }
    
}

class PieChartController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var pieChartView: PieChartView!
    var model: DataModel!
    var exerciseName: String!
    var mode: String!
    
    var dataEntries: [ChartDataEntry] = []
    
    func makeStrengthDataEntries() -> [ChartDataEntry] {
        return makeDataEntries(
            entries: self.model.strengthTrainingEntries,
            exercises:  self.model.strengthTrainingExercises.sorted(),
            yGetter: {Double($0.weight!)},
            nameGetter: {$0.exerciseName!})
    }
    
    func makeCardioDataEntries() -> [ChartDataEntry] {
        return makeDataEntries(
            entries: self.model.cardioEntries,
            exercises:  self.model.cardioExercises.sorted(),
            yGetter: {Double($0.duration!)},
            nameGetter: {$0.exerciseName!})
    }
    
    
    func makeDataEntries<T>(entries: [T], exercises: [String], yGetter: (T) -> Double, nameGetter: (T) -> String) -> [ChartDataEntry] {
        self.model.sortEntriesByDate()
        
//        return exercises.map{entries.filter()}

        return []
//        return zip(self.entries.indices, self.entries)
//            .filter{$1.exerciseName == exerciseName}
//            .map{ChartDataEntry(x: Double($0), y: Double($1.duration!))}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pieChartView.noDataText = "No data"
        
        if (mode == "strengthTrainingExerciseDistribution") {
            self.dataEntries = makeStrengthDataEntries()
        } else {
            self.dataEntries = makeCardioDataEntries()
        }
        
//        let chartDataSet = PieChartDataSet
//        let chartData = LineChartData(dataSet: chartDataSet)
        
//        self.lineChartView.data = chartData
    }
    
}
