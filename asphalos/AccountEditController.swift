//
//  PasswordEditController.swift
//  asphalos
//
//  Created by Saikiran Yerram on 12/28/14.
//  Copyright (c) 2014 Blackhorn. All rights reserved.
//

import UIKit
import CoreData

///Protocol to manage account level events
protocol AccountDelegate {
    func accountUpdated(account: Account, isNew: Bool)
    func accountDeleted()
}

struct Fields {
    static let Name = "name"
    static let UserName = "userName"
    static let Password = "password"
    static let GenerateButton = "generate"
    static let Website = "website"
    static let AdditionalInfo = "additionalInfo"
    static let Category = "category"
    static let DeleteButton = "delete"
}

class AccountEditController: FormViewController, FormViewControllerDelegate {

    var category:Category!
    var account:Account?
    var accountDelegate: AccountDelegate?

    var notifyFrame:CGRect?
    var notifyView:SFSwiftNotification?
    
    var isNew:Bool {
        get {
            return self.account == nil
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadForm()
    }

    override func viewDidLoad() {
        self.tableView.hideFooter()
        self.delegate = self

        var title = "New Account"
        if !self.isNew {
            title = "\(account!.name)"
            self.updateTableView()
        } else {
            self.hideRow(Fields.DeleteButton)
        }
        self.addNavigationBarTitle(title)
        self.addRightButton("done", actionStyle: UIBarButtonSystemItem.Done)

        notifyFrame = CGRectMake(0, 0, CGRectGetMaxX(self.view.frame), 50)
        notifyView = SFSwiftNotification.NewNotification(notifyFrame!, delegate: nil)
        self.view.addSubview(notifyView!)
    }

    func updateTableView() {
        self.setValue(self.account!.name, forTag: Fields.Name)
        self.setValue(self.account!.userName, forTag: Fields.UserName)
        self.setValue(self.account!.password, forTag: Fields.Password)
        self.setValue(self.account!.website, forTag: Fields.Website)
        self.setValue(self.account!.info, forTag: Fields.AdditionalInfo)
    }

    //Return false if any of the values passed are nil
    func validateIfNil(values: [AnyObject?]) -> Bool {
        for value in values {
            if value == nil {
                return false
            }
        }
        return true
    }

    func done() {
        let values = self.form.formValues()
        //required values. Validate for null (note downcasting NSNull to nil)
        if !validateIfNil([values[Fields.Name] as? String,
            values[Fields.UserName] as? String,
            values[Fields.Password] as? String]) {
                self.notifyView!.animate(self.notifyFrame!, delay: 2, title: "Account name, User name and Password are required!")
                return
        }

        let isNew = self.isNew
        if isNew {
            account = NSManagedObject.newEntity("Account") as Account
            category.accountCount = NSNumber(int: category.accountCount.integerValue + 1)
        }
        ///MARK: TODO Perhaps we can use property descriptors and then check validity on the object itself
        account!.name = values[Fields.Name] as! String
        account!.userName = values[Fields.UserName] as! String
        account!.password = values[Fields.Password] as! String
        account!.category = self.category

        //Non required values
        self.account!.website = ""
        if let site = values[Fields.Website] as? String {
            self.account!.website = site
        }
        self.account!.info = ""
        self.proxy(values[Fields.AdditionalInfo] as? String, callback: { (info:String) -> () in
            self.account!.info = info
        })

        NSManagedObject.save()
        self.proxy(accountDelegate, callback: { (object:AccountDelegate) -> () in
            object.accountUpdated(self.account!, isNew: isNew)
        })
        self.navigationController?.popViewControllerAnimated(true)

    }

    private func loadForm() {
        let form = FormDescriptor()
        form.title = "Password Entry"

        let section = FormSectionDescriptor()
        var row: FormRowDescriptor! = FormRowDescriptor(tag: Fields.Name, rowType: .Name, title: "Account")
        row.cellConfiguration = ["textField.placeholder" : "Bank of Millionaire", "textField.textAlignment" : NSTextAlignment.Right.rawValue]
        section.addRow(row)

        row = FormRowDescriptor(tag: Fields.UserName, rowType: .PlainText, title: "User Name")
        row.cellConfiguration = ["textField.placeholder" : "Enter user name", "textField.textAlignment" : NSTextAlignment.Right.rawValue]
        section.addRow(row)

        row = FormRowDescriptor(tag: Fields.Password, rowType: .PlainText, title: "Password")
        row.cellConfiguration = ["textField.placeholder" : "Enter password", "textField.textAlignment" : NSTextAlignment.Right.rawValue]
        section.addRow(row)

        row = FormRowDescriptor(tag: Fields.GenerateButton, rowType: .Button, title: "Generate Password")
        row.backgroundColor = Globals.Theme.AppTintColor
        row.tintColor = UIColor.whiteColor()
        section.addRow(row)

        let section2 = FormSectionDescriptor()

        row = FormRowDescriptor(tag: Fields.Website, rowType: .URL, title: "Web site")
        row.cellConfiguration = ["textField.placeholder" : "e.g. bankofmill.com", "textField.textAlignment" : NSTextAlignment.Right.rawValue]
        section2.addRow(row)

        row = FormRowDescriptor(tag: Fields.AdditionalInfo, rowType: .Textarea, title: "Additional Info", placeholder: "Any other non-sensitive information")
        section2.addRow(row)


        let section3 = FormSectionDescriptor()
        row = FormRowDescriptor(tag: Fields.DeleteButton, rowType: .Button, title: "Delete")
        row.backgroundColor = UIColor.redColor()
        row.tintColor = UIColor.whiteColor()
        section3.addRow(row)


        form.sections = [section, section2, section3]
        self.form = form
    }

    func formViewController(controller: FormViewController, didSelectRowDescriptor: FormRowDescriptor) {
        if didSelectRowDescriptor.tag == Fields.GenerateButton {
            var password = Globals.Password.generateRandomString()
            self.setValue(password, forTag: Fields.Password)
        } else if didSelectRowDescriptor.tag == Fields.DeleteButton {
            self.category.accountCount = NSNumber(int: self.category.accountCount.intValue - 1)
            NSManagedObject.deleteNow(self.account!)
            
            self.accountDelegate?.accountDeleted()
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
}
