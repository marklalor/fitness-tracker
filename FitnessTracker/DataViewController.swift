//
//  ViewController.swift
//  FitnessTracker
//
//  Created by Jenny Zhao on 4/24/19.
//  Copyright © 2019 Jenny Zhao. All rights reserved.
//

import UIKit

class DataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    let categories = ["Strength Training", "Cardio Training"]
    var categorySelected: String!
    
    var model: DataModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.model = DataModel.fromStorage()
        
        let visualizationsController = self.tabBarController!.viewControllers![1] as! VisualizationsViewController
        let editNavigationController = self.tabBarController!.viewControllers![2] as! UINavigationController
        let editController = editNavigationController.topViewController! as! EditViewController
        
        visualizationsController.model = self.model
        editController.model = self.model
        
//        self.addTestEntries()
//        self.clearEntries()
    }
    
    func addTestEntries() {
        let s1 = StrengthTrainingEntry(exerciseName: "Lifting giant chocolate cake", date: Date(), weight: 9, weightUnit: StrengthTrainingEntry.WeightUnit.pounds, reps: 10, sets: 2, details: nil)
        let c1 = CardioEntry(exerciseName: "Jogging", date: Date(), duration: 20, durationUnit: CardioEntry.DurationUnit.minutes, details: "ran really hard dude")
        self.model.strengthTrainingEntries.append(s1)
        self.model.cardioEntries.append(c1)
        self.model.persist()
    }
    
    func clearEntries() {
        self.model.strengthTrainingEntries = []
        self.model.cardioEntries = []
        self.model.persist()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ExerciseCategoryCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UITableViewCell else {
            fatalError("The dequeued cell is not an instance of ExerciseCategoryCell.")
        }
        cell.textLabel?.text = self.categories[indexPath.row]
        return cell;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.categories.count)
        return self.categories.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        categorySelected = self.categories[indexPath.row]
        print("You tapped cell number \(indexPath.row).")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "categorySegue" {
            let destinationController = segue.destination as! CategoryDataViewController
            
            destinationController.model = self.model
            
            destinationController.category = self.categories[(tableView.indexPathForSelectedRow?.row)!]
            destinationController.addNavbarButton()
        }
    }


}

