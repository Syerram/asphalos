## TODO

4. ~~Data models - Core data~~
5. ~~`Lists` - List/Edit~~
6. ~~`PasswordView` - List/Edit~~
7. ~~`GeneratePassword`~~
8. ~~`Search` in Category and Main view listing~~
9.  ~~Copy password feature~~
10. ~~`LockSmith` integration for storing password~~
12. Delete Account - 10mins
12. Settings controller
    a. UI
        *   ~~Tableview with 2 buttons - 15mins~~
        *   ~~Reset Master --> Reset Password Controller - 10mins~~
            *   ~~Move master password storage/check to Globals, so we can reuse (and also hash it) - 15mins~~
            *   ~~Store hashvalue of the password instead of raw - 15mins~~
        *   Purge 
            *   ~~UI Confirmation -> Remove -> CategoriesController - 15mins~~
            *   ~~Add `deleteAll` to `NSManagedObject` extension - stackoverflow question~~
12. ~~Additional info field integration - 15mins~~
12. ~~Delegate update from `AccountEditController` -> `AccountController` -> `CategoryController` - 15mins~~


## Enhancements
1. Use CloudKit to store in user's data
2. Use *Siri* voice to capture audio-text and store the password
3. Capture user voice on authentication
