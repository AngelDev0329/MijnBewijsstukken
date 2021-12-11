//
//  levelButtons.swift
//  MijnBewijsstukken
//
//  Created by Wijnand Boerma on 08-02-17.
//  Copyright © 2017 Wndworks. All rights reserved.
//

import UIKit

//Button of an available level

class levelBtnFilled: UIButton {
    
    required public init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor(red: 89/255, green: 184/255, blue: 207/255, alpha: 1)
        self.layer.cornerRadius = 3
        
    }
    
}

//Button of a completed level

class levelBtnCompleted: UIButton {
    
    required public init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor(red: 140/255, green: 236/255, blue: 135/255, alpha: 1)
        self.layer.cornerRadius = 3
        
    }
    
}

//Button of an empty level

class levelBtnEmpty: UIButton {
    
    required public init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
        self.layer.cornerRadius = 3
        
    }
    
}
