//
//  Color.swift
//  Connect4
//
//  Created by Yuhong He on 04/12/2023.
//

import Foundation
import UIKit

let boardColor = UIColor.init(0x00235CFF)
let userDiscContentColor = UIColor.init(0xFFFF00FF)
let userDiscBorderColor = UIColor.init(0xB8860BFF)
let botDiscContentColor = UIColor.init(0xFF0000FF)
let botDiscBorderColor = UIColor.init(0xCD2626FF)

extension UIColor {
    public convenience init(_ rgba: UInt32) {
        self.init(red: CGFloat(Int(rgba >> 24) & 0xFF) / 255.0,
                  green: CGFloat(Int(rgba >> 16) & 0xFF) / 255.0,
                  blue: CGFloat(Int(rgba >> 8) & 0xFF) / 255.0,
                  alpha: CGFloat(rgba & 0xFF) / 255.0)
    }
}
