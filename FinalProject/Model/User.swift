//
//  User.swift
//  FinalProject
//
//  Created by Ксения Чепурных on 18.12.2020.
//

import Foundation
//import FirebaseFirestore

struct User {
    let fullname: String
    let email: String
    let phone: String
    let uid: String
    
    
    init(dict: [String : Any]) {
        self.fullname = dict["fullname"] as? String ?? ""
        self.email = dict["email"] as? String ?? ""
        self.phone = dict["phoneNumber"] as? String ?? ""
        self.uid = dict["uid"] as? String ?? ""
    }
}
