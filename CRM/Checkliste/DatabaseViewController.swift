//
//  DatabaseViewController.swift
//  CRM
//
//  Created by Noel Jander on 12.06.18.
//  Copyright © 2018 Noel Jander. All rights reserved.
//

import UIKit
import SQLite

class DatabaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIViewController {
    
    /* Aufgaben/Gruppen Datenbank */
    
    // Erstellt die Gruppentabelle und befüllt ein Array mit den Gruppentiteln
    func setupGroupTable() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        let db = try! Connection("\(path)/db.sqlite3")
        
        // Erstellt die Gruppentabelle, falls diese noch nicht existiert
        let groups = Table("groups")
        let id = Expression<Int64>("id")
        let groupname = Expression<String>("groupname")
        let tasks = Expression<Int64>("tasks")
        let index = Expression<Int64>("index")
        do {
            try db.run(groups.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(groupname)
                t.column(tasks)
                t.column(index, unique: false, check: index >= 0)
            })
            // Speichert die Gruppen der Datenbank in einem Array das aus Gruppenobjekten besteht
            for group in try db.prepare(groups) {
                if !GroupManager.sharedInstance.groups.contains(where: { $0.id == group[id] } ) {
                    GroupManager.sharedInstance.groups.append(Groups(name: group[groupname] , taskcount: Int(group[tasks]), index: Int(group[index]), id: Int(group[id])))
                    print("id: \((group[id])), groupname: \(group[groupname]), tasks: \(group[tasks]), index: \(group[index])")
                } else {
                }
            }
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print ("constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            print("insertion failed: \(error)")
        }
    }
    
    // Löscht Gruppe, wird aufgerufen nach Longpressure Gesture
    func deleteGroupAtIndex(GroupIndex: Int) {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        let db = try! Connection("\(path)/db.sqlite3")
        
        let groups = Table("groups")
        let tasks = Table("tasks")
        let id = Expression<Int64>("id")
        let groupsid = Expression<Int64>("groupsid")
        let deleteGroup = groups.filter(Int64(GroupIndex) == groups[id])
        let deleteTasks = tasks.filter(groups[id] == tasks[groupsid]) // Sucht alle tasks die zu der Gruppe gehört haben
        do {
            if try db.run(deleteGroup.delete()) > 0{
                try db.run(deleteTasks.delete()) > 0 // löscht dazugehörige Aufgaben
                print("Gruppe und alle \(deleteTasks.delete()) zugehörigen Aufgaben wurden gelöscht!")
            } else {
                print("Gruppe existiert nicht!")
            }
        } catch {
            print("Löschen fehlgeschlagen: \(error)")
        }
    }
    
    // Löscht alle Gruppen / die GruppenTabelle
    func dropGroupTable() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        let db = try! Connection("\(path)/db.sqlite3")
        
        let groups = Table("groups")
        
        do {
            try db.run(groups.drop(ifExists: true))
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("droping table failed: \(message), in \(String(describing: statement))")
        } catch let error {
            print("droping failed: \(error)")
        }
    }
    
    
    
    // Gibt die Anzahl der erzeugten Gruppen zurueck
    func returnNumberOfGroups() -> Int {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        let db = try! Connection("\(path)/db.sqlite3")
        
        let groups = Table("groups")
        var groupsnumber: Int!
        
        do {
            groupsnumber =  try db.scalar(groups.count)
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print ("constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            print ("insertion failed: \(error)")
        }
        print("\(groupsnumber as Int)")
        return groupsnumber
    }
    
    
    
    // Fügt eine neue Gruppe hinzu
    func insertIntoGroups(groupTitle: String) {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        let db = try! Connection("\(path)/db.sqlite3")
        
        let groups = Table("groups")
        let groupname = Expression<String>("groupname")
        let tasks = Expression<Int64>("tasks")
        let index = Expression<Int64>("index")
        var newIndex: Int!
        newIndex = returnNumberOfGroups() + 1
        
        do {
            try db.run(groups.insert(groupname <- "\(groupTitle)", tasks <- 0, index <- Int64(newIndex)))
        }  catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print ("constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            print ("insertion failed: \(error)")
        }
    }
    
    
    
    // Updated Indexwert, nachdem Gruppen bewegt wurden.
    func updateGroupIndex() {
        
    }
    
    
    /* To-Do Listen einträge, (Tasks) */
    
    // Erstellt eine TaskTabelle, mit ForeignKey die auf die jeweilige Gruppe referenziert
    func setupTasks() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        let db = try! Connection("\(path)/db.sqlite3")
        
        let tasks = Table("tasks")
        let id = Expression<Int64>("id")
        let taskname = Expression<String>("taskname")
        let taskdescription = Expression<String>("taskdescription")
        let taskcolor = Expression<String>("taskcolor")
        let taskpriority = Expression<Int64>("taskpriority")
        let checkedstate = Expression<Bool>("checkedstate")
        let groupsid = Expression<Int64>("groupsid")
        
        let groups = Table("groups")
        
        do {
            try db.run(tasks.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(taskname)
                t.column(taskdescription)
                t.column(taskcolor)
                t.column(taskpriority)
                t.column(checkedstate)
                t.column(groupsid, references: groups, id)
            })
            for task in try db.prepare(tasks) {
                if !TaskManager.sharedInstance.tasks.contains(where: { $0.id == task[id] }) {
                    TaskManager.sharedInstance.tasks.append(Tasks(name: task[taskname], taskdescription: task[taskdescription], taskcolor: task[taskcolor], taskpriority: Int(task[taskpriority]), checkedstate: task[checkedstate], groupsid: Int(task[groupsid]), id: Int(task[id])))
                    print("taskid: \(task[id]), taskname: \(task[taskname]), groupsid: \(task[groupsid])")
                } else {
                    
                }
            }
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print ("constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            print("insertion failed: \(error)")
        }
    }
    
    
    // To-Do: Duplikate vermeiden! Speichtert neuen Task
    func insertIntoTasks(taskTitle: String, taskDescription: String, taskColor: String, insertGroupsid: Int) {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        let db = try! Connection("\(path)/db.sqlite3")
        let tasks = Table("tasks")
        let taskname = Expression<String>("taskname")
        let taskdescription = Expression<String>("taskdescription")
        let taskcolor = Expression<String>("taskcolor")
        let taskpriority = Expression<Int64>("taskpriority")
        let checkedstate = Expression<Bool>("checkedstate")
        let groupsid = Expression<Int64>("groupsid")
        
        do {
            try db.run(tasks.insert(taskname <- "\(taskTitle)", taskdescription <- "\(taskDescription)", taskcolor <- "\(taskColor)", taskpriority <- 0, checkedstate <- false, groupsid <- Int64(insertGroupsid)))
        }  catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print ("constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            print ("insertion failed: \(error)")
        }
    }
    
    
    // Gibt die Anzahl der Tasks zurück
    func returnNumberOfTasks() -> Int {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        let db = try! Connection("\(path)/db.sqlite3")
        
        let tasks = Table("tasks")
        var tasksnumber: Int!
        
        do {
            tasksnumber =  try db.scalar(tasks.count)
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print ("constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            print ("insertion failed: \(error)")
        }
        print("\(tasksnumber as Int)")
        return tasksnumber
    }
    
    func dropTaskTable() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        let db = try! Connection("\(path)/db.sqlite3")
        
        let tasks = Table("tasks")
        
        do {
            try db.run(tasks.drop(ifExists: true))
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("droping table failed: \(message), in \(String(describing: statement))")
        } catch let error {
            print("droping failed: \(error)")
        }
    }
    
    func updateTaskCheckedState(taskID: Int) {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        let db = try! Connection("\(path)/db.sqlite3")
        
        let tasks = Table("tasks")
        let id = Expression<Int64>("id")
        let checkedstate = Expression<Bool>("checkedstate")
        let filteredTask = tasks.filter(tasks[id] == Int64(taskID))
        
        // Nicht Fehler sicher! Catch block überarbeiten
        for task in try! db.prepare(tasks.filter(tasks[id] == Int64(taskID))) {
            do {
                if try task.get(checkedstate)/*TaskManager.sharedInstance.tasks.contains(where: { $0.checkedstate == true }) */{
                    try db.run(filteredTask.update(checkedstate <- false))
                    TaskManager.sharedInstance.tasks.filter({$0.id == taskID}).first?.checkedstate = false
                    print("Updated checkstate at \(task[id]) from true to \(filteredTask[checkedstate])")
                } else {
                    try db.run(filteredTask.update(checkedstate <- true))
                    TaskManager.sharedInstance.tasks.filter({$0.id == taskID}).first?.checkedstate = true
                    print("Updated checkstate at \(task[id]) from false to \(filteredTask[checkedstate])")
                }
            } catch {
                print("Checkstate update fehlgeschlagen!")
            } 
        }
    }
    
    func deleteTaskAtIndex(taskIndex: Int) {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        let db = try! Connection("\(path)/db.sqlite3")
        
        let tasks = Table("tasks")
        let id = Expression<Int64>("id")
        let deleteTask = tasks.filter(tasks[id] == Int64(taskIndex)) // Filtert zu löschende Aufgabe 
        
        do {
            if try db.run(deleteTask.delete()) > 0{
                print("Die Aufgabe \(deleteTask.delete()) wurde gelöscht!")
            } else {
                print("Gruppe existiert nicht!")
            }
        } catch {
            print("Löschen fehlgeschlagen: \(error)")
        }
    }
    
    func deleteCheckedTasks(selectedGroupID: Int) {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        let db = try! Connection("\(path)/db.sqlite3")
        
        let tasks = Table("tasks")
        let checkedstate = Expression<Bool>("checkedstate")
        let groupsid = Expression<Int64>("groupsid")
        
        let deleteTask = tasks.filter(tasks[groupsid] == Int64(selectedGroupID) && tasks[checkedstate])
        
        do {
            if try db.run(deleteTask.delete()) > 0 {
                print("Alle erfüllten Aufgaben wurden gelöscht!")
            } else {
                print("Keine erfüllten Aufgaben!")
            }
        } catch {
            print("Löschen fehlgeschlagen: \(error)")
        }
    }
    
}
