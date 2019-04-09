//
//  ViewController.swift
//  MyWeatherApp
//
//  Created by Konstantin Kalivod on 4/5/19.
//  Copyright © 2019 Kostya Kalivod. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherCollectionView: UICollectionView!
    
    var array = ["First", "Second", "Third", "Fourth", "Fifth", "Seven", "Eight", "Nine"]
    var myweatherList : Array = [List]()
    var myCityName = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        
        self.myCityName = defaults.string(forKey: "cityNameKey") ?? ""

        let jsonDecoder = JSONDecoder()
        let jsonData = defaults.object(forKey: "MyArrayJsonKey")
        
        if let jsonData = jsonData as? Data {
            let decodeData = try! jsonDecoder.decode([List].self, from: jsonData)
            self.myweatherList = decodeData as? [List] ?? [List]()
        } else{

            
        }
        self.cityLabel.text = self.myCityName
        weatherCollectionView.dataSource = self
        weatherCollectionView.delegate = self

        print("MyWeatherArrayCount!!!! = \(myweatherList.count)")
        // Do any additional setup after loading the view, typically from a nib.
    }
  

}
extension ViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myweatherList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCellID", for: indexPath) as! CollectionViewCell
        let myWeatherArray = myweatherList[indexPath.row]
        
        let date = Date(timeIntervalSince1970: Double(myWeatherArray.dt))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd.MM HH:mm" //Specify your format that you want
        var strDate = dateFormatter.string(from: date)
        itemCell.dateLabel.text = String(strDate)
        itemCell.tempLabel.text = String(Int(myWeatherArray.temp))
        itemCell.windLabel.text = String(myWeatherArray.speed)
        itemCell.iconImage.image = UIImage(named: myWeatherArray.icon ?? "sun")
        return itemCell
    }
    
    
    
    
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard  let text = textField.text else { return false }
        APIManager.getWeatherInfoIn(place: text) { (array, cityName) in
            self.myweatherList = array
            self.myCityName = cityName
            let defaults = UserDefaults.standard

            let jsonEncoder = JSONEncoder()
                let jsonData = try! jsonEncoder.encode(array)
                let jsonString = String(data: jsonData, encoding: .utf8)
                print("JSON String : " + jsonString!)
                
            defaults.set(jsonData, forKey: "MyArrayJsonKey")
            defaults.set(cityName, forKey: "cityNameKey")
            print("MyWeatherArrayCount!!!! = \(self.myweatherList.count)")
            DispatchQueue.main.async {
                self.weatherCollectionView.reloadData()
                self.cityLabel.text = self.myCityName
                self.cityLabel.reloadInputViews()
            }
        }

            textField.resignFirstResponder()
            
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
}
