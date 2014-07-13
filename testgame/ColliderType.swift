//
//  ColliderType.swift
//  testgame
//
//  Created by peacock on 14-7-12.
//  Copyright (c) 2014年 peacock. All rights reserved.
//

class ColliderType {
    class var hero: UInt32 {
        return 1 << 0
    }
    class var platform: UInt32 {
        return 1 << 1
    }
    class var worm: UInt32 {
        return 1 << 2
    }
    class var pipe: UInt32 {
        return 1 << 3
    }
}
