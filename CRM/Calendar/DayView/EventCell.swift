//
//  EventCell.swift
//  CRM
//
//  Created by Noel Jander on 16.09.18.
//  Copyright © 2018 Noel Jander. All rights reserved.
//

import UIKit
import JZCalendarWeekView

class EventCell: JZLongPressEventCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var borderView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupBasic()
    }
    
    func setupBasic() {
        self.clipsToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 5
        layer.shadowOpacity = 0
        locationLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        self.backgroundColor = UIColor(hex: 0xEEF7FF)
        borderView.backgroundColor = UIColor(hex: 0x0899FF)
    }
    
    func configureCell(event: DefaultEvent) {
        self.event = event
        locationLabel.text = event.location
        titleLabel.text = event.title
    }

}
