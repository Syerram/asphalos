//
//  DataManager.swift
//  asphalos
//
//  Created by Saikiran Yerram on 12/28/14.
//  Copyright (c) 2014 Blackhorn. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension NSManagedObject {

    ///Save all of the changes
    class func save() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.saveContext()
    }

    class func managedObjectContext() -> NSManagedObjectContext? {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let managedObjContext = appDelegate.managedObjectContext {
            return managedObjContext
        } else {
            return nil
        }
    }


    ///Calling this method will delete the object and commit changes.
    ///@warning: If you have any other changes in the context, those will be committed as well
    class func deleteNow(managedObject:NSManagedObject) {
        NSManagedObject.managedObjectContext()?.deleteObject(managedObject)
        NSManagedObject.save()
    }

    ///Remove all of the records for the given entities
    class func purge(entityNames: [String]) {
        var isDirty = false
        for entityName in entityNames {
            let fetchRequest = NSFetchRequest(entityName: entityName)
            fetchRequest.includesPropertyValues = false
            fetchRequest.includesSubentities = false
            if let results = NSManagedObject.managedObjectContext()!.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject] {
                for result in results {
                    NSManagedObject.managedObjectContext()?.deleteObject(result)
                    isDirty = true
                }
            }
        }
        if isDirty {
            NSManagedObject.save()
            NSManagedObject.managedObjectContext()?.reset()
        }
    }

    ///New entity
    class func newEntity<T>(entityName:String) -> T {
        return NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: self.managedObjectContext()!) as! T
    }

    ///Prepare sort descriptors for list of tuples with key, ascending order
    class func prepareSortDescriptors(sortKeys:[(String, Bool)]) -> [NSSortDescriptor]{
        var sortDescriptors:[NSSortDescriptor] = []
        for (key, ascending) in sortKeys {
            sortDescriptors.append(NSSortDescriptor(key: key, ascending: ascending))
        }
        return sortDescriptors
    }

    ///Return all objects of the given entity
    class func fetchAll(entityName:String, sortKeys:[(String, Bool)]? = nil) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        if let _sortKeys = sortKeys {
            fetchRequest.sortDescriptors = self.prepareSortDescriptors(_sortKeys)
        }
        if let fetchResults = NSManagedObject.managedObjectContext()!.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject] {
            return fetchResults
        } else {
            return []
        }
    }

    ///Return specific objects for the given predicate
    class func fetch(entityName:String, sortKeys:[(String, Bool)]? = nil, predicates:() -> NSPredicate) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = predicates()
        if let _sortKeys = sortKeys {
            fetchRequest.sortDescriptors = self.prepareSortDescriptors(_sortKeys)
        }
        if let fetchResults = NSManagedObject.managedObjectContext()!.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject] {
            return fetchResults
        } else {
            return []
        }
    }

    ///Provide count of objects for the given predicate
    class func count(entityName:String, predicates:() -> NSPredicate) -> Int {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = predicates()
        return NSManagedObject.managedObjectContext()!.countForFetchRequest(fetchRequest, error: nil)
    }

}