//
//  Reminder.swift
//  SmartBag
//
//  Created by admin on 11/12/17.
//  Copyright © 2017 indosystem. All rights reserved.
//

import Foundation
import ObjectMapper

class ReminderList: NSObject{
    var nama: [String]? = nil
    var dates:String? = nil
    
    init(date: String?, name: [String]?) {
        dates = date
        nama = name
    }
}


class Reminder: Mappable {    var name: String?
    
    required init?(map pMap: Map){
    }
    
    func mapping(map pMap: Map) {
        self.name <- pMap["nama"]
    }
}
