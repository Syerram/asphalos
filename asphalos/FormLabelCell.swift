//
//  FormLabelCell.swift
//  Taskffiency
//
//  Created by Saikiran Yerram on 11/24/14.
//  Copyright (c) 2014 Blackhorn. All rights reserved.
//

import Foundation


class FormLabelCell: FormTitleCell {
    
    override func configure() {
        super.configure()
        titleLabel.textAlignment = .Center
    }
    
    override func update() {
        super.update()
        titleLabel.text = rowDescriptor.title
    }
}