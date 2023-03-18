//
//  StoreSensorMovGraph+CoreDataProperties.swift
//  Monit
//
//  Created by john.lee on 2019. 4. 9..
//  Copyright © 2019년 맥. All rights reserved.
//
//

import Foundation
import CoreData


extension StoreSensorMovGraph {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoreSensorMovGraph> {
        return NSFetchRequest<StoreSensorMovGraph>(entityName: "StoreSensorMovGraph")
    }

    @NSManaged public var did: String?
    @NSManaged public var id: Int32
    @NSManaged public var mov: String?
    @NSManaged public var time: String?
    @NSManaged public var cnt: Int32

}
