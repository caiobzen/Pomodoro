//
//  CCCoreDataStack.swift
//  Pomodoro
//
//  Created by Carlos Corrêa on 8/25/15.
//  Copyright © 2015 Carlos Corrêa. All rights reserved.
//

import Foundation
import CoreData

public class CCCoreDataStack {
    
    public class var sharedInstance:CCCoreDataStack {
        struct Singleton {
            static let instance = CCCoreDataStack()
        }
        return Singleton.instance
    }

    // MARK: - CRUD methods
    /**
    This method will add a new TaskModel object into core data.
    
    :param: name The given name of the TaskModel object.
    
    :returns: A brand new TaskModel object.
    */
    public func createTask(name:String) -> TaskModel? {
        let newTask = NSEntityDescription.insertNewObjectForEntityForName("TaskModel", inManagedObjectContext: self.managedObjectContext!) as! TaskModel;
        newTask.name = name
        newTask.creationTime = NSDate()
        return newTask
    }

    /**
    This method will delete a TaskModel object from core data.

    :param: task The given TaskModel object to be deleted.
    */
    public func deleteTask(task:TaskModel) {
        self.managedObjectContext?.deleteObject(task)
        self.saveContext()
    }

    /**
    This method will fetch all the TaskModel objects from core data.
    
    :returns: An Array of TaskModel objects.
    */
    public func allTasks() -> [TaskModel]? {
        let request = NSFetchRequest(entityName: "TaskModel")
        request.sortDescriptors = [
            NSSortDescriptor(key: "creationTime", ascending: false)
        ]
        
        do {
            let tasks = try self.managedObjectContext?.executeFetchRequest(request) as! [TaskModel]?
            return tasks
        } catch let error as NSError {
            print(error)
            return []
        }
    }

    // MARK: - lazy vars
    //Why lazy vars? For delaying the creation of an object or some other expensive process until it’s needed. And we can also add logic to our lazy initialization. That is cool, huh?
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
    }()

    // The managed object model for the application.
    lazy var managedObjectModel: NSManagedObjectModel = {
        return NSManagedObjectModel.mergedModelFromBundles(nil)!
    }()

    // The persistent store coordinator for the application.
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        var containerPath = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Pomodoro.sqlite")
        var error: NSError? = nil
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: containerPath, options: nil)
        } catch {
            return nil
        }
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support
    public func saveContext () {
        if let context = self.managedObjectContext {
            if (context.hasChanges) {
                do{
                    try context.save()
                } catch let error as NSError {
                    print(error)
                }
            }
        }
    }
}