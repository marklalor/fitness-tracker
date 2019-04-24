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
    }


}

