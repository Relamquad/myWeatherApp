//
//  ViewController.swift
//  MyWeatherApp
//
//  Created by Konstantin Kalivod on 4/5/19.
//  Copyright © 2019 Kostya Kalivod. All rights reserved.
//

import UIKit
import Charts

class ViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherCollectionView: UICollectionView!
    @IBOutlet weak var lineChartView: LineChartView!
   
    //MARK: - variables
    var myweatherList : Array = [List]()
    var myCityName = ""
    var arrayTemp : [Double] = []
    var arrayDate : [Int] = []
   
    //MARK: - VC actions and life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        lineChartView.chartDescription?.enabled = false
        let defaults = UserDefaults.standard
        //setting from userdefaults
        self.myCityName = defaults.string(forKey: "cityNameKey") ?? ""
        let jsonDecoder = JSONDecoder()
        let jsonData = defaults.object(forKey: "MyArrayJsonKey")
        
        if let jsonData = jsonData as? Data {
            let decodeData = try! jsonDecoder.decode([List].self, from: jsonData)
            self.myweatherList = decodeData as? [List] ?? [List]()
        } else{
          
        }
        self.arrayTemp = defaults.array(forKey: "TempArrayKey")  as? [Double] ?? [Double]()
        self.arrayDate = defaults.array(forKey: "TempDateKey")  as? [Int] ?? [Int]()

        
        self.cityLabel.text = self.myCityName
        weatherCollectionView.dataSource = self
        weatherCollectionView.delegate = self

        print("MyWeatherArrayCount!!!! = \(myweatherList.count)")
        setChart(dataPoints: self.arrayDate, values: self.arrayTemp)
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
        let strDate = dateFormatter.string(from: date)
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
            //accepting weather and saving it to userdefaults
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
            //circle for appeding arrays temp and date for charts nad saving them to userdefaults
            self.arrayTemp = []
            self.arrayDate = []
            for temp in array.count {
                let getInfo = array[temp]
                self.arrayTemp.append(getInfo.temp)
                self.arrayDate.append(getInfo.dt)
            }
            defaults.set(self.arrayTemp, forKey: "TempArrayKey")
            defaults.set(self.arrayDate, forKey: "TempDateKey")
            print("ArrayTemp == \(self.arrayTemp)\n\n ArrayDate == \(self.arrayDate)")
            DispatchQueue.main.async {
                self.weatherCollectionView.reloadData()
                self.cityLabel.text = self.myCityName
                self.cityLabel.reloadInputViews()
                self.setChart(dataPoints: self.arrayDate, values: self.arrayTemp)
            }
        }
            textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
    
    //MARK: - func set Chart
    func setChart(dataPoints: [Int], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        
        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "temperature °C")
        lineChartDataSet.colors = [NSUIColor.blue]
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        lineChartView.data = lineChartData
        // circle for appending dataArray date with format type string from int timestamp format
        var dateArray : [String] = []
        for i in 0..<dataPoints.count {
            let date = Date(timeIntervalSince1970: Double(dataPoints[i]))
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "dd MMM\nHH:mm" //Specify your format that you want
            let strDate = dateFormatter.string(from: date)
            dateArray.append(strDate)
        }

        //x Axis
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dateArray)
        
}
}
