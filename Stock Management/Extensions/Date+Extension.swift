//
//  Date+Extension.swift
//  Stock Management
//
//  Created by sarath kumar on 07/07/20.
//  Copyright © 2020 sarath kumar. All rights reserved.
//

import Foundation

extension Date {
    
    func formatAsString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        return dateFormatter.string(from: self)
    }
}
