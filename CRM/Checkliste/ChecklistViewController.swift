//
//  ChecklistViewController.swift
//  CRM
//
//  Created by Noel Jander on 10.06.18.
//  Copyright © 2018 Noel Jander. All rights reserved.
//

import UIKit
import M13Checkbox

var tappedTaskCell: Int = 0

class ChecklistViewController: UIViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var deleteButton: UIButton!
    var selectedTask: Tasks?
    var cellSpacingHeight: CGFloat = 5
    var selectedTaskID: Int = 0
    
    @IBOutlet weak var Checklists: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Draws iOS default checkmarks
        // Do any additional setup after loading the view.
        Checklists.tableFooterView = UIView(frame: CGRect.zero)
        Checklists.tableFooterView?.backgroundColor = UIColor.clear
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        setupLongPressGesture()
        deleteButton.addTarget(self, action: #selector(deleteFullfilledTasks), for: .touchUpInside)
        self.Checklists.rowHeight = 52.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func loadList(){
        setupTasks()
        self.Checklists.reloadData()
    }
    
    // Long Pressure Gesture
    func setupLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 0.5 // 1 second press
        longPressGesture.delegate = self
        self.Checklists.addGestureRecognizer(longPressGesture)
    }
    
    // Long Pressure Handler für TableViewCells. Ermöglicht das löschen von Zellen
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .ended {
            let touchPoint = gestureRecognizer.location(in: self.Checklists)
            if let indexPath = Checklists.indexPathForRow(at: touchPoint) {

                let dialogMessage = UIAlertController(title: "Bestätigen", message: "Sind Sie sicher, dass sie die Aufgabe löschen möchten?", preferredStyle: .alert)
                
                // BUG: Löscht in Task Array die Zeile an der Stelle, die SectionAtLongPressure angibt.
                // Unabhängig von der jeweiligen Gruppe!!!
                // Gruppen unterscheidung einbringen
                // Create OK button with action handler
                // Derzeit Hackaround mit Array leeren und aus Datenbank, wo löschen richtig erfolgt ist neu befüllen.
                let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                    let sectionAtLongPressure = indexPath.section
                    let task = TaskManager.sharedInstance.tasks.filter({$0.groupsid == selectedGroupID})[indexPath.section]
                    self.selectedTaskID = task.id
                    // nächste Zeile sollte eigentlich die Gedrückte Zeile aus Array löschen
                    // ignoriert jedoch leider die Gruppe und löscht somit kreuz und quer in den Aufgaben
//                    TaskManager.sharedInstance.tasks.remove(at: sectionAtLongPressure)
                    // Dirty Hackaround: Löscht alle einträge im Array tasks und lädt den array anschließend neu aus der Datenbank, da
                    // das löschen in der Datenbank richtig von statten geht, ich jedoch das element im array selbst nicht an der richtigen Stelle löschen kann
                    TaskManager.sharedInstance.tasks.removeAll()
                    self.deleteTaskAtIndex(taskIndex: self.selectedTaskID)
                    self.setupTasks()
                    self.Checklists.reloadData()
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
    
    // Segue übergibt Daten, wie z.b. Beschreibung und Titel
    // der Ausgewählten Task an TaskDetailsViewController
    // Um dort Text zu setzen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TaskDetailsVC" {
            let vc = segue.destination as! TaskDetailsViewController
            // Übergibt den Ausgewählten Task an TaskDetailsViewController
            vc.task = self.selectedTask
        }
    }
    
   // Checkbox State Switch
    @objc func checkboxValueChanged(_ sender: M13Checkbox) {
        if let indexPath = self.Checklists.indexPathForCheckbox(sender) {
            let tappedCheckboxID = TaskManager.sharedInstance.tasks.filter({$0.groupsid == selectedGroupID })[indexPath.section].id
            print("TappedCheckboxID is: \(tappedCheckboxID)")
            updateTaskCheckedState(taskID: tappedCheckboxID)
            setupTasks()
            // Reload Data sorgt für sofortiges ändern der Textfarbe der Aufgabe, wenn diese erfüllt/Checked wurde
            self.Checklists.reloadData()
        } else {
            print("No checkbox found!")
        }
    }
    
    @objc func deleteFullfilledTasks(sender: UIButton) {
        let dialogMessage = UIAlertController(title: "Bestätigen", message: "Sind Sie sicher, dass sie alle erfüllten Aufgaben löschen möchten?", preferredStyle: .alert)
        
        // Create Ok button action
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            self.deleteCheckedTasks(selectedGroupID: selectedGroupID)
            TaskManager.sharedInstance.tasks.removeAll()
            self.setupTasks()
            self.Checklists.reloadData()
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

extension ChecklistViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedTask = TaskManager.sharedInstance.tasks.filter({$0.groupsid == selectedGroupID})[indexPath.section]
        self.performSegue(withIdentifier: "TaskDetailsVC", sender: nil)
    }
}

extension ChecklistViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let taskCount = TaskManager.sharedInstance.tasks.reduce(0) { $0 + ($1.groupsid == selectedGroupID ? 1 : 0)}
        return taskCount
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = TaskManager.sharedInstance.tasks.filter({$0.groupsid == selectedGroupID })[indexPath.section]
        let cell = Checklists.dequeueReusableCell(withIdentifier: "task", for: indexPath) as! ChecklistTableViewCell
//        cell.tasksTitle.text = task.name
        cell.backgroundColor = UIColor.init(colorWithHexValue: 0xEBEBEB, alpha: 1.0)
        cell.layer.cornerRadius = 3
        cell.clipsToBounds = true
        
        let attributedString: NSMutableAttributedString =  NSMutableAttributedString(string: task.name)
        attributedString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, attributedString.length))
        
        // Animationsstyle der Checkbox
        cell.checkBox.stateChangeAnimation = M13Checkbox.Animation.expand(M13Checkbox.AnimationStyle.stroke)
        // Checkbox State wenn TableviewCell geladen wird
        if task.checkedstate == true {
            cell.checkBox.checkState = M13Checkbox.CheckState.checked
            cell.tasksTitle.textColor = UIColor.init(colorWithHexValue: 0xC0C0C0, alpha: 1.0)
            cell.tasksTitle.attributedText = attributedString
            
        } else {
            cell.checkBox.checkState = M13Checkbox.CheckState.unchecked
            cell.tasksTitle.textColor = UIColor.darkText
            cell.tasksTitle.attributedText = nil
            cell.tasksTitle.text = task.name
        }
        // Eine Art Observer der registriert wenn die Checkbox getappt wurde
        cell.checkBox.checkedValue = 1
        cell.checkBox.addTarget(self, action: #selector(checkboxValueChanged(_:)), for: .valueChanged)
        return cell
    }
}


public extension UITableView {

    /**
     This method returns the indexPath of the cell that contains the specified view
     
     - Parameter view: The view to find.
     
     - Returns: The indexPath of the cell containing the view, or nil if it can't be found
     
     */
    
    func indexPathForCheckbox(_ checkbox: M13Checkbox) -> IndexPath? {
        let center = checkbox.center
        let checkboxCenter = self.convert(center, from: checkbox.superview)
        let indexPath = self.indexPathForRow(at: checkboxCenter)
        return indexPath
    }
}

