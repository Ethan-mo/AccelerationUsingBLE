//
//  StoreSensorVocGraph+CoreDataProperties.swift
//  Monit
//
//  Created by john.lee on 14/05/2020.
//  Copyright © 2020 맥. All rights reserved.
//
//

import Foundation
import CoreData


extension StoreSensorVocGraph {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoreSensorVocGraph> {
        return NSFetchRequest<StoreSensorVocGraph>(entityName: "StoreSensorVocGraph")
    }

    @NSManaged public var did: String?
    @NSManaged public var id: Int32
    @NSManaged public var cnt: Int32
    @NSManaged public var voc: String?
    @NSManaged public var time: String?

}
