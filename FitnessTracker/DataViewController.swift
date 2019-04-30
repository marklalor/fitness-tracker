//
//  ViewController.swift
//  FitnessTracker
//
//  Created by Jenny Zhao on 4/24/19.
//  Copyright © 2019 Jenny Zhao. All rights reserved.
//

import UIKit

class DataViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        
//        let s1 = StrengthTrainingEntry(exerciseName: "Lifting giant chocolate cake", date: Date(), weight: 9, weightUnit: StrengthTrainingEntry.WeightUnit.pounds, reps: 10, sets: 2, details: nil)
//        let c1 = CardioEntry(exerciseName: "Jogging", date: Date(), duration: 20, durationUnit: CardioEntry.DurationUnit.minutes, details: "ran really hard dude")
//
//        let model = DataModel([s1], [c1])
//        model.persist()
//        
//        let modelLoaded = DataModel.fromStorage()
//
//        for entry in modelLoaded.strengthTrainingEntries {
//            print(entry.exerciseName)
//        }
//        for entry in modelLoaded.cardioEntries {
//            print(entry.exerciseName)
//        }
    }


}

