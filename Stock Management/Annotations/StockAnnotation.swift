//
//  StockAnnotation.swift
//  Stock Management
//
//  Created by sarath kumar on 07/07/20.
//  Copyright © 2020 sarath kumar. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class StockAnnotations: MKPointAnnotation {
    
    let stock: Stocks
    
    init(_ stock: Stocks) {
        self.stock = stock
    }
}
