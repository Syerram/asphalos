//
//  Globals.swift
//  asphalos
//
//  Created by Saikiran Yerram on 12/28/14.
//  Copyright (c) 2014 Blackhorn. All rights reserved.
//

import Foundation
import UIKit


class ThemeGlobals {
    let AppTintColor:UIColor = UIColor(hue:0.53, saturation:1, brightness:0.98, alpha:1)
    let RegularFont = "Montserrat-Regular"
    let BoldFont = "Montserrat-Bold"
}

///Manages User defaults
class UserDefaultManager {
    var userDefaults:NSUserDefaults

    init() {
        self.userDefaults = NSUserDefaults.standardUserDefaults()
    }

    func setValueForKey(key:String, value:String) {
        self.userDefaults.setObject(value, forKey: key)
        self.userDefaults.synchronize()
    }

    func getValueForKey(key:String, defaultValue:String? = nil) -> String? {
        if let value = self.userDefaults.objectForKey(key) as? String {
            return value
        } else {
            return defaultValue
        }
    }

    func removeKey(key:String) {
        self.userDefaults.removeObjectForKey(key)
    }
}

///MARK: TODO Use either master password or some other unique Id from the IOS for `salt` purposes
class PasswordManager {

    ///Set the master password
    func setMasterPassword(password:String, update:Bool) -> Bool {
        ///hash it. This is a expensive operation
        var error:NSError? = nil
        if update {
            error = Locksmith.updateData(["asphalos.master": password.sha1()], inService: "asphalos", forUserAccount: "asphalos")
        } else {
            error = Locksmith.saveData(["asphalos.master": password.sha1()], inService: "asphalos", forUserAccount: "asphalos")
        }
        return error == nil
    }

    ///Check if the master password is the same
    func isMasterPassword(password:String) -> (Bool, NSError?) {
        let (dictionary, error) = Locksmith.loadDataInService("asphalos", forUserAccount: "asphalos")
        if let _err = error {
            return (false, _err)
        } else {
            var master = dictionary?.objectForKey("asphalos.master") as String
            return (master == password.sha1(), nil)
        }
    }

    ///Generate a random string for the given length
    func generateRandomString(length:Int? = 10) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
        var randomString : NSMutableString = NSMutableString(capacity: length!)

        var len = UInt32 (letters.length)
        for (var i=0; i < length; i++){
            var rand = arc4random_uniform(len)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }

        return randomString
    }
}

class GlobalManager {
    struct Keys {
        static let User:String = "touchUser"
    }

    let Theme = ThemeGlobals()
    let UserDefaults = UserDefaultManager()
    let Password = PasswordManager()

    var existingUser:Bool {
        get {
            if let value = self.UserDefaults.getValueForKey(Keys.User) {
                return true
            } else {
                return false
            }
        }
        set {
            if newValue {
                self.UserDefaults.setValueForKey(Keys.User, value: "SET")
            } else {
                self.UserDefaults.removeKey(Keys.User)
            }
        }
    }
}

var Globals = GlobalManager()

