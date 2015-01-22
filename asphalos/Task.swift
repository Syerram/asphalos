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
    @NSManaged var order: NSNumber

    ///MARK: Non managed
    var lengthFormatted:String {
        get {
            var hours = self.length.integerValue / 60
            var mins = self.length.integerValue % 60
            if hours > 0 {
                return "\(hours) hrs and \(mins) mins"
            } else {
                return "\(mins) mins"
            }
        }
    }

    ///Swap the task timings with each other
    class func SwapOrder(source:Task, destination:Task) {
        var startDate = destination.startDate
        destination.startDate = source.startDate
        source.startDate = startDate
        (destination.order, source.order) = (source.order, destination.order)

        Task.save()
    }

}
