//
//  MainLearningObjectCell.swift
//  MijnBewijsstukken
//
//  Created by Wijnand Boerma on 08-02-17.
//  Copyright © 2017 Wndworks. All rights reserved.
//

import UIKit

class LearningObjectCell: UITableViewCell {
    
    //Learning object name
    @IBOutlet weak var objectName: UILabel!

    @IBOutlet weak var borderCompleted: UIView!
    @IBOutlet weak var borderUncompleted: UIView!
    
    @IBOutlet weak var completedStar: DOFavoriteButton!
    
    @IBOutlet weak var pendingStar: UIButton!
    
}
