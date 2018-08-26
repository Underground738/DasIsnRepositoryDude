//
//  Groups.swift
//  CRM
//
//  Created by Noel Jander on 18.06.18.
//  Copyright © 2018 Noel Jander. All rights reserved.
//

import Foundation
import UIKit

class Groups {
    var name: String
    var taskcount: Int
    var index: Int
    var id: Int
    
    init(name: String, taskcount: Int, index: Int, id: Int) {
        self.name = name
        self.taskcount = taskcount
        self.index = index
        self.id = id
    }
}

/* SharedInstance um globales array groups mit
   custom Objects des Typs Groups zu füllen und nutzen */
class GroupManager {
    static var sharedInstance = GroupManager()
    var groups = [Groups]()
    init() {
    }
}
