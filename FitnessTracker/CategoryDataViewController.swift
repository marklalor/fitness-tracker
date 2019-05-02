//
//  CategoryDataViewController.swift
//  FitnessTracker
//
//  Created by Jenny Zhao on 4/30/19.
//  Copyright © 2019 Jenny Zhao. All rights reserved.
//

import UIKit

class CategoryDataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var sortPicker: UISegmentedControl!
    
    var category: String!
    var model : DataModel!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    
    @IBAction func sortBy(_ sender: Any) {
        if (sortPicker.titleForSegment(at: sortPicker.selectedSegmentIndex) == "Exercise Name"){
            self.model!.sortEntriesByName()
            tableView.reloadData()
        }
        else if (sortPicker.titleForSegment(at: sortPicker.selectedSegmentIndex) == "Date"){
            self.model.sortEntriesByDate()
            tableView.reloadData()
        }
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
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy"
        let cellIdentifier = "ExerciseEntryCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UITableViewCell  else {
            fatalError("The dequeued cell is not an instance of ExerciseCategoryCell.")
        }
        if (category == "Strength Training"){
            cell.textLabel?.text = self.model.strengthTrainingEntries[indexPath.row].exerciseName
            cell.detailTextLabel?.text = formatter.string(from: self.model.strengthTrainingEntries[indexPath.row].date!)
            print(formatter.string(from: self.model.strengthTrainingEntries[indexPath.row].date!))
        }
        else if (category == "Cardio Training"){
            cell.textLabel?.text = self.model.cardioEntries[indexPath.row].exerciseName
            cell.detailTextLabel?.text = formatter.string(from: self.model.cardioEntries[indexPath.row].date!)
            print("CR")
        }
        else {
            cell.textLabel?.text = "None"
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (category == "Strength Training"){
            if editingStyle == UITableViewCell.EditingStyle.delete {
                self.model.strengthTrainingEntries.remove(at: indexPath.row)
                self.model.persist()
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            }
        }
        else {
            if editingStyle == UITableViewCell.EditingStyle.delete {
                self.model.cardioEntries.remove(at: indexPath.row)
                self.model.persist()
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (category == "Strength Training"){
            self.performSegue(withIdentifier: "addStrengthEntry", sender: self)

        }
        else if (category == "Cardio Training"){
            self.performSegue(withIdentifier: "addCardioEntry", sender: self)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addStrengthEntry" {
            let destinationController = segue.destination as! AddStrengthEntryViewController
            destinationController.exercises = self.model.strengthTrainingExercises.sorted()
            destinationController.model = self.model
            destinationController.entry = self.model.strengthTrainingEntries[(tableView.indexPathForSelectedRow?.row)!]
            destinationController.entryIndex = (tableView.indexPathForSelectedRow?.row)!
        }
        else if segue.identifier == "addCardioEntry" {
            let destinationController = segue.destination as! AddCardioEntryViewController
            destinationController.exercises = self.model.cardioExercises.sorted()
            destinationController.model = self.model
            destinationController.entry = self.model.cardioEntries[(tableView.indexPathForSelectedRow?.row)!]
            destinationController.entryIndex = (tableView.indexPathForSelectedRow?.row)!
            print("CRsg")
        }
    }

}
