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
    
    init(desc: String, imgUrl: String?, name: String?, inventID: String?, stat: Int,toDay: Int?, toMonth: Int?, toYear: Int?, toHour: Int?, toMinute: Int?, toSecond: Int?,tiDay: Int?, tiMonth: Int?, tiYear: Int?, tiHour: Int?, tiMinute: Int?, tiSecond: Int?) {
        imageUrl = imgUrl
        deskripsi = desc
        nama = name
        ID = inventID
        status = stat
        timeOutDate = String(toDay!) + "/" + String(toMonth!) + "/" + String(toYear!)
        timeInDate = String(tiDay!) + "/" + String(tiMonth!) + "/" + String(tiYear!)
        timeOutTime = String(toHour!) + ":" + String(toMinute!) + ":" + String(toSecond!)
        timeInTime = String(tiHour!) + ":" + String(tiMinute!) + ":" + String(tiSecond!)
    }
}


class Inventory: Mappable {
    var imageUrl: String?
    var name: String?
    var deskripsi: String?
    var status:Int?
    var timeOutDay:Int?
    var timeOutMonth:Int?
    var timeOutYear:Int?
    var timeOutHour:Int?
    var timeOutMinute:Int?
    var timeOutSecond:Int?
    var timeInDay:Int?
    var timeInMonth:Int?
    var timeInYear:Int?
    var timeInHour:Int?
    var timeInMinute:Int?
    var timeInSecond:Int?
    
    required init?(map pMap: Map){
    }
    
    func mapping(map pMap: Map) {
        self.imageUrl <- pMap["imageUrl"]
        self.name <- pMap["nama"]
        self.deskripsi <- pMap["deskripsi"]
        self.status  <- pMap["status"]
        self.timeOutDay <- pMap["out.timeDay"]
        self.timeOutMonth <- pMap["out.timeMonth"]
        self.timeOutYear <- pMap["out.timeYear"]
        self.timeOutHour <- pMap["out.timeHour"]
        self.timeOutMinute <- pMap["out.timeMinute"]
        self.timeOutSecond <- pMap["out.timeSecond"]
        self.timeInDay <- pMap["in.timeDay"]
        self.timeInMonth <- pMap["in.timeMonth"]
        self.timeInYear <- pMap["in.timeYear"]
        self.timeInHour <- pMap["in.timeHour"]
        self.timeInMinute  <- pMap["in.timeMinute"]
        self.timeInSecond  <- pMap["in.timeSecond"]
    }
}
