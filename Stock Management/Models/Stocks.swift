//
//  Stocks.swift
//  Stock Management
//
//  Created by sarath kumar on 07/07/20.
//  Copyright © 2020 sarath kumar. All rights reserved.
//

import Foundation
import Firebase

struct Stocks {
    
    let longitude: Double
    let latitude: Double
    var reportedDate: Date = Date()
    var documentId: String?
}

extension Stocks {
    
    init?(_ snapshot: QueryDocumentSnapshot) {
        
        guard let latitude = snapshot["latitude"] as? Double ,
              let longitude = snapshot["longitude"] as? Double
            else {
            return nil
        }
        
        self.latitude = latitude
        self.longitude = longitude
        self.documentId = snapshot.documentID
    }
    
    init(longitude: Double, latitude: Double) {
        self.longitude = longitude
        self.latitude = latitude
    }
}

extension Stocks {
    
    func toDictionary() -> [String:Any] {
        return ["longitude": self.longitude,
                "latitude": self.latitude,
                "reportedDate": self.reportedDate.formatAsString()]
    }
}
