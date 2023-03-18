//
//  StoreDiaperSensingLog+CoreDataProperties.swift
//  Monit
//
//  Created by john.lee on 15/05/2020.
//  Copyright © 2020 맥. All rights reserved.
//
//

import Foundation
import CoreData


extension StoreDiaperSensingLog {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoreDiaperSensingLog> {
        return NSFetchRequest<StoreDiaperSensingLog>(entityName: "StoreDiaperSensingLog")
    }

    @NSManaged public var id: Int32
    @NSManaged public var did: String?
    @NSManaged public var time: String?
    @NSManaged public var cnt: Int32
    @NSManaged public var cnt_second: Int32
    @NSManaged public var tem: String?
    @NSManaged public var hum: String?
    @NSManaged public var voc: String?
    @NSManaged public var cap: String?
    @NSManaged public var act: String?
    @NSManaged public var sen: String?
    @NSManaged public var mlv: String?
    @NSManaged public var eth: String?
    @NSManaged public var co2: String?
    @NSManaged public var pres: String?
    @NSManaged public var comp: String?
    
}
