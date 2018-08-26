//
//  ViewController.swift
//  CRM
//
//  Created by Noel Jander on 03.05.18.
//  Copyright © 2018 Noel Jander. All rights reserved.
//

import UIKit
import SQLite

// Globale Variable, die die letzte ausgewählte GruppenID besitzt. Wird jedesmal neu gesetzt wenn eine Gruppe gewählt wird
var selectedGroupID: Int = 0

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    // Variable für die Anzahl der Aufgaben in einer Kategorie/Gruppe (Bspw.: Arbeit, Privat, etc...)
    var tasksCount: Int!
    // HeaderView Height, erzeugt Abstand zwischen einzelnen Zellen der Tabelle
    var cellSpacingHeight: CGFloat = 5
    
    // Gruppen Tabelle
    @IBOutlet weak var startTableView: UITableView!
    
    // NavigationBar Buttons
    @IBOutlet weak var navigationNotes: UIButton!
    @IBOutlet weak var navigationDocuments: UIButton!
    @IBOutlet weak var navigationContacts: UIButton!
    @IBOutlet weak var navigationCalendar: UIButton!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        // TableView Datasource and Delegate
        startTableView.delegate = self
        startTableView.dataSource = self
        // Registering the TableCell for reuse
        self.startTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        // Stops filling the whole screen with empty Cells
        startTableView.tableFooterView = UIView(frame: CGRect.zero)
        startTableView.tableFooterView?.backgroundColor = UIColor.clear
        // Initialisiert Datenbank Tabelle für Gruppen, falls nicht bereits vorhanden und initialisiert ein Array mit allen vorhanden Aufgaben
        setupGroupTable()
        // Initialisiert To-Do Aufgabenliste
        setupTasks()
        // Observer, der Benachrichtigt wenn eine neue Gruppe hinzugefügt wurde und reload der Tabelle aufruft
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        // Long pressure Gesture to delete cells
        setupLongPressGesture()
        // Button Animations für NavigationBar Buttons
        navigationCalendar.addTarget(self, action: #selector(buttonTouched(_:)), for: .touchUpInside)
        navigationDocuments.addTarget(self, action: #selector(buttonTouched(_:)), for: .touchUpInside)
        navigationNotes.addTarget(self, action: #selector(buttonTouched(_:)), for: .touchUpInside)
        navigationContacts.addTarget(self, action: #selector(buttonTouched(_:)), for: .touchUpInside)
    }
    
    // Wird aufgerufen, wenn observer eine änderung registriert. Lädt bei eingabe einer neuen Gruppe die Tabelle im hintergrund neu
    // und fügt die neue Gruppe hinzu
    @objc func loadList(){
        setupGroupTable()
        self.startTableView.reloadData()
    }
    
    // Bounce Animation für NavigationBar Buttons
    @IBAction func buttonTouched(_ sender: UIButton) {
        UIButton.animate(withDuration: 0.05, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8) },
                         completion: {
                            finish in UIButton.animate(withDuration: 0.05, animations: {
                                sender.transform = CGAffineTransform.identity
                            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Setting up the TableView Spacings
    func setupTableView() {
    }
    
    // Long Pressure Gesture. Ruft Alertview auf um zu bestätigen ob die gedrückte
    // Gruppe gelöscht werden soll oder abgebrochen werden soll
    
    // Long Pressure Gesture
    func setupLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 2.0 // 2 second press
        longPressGesture.delegate = self
        self.startTableView.addGestureRecognizer(longPressGesture)
    }
    
    // Long Pressure Handler für TableViewCells. Ermöglicht das löschen von Zellen
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .ended {
            let touchPoint = gestureRecognizer.location(in: self.startTableView)
            if let indexPath = startTableView.indexPathForRow(at: touchPoint) {
                
                let dialogMessage = UIAlertController(title: "Bestätigen", message: "Sind Sie sicher, dass sie die Gruppe löschen möchten?", preferredStyle: .alert)
                
                // Create OK button with action handler
                let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                    let sectionAtLongPressure = indexPath.section
                    let group = GroupManager.sharedInstance.groups[indexPath.section]
                    selectedGroupID = group.id
                    GroupManager.sharedInstance.groups.remove(at: sectionAtLongPressure)
                    self.startTableView.reloadData()
                    self.deleteGroupAtIndex(GroupIndex: selectedGroupID)
                    print("Ok button tapped")
                })
                
                // Create Cancel button with action handlder
                let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                    print("Cancel button tapped")
                }
                
                //Add OK and Cancel button to dialog message
                dialogMessage.addAction(ok)
                dialogMessage.addAction(cancel)
                
                // Present dialog message to user
                self.present(dialogMessage, animated: true, completion: nil)
            }
        }
    }
}


// Delegate und DataSource extensions

extension ViewController: UITableViewDelegate {
    // SelectRow function um die gedrückte TableCell id als globale Variable weiterzugeben
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = GroupManager.sharedInstance.groups[indexPath.section]
        selectedGroupID = group.id
    }
}

extension ViewController: UITableViewDataSource {
    // Anzahl der Gruppen
    func numberOfSections(in tableView: UITableView) -> Int {
        let countedGroups = GroupManager.sharedInstance.groups.count
        return countedGroups
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // HeaderView mit fester Höhe um Abstände zwischen Cellen zu realisieren
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    // Farbe und Eigenschaften des HeaderView
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    // Höhe des Headers ist 1.0 um graue Trennlinie der Tabellenzellen zu entfernen
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    // Farbe und Eigenschaften des FooterView
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    // Initialisiert TableCell's
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = startTableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as! GroupTableViewCell
        let group = GroupManager.sharedInstance.groups[indexPath.section] // indexPath.section verwenden, da Zelle pro section statt row
        cell.GroupTitle.text = group.name // setzt Aufgaben Title
        let taskCount = TaskManager.sharedInstance.tasks.reduce(0) { $0 + ($1.groupsid == group.id ? 1 : 0)} // Anzahl an Aufgaben in einer Gruppe
        cell.TasksCount.text = "\(taskCount)"
        //Zellen layout und Farbe
        cell.backgroundColor = UIColor.init(colorWithHexValue: 0xEBEBEB, alpha: 0.5)
        cell.layer.cornerRadius = 3
        cell.clipsToBounds = true
        return cell
    }
}

