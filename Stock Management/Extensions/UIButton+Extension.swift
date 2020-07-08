//
//  UIButton+Extension.swift
//  Stock Management
//
//  Created by sarath kumar on 07/07/20.
//  Copyright © 2020 sarath kumar. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    static func trashButton() -> UIButton {
        
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        button.setImage(UIImage(named: "trash"), for: .normal)
        return button
    }
}
