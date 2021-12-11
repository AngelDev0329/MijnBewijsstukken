//
//  SearchCell.swift
//  MijnBewijsstukken
//
//  Created by Wijnand Boerma on 28-06-18.
//  Copyright © 2018 Wndworks. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    @IBOutlet weak var objectName: UILabel!
    @IBOutlet weak var borderUncompleted: UIView!
    @IBOutlet weak var borderCompleted: UIView!
    @IBOutlet weak var classImage: UIImageView!
    @IBOutlet weak var objectLevel: UILabel!
    @IBOutlet weak var objectMain: UILabel!
    
    @IBOutlet weak var completedStar: DOFavoriteButton!
    @IBOutlet weak var pendingStar: UIButton!
    
}
