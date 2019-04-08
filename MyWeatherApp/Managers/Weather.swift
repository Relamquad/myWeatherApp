//
//  Weather.swift
//  MyWeatherApp
//
//  Created by Konstantin Kalivod on 4/6/19.
//  Copyright © 2019 Kostya Kalivod. All rights reserved.
//

import Foundation

struct List {
    var name : String?
    var dt : Int
    var temp : Double
    var speed : Double
    var icon : String?
    init(dictionary: Dictionary <String, Any>){
//        name = dictionary["name"] as? String ?? "error name"
        dt = dictionary["dt"] as? Int ?? 0
        temp = (dictionary["main"] as? [String : Any] ?? ["":""])["temp"] as? Double ?? 0
        speed = (dictionary["wind"] as? [String : Any] ?? ["":""])["speed"] as? Double ?? 0
        icon = (dictionary["weather"] as? [Dictionary<String, Any>] ?? []).first?["icon"] as? String ?? "error icon"
    }

}