//
//  Service.swift
//  FinalProject
//
//  Created by Ксения Чепурных on 18.12.2020.
//

import Firebase
import MapKit

let DB_REF = Database.database().reference()
let USERS_REF = DB_REF.child("users")
let SESSIONS_REF = DB_REF.child("sessions")

struct Service {
    static let shared = Service()
    
    let currentUID = Auth.auth().currentUser?.uid
    
    func fetchUserData(completion: @escaping(User) -> Void) {
        
        USERS_REF.child(currentUID!).observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? [String : Any] else { return }
            let user = User(dict: dict)
            completion(user)
        }
    }
    
//    func fetchCompanions(copmpletion: @escaping([Companion]) -> Void) {
//        var companions: [Companion] = []
//        USERS_REF.child(currentUID!).child("companions").observeSingleEvent(of: .value) { (snapshot) in
//            guard let dict = snapshot.value as? [String : [String : Any]] else { return }
//            for i in dict {
//
//                guard let value = i.value as? [String: String] else { return }
//                let fullname = value["fullname"]! as String
//                let uid = value["uid"]! as String
//                let phone = value["phoneNumber"]! as String
//
//                let companion = Companion(fullname: fullname, uid: uid, phone: phone)
//                companions.append(companion)
//            }
//            copmpletion(companions)
//        }
//    }
    
    func fetchCompanions(copmpletion: @escaping([Companion]) -> Void) {
        var companions: [Companion] = []
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        USERS_REF.observe(.value) { (snapshot) in
            guard let dict = snapshot.value as? [String : [String : Any]] else { return }
            for i in dict {
                if i.key != userUID {
                    guard let value = i.value as? [String: String] else { return }
                    let fullname = value["fullname"]! as String
                    let uid = value["uid"]! as String
                    let phone = value["phoneNumber"]! as String

                    let companion = Companion(fullname: fullname, uid: uid, phone: phone)
                    companions.append(companion)
                }
            }
            copmpletion(companions)
        }
    }
    
    func createSession(_ startCoordinates: CLLocationCoordinate2D, companionUID: String, companionPhone: String, userPhone: String, _ destinationCoordinates: CLLocationCoordinate2D, companionName: String, userName: String, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        let start = [startCoordinates.latitude, startCoordinates.longitude]
        let destination = [destinationCoordinates.latitude, destinationCoordinates.longitude]
        
        let valuesForUser = ["start": start,
                             "destination": destination,
                             "companion": companionUID,
                             "currentLocation": start,
                             "state": SessionState.requested.rawValue,
                             "companionPhone": companionPhone,
                             "companionName": companionName,
                             "role": SessionRole.user.rawValue] as [String : Any] //добавить currentLocation и возможно имя юзера
        
        USERS_REF.child(userUID).child("session").updateChildValues(valuesForUser, withCompletionBlock: completion)
        
        let valuesForCompanion = ["start": start,
                                  "destination": destination,
                                  "companion": userUID,
                                  "currentLocation": start,
                                  "state": SessionState.requested.rawValue,
                                  "companionPhone": userPhone,
                                  "companionName": userName,
                                  "role": SessionRole.companion.rawValue] as [String : Any]
        
        USERS_REF.child(companionUID).child("session").updateChildValues(valuesForCompanion, withCompletionBlock: completion)
    }
    
    func observeSession(completion: @escaping(Session) -> Void) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        USERS_REF.child(userUID).child("session").observe(.value) { (snapshot) in
            
            print("DEBUG: observing...")
            
            guard let dict = snapshot.value as? [String: Any] else { return }
            let session = Session(userUID: userUID, dictionary: dict)
            completion(session)
        }
    }
    
    func acceptSession(session: Session, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        let values = ["state": SessionState.inProgress.rawValue] as [String : Any]
        USERS_REF.child(userUID).child("session").updateChildValues(values, withCompletionBlock: completion)
        guard let companionUID = session.companionUID else { return }
        USERS_REF.child(companionUID).child("session").updateChildValues(values, withCompletionBlock: completion)
    }
    
    func endSession(session: Session, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        USERS_REF.child(userUID).child("session").removeValue(completionBlock: completion)
        guard let companionUID = session.companionUID else { return }
        USERS_REF.child(companionUID).child("session").removeValue(completionBlock: completion)
    }
    
    func observeSessionCancelled(session: Session, completion: @escaping() -> Void) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        USERS_REF.child(userUID).observeSingleEvent(of: .childRemoved) { _ in
            completion()
        }
    }
    
    func updateLocation(location: CLLocation, session: Session) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        let values = [lat, lon]
        //USERS_REF.child(userUID).child("session").child("currentLocation").updateChildValues(["currentLocation": values])
        USERS_REF.child(userUID).child("session").updateChildValues(["currentLocation": values])
        guard let companionUID = session.companionUID else { return }
        USERS_REF.child(companionUID).child("session").updateChildValues(["currentLocation": values])
    }
}
