//
//  InterfaceController.swift
//  Pomodoro WatchKit 1 Extension
//
//  Created by Carlos Corrêa on 8/25/15.
//  Copyright © 2015 Carlos Corrêa. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {

    //MARK: - Variables and Properties
    @IBOutlet var table: WKInterfaceTable!
    @IBOutlet var lblNoTasks: WKInterfaceLabel!
    @IBOutlet var imgTomato: WKInterfaceImage!
    var selectedTask: TaskModel?

    //MARK: - WKInterfaceController lifecycle
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.setupTable()
        
        //This will animate our tomato. Let's make that pretty dude!
        self.imgTomato.setImageNamed("tomato")
        self.imgTomato.startAnimatingWithImagesInRange(NSMakeRange(1, 10), duration: 0.8, repeatCount: 0)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    //MARK: - UI Setup
    //Loads the TaskModel objects into the WKInterfaceTable.
    func setupTable() {
        if let activitiesList = CCCoreDataStack.sharedInstance.allTasks() as [TaskModel]? {
            self.table.setNumberOfRows(activitiesList.count, withRowType: "TaskRowType")
            if activitiesList.count != 0 {
                var i=0
                for task in activitiesList {
                    let row = self.table.rowControllerAtIndex(i) as! TaskRowType
                    //task = activitiesList[i] as! TaskModel
                    row.rowDescription.setText(task.name)
                    i++
                }
                self.lblNoTasks.setHidden(true)
                self.imgTomato.setHidden(true)
            } else {
                self.lblNoTasks.setHidden(false)
                self.imgTomato.setHidden(false)
            }
        }
    }
    
    //MARK: - Sending data to TaskController
    override func contextForSegueWithIdentifier(segueIdentifier: String,
        inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
            if segueIdentifier == "TaskDetailsSegue" {
                if let activitiesList = CCCoreDataStack.sharedInstance.allTasks() as [TaskModel]? {
                    self.table.setNumberOfRows(activitiesList.count, withRowType: "TaskRowType")
                    let task = activitiesList[rowIndex]
                    return task
                }
            }
            return nil
    }
    
    //MARK: - User Input
    @IBAction func enterActivityNameButtonTapped() {
        self.presentTextInputControllerWithSuggestions([
            "Read a book",
            "Gym",
            "Run",
            "Walk with my dog",
            "Work"], allowedInputMode: WKTextInputMode.Plain, completion:{(selectedAnswers) -> Void  in
                if selectedAnswers != nil {
                    if let taskName = selectedAnswers!.first as? String {
                        CCCoreDataStack.sharedInstance.createTask(taskName)
                        CCCoreDataStack.sharedInstance.saveContext()
                        self.setupTable()
                    }
                }
        })
    }
}

//MARK: - Misc
//The row class with a custom WKInterfaceLabel on it.
class TaskRowType: NSObject {
    @IBOutlet weak var rowDescription: WKInterfaceLabel!
}