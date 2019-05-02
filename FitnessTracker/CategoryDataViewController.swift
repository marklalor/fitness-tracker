//
//  CategoryDataViewController.swift
//  FitnessTracker
//
//  Created by Jenny Zhao on 4/30/19.
//  Copyright © 2019 Jenny Zhao. All rights reserved.
//

import UIKit

class CategoryDataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var category: String!
    var model : DataModel!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func addNavbarButton() {
        let button = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(transitionAdd(sender:)))
        self.navigationItem.rightBarButtonItem = button
    }
    
    @objc func transitionAdd(sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(
            withIdentifier: category == "Cardio Training" ? "cardioEntry": "strengthEntry")
        
        if let controller = controller as? AddStrengthEntryViewController {
            controller.exercises = self.model.strengthTrainingExercises.sorted()
            controller.model = self.model
        } else if let controller = controller as? AddCardioEntryViewController {
            controller.exercises = self.model.cardioExercises.sorted()
            controller.model = self.model
        }
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (category == "Cardio Training"){
            return self.model.cardioEntries.count
        }
        else if (category == "Strength Training"){
            return self.model.strengthTrainingEntries.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ExerciseEntryCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UITableViewCell  else {
            fatalError("The dequeued cell is not an instance of ExerciseCategoryCell.")
        }
        if (category == "Strength Training"){
            cell.textLabel?.text = self.model.strengthTrainingEntries[indexPath.row].exerciseName
            print("St")
        }
        else if (category == "Cardio Training"){
            cell.textLabel?.text = self.model.cardioEntries[indexPath.row].exerciseName
            print("CR")
        }
        else {
            cell.textLabel?.text = "None"
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }

    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

}
