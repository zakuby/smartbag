//
//  Inventory.swift
//  SmartBag
//
//  Created by admin on 11/20/17.
//  Copyright © 2017 indosystem. All rights reserved.
//

import UIKit
import ObjectMapper

class InventoryList: NSObject{
    var imageUrl: String? = nil
    var ID: String? = nil
    var deskripsi: String? = nil
    var status:Int? = nil
    var nama: String? = nil
    var timeOutDate:String? = nil
    var timeOutTime:String? = nil
    var timeInDate:String? = nil
    var timeInTime:String? = nil
    var isAdded:Bool? = nil
    
    
    init(added:Bool, desc: String, imgUrl: String?, name: String?, inventID: String?, stat: Int, timeOut: String, timeIn: String) {
        isAdded = added
        imageUrl = imgUrl
        deskripsi = desc
        nama = name
        ID = inventID
        status = stat
        timeOutDate = timeOut
        timeInDate = timeIn
    }
}


class Inventory: Mappable {
    var imageUrl: String?
    var name: String?
    var deskripsi: String?
    var status:Int?
    var timeOut: String?
    var timeIn: String?
    
    required init?(map pMap: Map){
    }
    
    func mapping(map pMap: Map) {
        self.imageUrl   <- pMap["imageUrl"]
        self.name       <- pMap["nama"]
        self.deskripsi  <- pMap["deskripsi"]
        self.status     <- pMap["status"]
        self.timeOut    <- pMap["out.time"]
        self.timeIn     <- pMap["in.time"]
    }
}
