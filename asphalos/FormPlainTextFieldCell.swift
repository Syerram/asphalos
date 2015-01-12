//
//  PlainTextFieldCell.swift
//  asphalos
//
//  Created by Saikiran Yerram on 12/30/14.
//  Copyright (c) 2014 Blackhorn. All rights reserved.
//

import UIKit

class FormPlainTextFieldCell: FormTextFieldCell {

    override func configure() {
        super.configure()
        self.textField.autocorrectionType = UITextAutocorrectionType.No
        self.textField.spellCheckingType = UITextSpellCheckingType.No
        self.textField.autocapitalizationType = UITextAutocapitalizationType.None
    }
}