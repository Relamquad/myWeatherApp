//
//  CollectionViewCell.swift
//  MyWeatherApp
//
//  Created by Konstantin Kalivod on 4/5/19.
//  Copyright © 2019 Kostya Kalivod. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
}
