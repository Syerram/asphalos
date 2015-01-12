//
//  CategoryEditController.swift
//  asphalos
//
//  Created by Saikiran Yerram on 12/28/14.
//  Copyright (c) 2014 Blackhorn. All rights reserved.
//

import UIKit
import CoreData

///Protocol to manage Categiry related events
protocol CategoryDelegate {
    func categoryUpdated(category: Category, isNew: Bool)
}

class CategoryEditController: FormViewController, FormViewControllerDelegate {

    struct Fields {
        static let Name = "name"
        static let Color = "color"
    }

    var category:Category? = nil
    var categoryDelegate:CategoryDelegate?

    var isNew:Bool {
        get {
            return self.category == nil
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.hideFooter()
        var title = "New Category"
        if !self.isNew {
            title = "\(category!.name)"
            self.updateTableView()
        }
        self.addNavigationBarTitle(title)
        self.addRightButton("done", actionStyle: UIBarButtonSystemItem.Done)
        self.delegate = self
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadForm()
    }

    func updateTableView() {
        self.setValue(category!.name, forTag: Fields.Name)
    }

    func done() {
        let values = self.form.formValues()
        let isNew = self.isNew
        if isNew {
            category = NSManagedObject.newEntity("Category") as Category
        }
        category!.name = (values[Fields.Name] as String).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        Category.save()
        self.proxy(categoryDelegate, callback: { (object:CategoryDelegate) -> () in
            object.categoryUpdated(self.category!, isNew: isNew)
        })
        self.navigationController?.popViewControllerAnimated(true)
    }

    private func loadForm() {
        let form = FormDescriptor()
        form.title = "Task Edit"

        let section = FormSectionDescriptor()

        var row: FormRowDescriptor! = FormRowDescriptor(tag: Fields.Name, rowType: FormRowType.Text, title: "Name")
        row.cellConfiguration = ["textField.placeholder": "e.g. Banks, Work", "textField.textAlignment": NSTextAlignment.Right.rawValue]
        section.addRow(row)

        form.sections = [section]
        self.form = form
    }

}
