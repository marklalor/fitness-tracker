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
    
    func data(for pickerView: UIPickerView) -> [String] {
        if (categoryPicker.titleForSegment(at: categoryPicker.selectedSegmentIndex) == "Strength Training"){
            print("str")
            return self.model!.strengthTrainingExercises.sorted()
        }
        else {
            print("car")
            return self.model!.cardioExercises.sorted()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data(for: pickerView).count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data(for: pickerView)[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.exerciseNamePicker.delegate = self
        self.exerciseNamePicker.dataSource = self
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
        
        if let chartController = segue.destination as? ChartController {
            chartController.model = self.model
            chartController.mode = getMode(sender: sender as! UIButton)
        }
    }

}

class ChartController: UIViewController {
    
    var model: DataModel!
    var mode: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}
