//
//  CalendarEvents.swift
//  CRM
//
//  Created by Noel Jander on 08.08.18.
//  Copyright © 2018 Noel Jander. All rights reserved.
//

import Foundation
import UIKit

class Events {
    var title: String
    var description: String
    var date: Date
    var timeInterval: DateInterval
    
    init(title: String, description: String, date: Date, timeInterval: DateInterval) {
        self.title = title
        self.description = description
        self.date = date
        self.timeInterval = timeInterval
    }
}


class EventManager {
    static var sharedInstance = EventManager()
    var events = [Events]()
    
    init() {
    }
}

