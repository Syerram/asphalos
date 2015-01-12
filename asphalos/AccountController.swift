//
//  PasswordViewController.swift
//  asphalos
//
//  Created by Saikiran Yerram on 12/28/14.
//  Copyright (c) 2014 Blackhorn. All rights reserved.
//

import UIKit

class AccountController: FormViewController, FormViewControllerDelegate, AccountDelegate {

    var account:Account?
    var accountDelegate:AccountDelegate?

    var notifyFrame:CGRect?
    var notifyView:SFSwiftNotification?

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadForm()
    }

    override func viewDidLoad() {
        //ui
        self.addNavigationBarTitle("\(account!.name)")
        self.addRightButton("edit", title: "Edit", callback: nil)
        self.tableView.hideFooter()
        self.delegate = self

        notifyFrame = CGRectMake(0, 0,
            CGRectGetMaxX(self.view.frame), 50)
        notifyView = SFSwiftNotification.NewNotification(notifyFrame!, delegate: nil)
        self.view.addSubview(notifyView!)
        //data
        self.updateTableView()
    }

    func updateTableView() {
        self.setValue(self.account!.name, forTag: Fields.Name)
        self.setValue(self.account!.userName, forTag: Fields.UserName)
        self.setValue(self.account!.password, forTag: Fields.Password)
        self.setValue(self.account!.category.name, forTag: Fields.Category)
        self.setValue(self.account!.website, forTag: Fields.Website)
        self.setValue(self.account!.info, forTag: Fields.AdditionalInfo)
    }

    func edit() {
        self.pushControllerOnNavigationStack("AccountEditController", callback: { (controller:AccountEditController) -> () in
            controller.account = self.account!
            controller.category = self.account!.category
            controller.accountDelegate = self
        })
    }

    func accountUpdated(account: Account, isNew: Bool) {
        self.account = account
        self.updateTableView()
        self.notifyView!.animate(self.notifyFrame!, delay: 2, title: "Account saved!")
    }

    func accountDeleted() {
        self.accountDelegate!.accountDeleted()
    }

    private func loadForm() {
        let form = FormDescriptor()
        form.title = "Password View"

        let section = FormSectionDescriptor()
        var row = FormRowDescriptor(tag: Fields.Name, rowType: .ReadOnlyTextField, title: "Account")
        row.cellConfiguration = ["titleLabel.textAlignment" : NSTextAlignment.Left.rawValue]
        section.addRow(row)

        var bgView = UIView()
        bgView.backgroundColor = Globals.Theme.AppTintColor
        row = FormRowDescriptor(tag: Fields.UserName, rowType: .ReadOnlyTextField, title: "Username")
        row.cellConfiguration = ["titleLabel.textAlignment" : NSTextAlignment.Left.rawValue,
            "selectedBackgroundView": bgView,
            "selectionStyle": UITableViewCellSelectionStyle.Default.rawValue]
        section.addRow(row)

        row = FormRowDescriptor(tag: Fields.Password, rowType: .ReadOnlyTextField, title: "Password")
        row.cellConfiguration = ["titleLabel.textAlignment" : NSTextAlignment.Left.rawValue,
            "selectedBackgroundView": bgView,
            "selectionStyle": UITableViewCellSelectionStyle.Default.rawValue]
        section.addRow(row)

        let section2 = FormSectionDescriptor()

        row = FormRowDescriptor(tag: Fields.Category, rowType: .ReadOnlyTextField, title: "Category")
        row.cellConfiguration = ["titleLabel.textAlignment" : NSTextAlignment.Left.rawValue]
        section2.addRow(row)

        let section3 = FormSectionDescriptor()

        row = FormRowDescriptor(tag: Fields.Website, rowType: .ReadOnlyTextField, title: "Website")
        row.cellConfiguration = ["titleLabel.textAlignment" : NSTextAlignment.Left.rawValue]
        section3.addRow(row)

        row = FormRowDescriptor(tag: Fields.AdditionalInfo, rowType: .MultiLineLabel, title: "Additional Info")
        row.cellConfiguration = ["titleLabel.textAlignment" : NSTextAlignment.Left.rawValue]
        section3.addRow(row)

        form.sections = [section, section2, section3]
        self.form = form
    }

    func formViewController(controller: FormViewController, didSelectRowDescriptor: FormRowDescriptor) {
        if didSelectRowDescriptor.tag == Fields.UserName || didSelectRowDescriptor.tag == Fields.Password {
            UIPasteboard.generalPasteboard().string = (didSelectRowDescriptor.value as? String)!
            self.notifyView!.animate(self.notifyFrame!, delay: 2, title: "Copied to clipboard")
        }
    }

}
