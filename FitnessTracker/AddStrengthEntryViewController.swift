//
//  AddEntryViewController.swift
//  FitnessTracker
//
//  Created by Jenny Zhao on 5/1/19.
//  Copyright © 2019 Jenny Zhao. All rights reserved.
//

import UIKit

class AddStrengthEntryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var exercisePicker: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var weight: UITextField!
    @IBOutlet weak var weightUnit: UIPickerView!
    @IBOutlet weak var reps: UITextField!
    @IBOutlet weak var sets: UITextField!
    @IBOutlet weak var details: UITextField!
    
    public var exercises: [String]!
    public var model: DataModel!
    public var entry: StrengthTrainingEntry!
    public var entryIndex: Int!
    
    let units = ["pounds", "kilograms"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.datePicker.maximumDate = Date()
        self.exercisePicker.delegate = self
        self.exercisePicker.dataSource = self
        self.weightUnit.delegate = self
        self.weightUnit.dataSource = self
        
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveAndExit(sender:)))
        self.navigationItem.rightBarButtonItem = saveButton
        
        loadFields()
    }
    
    func createNewEntry() -> StrengthTrainingEntry? {
        let exercise = self.exercises[self.exercisePicker.selectedRow(inComponent: 0)]
        let date = self.datePicker.date
        let weight = self.weight.text.flatMap{Int($0)}
        let weightUnit = self.units[self.weightUnit.selectedRow(inComponent: 0)]
        let weightUnitEnum = StrengthTrainingEntry.WeightUnit.fromString(weightUnit)
        let reps = self.reps.text.flatMap{Int($0)}
        let sets = self.sets.text.flatMap{Int($0)}
        let details = self.details.text
        
        if weight == nil || reps == nil || sets == nil {
            // return nil if there is not enough information to create a complete entry.
            // Will show an error message
            return nil
        } else {
        return StrengthTrainingEntry(exerciseName: exercise, date: date, weight: weight, weightUnit: weightUnitEnum, reps: reps, sets: sets, details: details)
        }
    }
    
    func loadFields() {
        if (self.entry != nil){ // we are not adding a new entry but rather loading an existing one
            if (entry.weight != nil){
                weight.text = String(Int(entry.weight!))
            }
            if (entry.reps != nil){
                reps.text = String(entry.reps!)
            }
            if (entry.sets != nil){
                sets.text = String(entry.sets!)
            }
            if (entry.details != nil){
                details.text = String(entry.details!)
            }
            if (entry.date != nil) {
                self.datePicker.setDate(entry.date!, animated: false)
            }
            if (entry.weightUnit != nil){
                let str = entry.weightUnit!.rawValue
                let index = StrengthTrainingEntry.WeightUnit.allCases.firstIndex(of: StrengthTrainingEntry.WeightUnit(rawValue: str)!)
                self.weightUnit.selectRow(index!, inComponent: 0, animated: true)
            }
            if (entry.exerciseName != nil){
                let index = self.model.strengthTrainingExercises.sorted().firstIndex(of: entry.exerciseName!)
                if (index != nil){
                    self.exercisePicker.selectRow(index!, inComponent: 0, animated: true)
                }
                else {
                    self.exercisePicker.selectRow(0, inComponent: 0, animated: true)
                }
            }
        }
    }
    
    @objc func saveAndExit(sender: UIBarButtonItem) {
        if (self.entry == nil){
            if let entry = createNewEntry() {
                self.model.strengthTrainingEntries.append(entry)
                self.model.persist()
                self.navigationController?.popViewController(animated: true)
            } else {
                let alert = UIAlertController(title: "Could not save entry", message: "Not all fields filled out", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        else {
            if let entry = createNewEntry(){
                self.model.strengthTrainingEntries.remove(at: self.entryIndex)
                self.model.strengthTrainingEntries.append(entry)
                self.model.persist()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func data(for pickerView: UIPickerView) -> [String] {
        return pickerView == exercisePicker ? exercises : units
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data(for: pickerView).count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data(for: pickerView)[row]
    }

}
