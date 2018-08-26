//
//  calendarWeekView.swift
//  CRM
//
//  Created by Noel Jander on 23.08.18.
//  Copyright © 2018 Noel Jander. All rights reserved.
//

import UIKit
import JZCalendarWeekView

class calendarWeekView: JZBaseWeekView {

    override func registerViewClasses() {
        super.registerViewClasses()
        
        // Register CollectionViewCell
        self.collectionView.register(UINib(nibName: "EventCell", bundle: nil), forCellWithReuseIdentifier: "EventCell")
        
        // Register DecorationView: must provide corresponding JZDecorationViewKinds
        self.flowLayout.register(BlackGridLine.self, forDecorationViewOfKind: JZDecorationViewKinds.verticalGridline)
        self.flowLayout.register(BlackGridLine.self, forDecorationViewOfKind: JZDecorationViewKinds.horizontalGridline)
        
        // Register SupplementrayView: must override collectionView viewForSupplementaryElementOfKind
        collectionView.register(RowHeader.self, forSupplementaryViewOfKind: JZSupplementaryViewKinds.rowHeader, withReuseIdentifier: "RowHeader")
    }

}
