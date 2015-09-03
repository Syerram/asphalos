//
//  FormReadTextFieldCell.swift
//  asphalos
//
//  Created by Saikiran Yerram on 12/29/14.
//  Copyright (c) 2014 Blackhorn. All rights reserved.
//

import Foundation
import UIKit

class FormReadTextFieldCell: FormBaseCell {

    /// MARK: Cell views

    let titleLabel = UILabel()
    let valueLabel = UILabel()

    /// MARK: Properties

    private var customConstraints: [AnyObject]!

    /// MARK: FormBaseCell

    override func configure() {
        super.configure()

        if let selectionStyle: AnyObject = rowDescriptor.cellConfiguration.objectForKey("selectionStyle") {
            //ignore
        } else {
            selectionStyle = .None
        }

        titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        valueLabel.setTranslatesAutoresizingMaskIntoConstraints(false)

        titleLabel.font = UIFont(name: Globals.Theme.RegularFont, size: 16)
        titleLabel.textColor = UIColor.grayColor()
        valueLabel.font = UIFont(name: Globals.Theme.RegularFont, size: 16)

        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)

        titleLabel.setContentHuggingPriority(500, forAxis: .Horizontal)
        titleLabel.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)

        valueLabel.setContentHuggingPriority(500, forAxis: .Horizontal)
        valueLabel.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)

        contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Height, relatedBy: .Equal, toItem: contentView, attribute: .Height, multiplier: 1.0, constant: 0.0))
        contentView.addConstraint(NSLayoutConstraint(item: valueLabel, attribute: .Height, relatedBy: .Equal, toItem: contentView, attribute: .Height, multiplier: 1.0, constant: 0.0))
        contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        contentView.addConstraint(NSLayoutConstraint(item: valueLabel, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
    }

    override func update() {
        super.update()

        titleLabel.text = rowDescriptor.title
        valueLabel.text = rowDescriptor.value as? String
    }

    override func constraintsViews() -> [String : UIView] {
        var views = ["titleLabel" : titleLabel, "valueLabel" : valueLabel]
        return views
    }

    override func defaultVisualConstraints() -> [String] {
        let _imageView = self.imageView! as UIImageView
        if _imageView.image != nil {
            if titleLabel.text != nil && count(titleLabel.text!) > 0 {
                return ["H:[imageView]-[titleLabel]-[valueLabel]-16-|"]
            }
            else {
                return ["H:[imageView]-[valueLabel]-16-|"]
            }
        }
        else {
            if titleLabel.text != nil && count(titleLabel.text!) > 0 {
                return ["H:|-16-[titleLabel]-[valueLabel]-16-|"]
            }
            else {
                return ["H:|-16-[valueLabel]-16-|"]
            }
        }
    }

    override class func formRowCanBecomeFirstResponder() -> Bool {
        return false
    }
}