//
//  Enemy.swift
//  Independent Study
//
//  Created by Zach Caton on 2/16/18.
//  Copyright © 2018 Zach Caton. All rights reserved.
//

import UIKit


class Enemy {
    
    var isAlive = true
    var canSee = true
    var x = Int()
    var y = Int()
    
    func enemyTouched(){
        isAlive = false
        print("makes enemy state dead aka false")
    }
    
    func isInvisible() {
        canSee = false
        print("Makes enemy invisible")
    }
    
    
}


