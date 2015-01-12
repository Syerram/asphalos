//
//  MasterPasswordController.swift
//  asphalos
//
//  Created by Saikiran Yerram on 12/30/14.
//  Copyright (c) 2014 Blackhorn. All rights reserved.
//

import UIKit

/*
We could merge this controller with TouchAuthenticationController, since both do the same.
Also, Not sure if we need to request for old master to reset to new.
*/
class MasterPasswordController: UIViewController {

    @IBOutlet weak var masterPassword: MasterPasswordTextField!

    var notifyFrame:CGRect?
    var notifyView:SFSwiftNotification?

    override func viewDidLoad() {
        self.navigationController?.addNavigationBarTitle("Reset Password", attributes: nil)
        self.addRightButton("done", actionStyle: UIBarButtonSystemItem.Done)

        notifyFrame = CGRectMake(0, self.navigationController!.navigationBar.frame.height + 20,
            CGRectGetMaxX(self.view.frame), 50)
        notifyView = SFSwiftNotification.NewNotification(notifyFrame!, delegate: nil)
        self.view.addSubview(notifyView!)
    }

    ///Save password to keychain
    func done() {
        if self.masterPassword.isValid() {
            Globals.Password.setMasterPassword(masterPassword.text, update: true)
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            self.notifyView!.animate(self.notifyFrame!, delay: 5, title: "Password should be more than 10 characters")
        }
    }
}
