//
//  AddGroupViewController.swift
//  CRM
//
//  Created by Noel Jander on 12.06.18.
//  Copyright © 2018 Noel Jander. All rights reserved.
//

import UIKit
import SQLite
import SkyFloatingLabelTextField

class AddGroupViewController: UIViewController {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var titleTextfield: SkyFloatingLabelTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.addTarget(self, action: #selector(action), for: .touchUpInside)
        self.title = "Neue Gruppe erstellen"
        self.preferredContentSize = CGSize(width: 375, height: 125)
        saveButton.layer.cornerRadius = 2.0
        // Popover Arrow erscheint Standardmäßig leider an der falschen Positon und verdeckt den Button
        // Abhilfe schafft die sourceRect einstellung, die den SourceButton definiert
        // Arrow darf nur Aufwärts erscheinen
        self.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.popoverPresentationController?.permittedArrowDirections = .up
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /* Action für SaveButton
       Observer ruft in ViewController TableReloadData auf um so die neue Gruppe sofort anzuzeigen
       andernfalls wäre neue Gruppe vorallem bei Ipad nicht sofort zu sehen
       schließt zudem automatisch diesen View und kehrt zur Übersicht aller Gruppen zurück */
    @objc func action(sender: UIButton) {
        insertIntoGroups(groupTitle: "\(titleTextfield.text!)")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        print("Neue gruppe wurde Datenbank hinzugefügt!")
        self.dismiss(animated: true, completion: nil)
    }
}
