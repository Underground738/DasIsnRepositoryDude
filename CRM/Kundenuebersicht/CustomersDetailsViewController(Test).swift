//
//  CustomersDetailsViewController(Test).swift
//  CRM
//
//  Created by Julian Voith on 27.08.18.
//  Copyright © 2018 Noel Jander. All rights reserved.
//

import UIKit



class CustomersDetailsViewController_Test_: UIViewController{
    
    @IBOutlet weak var DetailOptions: UITableView!
    var detailOptions = ["Persönliche Daten", "Kontaktdaten", "Berufliches", "Personalien und Versicherungen"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       DetailOptions.dataSource = self
        
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

extension CustomersDetailsViewController_Test_: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customcell", for: indexPath) 
        cell.textLabel?.text = detailOptions[indexPath.item]
        return cell
    }
    
    
    
    
    
}
