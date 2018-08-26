//
//  NotesViewController.swift
//  CRM
//
//  Created by Noel Jander on 14.07.18.
//  Copyright © 2018 Noel Jander. All rights reserved.
//

import UIKit
import PDFKit

class NotesViewController: UIViewController {
    
    @IBOutlet weak var redoButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var drawingView: CanvasView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Todo: Button selector setup
    // Image getten aus Stack info und dann an canvasView weitergeben 
    @IBAction func redoButtonTouched(_ sender: UIButton) {
        store.redo()
    }
    
    @IBAction func undoButtonTouched(_ sender: UIButton) {
        store.undo()
    }
}



