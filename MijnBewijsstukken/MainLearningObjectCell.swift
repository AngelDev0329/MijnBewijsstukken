//
//  MainLearningObjectCell.swift
//  MijnBewijsstukken
//
//  Created by Wijnand Boerma on 08-02-17.
//  Copyright © 2017 Wndworks. All rights reserved.
//

import UIKit

protocol MainLearningObjectCellDelegate: class {
    func didClickedTotalPercentButton(_ indexPath: IndexPath, percentStr: String )
    func didClickedLevelPercentButton(_ indexPath: IndexPath, percentStr: String )
    func didStartPanGesture(cell: MainLearningObjectCell)
}



open class MainLearningObjectCell: UITableViewCell {
    
    //Main learning object name
    @IBOutlet weak var objectName: UILabel!
    
    //Level buttons
    @IBOutlet weak var levelA: UIButton!
    @IBOutlet weak var levelB: UIButton!
    @IBOutlet weak var levelC: UIButton!
    @IBOutlet weak var levelD: UIButton!
    @IBOutlet weak var levelE: UIButton!
    @IBOutlet weak var levelF: UIButton!
    @IBOutlet weak var levelG: UIButton!
    @IBOutlet weak var levelH: UIButton!
    @IBOutlet weak var levelI: UIButton!
    @IBOutlet weak var currentNiveau: UILabel!
    @IBOutlet weak var revealedStarCurrentLevelStats: UIImageView!
    
    @IBOutlet var totalPercent: UILabel!
    @IBOutlet var levelPercent: UILabel!
    //Completed star animation button
    @IBOutlet weak var completedStar: DOFavoriteButton!
    @IBOutlet weak var statsLevelBackground: UIView!
    @IBOutlet weak var statsLevelStarDisabled: UIImageView!
    
    var indexPath : IndexPath!
    weak var delegate: MainLearningObjectCellDelegate?
    @IBOutlet var mainLeftConstraint: NSLayoutConstraint!
    @IBOutlet var mainContentView: UIView!
    @IBOutlet var menuView: UIView!
    
    
    private var initialPositionX: CGFloat = 0
    private var startPositionX: CGFloat = 0
    var revealingState: RevealingState = .closed
    
    public enum RevealingState: Int
    {
        case closed = -1
        
        case open = 1
    }
    override open func awakeFromNib() {
        super.awakeFromNib()
        mainContentView.layer.cornerRadius = 3
        self.setUpGesture()
    }
    
    @IBAction func onClickTotalPercentButton(_ sender: Any) {
        self.delegate?.didClickedTotalPercentButton(indexPath, percentStr:totalPercent.text!)
    }
    @IBAction func onClickLevelPercentButton(_ sender: Any) {
        self.delegate?.didClickedLevelPercentButton(indexPath, percentStr: levelPercent.text!)
    }

    func setUpGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.selector_panGesture(_:)))
        panGesture.delegate = self
        self.mainContentView.addGestureRecognizer(panGesture)
        initialPositionX = mainLeftConstraint.constant
    }

    @objc func selector_panGesture(_ panGesture: UIPanGestureRecognizer)
    {
        let translationX = panGesture.translation(in: self.mainContentView).x
        var xProposed = self.startPositionX + translationX
        if xProposed > self.initialPositionX {
            xProposed = self.initialPositionX
        }
        if xProposed < -self.menuView.frame.size.width-100 {
            xProposed = -self.menuView.frame.size.width-100
        }
        
        switch panGesture.state
        {
        case .began:
            startPositionX = self.mainLeftConstraint.constant
            self.delegate?.didStartPanGesture(cell: self)
            break
        case .changed:
            mainLeftConstraint.constant = xProposed
            break
        case .ended:
            if self.revealingState == .open {
                if translationX*CGFloat(self.revealingState.rawValue) > self.menuView.frame.size.width/5 {
                    closeMenu()
                } else {
                    openMenu()
                }
                
            } else {
                if translationX*CGFloat(self.revealingState.rawValue) > self.menuView.frame.size.width/5 {
                    openMenu()
                } else {
                    closeMenu()
                }
            }
            break
        case .cancelled:
            break
        default:
            break
        }
    }
    
    func openMenu() {
        animateMenu(.open)
    }
    
    func closeMenu() {
        animateMenu(.closed)
    }
    
    func animateMenu(_ state: RevealingState) {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 30, options: [.allowUserInteraction], animations: {
            if state == .open {
                self.mainLeftConstraint.constant = self.initialPositionX - self.menuView.frame.size.width
                self.layoutIfNeeded()
            } else {
                self.mainLeftConstraint.constant = self.initialPositionX
                self.layoutIfNeeded()
            }
        }, completion: { (finished: Bool) in
            if finished {
                self.revealingState = state
            }
        })
    }
    
    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer
        {
            let translation = panGestureRecognizer.translation(in: panGestureRecognizer.view)
            let isHorizontalTranslationLargerThanVertical = (fabs(translation.x) > fabs(translation.y))
            return isHorizontalTranslationLargerThanVertical
        }
        
        return false
    }
    
}

public extension UITableView
{
    public func closeAllCells(exceptThisOne cellThatShouldNotBeClosed: MainLearningObjectCell? = nil)
    {
        for visibleCell in self.visibleCells
        {
            if let revealingTableViewCell = visibleCell as? MainLearningObjectCell
            {
                if let cellThatShouldNotBeClosed = cellThatShouldNotBeClosed
                {
                    if visibleCell != cellThatShouldNotBeClosed
                    {
                        revealingTableViewCell.closeMenu()
                    }
                }
                else
                {
                    revealingTableViewCell.closeMenu()
                }
            }
        }
    }
}
