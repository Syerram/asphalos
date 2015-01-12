//
//  FormMultiLineLabelCell.swift
//  asphalos
//
//  Created by Saikiran Yerram on 12/29/14.
//  Copyright (c) 2014 Blackhorn. All rights reserved.
//

import UIKit

class FormMultiLineLabelCell: FormBaseCell {
    
    var titleLabel: UILabel = UILabel(frame: CGRectMake(11, 0, 320 - 11 - 11, 174))

    override func configure() {
        super.configure()
        if let selectionStyle: AnyObject = rowDescriptor.cellConfiguration.objectForKey("selectionStyle") {
            //ignore
        } else {
            selectionStyle = .None
        }

        titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        titleLabel.font = UIFont(name: Globals.Theme.RegularFont, size: 16)
        titleLabel.textColor = rowDescriptor.tintColor
        titleLabel.numberOfLines = 5
        titleLabel.sizeThatFits(CGSize(width: 320, height: 174))


        titleLabel.setContentHuggingPriority(500, forAxis: .Horizontal)
        titleLabel.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)

        contentView.addSubview(titleLabel)

        contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Height, relatedBy: .Equal, toItem: contentView, attribute: .Height, multiplier: 1.0, constant: 0.0))
    }

    override func update() {
        super.update()

        titleLabel.text = rowDescriptor.value as? String
    }

    override func constraintsViews() -> [String : UIView] {
        var views = ["titleLabel" : titleLabel]
        return views
    }

    override func defaultVisualConstraints() -> [String] {
        let _imageView = self.imageView! as UIImageView
        if _imageView.image != nil {
            return ["H:[imageView]-[titleLabel]-16-|"]
        }
        else {
            return ["H:|-16-[titleLabel]-16-|"]
        }
    }

    override class func formRowCanBecomeFirstResponder() -> Bool {
        return false
    }
    
    override class func formRowCellHeight() -> CGFloat {
        return 176
    }
    
}
