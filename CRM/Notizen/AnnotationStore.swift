//
//  AnnotationStore.swift
//  CRM
//
//  Created by Noel Jander on 24.07.18.
//  Copyright © 2018 Noel Jander. All rights reserved.
//

import Foundation

class AnnotationStore {
    
    var db: DB
    var state: Set<Annotation> = []
    
    var undoStack: [UndoRedoStep<Annotation>] = []
    var redoStack: [UndoRedoStep<Annotation>] = []
    
    init(db: DB) {
        self.db = db
    }
    
    func annotationByID(annotationID: UUID) -> Annotation? {
        return self.state.first { $0.id == annotationID }
    }
    
    func save(annotation: Annotation, isUndoRedo: Bool = false) {
        // Don't record undo step for actions that are performed
        // as part of undo/redo
        
        if !isUndoRedo {
            // Fetch oldValue
            let oldValue = self.annotationByID(annotationID: annotation.id)
            // Store change on undo Stack
            let undoStep = UndoRedoStep(oldValue: oldValue, newValue: annotation)
            self.undoStack.append(undoStep)
            
            // Reset redo stack after each user action that is not an undo/redo
            self.redoStack = []
        }
        
        // Update in-memory state
        self.state.remove(annotation)
        self.state.insert(annotation)
        
        // Update db state
        self.db.saveAnnotation(annotation: annotation)
    }
    
    func delete(annotation: Annotation, isUndoRedo: Bool = false) {
        if !isUndoRedo {
            // Fetch oldValue
            let oldValue = self.annotationByID(annotationID: annotation.id)
            // Store change on undo stack
            let undoStep = UndoRedoStep(oldValue: oldValue, newValue: nil)
            self.undoStack.append(undoStep)
            
            // Reset redo stack after each user action that is not an undo/redo
            self.redoStack = []
        }
        
        self.state.remove(annotation)
        self.db.delete(annotation: annotation)
    }
    
    func undo() {
        guard let undoRedoStep = self.undoStack.popLast() else {
            return
        }
        
        self.perform(undoRedoStep: undoRedoStep)
        
        self.redoStack.append(undoRedoStep.flip())
    }
    
    func redo() {
        guard let undoRedoStep = self.redoStack.popLast() else {
            return
        }
        
        self.perform(undoRedoStep: undoRedoStep)
        
        self.undoStack.append(undoRedoStep.flip())
    }
    
    func perform(undoRedoStep: UndoRedoStep<Annotation>) {
        // Switch over the old and new value and call a store method that
        // implements the transition between these values.
        switch (undoRedoStep.oldValue, undoRedoStep.newValue) {
        // Old and new Value are non-nil: update.
        case let (oldValue?, _?):
            self.save(annotation: oldValue, isUndoRedo: true)
        // New Value is nil, old Value was non-nil: create
        case (let oldValue?, nil):
            // Our save implementation also handles creates, but depending
            // on your DB interface these might be seperate methodes.
            self.save(annotation: oldValue, isUndoRedo: true)
        // Old Value was nil, new Value was non-nil: delete
        case (nil, let newValue?):
            self.delete(annotation: newValue, isUndoRedo: true)
        default:
            fatalError("Undo step with neither old nor new value makes sense!")
        }
    }
    
}








