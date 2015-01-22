//
//  FormTextViewCell.swift
//  Taskffiency
//
//  Created by Saikiran Yerram on 11/25/14.
//  Copyright (c) 2014 Blackhorn. All rights reserved.
//

import Foundation
import UIKit

class FormTextareaCell: FormBaseCell, UITextViewDelegate {
    
    let textView = UITextView(frame: CGRectMake(11, 0, 320 - 11 - 11, 174))
    
    override func configure() {
        super.configure()
        selectionStyle = .None
        
        textView.setTranslatesAutoresizingMaskIntoConstraints(false)
        textView.font = UIFont(name: Globals.Theme.RegularFont, size: 16)
        textView.backgroundColor = UIColor.clearColor();
        textView.delegate = self
        textView.text = rowDescriptor.placeholder
        textView.textColor = UIColor.lightGrayColor()
        
        contentView.addSubview(textView)
    }
    
    override class func formRowCellHeight() -> CGFloat {
        return 200
    }
    
    override func update() {
        super.update()
        self.textView.text = self.rowDescriptor.value as? String
        if !self.textView.text.isEmpty {
            textView.textColor = UIColor.blackColor()
        } else {
            textView.text = rowDescriptor.placeholder
        }
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if self.textView.text.isEmpty || self.textView.text == rowDescriptor.placeholder {
            textView.text = ""
            textView.textColor = UIColor.blackColor();
        }
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if self.textView.text.isEmpty {
            textView.text = rowDescriptor.placeholder
            textView.textColor = UIColor.lightGrayColor()
        }
        textView.resignFirstResponder()
    }

    func textViewDidChange(textView: UITextView) {
        let trimmedText = textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        rowDescriptor.value = countElements(trimmedText) > 0 ? textView.text : nil
    }
    
    
}