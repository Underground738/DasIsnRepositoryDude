//
//  CalendarViewController.swift
//  CRM
//
//  Created by Noel Jander on 03.05.18.
//  Copyright © 2018 Noel Jander. All rights reserved.
//


// TO DO:
// Events, Searchbar, Scoopes search bar


import UIKit
import JTAppleCalendar

class CalendarViewController: UIViewController {
    
    var tappedDate : String! = ""
    var tappedDay : String! = ""
    
    let searchController = UISearchController(searchResultsController: nil)
    var scopeIndex: Int = 0
    
    private let refreshControl = UIRefreshControl()
    let formatter = DateFormatter()
    let todaysDate = Date()
    var eventsFromServer: [String:String] = [:]
    
    @IBOutlet weak var CalendarView: JTAppleCalendarView!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setup Calendar spacings
        setupCalenderView()
        // scrolling to the actual month and selecting the current Date
        CalendarView.scrollToDate(Date(), animateScroll: false)
        CalendarView.selectDates([Date()])
        // setup labels
        CalendarView.visibleDates{ (visibleDates) in
            self.setupViewsOfCalendar(from: visibleDates)
        // Fake loading data from the Server
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                let serverObjects = self.getServerEvents()
                for (date, event) in serverObjects {
                    let stringDate  = self.formatter.string(from: date)
                    self.eventsFromServer[stringDate] = event
                }
            
                    DispatchQueue.main.async {
                        self.CalendarView.reloadData()
                    }
                }
        }
        
        // Setup Searchbar
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Suche z.B. 15 04 2000 oder nach Heute..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.showsSearchResultsButton = true
        searchController.searchBar.delegate = self
        searchController.searchBar.scopeButtonTitles = ["Monat", "Woche"]
        searchController.searchBar.tintColor = UIColor.init(colorWithHexValue: 0xC0C0C0, alpha: 1.0)
    }
    
    // handles the Events of a said Cell
    func handleCellEvents (view: JTAppleCell?, cellstate: CellState) {
        guard let CalendarCell = view as? CalendarCell else { return }
        CalendarCell.eventLabel1.isHidden = !eventsFromServer.contains { $0.key == formatter.string(from: cellstate.date) }
        // to-do: Text von eventLabel setzen, case für eventlabel1 - 4 schreiben
        CalendarCell.eventLabel1.text = eventsFromServer["\(formatter.string(from: cellstate.date))"]
    }
    
    // handles the textcolor depending on indate, outdate or monthdate
    func handleCelltextColor (view: JTAppleCell?, cellState: CellState) {
        guard let CalendarCell = view as? CalendarCell else { return }
        formatter.dateFormat = "yyyy MM dd"
        let todaysDateString = formatter.string(from: todaysDate)
        let monthDateString = formatter.string(from: cellState.date)
        // Aktueller Tag soll blaue textfarbe haben, Monat schwarz und Vorhergehende und nachfolgende sind grau hinterlegt
        if todaysDateString == monthDateString {
            CalendarCell.dateLabel.textColor = UIColor.init(colorWithHexValue: 0x0096FF, alpha: 1.0)
        } else {
            if  cellState.dateBelongsTo == .thisMonth {
                CalendarCell.dateLabel.textColor = UIColor.black
            } else {
                CalendarCell.dateLabel.textColor = UIColor.lightGray
            }
        }
    }
    
    //    setup of month and yearlabel, displaying the current month you are looking at and the current year you are in
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        formatter.dateFormat = "yyyy"
        yearLabel.text = formatter.string(from: date)
        formatter.dateFormat = "MMMM"
        monthLabel.text = formatter.string(from: date)
    }
    
    // setup Spacing between Cells of the UICollectionView
    func setupCalenderView() {
        CalendarView.minimumLineSpacing = 1
        CalendarView.minimumInteritemSpacing = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension CalendarViewController: JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
//        let CalendarCell = cell as! CalendarCell
        let CalendarCell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        CalendarCell.eventLabel1.isHidden = true
        CalendarCell.eventLabel2.isHidden = true
        CalendarCell.eventLabel3.isHidden = true
        CalendarCell.eventLabel4.isHidden = true
        CalendarCell.dateLabel.text = cellState.text
        if cellState.isSelected {
            CalendarCell.selectedView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        } else {
            CalendarCell.selectedView.backgroundColor = UIColor.white
        }
        handleCelltextColor(view: cell, cellState: cellState)
        handleCellEvents(view: cell, cellstate: cellState)
        return
    }
    
    //    seting a celltext and textcolor depending on indate, outdate and monthdate
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        //Setzt das jeweilige Datum der Zelle
        cell.eventLabel1.isHidden = true
        cell.eventLabel2.isHidden = true
        cell.eventLabel3.isHidden = true
        cell.eventLabel4.isHidden = true
        cell.dateLabel.text = cellState.text
        if cellState.isSelected {
            cell.selectedView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        } else {
            cell.selectedView.backgroundColor = UIColor.white
        }
        handleCelltextColor(view: cell, cellState: cellState)
        handleCellEvents(view: cell, cellstate: cellState)
        return cell
    }
    
    //    performing actions whenever a cell is selected
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let CalendarCell = cell as? CalendarCell else { return }
        UIView.animate(withDuration: 0.5) {
                CalendarCell.selectedView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        //        text für textview aus selectierter Zelle ziehen und in testview einfügen
        }
        
        // Getting tapped Date and Day to return it as Variables in the Segue
        formatter.dateFormat = "dd"
        tappedDate = formatter.string(from: cellState.date)
        
        // todo switch case for Weekday Monday = Montag etc..
        print(cellState.date)
        print(cellState.day)
        
//        switch (cellState.day) {
//      case cellState.day == "monday": print(Montag)
//        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let CalendarCell = cell as? CalendarCell else { return }
        UIView.animate(withDuration: 0.5) {
            CalendarCell.selectedView.backgroundColor = UIColor.white
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
}

// setting and returning of startDate, endDate of Calendar
extension CalendarViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        let startDate = formatter.date(from: "2000 01 01")!
        let endDate = formatter.date(from: "2100 12 31")!
        // TO-DO Reloading the view with the right parameters when changing the Device Orientation
        if scopeIndex == 1 /*UIDevice.current.orientation.isLandscape */ {
            let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 1, calendar: Calendar.autoupdatingCurrent, generateInDates: .forFirstMonthOnly, generateOutDates: .off, firstDayOfWeek: .sunday, hasStrictBoundaries: false)
            return parameters
        } else {
            let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 6, calendar: Calendar.autoupdatingCurrent, generateInDates: .forAllMonths, generateOutDates: .tillEndOfGrid, firstDayOfWeek: .sunday, hasStrictBoundaries: false)
            return parameters
        }
    }
}

//extension for setting hexcolors
extension UIColor {
    convenience init(colorWithHexValue value: Int, alpha:CGFloat = 1.0) {
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(value & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

extension CalendarViewController {
    func getServerEvents() ->  [Date:String] {
        formatter.dateFormat = "yyyy MM dd"
        
        return [
            formatter.date(from: "2018 02 14")!: "Kein plan diggi",
            formatter.date(from: "2018 05 30")!: "Flipchat umkicken",
        ]
    }
}

// Ermöglicht das suchen nach einem bestimmtem Datum, oder zum Beispiel nach "Heute" und scrollt dahin.
extension CalendarViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchString = searchBar.text else { return }
        if searchString.lowercased().range(of: "heute") != nil {
            CalendarView.scrollToDate(Date(), animateScroll: true)
            CalendarView.selectDates([Date()])
        } else {
            formatter.dateFormat = "dd MM yyyy"
            guard let date = formatter.date(from: searchString) else { return }
            CalendarView.scrollToDate(date, animateScroll: true)
            CalendarView.selectDates([date])
        }
    }
    
    // Scope Button für Monats und Wochenansicht
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        scopeIndex = selectedScope
        CalendarView.reloadData()
        CalendarView.scrollToDate(Date(), animateScroll: false)
        print("\(selectedScope)")
    }
}









