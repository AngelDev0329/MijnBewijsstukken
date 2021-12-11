//
//  FormCell.swift
//  MijnBewijsstukken
//
//  Created by Wijnand Boerma on 16-03-18.
//  Copyright © 2018 Wndworks. All rights reserved.
//

import UIKit

class FormCell: UITableViewCell, UITextViewDelegate {
    
    weak var delegate: FormCellDelegate?
    
    var textViewHeighConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var formQuestion: UILabel!
    @IBOutlet var formAnswer: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        formAnswer.delegate = self
        formAnswer.autocorrectionType = .no
        formAnswer.spellCheckingType = .no
        
        textViewHeighConstraint = formAnswer.heightAnchor.constraint(equalToConstant: 80)
        textViewHeighConstraint.priority = UILayoutPriority.init(250)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        delegate?.formCell(self, textViewDidChange: textView)
    }
    
}

protocol FormCellDelegate: class {
    func formCell(_ cell: FormCell, textViewDidChange textView: UITextView)
}
