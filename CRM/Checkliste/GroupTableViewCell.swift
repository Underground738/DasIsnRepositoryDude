//
//  GroupTableViewCell.swift
//  CRM
//
//  Created by Noel Jander on 10.06.18.
//  Copyright © 2018 Noel Jander. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {

    @IBOutlet weak var GroupTitle: UILabel!
    @IBOutlet weak var TasksCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
