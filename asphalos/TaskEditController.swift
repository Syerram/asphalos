//
//  TaskEditController.swift
//  asphalos
//
//  Created by Saikiran Yerram on 1/14/15.
//  Copyright (c) 2015 Blackhorn. All rights reserved.
//

import UIKit
import CoreData

protocol TaskDelegate {
    func taskUpdated(task: Task, isNew: Bool)
}

class TaskEditController: FormViewController, FormViewControllerDelegate {

    struct Fields {
        static let Task = "task"
        static let Length = "length"
        static let Info = "info"
    }

    var task:Task! = nil
    var currentDate:NSDate!
    var nextSlot:Int!
    var taskDelegate:TaskDelegate?

    var isNew:Bool {
        get {
            return self.task == nil
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //UI
        self.tableView.hideFooter()
        var title = "New Task"
        if !self.isNew {
            title = "\(task!.name)"
            self.updateTableView()
        }
        self.addNavigationBarTitle(title)
        self.addRightButton("save", actionStyle: UIBarButtonSystemItem.Save)
        self.delegate = self
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadForm()
    }

    private func updateTableView() {
        self.setValue(self.task!.name, forTag: Fields.Task)
        self.setValue("\(self.task!.length)", forTag: Fields.Length)
        self.setValue(self.task!.info, forTag: Fields.Info)
    }

    private func loadForm() {
        let form = FormDescriptor()
        form.title = "Task Edit"

        let section1 = FormSectionDescriptor()

        var row: FormRowDescriptor! = FormRowDescriptor(tag: Fields.Task, rowType: FormRowType.Text, title: "Task")
        row.cellConfiguration = ["textField.placeholder": "e.g. Short name", "textField.textAlignment": NSTextAlignment.Right.rawValue]
        section1.addRow(row)

        row = FormRowDescriptor(tag: Fields.Length, rowType: FormRowType.Picker, title: "Length")
        row.options = ["30", "60", "90", "120"]
        row.titleFormatter = { value in
            switch(value) {
            case "30":
                return "30 mins"
            case "60":
                return "1 hour"
            case "90":
                return "1 and half hour"
            case "120":
                return "2 hours"
            default:
                return "30 mins"
            }
        }
        section1.addRow(row)


        let section2 = FormSectionDescriptor()
        row = FormRowDescriptor(tag: Fields.Info, rowType: FormRowType.Textarea, title: "Additional Info", placeholder: "Additional Info")
        section2.addRow(row)

        form.sections = [section1, section2]
        self.form = form
    }

    /*
    Get the next available slot.
    Prep first with starting time [use settings to get per day available time]
    Add the total minutes and return the new date/time
    
    MARK: TODO:
        1. Put day available in settings
        1. check if total minutes are beyond 24hrs, 
        2. Add breaks in between. Count the total breaks they need

    */
    func getTaskStartTime() -> NSDate {
        return NSCalendar.currentCalendar().dateBySettingHour(0, minute: 0, second: 0, ofDate: currentDate, options: NSCalendarOptions.allZeros)!
    }

    func save() {
        let values = self.form.formValues()
        let length = (values.objectForKey("length") as! String).toInt()!

        let isNew = self.isNew
        if isNew {
            self.task = NSManagedObject.newEntity("Task") as Task
        }
        self.task.length = (values.objectForKey("length") as! String).toInt()!
        self.task.startDate = getTaskStartTime()
        self.task.name = values.objectForKey(Fields.Task) as! String
        self.task.info = (values.objectForKey("info") as! String)
        self.task.completed = false
        self.task.actual = 0
        self.task.order = nextSlot
        Task.save()

        self.proxy(taskDelegate, callback: { (object:TaskDelegate) -> () in
            object.taskUpdated(self.task!, isNew: isNew)
        })
        self.navigationController?.popViewControllerAnimated(true)
    }

}
