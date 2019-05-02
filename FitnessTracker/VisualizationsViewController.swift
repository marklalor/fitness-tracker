//
//  ViewController.swift
//  FitnessTracker
//
//  Created by Jenny Zhao on 4/24/19.
//  Copyright © 2019 Jenny Zhao. All rights reserved.
//

import UIKit
import Charts

class VisualizationsViewController: UIViewController {

    var model: DataModel!
    
    @IBOutlet weak var categoryPicker: UISegmentedControl!
    
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
