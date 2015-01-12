//
//  Category.swift
//  asphalos
//
//  Created by Saikiran Yerram on 12/30/14.
//  Copyright (c) 2014 Blackhorn. All rights reserved.
//

import Foundation
import CoreData

class Category: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var accountCount: NSNumber

}
