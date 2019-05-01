//
//  CategoryDataViewController.swift
//  FitnessTracker
//
//  Created by Jenny Zhao on 4/30/19.
//  Copyright © 2019 Jenny Zhao. All rights reserved.
//

import UIKit

class CategoryDataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var category: String = ""
    var modelLoaded : DataModel?
    var strengthTrainingEntries : [StrengthTrainingEntry]?
    var cardioTrainingEntries : [CardioEntry]?

    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.cardioTrainingEntries = modelLoaded?.cardioEntries
        self.strengthTrainingEntries = modelLoaded?.strengthTrainingEntries
        print(category);
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        tableView.reloadData()
//    }
//
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (category == "Cardio Training"){
            return (self.cardioTrainingEntries?.count)!
        }
        else if (category == "Strength Training"){
            return (self.strengthTrainingEntries?.count)!
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
            cell.textLabel?.text = self.strengthTrainingEntries![indexPath.row].exerciseName
            print("St")
        }
        else if (category == "Cardio Training"){
            cell.textLabel?.text = self.cardioTrainingEntries![indexPath.row].exerciseName
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }

}
