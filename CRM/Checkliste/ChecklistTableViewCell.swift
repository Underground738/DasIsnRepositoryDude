//
//  ChecklistTableViewCell.swift
//  CRM
//
//  Created by Noel Jander on 10.06.18.
//  Copyright © 2018 Noel Jander. All rights reserved.
//

import UIKit
import M13Checkbox

class ChecklistTableViewCell: UITableViewCell {

    @IBOutlet weak var checkBox: M13Checkbox!
    @IBOutlet weak var tasksTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let cellTapGesture = UITapGestureRecognizer(target: self, action: #selector(checkboxTapped))
        checkBox.addGestureRecognizer(cellTapGesture)
        checkBox.isUserInteractionEnabled = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @objc func checkboxTapped(sender: UITapGestureRecognizer) {
        print("Cell was tapped")
    }
}
