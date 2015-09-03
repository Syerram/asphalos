//
//  PasswordManagerController.swift
//  asphalos
//
//  Created by Saikiran Yerram on 12/28/14.
//  Copyright (c) 2014 Blackhorn. All rights reserved.
//

import UIKit
import CoreData

class CategoriesController: UITableViewController, CategoryDelegate, SettingsDelegate, UISearchBarDelegate, UISearchDisplayDelegate {

    var categories:[Category] = [] {
        didSet {
            if categories.count == 0 {
                self.setDefaultMessage("Nothing in here. Start by tapping +")
            } else {
                self.tableView.backgroundView = nil
            }
        }
    }
    var accountResults:[Account] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        //UI
        self.tableView.hideFooter()
        self.addNavigationBarTitle("Manager")
        self.addRightButton("add", actionStyle: UIBarButtonSystemItem.Add)
        self.addLeftButton("settings", title: "Settings", callback: nil)
        self.updateBackButton("Back")
        self.refreshControl = self.addPullToDrag("refreshOnPullToDrag")

        self.navigationController?.navigationBar.translucent = false
        self.tabBarItem.image = UIImage(named: "Vault")
        self.tabBarItem.selectedImage = UIImage(named: "VaultSelected")

        //Data
        loadData(reload: false)
    }

    ///MARK: Refresh methods
    func loadData(reload:Bool = false) {
        self.categories = NSManagedObject.fetchAll("Category", sortKeys: [("name", true)]) as! [Category]
        if reload {
            self.tableView.reloadData()
        }
    }

    func refreshOnPullToDrag() {
        self.loadData(reload: true)
        self.refreshControl?.endRefreshing()
    }

    func categoryUpdated(category: Category, isNew: Bool) {
        self.loadData(reload: true)
    }

    func systemPurge() {
        self.loadData(reload: true)
    }

    func masterPasswordReset() {
        //do nothing
    }

    ///MARK: Actions
    func add() {
        self.pushControllerOnNavigationStack("CategoryEditController", callback: { (controller:CategoryEditController) -> () in
            controller.categoryDelegate = self
        })
    }

    func settings() {
        self.pushControllerOnNavigationStack("SettingsController", callback: { (controller:SettingsController) -> () in
            controller.settingsDelegate = self
        })
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController?.searchResultsTableView {
            return accountResults.count
        } else {
            return categories.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell!

        if tableView == self.searchDisplayController?.searchResultsTableView {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CategoryCell") as UITableViewCell
            cell.textLabel?.text = accountResults[indexPath.row].name
            cell.detailTextLabel?.text = accountResults[indexPath.row].category.name
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath) as! UITableViewCell
            (cell.contentView.viewWithTag(1) as! UILabel).text = categories[indexPath.row].name
            (cell.contentView.viewWithTag(2) as! UILabel).text = "\(categories[indexPath.row].accountCount) accounts"
        }
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.searchDisplayController?.searchResultsTableView {
            self.pushControllerOnNavigationStack("AccountController", callback: { (controller:AccountController) -> () in
                controller.account = self.accountResults[indexPath.row]
            })
        } else {
            self.pushControllerOnNavigationStack("CategoryController", callback: { (controller:CategoryController) -> () in
                controller.category = self.categories[indexPath.row]
                controller.categoryDelegate = self
            })
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
    }

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject] {
        var editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Edit") {
            (action, indexPath) -> Void in
            println("Edit")
            self.pushControllerOnNavigationStack("CategoryEditController", transitionSyle: nil, callback: { (controller:CategoryEditController) -> () in
                controller.category = self.categories[indexPath.row]
                controller.categoryDelegate = self
                })
        }
        editAction.backgroundColor = UIColor.greenColor()

        return [editAction]
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }

    // MARK: Search

    //MARK: Private
    private func filter(q:String) {
        self.accountResults = (NSManagedObject.fetch("Account", sortKeys: [("name", true)], predicates: { () -> NSPredicate in
            return NSPredicate(format: "%K CONTAINS[cd] %@", argumentArray: ["name", q])
        }) as? [Account])!
    }

    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.filter(searchString)
        return true
    }

}
