//
//  AddEntryViewController.swift
//  FitnessTracker
//
//  Created by Jenny Zhao on 5/1/19.
//  Copyright © 2019 Jenny Zhao. All rights reserved.
//

import UIKit

class AddStrengthEntryViewController: UIViewController {

    @IBOutlet weak var exerciseName: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var weight: UITextField!
    @IBOutlet weak var weightUnit: UIPickerView!
    @IBOutlet weak var reps: UITextField!
    @IBOutlet weak var sets: UITextField!
    @IBOutlet weak var details: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
