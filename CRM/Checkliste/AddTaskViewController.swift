//
//  AddTaskViewController.swift
//  CRM
//
//  Created by Noel Jander on 19.06.18.
//  Copyright © 2018 Noel Jander. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import KMPlaceholderTextView

class AddTaskViewController: UIViewController {

    @IBOutlet weak var taskDescription: KMPlaceholderTextView!
    @IBOutlet weak var titleTextfield: SkyFloatingLabelTextField!
    @IBOutlet weak var saveButton: UIButton!
    var placeholderLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.addTarget(self, action: #selector(action), for: .touchUpInside)
        self.title = "Neue Aufgabe erstellen"
        saveButton.layer.cornerRadius = 2.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func action(sender: UIButton) {
        insertIntoTasks(taskTitle: "\(titleTextfield.text!)", taskDescription: "\(taskDescription.text!)", taskColor: "white", insertGroupsid:  selectedGroupID)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        print("Neue Aufgabe wurde Datenbank hinzugefügt!")
        // dissmisses the current viewcontroller
        // other then self.dismiss this just closes the current viewcontroller in the navigationcontrollers view stack
        // meaning it basically behaves like the back button in top left corner
        self.navigationController?.popViewController(animated: true)
    }
}
