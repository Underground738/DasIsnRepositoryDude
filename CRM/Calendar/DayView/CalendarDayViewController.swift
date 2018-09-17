//
//  CalendarDayViewController.swift
//  CRM
//
//  Created by Noel Jander on 16.09.18.
//  Copyright © 2018 Noel Jander. All rights reserved.
//

import UIKit
import JZCalendarWeekView

class CalendarDayViewController: UIViewController {

    
    @IBOutlet weak var calendarWeekView: LongPressWeekView!
    let viewModel = AllDayViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDayViewCalendar()

        // Do any additional setup after loading the view.
    }
    
    // Support device orientation change
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        JZWeekViewHelper.viewTransitionHandler(to: size, weekView: calendarWeekView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupDayViewCalendar() {
        calendarWeekView.setupCalendar(numOfDays: 1, setDate: Date(), allEvents: viewModel.eventsByDate, scrollType: .pageScroll, firstDayOfWeek: .monday)
        
        // Delegate and Datasource for longpress
        calendarWeekView.longPressDelegate = self
        calendarWeekView.longPressDataSource = self
        calendarWeekView.longPressTypes = [.addNew, .move]
        
        // Optionals
        calendarWeekView.addNewDurationMins = 120
        calendarWeekView.moveTimeMinInterval = 10
    }
}

extension CalendarDayViewController: JZLongPressViewDelegate, JZLongPressViewDataSource {
    
    // Adding a new View of Type EventCell on Longpressgesture
    func weekView(_ weekView: JZLongPressWeekView, viewForAddNewLongPressAt startDate: Date) -> UIView {
        let view = UINib(nibName: EventCell.className, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! EventCell
        view.titleLabel.text = "New Event"
        return view
    }
    
    func weekView(_ weekView: JZLongPressWeekView, didEndAddNewLongPressAt startDate: Date) {
        let newEvent = AllDayEvent(id: UUID().uuidString, title: "New Event", startDate: startDate, endDate: startDate.add(component: .hour, value: weekView.addNewDurationMins/60),
                                   location: "Melbourne", isAllDay: false)
        
        if viewModel.eventsByDate[startDate.startOfDay] == nil {
            viewModel.eventsByDate[startDate.startOfDay] = [AllDayEvent]()
        }
        viewModel.events.append(newEvent)
        viewModel.eventsByDate = JZWeekViewHelper.getIntraEventsByDate(originalEvents: viewModel.events)
        weekView.forceReload(reloadEvents: viewModel.eventsByDate)
    }
    
    func weekView(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndMoveLongPressAt startDate: Date) {
        let event = editingEvent as! AllDayEvent
        let duration = Calendar.current.dateComponents([.minute], from: event.startDate, to: event.endDate).minute!
        let selectedIndex = viewModel.events.index(where: { $0.id == event.id })!
        viewModel.events[selectedIndex].startDate = startDate
        viewModel.events[selectedIndex].endDate = startDate.add(component: .minute, value: duration)
        
        viewModel.eventsByDate = JZWeekViewHelper.getIntraEventsByDate(originalEvents: viewModel.events)
        weekView.forceReload(reloadEvents: viewModel.eventsByDate)
    }
}
