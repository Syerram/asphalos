//
//  TaskerController.swift
//  asphalos
//
//  Created by Saikiran Yerram on 1/13/15.
//  Copyright (c) 2015 Blackhorn. All rights reserved.
//

import UIKit
import CoreData

class TaskerController: UITableViewController, TaskDelegate, TaskMarked {

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
        let longGesture = UILongPressGestureRecognizer(target: self, action: "longGestureRecognized:")
        self.tableView.addGestureRecognizer(longGesture)
        self.setupHeader(false)
        self.tableView.registerClass(TaskViewCell.self, forCellReuseIdentifier: "TaskViewCell")
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None

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
            }, sortKeys: [("startDate", true), ("order", true)]) as [Task]

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
        let cell = tableView.dequeueReusableCellWithIdentifier("TaskViewCell", forIndexPath: indexPath) as TaskViewCell
        self.updateCell(cell, task: tasks[indexPath.row], rowNum: indexPath.row)
        cell.taskMarkDelegate = self
        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if toggleListOn {
            return 70
        }

        var fontSize:CGFloat = otherCellFontSize

        switch (indexPath.row) {
        case 0:
            fontSize = firstCellFontSize
        case 1:
            fontSize = secondCellFontSize
        case 2:
            fontSize = thirdCellFontSize
        default:
            fontSize = otherCellFontSize
        }

        let font:UIFont! = UIFont(name: Globals.Theme.RegularFont, size: fontSize)

        let textLabelWidth:CGFloat = self.view.frame.size.width - 54 - 7
        var height = UILabel.getHeight(tasks[indexPath.row].name, font: font, width: textLabelWidth, height: 20000.0)
        if height < 21 {
            height = 21
        }

        return ceil(height) + 75
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.pushControllerOnNavigationStack("TaskDetailController", callback: { (controller:TaskDetailController) -> () in
            controller.task = self.tasks[indexPath.row]
            controller.currentDate = self.currentDate
            controller.nextSlot = self.nextSlot()
            controller.taskDelegate = self
        }, transitionSyle: nil)
    }

    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }


    ///MARK: Event handlers
    func add() {
        self.pushControllerOnNavigationStack("TaskEditController", callback: { (controller:TaskEditController) -> () in
            controller.taskDelegate = self
            controller.currentDate = self.currentDate
            controller.nextSlot = self.nextSlot()
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
        dayComponent.hour = 9
        var tempDate = calendar.dateByAddingComponents(dayComponent, toDate: currentDate, options: NSCalendarOptions.allZeros)!
        currentDate = calendar.dateBySettingHour(9, minute: 0, second: 0, ofDate: tempDate, options: NSCalendarOptions.allZeros)!
    }

    @IBAction func back(sender: AnyObject) {
        var dayComponent = NSDateComponents()
        dayComponent.day = -1
        dayComponent.hour = 9
        var tempDate = calendar.dateByAddingComponents(dayComponent, toDate: currentDate, options: NSCalendarOptions.allZeros)!
        currentDate = calendar.dateBySettingHour(9, minute: 0, second: 0, ofDate: tempDate, options: NSCalendarOptions.allZeros)!
    }

    ///MARK: Moving rows

    ///Update cell helper method
    func updateCell(cell:TaskViewCell, task:Task, rowNum:Int) {
        cell.rowNum = rowNum
        cell.isLastRow = (rowNum + 1) == tasks.count
        var formatter = NSDateFormatter()
        var components = NSCalendar.currentCalendar().components(NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.YearCalendarUnit, fromDate: task.startDate)

        cell.textLabel?.text = task.name
        var dueTimeParts = ""

        if toggleListOn {
            formatter.dateFormat = "MMM"
            dueTimeParts = "\(components.day), \(formatter.stringFromDate(task.startDate)) \(components.year) - "
        }

        cell.dueTime.text = "\(dueTimeParts)\(task.lengthFormatted)"
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
                Task.SwapOrder(tasks[indexPath!.row], destination: tasks[sourceIndex!.row])
                (tasks[indexPath!.row], tasks[sourceIndex!.row]) = (tasks[sourceIndex!.row], tasks[indexPath!.row])
                self.tableView.moveRowAtIndexPath(sourceIndex!, toIndexPath: indexPath!)
                self.updateCell(self.tableView.cellForRowAtIndexPath(sourceIndex!)! as TaskViewCell, task: tasks[sourceIndex!.row], rowNum: sourceIndex!.row)
                self.updateCell(self.tableView.cellForRowAtIndexPath(indexPath!)! as TaskViewCell, task: tasks[indexPath!.row], rowNum: indexPath!.row)
                UIView.delay(0.5, callback: { () -> () in
                    self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
                })
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
    func nextSlot() -> Int {
        return tasks.count > 0 ? tasks[tasks.count - 1].order.integerValue + 1 : 1
    }

    func taskMarked(rowNum: Int, selected: Bool) {
        let task = self.tasks[rowNum]
        task.completed = NSNumber(bool: selected)
        Task.save()
        if selected {
            self.tasks.removeAtIndex(rowNum)
            let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: rowNum, inSection: 0)) as TaskViewCell
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: rowNum, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
            UIView.delay(0.5, callback: { () -> () in
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
                cell.reset()
            })
        }
    }
}
