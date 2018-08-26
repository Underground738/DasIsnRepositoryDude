//
//  Tasks.swift
//  CRM
//
//  Created by Noel Jander on 15.06.18.
//  Copyright © 2018 Noel Jander. All rights reserved.
//

import Foundation
import UIKit

class Tasks {
    var name: String
    var taskdescription: String
    var taskcolor: String
    var taskpriority: Int
    var checkedstate: Bool
    var groupsid: Int
    var id: Int
    
    
    init(name: String, taskdescription: String, taskcolor: String, taskpriority: Int, checkedstate: Bool, groupsid: Int, id: Int) {
        self.name = name
        self.taskdescription = taskdescription
        self.taskcolor = taskcolor
        self.taskpriority = taskpriority
        self.checkedstate = checkedstate
        self.groupsid = groupsid
        self.id = id
    }
}

class TaskManager {
    static var sharedInstance = TaskManager()
    var tasks = [Tasks]()
    
    init() {
//        self.tasks.append(Tasks(name: "Einkaufen", taskdescription: "Melonen einkaufen", taskcolor: "Blue", taskpriority: 0, checkedstate: false, groupsid: 1, id: 1))
//        self.tasks.append(Tasks(name: "Essen machen", taskdescription: "Melonen in Scheiben schneiden", taskcolor: "Yellow", taskpriority: 0, checkedstate: false, groupsid: 1, id: 2))
//        self.tasks.append(Tasks(name: "Wäsche waschen", taskdescription: "Wäsche sortieren und waschen!", taskcolor: "Red", taskpriority: 3, checkedstate: false, groupsid: 2, id: 3))
//        self.tasks.append(Tasks(name: "Kartoffeln zubereiten", taskdescription: "Kartoffeln waschen, schälen und in heißem Wasser köcheln lassen bis sie durch sind.", taskcolor: "Green", taskpriority: 0, checkedstate: true, groupsid: 5, id: 10))
    }
}
