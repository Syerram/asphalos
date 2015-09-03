//
//  TaskDetailController.swift
//  asphalos
//
//  Created by Saikiran Yerram on 1/15/15.
//  Copyright (c) 2015 Blackhorn. All rights reserved.
//

import UIKit

class TaskDetailController: UITableViewController, TaskDelegate {

    ///MARK: Control tags
    struct TaskDetailHeader {
        static let Identifier = "TaskDetailHeader"
        static let CurrentDate = 1
        static let Complete = 2
        static let Edit = 3
    }

    struct TaskDetail {
        static let Identifier = "TaskDetail"
        static let Detail = 1
    }
    
    struct TaskCell {
        static let Identifier = "TaskCell"
        static let Length = 1
        static let Task = 2
    }
    

    var task:Task!
    var currentDate:NSDate!
    var taskDelegate:TaskDelegate?
    var nextSlot:Int!


    override func viewDidLoad() {

        var dayFormatter = NSDateFormatter()
        dayFormatter.dateFormat = "EEE, MMM dd"

        self.addNavigationBarTitle(dayFormatter.stringFromDate(currentDate), attributes: nil)
        self.addRightButton("edit", title: "Edit", callback: nil)
        self.tableView.hideFooter()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell!
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier(TaskCell.Identifier, forIndexPath: indexPath) as! UITableViewCell
            (cell.contentView.viewWithTag(TaskCell.Task) as! UILabel).text = task.name
            (cell.contentView.viewWithTag(TaskCell.Length) as! UILabel).text = task.lengthFormatted
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier(TaskDetail.Identifier, forIndexPath: indexPath) as! UITableViewCell
            (cell.contentView.viewWithTag(TaskDetail.Detail) as! UILabel).text = task.info
        }
        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 75
        } else {
            let label:UILabel = UILabel()
            label.text = task.info
            let height = label.getHeight(tableView.bounds.width) + 44 //offset
            return height
        }
    }

    func edit() {
        self.pushControllerOnNavigationStack("TaskEditController", callback: { (controller:TaskEditController) -> () in
            controller.task = self.task
            controller.currentDate = self.currentDate
            controller.nextSlot = self.nextSlot
            controller.taskDelegate = self
        })
    }

    func taskUpdated(task: Task, isNew: Bool) {
        self.task = task
        self.tableView.reloadData()
        self.taskDelegate!.taskUpdated(task, isNew: isNew)
    }
}
