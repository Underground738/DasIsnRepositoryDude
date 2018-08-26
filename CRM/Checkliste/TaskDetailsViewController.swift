//
//  TaskDetailsViewController.swift
//  CRM
//
//  Created by Noel Jander on 15.06.18.
//  Copyright © 2018 Noel Jander. All rights reserved.
//

import UIKit

class TaskDetailsViewController: UIViewController {

    @IBOutlet weak var descriptionTextfield: UITextView!
    var task: Tasks?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup() {
        self.view.frame.origin.y = UIApplication.shared.statusBarFrame.size.height
        self.title = task?.name
        self.descriptionTextfield.text = task?.taskdescription
    }

}
