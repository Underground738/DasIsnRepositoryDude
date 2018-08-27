//
//  CustomersViewController.swift
//  CRM
//
//  Created by Noel Jander on 06.07.18.
//  Copyright © 2018 Noel Jander. All rights reserved.
//

import UIKit

class CustomersViewController: UIViewController {

    var customersDictionary = [String: [String]]()
    var customerSectionTitles = [String]()
    var customers = [String]()
    var filteredCustomers = [String]()
    
    let searchController = UISearchController(searchResultsController: nil)
 
    @IBOutlet weak var CustomersList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Suche Kunden..."
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        CustomersList.dataSource = self
        CustomersList.delegate = self
        
        customers = ["Bill Gates", "Steve Jobs", "Hugh Heffner", "Paul Walker", "Hugh Laurie", "Max Mustermann", "Melania Trump", "Donald Trump", "Barack Obama", "George Bush", "Johnny Walker", "Julian der Ranzige", "Peter Parker"]
        
        for customer in customers {
            let customerKey = String(customer.prefix(1))
            if var customerValues = customersDictionary[customerKey] {
                customerValues.append(customer)
                customersDictionary[customerKey] = customerValues
            } else {
                customersDictionary[customerKey] = [customer]
            }
        }
        
        customerSectionTitles = [String](customersDictionary.keys)
        customerSectionTitles = customerSectionTitles.sorted(by: { $0 < $1 })
        
        CustomersList.separatorInset = .zero
        
        CustomersList.tableFooterView = UIView(frame: CGRect.zero)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Ueberprueft ob SearchBar leer ist oder nicht
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredCustomers = customers.filter({$0.lowercased().contains(searchText.lowercased())})
        CustomersList.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }

}

extension CustomersViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let customerKey = customerSectionTitles[section]
        if isFiltering() {
            return filteredCustomers.count
        } else  if let customerValues = customersDictionary[customerKey] {
            return customerValues.count
        }
        
       // return candies.count
        
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering() {
            return 1
        } else {
            return customerSectionTitles.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerCell", for: indexPath)
        
        // Configure the cell...
        let customerKey = customerSectionTitles[indexPath.section]
        if isFiltering() {
            cell.textLabel?.text = filteredCustomers[indexPath.row]
        } else if let customerValues = customersDictionary[customerKey] {
            cell.textLabel?.text = customerValues[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFiltering() {
            return "Suchergebnisse"
        } else {
            return customerSectionTitles[section]
        }
    }
    
}

extension CustomersViewController: UITableViewDelegate {

}

extension CustomersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
