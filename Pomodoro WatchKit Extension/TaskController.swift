//
//  TaskController.swift
//  Pomodoro
//
//  Created by Carlos Corrêa on 8/26/15.
//  Copyright © 2015 Carlos Corrêa. All rights reserved.
//

import WatchKit
import Foundation

class TaskController: WKInterfaceController {

     //MARK: - Vars and properties
    let defaultPomodoroTimeInMinutes = 1 //Default is 25
    let defaultBreakTimeInMinutes = 1 //Default is 5
    var currentTask:TaskModel?
    var bgImageString:String?
    var taskTimer:NSTimer?
    var isBreakMode:Bool!
    @IBOutlet weak var lblTimer:WKInterfaceLabel?
    @IBOutlet weak var lblTaskName:WKInterfaceLabel?
    @IBOutlet weak var timerRingInterfaceGroup:WKInterfaceGroup?
    var seconds = 0
    
    //MARK: - WKInterfaceController lifecycle
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        if let task = context as? TaskModel {
            currentTask = task
            self.lblTaskName?.setText(task.name)
        }
        isBreakMode = false
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.updateInterfaceMenu()
    }
    
    //MARK: - Timer methods
    func startTaskTimer () {
        self.invalidateTimers()
        self.taskTimer = NSTimer(timeInterval: 1, target: self, selector: Selector("taskTimerFired"), userInfo: nil, repeats: true)
        self.scheduleTimerInRunLoop(self.taskTimer!)
    }
    
    func scheduleTimerInRunLoop(timer:NSTimer) {
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
    }
    
    func invalidateTimers() {
        self.taskTimer?.invalidate()
    }
    
    @objc func taskTimerFired() {
        self.updateTimerBackgroundImage()
        self.seconds++
        let (m, s) = self.secondsToMinutesSeconds(self.seconds)
        var minutes:String
        var seconds:String
    
        if m < 10 {
            minutes = "0\(m)"
        } else {
            minutes = "\(m)"
        }
        
        if s < 10 {
            seconds = "0\(s)"
        } else {
            seconds = "\(s)"
        }
        
        self.lblTimer?.setText("\(minutes):\(seconds)")
        self.updateTimerBackgroundImage()
        self.updateInterfaceMenu()
    }

    func secondsToMinutesSeconds (seconds : Int) -> (Int, Int) {
        return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }

    private func updateTimerBackgroundImage () {
        var elapsedSections = self.seconds/((defaultPomodoroTimeInMinutes*60)/12)
        
        if isBreakMode == true {
            elapsedSections = self.seconds/((defaultBreakTimeInMinutes*60)/12)
            if  self.seconds == defaultBreakTimeInMinutes*60 {
                self.stopTask()
                displayRestartAlert()
                isBreakMode = false
                self.lblTimer?.setTextColor(UIColor.whiteColor())
            }
        } else if self.seconds == defaultPomodoroTimeInMinutes*60 {
            startBreak()
        }
        
        //Updates the background image according with the time spent.
        let backgroundImageString = "circles_\(elapsedSections)"
        if backgroundImageString != self.bgImageString {
            self.bgImageString = backgroundImageString
            self.timerRingInterfaceGroup!.setBackgroundImageNamed(backgroundImageString)
        }
    }
    
     //MARK: - Interface methods
    private func displayRestartAlert () {
        let noAction = WKAlertAction(title: "No", style: WKAlertActionStyle.Cancel, handler: { () -> Void in
            // Delete this task fom Coredata and return to menu.
            self.deleteTask()
        })
        let yesAction = WKAlertAction(title: "Yes", style: WKAlertActionStyle.Default, handler: { () -> Void in
            // Restart 25 min timer.
            self.startTaskTimer()
        })
        self.presentAlertControllerWithTitle("Pomodoro", message: "Keep working on this task?", preferredStyle: WKAlertControllerStyle.SideBySideButtonsAlert, actions: [yesAction, noAction])
    }
    
    private func updateInterfaceMenu () {
        self.clearAllMenuItems()
        if self.taskTimer?.valid == true {
            self.addMenuItemWithItemIcon(WKMenuItemIcon.Decline, title: "Stop", action: Selector("stopTask"))
        } else {
            self.addMenuItemWithItemIcon(WKMenuItemIcon.Play, title: "Start", action: Selector("startTask"))
            self.addMenuItemWithItemIcon(WKMenuItemIcon.Trash, title: "Delete", action: Selector("deleteTask"))
        }
    }
    
    //MARK: - Task lifecycle
    func startTask () {
        self.startTaskTimer()
    }
    
    func stopTask () {
        self.taskTimer?.invalidate()
        //Reset the timer. We have work to do here!
        self.seconds = 0
        self.lblTimer?.setText("00:00")
        self.lblTaskName?.setText(self.currentTask?.name)
        self.updateTimerBackgroundImage()
        self.updateInterfaceMenu()
        self.timerRingInterfaceGroup!.setBackgroundImageNamed("circles_background")
    }
    
    func startBreak () {
        isBreakMode = true
        //Reset the timer. We want a break!
        self.seconds = 0
        self.lblTaskName?.setText("Break")
        //Let's notify user that he just finished this pomo and he needs a break.
        WKInterfaceDevice.currentDevice().playHaptic(WKHapticType.Success)
        self.timerRingInterfaceGroup!.setBackgroundImageNamed("circles_background")
    }
    
    func deleteTask () {
        self.dismissController()
        CCCoreDataStack.sharedInstance.deleteTask(self.currentTask!)
        self.popToRootController()
    }
}