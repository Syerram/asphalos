//
//  SettingsController.swift
//  asphalos
//
//  Created by Saikiran Yerram on 12/29/14.
//  Copyright (c) 2014 Blackhorn. All rights reserved.
//

import UIKit
import CoreData

protocol SettingsDelegate {
    func systemPurge()
    func masterPasswordReset()
}

class SettingsController: FormViewController, FormViewControllerDelegate {

    struct Fields {
        static let ResetMaster = "resetMaster"
        static let PurgeAll = "purgeAll"
    }

    var notifyFrame:CGRect?
    var notifyView:SFSwiftNotification?

    var settingsDelegate:SettingsDelegate?

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadForm()
    }

    override func viewDidLoad() {
        //ui
        self.addNavigationBarTitle("Settings")
        self.tableView.hideFooter()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.delegate = self

        notifyFrame = CGRectMake(0, 0,
            CGRectGetMaxX(self.view.frame), 50)
        notifyView = SFSwiftNotification.NewNotification(notifyFrame!, delegate: nil)
        self.view.addSubview(notifyView!)
    }

    private func loadForm() {
        let form = FormDescriptor()
        form.title = "Password Entry"

        let section = FormSectionDescriptor()
        var row: FormRowDescriptor! = FormRowDescriptor(tag: Fields.ResetMaster, rowType: .Button, title: "Reset Master Password")
        row.tintColor = Globals.Theme.AppTintColor
        section.addRow(row)

        let section1 = FormSectionDescriptor()
        let section2 = FormSectionDescriptor()
        row = FormRowDescriptor(tag: Fields.PurgeAll, rowType: .Button, title: "Purge All")
        row.backgroundColor = UIColor.redColor()
        row.tintColor = UIColor.whiteColor()
        section2.addRow(row)

        form.sections = [section, section1, section2]
        self.form = form
    }

    func formViewController(controller: FormViewController, didSelectRowDescriptor: FormRowDescriptor) {
        if didSelectRowDescriptor.tag == Fields.ResetMaster {
            self.pushControllerOnNavigationStack("MasterPasswordController", callback: { (controller:MasterPasswordController) -> () in
                //
            }, transitionSyle: nil)
        } else if didSelectRowDescriptor.tag == Fields.PurgeAll {
            SweetAlert().showAlert("Are you sure?", subTitle: "You will lose all your data. It cannot be recovered", style: AlertStyle.Warning, buttonTitle: "Cancel", buttonColor: Globals.Theme.AppTintColor , otherButtonTitle: "Yes, I am sure", action: { (isOtherButton) -> Void in
                if isOtherButton == false {
                    ///MARK: TODO: Perhaps we can run this in a different thread, some progress meter and then up on completion move to main controller
                    NSManagedObject.purge(["Account", "Category"])
                    self.settingsDelegate!.systemPurge()
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
            })
        }
    }


}
