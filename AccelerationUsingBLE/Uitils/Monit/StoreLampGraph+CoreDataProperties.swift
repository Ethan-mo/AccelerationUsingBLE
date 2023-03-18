//
//  StoreLampGraph+CoreDataProperties.swift
//  Monit
//
//  Created by john.lee on 14/01/2020.
//  Copyright © 2020 맥. All rights reserved.
//
//

import Foundation
import CoreData


extension StoreLampGraph {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoreLampGraph> {
        return NSFetchRequest<StoreLampGraph>(entityName: "StoreLampGraph")
    }

    @NSManaged public var did: String?
    @NSManaged public var hum: String?
    @NSManaged public var id: Int32
    @NSManaged public var tem: String?
    @NSManaged public var time: String?
    @NSManaged public var voc: String?

}
