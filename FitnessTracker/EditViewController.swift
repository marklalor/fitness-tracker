//
//  ViewController.swift
//  FitnessTracker
//
//  Created by Jenny Zhao on 4/24/19.
//  Copyright © 2019 Jenny Zhao. All rights reserved.
//

import UIKit

class EditViewController: UIViewController, UITableViewDelegate {

    var model: DataModel!
    
    @IBAction func editStrengthTraining(_ sender: Any) {
        edit(strings: model.strengthTrainingExercises.sorted(), applyFunction: {(items: [String]) in
            self.model.strengthTrainingExercises = Set(items)
            self.model.persist()
        })
    }
    
    @IBAction func editCardio(_ sender: Any) {
        edit(strings: model.cardioExercises.sorted(), applyFunction: {(items: [String]) in
            self.model.cardioExercises = Set(items)
            self.model.persist()
        })
    }
    
    func edit(strings: [String], applyFunction: @escaping ([String]) -> Void) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "arrayEditor")
        
        if let editController = controller as? EditableStringArrayTableViewController {
            editController.data = strings
            editController.model = self.model
            editController.applyFunction = applyFunction
            self.navigationController?.pushViewController(editController, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }


}

class EditableStringArrayTableViewController: UITableViewController {
    
    var category: String!
    var data: [String]!
    var model: DataModel!
    var applyFunction: (([String]) -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(add(sender:)))
        self.navigationItem.rightBarButtonItems = [addButtonItem, self.editButtonItem]
    }
    
    @objc func add(sender: Any) {
        let alert = UIAlertController(title: "Add new exercise", message: "Enter a name", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "exercise name"
        }
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            let newExercise = textField?.text! ?? ""
            if (newExercise != ""){
                self.data.append(newExercise)
                self.data.sort()
                self.apply()
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func apply() {
        self.applyFunction(self.data)
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Edit exercise name", message: "Enter a new value", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = self.data[indexPath.row]
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            self.data[indexPath.row] = textField?.text! ?? ""
            self.apply()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "editStringArrayCell", for: indexPath) as? UITableViewCell else {
            fatalError("The dequeued cell is not an instance of stringItemCell.")
        }
        cell.textLabel?.text = self.data[indexPath.row]
        return cell
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return NO if you do not want the specified item to be editable.
     return true
     }
     */
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            self.data.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.apply()
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let rowToMove = self.data[sourceIndexPath.row]
        self.data.remove(at: sourceIndexPath.row)
        self.data.insert(rowToMove, at: destinationIndexPath.row)
        self.apply()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
}
