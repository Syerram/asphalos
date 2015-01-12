//
//  Extensions.swift
//  asphalos
//
//  Created by Saikiran Yerram on 12/28/14.
//  Copyright (c) 2014 Blackhorn. All rights reserved.
//

import Foundation
import UIKit

extension UIWindow {
    ///Navigate to root controller for the given nib
    func navigateToRootController(nibName: String) {
        var rootController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(nibName) as UIViewController
        UIView.transitionWithView(self, duration: 0.5, options: UIViewAnimationOptions.TransitionCurlDown, animations: {
            self.rootViewController = rootController
            }, completion: nil)
    }
}

extension UIView {

    ///Remove the subview with animation. Perhaps we should let caller pass the duration/delay?
    func removeFromSuperview(animation:UIViewAnimationOptions) {
        UIView.animateWithDuration(1, delay: 0.5, options: animation, animations: { () -> Void in
            //do some sliding or other animations
        }) { (completed) -> Void in
            self.removeFromSuperview()
        }
    }
}

extension UIImageView {

    convenience init(named: String, x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat) {
        self.init(image: UIImage(named: named))
        self.frame = CGRect(x: x, y: y, width: width, height: height)
    }

    convenience init(named: String, bounds:CGRect) {
        self.init(image: UIImage(named: named))
        self.frame = bounds
    }

}

extension UITableView {

    ///Scrolls to the bottom of the section
    func scrollToBottom(section: Int, animated: Bool) {
        let numberOfRows = self.numberOfRowsInSection(section)
        if numberOfRows > 0 {
            self.scrollToRowAtIndexPath(NSIndexPath(forRow: numberOfRows - 1, inSection: section), atScrollPosition: .Bottom, animated: animated)
        }
    }

    func hideFooter() {
        self.tableFooterView = UIView()
    }
}

extension UIViewController {

    ///Add a title to the navigation bar
    ///Uses label to set the title
    func addNavigationBarTitle(title:String, attributes:((label:UILabel) -> ())? = nil)  {
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, self.view.frame.size.width, 44))
        titleLabel.text = title
        titleLabel.font = UIFont(name: Globals.Theme.RegularFont, size: 18)
        titleLabel.textAlignment = NSTextAlignment.Center
        if attributes != nil {
            attributes!(label: titleLabel)
        }
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
    }

    ///Add Left button with default options
    func addLeftButton(action:String, actionStyle:UIBarButtonSystemItem) {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: actionStyle, target: self, action: Selector(action))
        self.navigationItem.leftBarButtonItem?.tintColor = Globals.Theme.AppTintColor
    }

    ///Add left button with customization (title)
    func addLeftButton(action:String, title:String, callback:((barButton:UIBarButtonItem) -> ())? = nil) {
        var barButton:UIBarButtonItem = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Plain, target: self, action: Selector(action))
        var font:UIFont = UIFont(name: Globals.Theme.RegularFont, size: 16)!
        barButton.setTitleTextAttributes([NSFontAttributeName : font, NSForegroundColorAttributeName : Globals.Theme.AppTintColor], forState: UIControlState.Normal)
        if callback != nil {
            callback!(barButton: barButton)
        }
        self.navigationItem.leftBarButtonItem = barButton
    }

    ///Add custom image for left button
    func addLeftButton(action:String, imagePath:String, callback:((barButton:UIBarButtonItem) -> ())? = nil) {
        var barButton:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: imagePath), style: UIBarButtonItemStyle.Plain, target: self, action: Selector(action))
        if callback != nil {
            callback!(barButton: barButton)
        }
        self.navigationItem.leftBarButtonItem = barButton
    }

    ///Add Right button with default style
    func addRightButton(action:String, actionStyle:UIBarButtonSystemItem) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: actionStyle, target: self, action: Selector(action))
        self.navigationItem.rightBarButtonItem?.tintColor = Globals.Theme.AppTintColor
    }

    ///Add right button with title and callback
    func addRightButton(action:String, title:String, callback:((barButton:UIBarButtonItem) -> ())? = nil) {
        var barButton:UIBarButtonItem = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Plain, target: self, action: Selector(action))
        var font:UIFont = UIFont(name: Globals.Theme.RegularFont, size: 16)!
        barButton.setTitleTextAttributes([NSFontAttributeName : font, NSForegroundColorAttributeName : Globals.Theme.AppTintColor], forState: UIControlState.Normal)
        if callback != nil {
            callback!(barButton: barButton)
        }
        self.navigationItem.rightBarButtonItem = barButton
    }

    ///Add custom right button
    func addRightButton(action:String, imagePath:String, callback:((barButton:UIBarButtonItem) -> ())? = nil) {
        var barButton:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: imagePath), style: UIBarButtonItemStyle.Plain, target: self, action: Selector(action))
        if callback != nil {
            callback!(barButton: barButton)
        }
        self.navigationItem.rightBarButtonItem = barButton
    }


    ///Update back button
    func updateBackButton(title: String) {
        var barButton:UIBarButtonItem = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        var font:UIFont = UIFont(name: Globals.Theme.RegularFont, size: 16)!
        barButton.tintColor = Globals.Theme.AppTintColor
        barButton.setTitleTextAttributes([NSFontAttributeName : font, NSForegroundColorAttributeName : Globals.Theme.AppTintColor], forState: UIControlState.Normal)
        self.navigationItem.backBarButtonItem = barButton
    }


    ///Push the controller provided by nib name (from main storyboard) on the current navigation stack using the transition style
    ///Callers have the opportunity to work with the controller once its created by passing code block to callback
    ///@param: nibName: Pass the storyboard name for the controller
    ///@param: callback: Pass the code block. Ensure to provide the actual type of your controller
    func pushControllerOnNavigationStack<T>(nibName:String, callback:(controller:T) -> (), transitionSyle:UIViewAnimationTransition? = nil) -> T {
        var controller:T = self.storyboard?.instantiateViewControllerWithIdentifier(nibName)! as T
        callback(controller: controller)
        var currentView = self.navigationController!.view
        if transitionSyle != nil {
            UIView.animateWithDuration(0.75, animations: { () -> Void in
                UIView.setAnimationCurve(UIViewAnimationCurve.EaseIn)
                self.navigationController?.pushViewController(controller as UIViewController, animated: false)
                UIView.setAnimationTransition(transitionSyle!, forView: currentView, cache: false)
                }, completion: nil)
        } else {
            self.navigationController?.pushViewController(controller as UIViewController, animated: true)
        }
        return controller
    }

    ///Push the provided controller on to the stack with transition style if any
    func pushControllerOnNavigationStack<T>(controller:T, transitionSyle:UIViewAnimationTransition? = nil) {
        var currentView = self.navigationController!.view
        if transitionSyle != nil {
            UIView.animateWithDuration(0.75, animations: { () -> Void in
                UIView.setAnimationCurve(UIViewAnimationCurve.EaseIn)
                self.navigationController?.pushViewController(controller as UIViewController, animated: false)
                UIView.setAnimationTransition(transitionSyle!, forView: currentView, cache: false)
                }, completion: nil)
        } else {
            self.navigationController?.pushViewController(controller as UIViewController, animated: true)
        }
    }

    ///Present the controller as a root controller
    func presentAsRootController(nibName:String, transitionStyle:UIViewAnimationOptions) {
        var controller = self.storyboard!.instantiateViewControllerWithIdentifier(nibName) as UIViewController
        var appDelegate:AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        UIView.transitionWithView(appDelegate.window!, duration: 0.5, options: transitionStyle, animations: { () -> Void in
            appDelegate.window!.rootViewController = controller
        }, completion: nil)

    }


    ///MARK: Utils
    func proxy<T>(object:T?, callback:(object:T)->()) {
        if let _object = object {
            callback(object: _object)
        }
    }
}

extension UITableViewController {

    ///Adds pull to drag with current theme
    func addPullToDrag(action: Selector) -> UIRefreshControl {
        var refreshControl = UIRefreshControl()
        var font:UIFont = UIFont(name: Globals.Theme.RegularFont, size: 14)!
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh", attributes: [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.whiteColor()])
        refreshControl.backgroundColor = Globals.Theme.AppTintColor
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.addTarget(self, action: action, forControlEvents: UIControlEvents.ValueChanged)
        return refreshControl
    }

    ///add default message to tableview
    func setDefaultMessage(title: String) {
        var label = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))

        label.text = title
        label.textColor = Globals.Theme.AppTintColor
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignment.Center;
        label.font = UIFont(name: Globals.Theme.RegularFont, size: 16)
        label.sizeToFit()

        self.tableView.backgroundView = label;
    }

}

extension SFSwiftNotification {

    ///Add new notification and get back the view
    class func NewNotification(frame: CGRect, delegate:SFSwiftNotificationProtocol?) -> SFSwiftNotification {
        var notifyView = SFSwiftNotification(frame: frame,
            title: nil,
            animationType: AnimationType.AnimationTypeBounce,
            direction: Direction.TopToBottom,
            delegate: nil)
        notifyView.backgroundColor = Globals.Theme.AppTintColor
        notifyView.label.textColor = UIColor.whiteColor()
        if let _del = delegate {
            notifyView.delegate = _del
        }
        return notifyView
    }
}