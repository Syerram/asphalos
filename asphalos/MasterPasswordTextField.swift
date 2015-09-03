//
//  MasterPasswordTextView.swift
//  asphalos
//
//  Created by Saikiran Yerram on 12/30/14.
//  Copyright (c) 2014 Blackhorn. All rights reserved.
//

import UIKit

///Validates to ensure master password is made of valid characters
class MasterPasswordTextField: UITextField, UITextFieldDelegate {

    //Need to override all initializers
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.localInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.localInit()
    }

    private func localInit() {
        self.delegate = self
        self.secureTextEntry = true
    }

    func isValid() -> Bool{
        return !self.text.isEmpty && count(self.text.utf16) > 10
    }

}
