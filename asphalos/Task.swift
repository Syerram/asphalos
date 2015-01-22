//
//  asphalos.swift
//  asphalos
//
//  Created by Saikiran Yerram on 1/14/15.
//  Copyright (c) 2015 Blackhorn. All rights reserved.
//

import Foundation
import CoreData

class Task: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var length: NSNumber
    @NSManaged var startDate: NSDate
    @NSManaged var info: String
    @NSManaged var completed: NSNumber
    @NSManaged var actual: NSNumber


    ///MARK: Non managed
    var endTime:NSDate {
        get {
            var interval:NSTimeInterval = Double(length) * 60.00
            return self.startDate.dateByAddingTimeInterval(interval)
        }
    }

    ///Swap the task timings with each other
    class func SwapTimes(source:Task, destination:Task) {
        var startDate = destination.startDate
        destination.startDate = source.startDate
        source.startDate = startDate
        Task.save()
    }

}
