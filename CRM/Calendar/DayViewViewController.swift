//
//  DayViewViewController.swift
//  CRM
//
//  Created by Noel Jander on 09.06.18.
//  Copyright © 2018 Noel Jander. All rights reserved.
//

import UIKit
import JZCalendarWeekView

class DayViewViewController: UIViewController {

    @IBOutlet weak var calendarWeekView: JZBaseWeekView!
    var events: [JZBaseEvent]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarWeekView.setupCalendar(numOfDays: 1, setDate: Date(), allEvents: JZWeekViewHelper.getIntraEventsByDate(originalEvents: events), scrollType: .pageScroll, firstDayOfWeek: .monday)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        JZWeekViewHelper.viewTransitionHandler(to: size, weekView: calendarWeekView)
    }
}
