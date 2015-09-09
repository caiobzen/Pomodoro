//
//  TaskModel.swift
//  Pomodoro
//
//  Created by Carlos Corrêa on 8/25/15.
//  Copyright © 2015 Carlos Corrêa. All rights reserved.
//

import Foundation
import CoreData

@objc(TaskModel)

public class TaskModel: NSManagedObject {

    @NSManaged public var creationTime: NSDate
    @NSManaged public var name: String

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?){
        super.init(entity: entity, insertIntoManagedObjectContext:context)
    }

}


