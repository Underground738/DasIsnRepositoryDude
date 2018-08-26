//
//  Customers.swift
//  CRM
//
//  Created by Noel Jander on 09.07.18.
//  Copyright © 2018 Noel Jander. All rights reserved.
//

import Foundation
import UIKit

class Customers {
    var name: String
    var age: Date
    var job: String
    var familystate: String
    
    init(name: String, age: Date, job: String, familystate: String) {
        self.name = name
        self.age = age
        self.job = job
        self.familystate = familystate
    }
}

class CustomerManager {
    static var sharedInstance = CustomerManager()
    var customers = [Customers]()
    init() {
    }
}
