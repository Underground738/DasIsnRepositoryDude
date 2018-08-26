//
//  StartmenuTableViewCell.swift
//  CRM
//
//  Created by Noel Jander on 04.06.18.
//  Copyright © 2018 Noel Jander. All rights reserved.
//

import UIKit

class StartmenuTableViewCell: UITableViewCell {

    @IBOutlet weak var checkBoxImage: UIImageView!
    @IBOutlet weak var CheckboxTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
