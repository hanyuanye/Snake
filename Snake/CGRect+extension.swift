//
//  CGRect+extension.swift
//  Snake
//
//  Created by Hanyuan Ye on 2019-07-06.
//  Copyright © 2019 HY. All rights reserved.
//

import UIKit

extension CGRect {
    
    func isCollidingWith(_ frame: CGRect) -> Bool {
        return self.minX  < frame.maxX &&
               frame.minX < self.maxX &&
               self.minY  < frame.maxY &&
               frame.minY < self.maxY
    }
}
