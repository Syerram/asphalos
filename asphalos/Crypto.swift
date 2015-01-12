//
//  Crypto.swift
//  asphalos
//
//  Created by Saikiran Yerram on 12/30/14.
//  Copyright (c) 2014 Blackhorn. All rights reserved.
//

import Foundation

extension String {

    ///Generate a SHA1 string using Crypto package
    func sha1() -> String {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)!
        //container
        var digest = [UInt8](count:Int(CC_SHA1_DIGEST_LENGTH), repeatedValue: 0)
        //copy over the bytes to digest
        CC_SHA1(data.bytes, CC_LONG(data.length), &digest)
        //finally loop thru digest & prep hex value
        let output = NSMutableString(capacity: Int(CC_SHA1_DIGEST_LENGTH))
        for byte in digest {
            //2 digits of zero-padded hex
            output.appendFormat("%02x", byte)
        }
        return output
    }
}