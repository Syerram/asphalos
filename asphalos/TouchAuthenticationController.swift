//
//  LoginController.swift
//  asphalos
//
//  Created by Saikiran Yerram on 12/28/14.
//  Copyright (c) 2014 Blackhorn. All rights reserved.
//

import UIKit
import LocalAuthentication

class TouchAuthenticationController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var masterPassword: MasterPasswordTextField!
    
    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var helperText: UILabel!

    var notifyFrame:CGRect?
    var notifyView:SFSwiftNotification?

    override func viewDidLoad() {
        super.viewDidLoad()
        notifyFrame = CGRectMake(0, self.navigationController!.navigationBar.frame.height + 20,
            CGRectGetMaxX(self.view.frame), 50)
        notifyView = SFSwiftNotification.NewNotification(notifyFrame!, delegate: nil)
        self.view.addSubview(notifyView!)

        if !Globals.existingUser {
            containerView.hidden = false
            self.addNavigationBarTitle("New User", attributes: nil)
            self.addRightButton("touchIDSetup", title: "Touch ID", callback: nil)
        } else {
            containerView.hidden = true
            self.addNavigationBarTitle("Touch ID", attributes: nil)
            self.touchIDAuthenticate("Verify Touch ID") { (success:Bool, error:NSError?) -> () in
                if !success {
                    self.addNavigationBarTitle("Authenticate", attributes: nil)
                    self.headerText.text = "Enter Master Password"
                    self.containerView.hidden = false
                    self.addRightButton("validatePassword", title: "Done", callback: nil)

                    switch error!.code {
                    case LAError.SystemCancel.rawValue:
                        self.helperText.text = "TouchID isn't available at the moment. Enter Master Password for access."
                    case LAError.UserCancel.rawValue, LAError.UserFallback.rawValue:
                        self.helperText.text = "Enter Master Password for access."
                    default:
                        self.helperText.text = "Touch ID isn't available on this device. Enter Master Password for access."
                    }

                } else {
                    self.navigateToMainController()
                }

            }
        }
    }

    func touchIDSetup() {
        ///MARK: TODO validate master is atleast 10 digits long and has special characters. Store in keychain
        if !masterPassword.isValid() {
            self.notifyView!.animate(self.notifyFrame!, delay: 5, title: "Password should be more than 10 characters")
            return
        } else {
            Globals.Password.setMasterPassword(masterPassword.text, update: false)
        }
        masterPassword.resignFirstResponder()

        self.touchIDAuthenticate("Touch ID Setup") { (success:Bool, error:NSError?) -> () in
            if !success {
                self.notifyView!.animate(self.notifyFrame!, delay: 5, title: "TouchID isn't available. Will resort to manual password")
            }
            Globals.existingUser = true
            self.navigateToMainController()
        }
    }

    ///called to validate master password manually
    func validatePassword() {
        let (success, error) = Globals.Password.isMasterPassword(masterPassword.text)
        ///MARK: TODO: We need to handle `error` as well
        if !success {
            self.notifyView!.animate(self.notifyFrame!, delay: 5, title: "Password doesn't match. Please re-enter")
            return
        }
        self.navigateToMainController()
    }

    ///Authenticate user via touch ID
    private func touchIDAuthenticate(prompt:String, callback:((Bool, error: NSError?) -> ())) {
        let context = LAContext()
        var error: NSError?

        //TouchID is invoked at the time of app being active or transitioning
        //Since it is a time consuming process, the app is frozen till the touchID is available.
        //Instead we are dispatching the touchID invokation to a different thread (high priority thread), 
        //  and continue with our rendering of screens on the main thread
        //Once the touchID thread is done, we callback on the main thread (join)
        //e.g. Main thread
        //          |
        //          -> async with callback -> Touch ID ->
        //          |                                   |
        // view/render called                           |
        //          |                                   |
        //      callback with results  <----------------|

        var highPriorityQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)

        dispatch_after(DISPATCH_TIME_NOW, highPriorityQueue) { () -> Void in
            if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
                context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: prompt,
                    reply: { (success:Bool, error:NSError!) -> Void in
                        //execute on main thread
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            callback(success, error: error)
                        })
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    callback(false, error: NSError(domain: "asphalos", code: 99, userInfo: nil))
                })
            }
        }
    }

    private func navigateToMainController() {
        self.presentAsRootController("MainController", transitionStyle: UIViewAnimationOptions.TransitionFlipFromBottom)
    }
}
