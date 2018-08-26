//
//  File.swift
//  CRM
//
//  Created by Noel Jander on 24.07.18.
//  Copyright © 2018 Noel Jander. All rights reserved.
//

import Foundation
import UIKit

//enum Color {
//    case red
//    case blue
//    case yellow
//}

struct Annotation: Hashable, Equatable {
    let id: UUID
    var color: UIColor
    var image: UIImage
    
    init(id: UUID = UUID(), color: UIColor, image: UIImage) {
        self.id = id
        self.color = color
        self.image = image
        
    }
    
    var hashValue: Int {
        return self.id.hashValue
    }
    
    static func == (lhs: Annotation, rhs: Annotation) -> Bool {
        return lhs.id == rhs.id
    }
}

// Undo/Redo - Types
struct UndoRedoStep<T> {
    let oldValue: T?
    let newValue: T?
    
    // Konvertiert einen Undo-Step in einen Redo und einen Redo in einen Undo-Step
    func flip() -> UndoRedoStep<T> {
        return UndoRedoStep(oldValue: self.newValue, newValue: self.oldValue)
    }
    
}

class DB {
    var state: Set<Annotation> = []
    
    init() {}
    
    func saveAnnotation(annotation: Annotation) {
        // Replace old with new
        self.state.remove(annotation)
        self.state.insert(annotation)
    }
    
    func delete(annotation: Annotation) {
        self.state.remove(annotation)
    }
    
    func create(annotation: Annotation) {
        self.state.insert(annotation)
    }
    
}


