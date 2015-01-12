//
//  CategoryController.swift
//  asphalos
//
//  Created by Saikiran Yerram on 12/28/14.
//  Copyright (c) 2014 Blackhorn. All rights reserved.
//

import UIKit
import CoreData

class CategoryController: UITableViewController, AccountDelegate {

    var category:Category!
    var categoryDelegate: CategoryDelegate?
    var accounts:[Account] = [] {
        didSet {
            if accounts.count == 0 {
                self.setDefaultMessage("Nothing in here. Start by tapping +")
            } else {
                self.tableView.backgroundView = nil
            }
        }
    }

    var notifyFrame:CGRect?
    var notifyView:SFSwiftNotification?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addNavigationBarTitle("\(category.name)")
        self.addRightButton("add", actionStyle: UIBarButtonSystemItem.Add)
        self.tableView.hideFooter()
        self.refreshControl = self.addPullToDrag("refreshOnPullToDrag")

        notifyFrame = CGRectMake(0, 0,
            CGRectGetMaxX(self.view.frame), 50)
        notifyView = SFSwiftNotification.NewNotification(notifyFrame!, delegate: nil)
        self.view.addSubview(notifyView!)

        //data
        self.loadData(reload: false)
    }

    ///MARK: Refresh methods
    func loadData(reload:Bool = false) {
        self.accounts = NSManagedObject.fetch("Account", predicates: { () -> NSPredicate in
            return NSPredicate(format: "category = %@", self.category)!
        }, sortKeys: [("name", true)]) as [Account]
        if reload {
            self.tableView.reloadData()
        }
    }

    func refreshOnPullToDrag() {
        self.loadData(reload: true)
        self.refreshControl?.endRefreshing()
    }

    func accountUpdated(account: Account, isNew: Bool) {
        self.loadData(reload: true)
        if isNew {
            self.categoryDelegate?.categoryUpdated(self.category, isNew: false)
        }
    }

    func accountDeleted() {
        self.loadData(reload: true)
    }

    ///MARK: Actions
    func add() {
        self.pushControllerOnNavigationStack("AccountEditController", callback: { (controller:AccountEditController) -> () in
            controller.category = self.category
            controller.accountDelegate = self
        })
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AccountCell", forIndexPath: indexPath) as UITableViewCell
        (cell.contentView.viewWithTag(1) as UILabel).text = accounts[indexPath.row].name
        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.pushControllerOnNavigationStack("AccountController", callback: { (controller:AccountController) -> () in
            controller.account = self.accounts[indexPath.row]
            controller.accountDelegate = self
        })
    }

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject] {
        var copyAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Copy") {
            (action, indexPath) -> Void in


            UIPasteboard.generalPasteboard().string = self.accounts[indexPath.row].password
            tableView.setEditing(false, animated: false)
            self.notifyView!.animate(self.notifyFrame!, delay: 2, title: "Copied to clipboard")
        }
        copyAction.backgroundColor = Globals.Theme.AppTintColor

        var editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Edit") {
            (action, indexPath) -> Void in

            self.pushControllerOnNavigationStack("AccountEditController", callback: { (controller:AccountEditController) -> () in
                controller.account = self.accounts[indexPath.row]
                controller.category = self.accounts[indexPath.row].category
                controller.accountDelegate = self
            })

            tableView.setEditing(false, animated: false)
        }
        editAction.backgroundColor = UIColor.greenColor()

        var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete") {
            (action, indexPath) -> Void in

            //data related updates
            self.category.accountCount = NSNumber(int: self.category.accountCount.intValue - 1)
            NSManagedObject.deleteNow(self.accounts[indexPath.row])

            //ui related updates
            self.categoryDelegate?.categoryUpdated(self.category, isNew: false)
            self.accounts.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
        }
        deleteAction.backgroundColor = UIColor.redColor()


        return [copyAction, editAction, deleteAction]
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }

}
