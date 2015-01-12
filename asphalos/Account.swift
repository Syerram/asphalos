//
//  Account.swift
//  asphalos
//
//  Created by Saikiran Yerram on 12/30/14.
//  Copyright (c) 2014 Blackhorn. All rights reserved.
//

import Foundation
import CoreData

class Account: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var password: String
    @NSManaged var userName: String
    @NSManaged var website: String
    @NSManaged var info: String
    @NSManaged var category: Category


}
