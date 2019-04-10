//
//  APIManager.swift
//  MyWeatherApp
//
//  Created by Konstantin Kalivod on 4/6/19.
//  Copyright © 2019 Kostya Kalivod. All rights reserved.
//

import Foundation
import Alamofire
class APIManager {
    class func getWeatherInfoIn(place: String, completion: @escaping ([List], String) -> ()){
    var weatherList : [List] = []
    var cityName = ""
       let baseURL = "http://api.openweathermap.org/data/2.5/forecast?q=\(place)&units=metric&APPID=eb16dd851a03c951de26cb3f0c0126d6"
        
        Alamofire.request(baseURL).responseJSON { response in
            
            guard response.result.isSuccess else {
                print("Ошибка при запросе данных \n\n\(String(describing: response.result.error))")
                return
            }
            if let JSON = response.result.value as? Dictionary<String, AnyObject> {
                //Получаем json и массив с погодой + проверка
                let list = JSON["list"] as?  [Dictionary<String, Any>]
                print("JSON == \(String(describing: list))")
              
                //Получаем город из массива с погодой + проверка
                let city = JSON["city"] as?  [String : Any]
                let name = city?["name"] as? String ?? ""
                print("cityname!!!!!! == \(name)")
                
                //Заполняем наш массив данными 
                var returnArray: [List] = []
                for dict in list ?? [] {
                    let newWeather = List(dictionary: dict)
                    returnArray.append(newWeather)
                }
                weatherList = returnArray
                cityName = name
            } else {
                print ("Error weather JSON")
            }
            print("Weatherlist count == \(weatherList.count)")
        completion(weatherList, cityName)
            
        }
    }

}
