//
//  TaskerController.swift
//  asphalos
//
//  Created by Saikiran Yerram on 1/13/15.
//  Copyright (c) 2015 Blackhorn. All rights reserved.
//

import UIKit
import CoreData

class TaskerController: UITableViewController, TaskDelegate {

    struct TaskCell {
        static let StartTime = 1
        static let EndTime = 2
        static let Task = 3
    }

    struct TaskListCell {
        static let Month = 1
        static let Day = 2
        static let Year = 3
        static let Task = 4
        static let Time = 5
    }

    var snapshot:UIView? = nil
    var sourceIndex:NSIndexPath? = nil

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var todayHeader: UILabel!
    var toggleListButton: UIBarButtonItem!
    var toggleListOn:Bool = false

    ///MARK: Move this to settings
    let startTime:Double = 9.0 //in 24 hour format

    var currentDate:NSDate! {
        didSet {
            var formatter = NSDateFormatter()
            formatter.dateFormat = "EEE, MMM dd"

            todayHeader.text = formatter.stringFromDate(currentDate)
            self.loadData(reload: true)
        }
    }

    var calendar = NSCalendar.currentCalendar()
    var tasks:[Task] = [] {
        didSet {
            if tasks.count == 0 {
                self.setDefaultMessage("Nothing in here. Start by tapping +")
            } else {
                self.tableView.backgroundView = nil
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //UI
        self.addNavigationBarTitle("Tasker")
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("add"))
        toggleListButton = UIBarButtonItem(image: UIImage(named: "List"), style: UIBarButtonItemStyle.Plain, target: self, action: "toggleList")
        self.navigationItem.setRightBarButtonItems([addButton, toggleListButton], animated: false)

        self.addRightButton("add", actionStyle: UIBarButtonSystemItem.Add)
        self.addLeftButton("settings", title: "Settings", callback: nil)
        self.updateBackButton("")

        self.navigationController?.navigationBar.translucent = false
        self.tabBarItem.image = UIImage(named: "Tick")
        self.tabBarItem.selectedImage = UIImage(named: "TickSelected")
        self.tableView.hideFooter()
        let longGesture = UILongPressGestureRecognizer(target: self, action: "longGestureRecognized:")
        self.tableView.addGestureRecognizer(longGesture)
        self.setupHeader(false)

        currentDate = NSDate()
    }

    func loadData(reload:Bool = false) {
        var predicate:NSPredicate!
        if toggleListOn {
            predicate = NSPredicate(format: "completed = %@", false)!
        } else {
            //Get day components from the current date and create range of one day
            var currentDayComponents = calendar.components(NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.YearCalendarUnit, fromDate: currentDate)
            currentDayComponents.hour = 0
            var startDate = self.calendar.dateFromComponents(currentDayComponents)!

            var dayComponent = NSDateComponents()
            dayComponent.day = 1
            var endDate = self.calendar.dateByAddingComponents(dayComponent, toDate: startDate, options: NSCalendarOptions.allZeros)!
            predicate = NSPredicate(format: "startDate >= %@ AND startDate <= %@ AND completed = %@", startDate, endDate, false)!
        }

        self.tasks = NSManagedObject.fetch("Task", predicates:{ () -> NSPredicate in
            return predicate
            }, sortKeys: [("startDate", true)]) as [Task]

        if reload {
            self.tableView.reloadData()
        }
    }

    func setupHeader(hide:Bool) {
        if hide {
            headerView.height = 0.00
            headerView.alpha = 0.00
        } else {
            headerView.height = 75.00
            headerView.alpha = 1.00
        }
        self.tableView.tableHeaderView = headerView
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(toggleListOn ? "TaskListCell" : "TaskCell", forIndexPath: indexPath) as UITableViewCell
        self.updateCell(cell, task: tasks[indexPath.row])
        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return toggleListOn ? 70 : 55
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.pushControllerOnNavigationStack("TaskDetailController", callback: { (controller:TaskDetailController) -> () in
            controller.task = self.tasks[indexPath.row]
            controller.currentDate = self.currentDate
            controller.nextSlot = self.getLatestTime()
            controller.taskDelegate = self
        }, transitionSyle: nil)
    }

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject] {
        var completeAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Done") {
            (action, indexPath) -> Void in
            let task = self.tasks[indexPath.row]
            task.completed = NSNumber(bool: true)
            Task.save()
            self.tasks.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.setEditing(false, animated: false)
        }
        completeAction.backgroundColor = UIColor.greenColor()

        return [completeAction]
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }

    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        (tasks[sourceIndexPath.row], tasks[destinationIndexPath.row]) = (tasks[destinationIndexPath.row], tasks[sourceIndexPath.row])
        self.tableView.editing = false
    }


    ///MARK: Event handlers
    func add() {
        self.pushControllerOnNavigationStack("TaskEditController", callback: { (controller:TaskEditController) -> () in
            controller.taskDelegate = self
            controller.currentDate = self.currentDate
            controller.nextSlot = self.getLatestTime()
        }, transitionSyle: nil)
    }

    func toggleList() {
        toggleListOn = !toggleListOn
        toggleListButton.image = UIImage(named: toggleListOn ? "ListOn" : "List")
        self.setupHeader(toggleListOn)
        self.loadData(reload: true)
    }


    @IBAction func forward(sender: AnyObject) {
        var dayComponent = NSDateComponents()
        dayComponent.day = 1
        currentDate = calendar.dateByAddingComponents(dayComponent, toDate: currentDate, options: NSCalendarOptions.allZeros)!
    }

    @IBAction func back(sender: AnyObject) {
        var dayComponent = NSDateComponents()
        dayComponent.day = -1
        currentDate = calendar.dateByAddingComponents(dayComponent, toDate: currentDate, options: NSCalendarOptions.allZeros)!

    }

    ///MARK: Moving rows

    ///Update cell helper method
    func updateCell(cell:UITableViewCell, task:Task) {
        var formatter = NSDateFormatter()
        formatter.dateFormat = "hh:mm a"
        var components = NSCalendar.currentCalendar().components(NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.YearCalendarUnit, fromDate: task.startDate)

        if toggleListOn {
            formatter.dateFormat = "MMM"
            (cell.contentView.viewWithTag(TaskListCell.Task) as UILabel).text = task.name
            (cell.contentView.viewWithTag(TaskListCell.Day) as UILabel).text = "\(components.day)"
            (cell.contentView.viewWithTag(TaskListCell.Month) as UILabel).text = "\(formatter.stringFromDate(task.startDate))"
            (cell.contentView.viewWithTag(TaskListCell.Year) as UILabel).text = "\(components.year)"
            formatter.dateFormat = "hh:mm a"
            (cell.contentView.viewWithTag(TaskListCell.Time) as UILabel).text = "\(formatter.stringFromDate(task.startDate)) - \(formatter.stringFromDate(task.endTime))"
        } else {
            (cell.contentView.viewWithTag(TaskCell.Task) as UILabel).text = task.name
            (cell.contentView.viewWithTag(TaskCell.StartTime) as UILabel).text = formatter.stringFromDate(task.startDate)
            (cell.contentView.viewWithTag(TaskCell.EndTime) as UILabel).text = formatter.stringFromDate(task.endTime)
        }
    }


    ///Long gesture to move the cells
    func longGestureRecognized(sender:AnyObject) {
        if toggleListOn {
            return
        }
        var longPress = sender as UILongPressGestureRecognizer
        var state = longPress.state
        var location:CGPoint = longPress.locationInView(self.tableView)
        var indexPath = self.tableView.indexPathForRowAtPoint(location)

        switch(state) {
        case UIGestureRecognizerState.Began:
            //Take the snapshot of the current cell and use that to animate with the location
            //of the current longpress gesture. The goal is to set its center to the center of the press
            if indexPath != nil {
                sourceIndex = indexPath!
                var cell = self.tableView.cellForRowAtIndexPath(indexPath!)
                snapshot = cell!.snapshot()
                var center:CGPoint = cell!.center
                snapshot?.center = center
                snapshot?.alpha = 0.0
                self.tableView.addSubview(snapshot!)
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    center.y = location.y
                    self.snapshot?.center = center
                    self.snapshot?.transform = CGAffineTransformMakeScale(1.05, 1.05)
                    self.snapshot?.alpha = 0.98

                    cell!.alpha = 0.0

                }, completion: { (finished:Bool) -> Void in
                    cell!.hidden = true
                })
            }
            break
        case UIGestureRecognizerState.Changed:
            //once completed, simply swap the cells and update core data
            var center = snapshot?.center
            center?.y = location.y
            snapshot?.center = center!
            if indexPath != nil && !(indexPath == sourceIndex) {
                Task.SwapTimes(tasks[indexPath!.row], destination: tasks[sourceIndex!.row])
                (tasks[indexPath!.row], tasks[sourceIndex!.row]) = (tasks[sourceIndex!.row], tasks[indexPath!.row])
                self.tableView.moveRowAtIndexPath(sourceIndex!, toIndexPath: indexPath!)
                self.updateCell(self.tableView.cellForRowAtIndexPath(sourceIndex!)!, task: tasks[sourceIndex!.row])
                self.updateCell(self.tableView.cellForRowAtIndexPath(indexPath!)!, task: tasks[indexPath!.row])
                sourceIndex = indexPath
            }
            break
        default:
            //else reset the move
            var cell = self.tableView.cellForRowAtIndexPath(sourceIndex!)
            cell?.hidden = false
            cell?.alpha = 0.0
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.snapshot?.center = cell!.center
                self.snapshot?.transform = CGAffineTransformIdentity
                self.snapshot?.alpha = 0.0

                cell?.alpha = 1.0
            }, completion: { (finished:Bool) -> Void in
                self.sourceIndex = nil
                self.snapshot?.removeFromSuperview()
                self.snapshot = nil
            })
            break
        }

    }

    ///MARK: Delegates
    func taskUpdated(task: Task, isNew: Bool) {
        self.loadData(reload: true)
    }

    ///get total minutes taken
    func getLatestTime() -> Double {
        var takenSlots:Double = 0.0
        for task in tasks {
            takenSlots += Double(task.length)
        }
        return takenSlots
    }
}
