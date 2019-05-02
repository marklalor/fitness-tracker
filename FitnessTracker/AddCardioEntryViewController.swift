//
//  AddCardioEntryViewController.swift
//  FitnessTracker
//
//  Created by Mark Lalor on 5/1/19.
//  Copyright © 2019 Jenny Zhao. All rights reserved.
//

import UIKit

class AddCardioEntryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var exercisePicker: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var duration: UITextField!
    @IBOutlet weak var durationUnit: UIPickerView!
    @IBOutlet weak var details: UITextField!
    
    public var exercises: [String] = []
    public var model: DataModel!
    public var entry: CardioEntry!
    public var entryIndex: Int!
    
    let units = ["minutes", "seconds", "hours"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.datePicker.maximumDate = Date()
        self.exercisePicker.delegate = self
        self.exercisePicker.dataSource = self
        self.durationUnit.delegate = self
        self.durationUnit.dataSource = self
        
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveAndExit(sender:)))
        self.navigationItem.rightBarButtonItem = saveButton
        
        loadFields()
    }
    
    func loadFields() {
        if (self.entry != nil){ // we are not adding a new entry but rather loading an existing one
            if (entry.duration != nil){
                duration.text = String(entry.duration!)
            }
            if (entry.details != nil){
                details.text = String(entry.details!)
            }
            if (entry.date != nil) {
                self.datePicker.setDate(entry.date!, animated: false)
            }
            if (entry.durationUnit != nil){
                let str = entry.durationUnit!.rawValue
                let index = CardioEntry.DurationUnit.allCases.index(of: CardioEntry.DurationUnit(rawValue: str)!)
                self.durationUnit.selectRow(index!, inComponent: 0, animated: true)
            }
            if (entry.exerciseName != nil){
                let index = self.model.strengthTrainingExercises.sorted().index(of: entry.exerciseName!)
                if (index != nil){
                    self.exercisePicker.selectRow(index!, inComponent: 0, animated: true)
                }
                else {
                    self.exercisePicker.selectRow(0, inComponent: 0, animated: true)
                }
            }
        }
    }
    
    func createNewEntry() -> CardioEntry? {
        let exercise = self.exercises[self.exercisePicker.selectedRow(inComponent: 0)]
        let date = self.datePicker.date
        let duration = self.duration.text.flatMap{Int($0)}
        let durationUnit = self.units[self.durationUnit.selectedRow(inComponent: 0)]
        let durationUnitEnum = CardioEntry.DurationUnit.fromString(durationUnit)
        let details = self.details.text
        
        if duration == nil {
            // return nil if there is not enough information to create a complete entry.
            // Will show an error message
            return nil
        } else {
            return CardioEntry(exerciseName: exercise, date: date, duration: duration, durationUnit: durationUnitEnum, details: details)
        }
    }
    
    @objc func saveAndExit(sender: UIBarButtonItem) {
        if (self.entry == nil){
            if let entry = createNewEntry() {
                self.model.cardioEntries.append(entry)
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
                self.model.cardioEntries.remove(at: self.entryIndex)
                self.model.cardioEntries.append(entry)
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

