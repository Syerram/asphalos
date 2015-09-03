//
//  UpcomingTaskCell.swift
//  Robinhood
//
//  Created by Abhinay Ashutosh on 10/12/14.
//  Copyright (c) 2014 Kipin Hall. All rights reserved.
//

import UIKit

let firstCellFontSize:CGFloat = 22
let secondCellFontSize:CGFloat = 18
let thirdCellFontSize:CGFloat = 17
let otherCellFontSize:CGFloat = 14

protocol TaskMarked {
    func taskMarked(rowNum:Int, selected:Bool)
}

class TaskViewCell: UITableViewCell /*SWTableViewCell*/ {
    
    let DARK_TEXT_COLOR = UIColor(red: 0.23, green: 0.25, blue: 0.30, alpha: 1)


    // external
    var rowNum:Int = 0
    var cellHeight:CGFloat = 44.0
    var tint:UIColor = UIColor.whiteColor()
    var dueTime:UILabel = UILabel()
    var isLastRow = false
    var taskMarkDelegate:TaskMarked?

    // internal
    var taskCheck:UIButton?
    var isTaskCompleted:Bool = false
    var upBar:UIView?
    var downBar:UIView?
    var separatorLine:UIView?
    var addedDueTime:Bool = false
    var isFirstCell:Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var fontSize:CGFloat = otherCellFontSize
        isFirstCell = false
        

        switch (rowNum) {
        case 0:
            fontSize = firstCellFontSize
            self.textLabel?.textColor = DARK_TEXT_COLOR //UIColor.whiteColor()
            isFirstCell = false //true
            break
        case 1:
            fontSize = secondCellFontSize
            self.textLabel?.textColor = DARK_TEXT_COLOR
            break
        case 2:
            fontSize = thirdCellFontSize
            self.textLabel?.textColor = DARK_TEXT_COLOR.colorWithAlphaComponent(0.8)
            break
        default:
            fontSize = otherCellFontSize
            self.textLabel?.textColor = DARK_TEXT_COLOR.colorWithAlphaComponent(0.5)
            break
        }

        
        self.textLabel?.font = UIFont(name: Globals.Theme.RegularFont, size: fontSize)
        self.textLabel?.numberOfLines = 0
        //self.textLabel.layer.borderColor = isFirstCell ? KIPIN_HALL_BLUE.CGColor : UIColor.whiteColor().CGColor
        //self.textLabel.layer.borderWidth = 2.0
        
        let textLabelWidth:CGFloat = self.frame.size.width - 54 - 7
        let text:NSString = self.textLabel!.text!
        let options:NSStringDrawingOptions =  .UsesLineFragmentOrigin
        var stringAttributes:NSDictionary = [NSFontAttributeName:self.textLabel!.font!]
        var size:CGSize = text.boundingRectWithSize(CGSizeMake(textLabelWidth, 20000.0),
            options: options,
            attributes: stringAttributes as [NSObject : AnyObject],
            context: nil).size
        
        if (size.height < 21) {
            size.height = 21
        }
        
        self.textLabel?.frame = CGRectMake(54, isFirstCell ? 18 : 20, textLabelWidth, ceil(size.height));
        
        /*
        self.detailTextLabel?.font = UIFont(name: REGULAR_FONT, size: 14)
        self.detailTextLabel?.textColor = UIColor.lightGrayColor()
        self.detailTextLabel?.text = "HELLO"
        */
        
        cellHeight = (2*self.textLabel!.frame.origin.y) + ceil(size.height) + 75
        if (cellHeight < 44) {
            cellHeight = 44;
        }
        
        

        if (upBar == nil) {
            upBar = UIView()
            self.addSubview(upBar!)
        }
        
        upBar!.frame = CGRectMake(30, 0, 2, 20)
        upBar!.backgroundColor = isFirstCell ? UIColor.whiteColor() : UIColor(white: 238.0/255.0, alpha: 1)
        self.backgroundColor = isFirstCell ? Globals.Theme.AppTintColor: UIColor.whiteColor()
        
        if (downBar == nil) {
            downBar = UIView()
            self.addSubview(downBar!)
        }

        downBar!.frame = CGRectMake(30, 20 + 22, 2, height - 20 - 22)
        downBar!.backgroundColor = isFirstCell ? UIColor.whiteColor() : UIColor(white: 238.0/255.0, alpha: 1)
        self.backgroundColor = isFirstCell ? Globals.Theme.AppTintColor : UIColor.whiteColor()


        if (taskCheck != nil) {
            taskCheck?.removeFromSuperview()
        }
        taskCheck = UIButton(frame: CGRectMake(20, 20, 22, 22))
        self.addSubview(taskCheck!)
        
        if (isTaskCompleted) {
            taskCheck!.setImage(UIView.colorizeImage(UIImage(named: "Task_Icon_Selected")!, withColor: Globals.Theme.AppTintColor), forState: .Normal)
        } else {
            taskCheck!.setImage(UIView.colorizeImage(UIImage(named: "Task_Icon_Unselected")!, withColor: Globals.Theme.AppTintColor), forState: .Normal)
        }

        taskCheck!.addTarget(self, action: "taskCheckClicked", forControlEvents: .TouchUpInside)
        taskCheck!.tintColor = isFirstCell ? tint : UIColor.whiteColor()

        if (!addedDueTime) {
            self.addSubview(dueTime)
        }
        
        dueTime.frame = CGRectMake(self.textLabel!.frame.origin.x, self.textLabel!.frame.origin.y + self.textLabel!.frame.size.height + 7, self.textLabel!.frame.size.width, 21);
        dueTime.font = UIFont(name: Globals.Theme.RegularFont, size: otherCellFontSize)
        dueTime.textColor = self.textLabel?.textColor
        dueTime.sizeToFit()
    }
    
    func taskCheckClicked() {
        if (isTaskCompleted) {
            isTaskCompleted = false
            taskCheck!.setImage(UIView.colorizeImage(UIImage(named: "Task_Icon_Unselected")!, withColor: Globals.Theme.AppTintColor), forState: .Normal)
        } else {
            isTaskCompleted = true
            taskCheck!.setImage(UIView.colorizeImage(UIImage(named: "Task_Icon_Selected")!, withColor: Globals.Theme.AppTintColor), forState: .Normal)
            // do something here to update the server and send back "selected" information to the table view parent for animations
        }
        taskMarkDelegate?.taskMarked(rowNum, selected: isTaskCompleted)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


    func reset() {
        isTaskCompleted = false
        taskCheck!.setImage(UIView.colorizeImage(UIImage(named: "Task_Icon_Unselected")!, withColor: Globals.Theme.AppTintColor), forState: .Normal)
    }

}
