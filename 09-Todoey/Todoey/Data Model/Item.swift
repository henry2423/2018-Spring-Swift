//
//  Item.swift
//  Todoey
//
//  Created by Henry on 03/03/2018.
//  Copyright © 2018 Henry Huang. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dataCreated: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
