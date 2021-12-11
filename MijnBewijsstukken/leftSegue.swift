//
//  leftSegue.swift
//  MijnBewijsstukken
//
//  Created by Wijnand Boerma on 24-11-17.
//  Copyright © 2017 Wndworks. All rights reserved.
//

import UIKit
import AVFoundation
import QuartzCore

class SegueFromLeft: UIStoryboardSegue
{
    override func perform()
    {
        let src = self.source
        print(src)
        let dst = self.destination
        print(dst)
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: -src.view.frame.size.height, y: 0)
        
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseInOut,
                       animations: {
                        dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
        },
                       completion: { finished in
                        if let navController = src.navigationController {
                            navController.pushViewController(dst, animated: false)
                            
                        } else {
                            src.present(dst, animated: false, completion: nil)
                        }            }
        )
    }
}
