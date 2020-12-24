//
//  Session.swift
//  FinalProject
//
//  Created by Ксения Чепурных on 20.12.2020.
//

import CoreLocation
import RealmSwift

enum SessionState: Int {
    case requested
    case denied
    case inProgress
}

enum SessionRole: Int {
    case user
    case companion
}

class Session: Object {
    var startCoordinates: CLLocationCoordinate2D!
    var destinationCoordinates: CLLocationCoordinate2D!
//    @objc dynamic var startCoordinatesArr: [Double] = []
//    @objc dynamic var destinationCoordinatesArr: [Double] = []
    @objc dynamic var userUID: String = ""
    @objc dynamic var companionUID: String = ""
    var state: SessionState?
    var role: SessionRole?
    var currentCoordinates: CLLocationCoordinate2D!
    @objc dynamic var companionPhone: String = ""
    @objc dynamic var companionName: String = ""
    
    convenience init(userUID: String, dictionary: [String: Any]) {
        self.init()
        
        self.userUID = userUID
        
        if let startCoordinates = dictionary["start"] as? NSArray {
            guard let lat = startCoordinates[0] as? CLLocationDegrees else { return }
            guard let long = startCoordinates[1] as? CLLocationDegrees else { return }
            self.startCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        if let currentCoordinates = dictionary["currentLocation"] as? NSArray {
            guard let lat = currentCoordinates[0] as? CLLocationDegrees else { return }
            guard let long = currentCoordinates[1] as? CLLocationDegrees else { return }
            self.currentCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
//            self .startCoordinatesArr.append(lat)
//            self .startCoordinatesArr.append(long)
        }
        
        if let destinationCoordinates = dictionary["destination"] as? NSArray {
            guard let lat = destinationCoordinates[0] as? CLLocationDegrees else { return }
            guard let long = destinationCoordinates[1] as? CLLocationDegrees else { return }
            self.destinationCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
//            self .destinationCoordinatesArr.append(lat)
//            self .destinationCoordinatesArr.append(long)
        }
        
        self.companionUID = dictionary["companion"] as? String ?? ""
        self.companionPhone = dictionary["companionPhone"] as? String ?? ""
        self.companionName = dictionary["companionName"] as? String ?? ""
        
        if let state = dictionary["state"] as? Int {
            self.state = SessionState(rawValue: state)
        }
        
        if let role = dictionary["role"] as? Int {
            self.role = SessionRole(rawValue: role)
        }
    }
}
