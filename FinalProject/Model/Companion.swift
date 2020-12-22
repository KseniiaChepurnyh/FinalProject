//
//  Companion.swift
//  FinalProject
//
//  Created by Ксения Чепурных on 18.12.2020.
//

import Foundation

struct Companion {
    let fullname: String
    let uid: String
    let phone: String
    
    init(fullname: String, uid: String, phone: String) {
        self.fullname = fullname
        self.uid = uid
        self.phone = phone
    }
    
    init?(dict: [String : Any]) {
        self.fullname = dict["fullname"] as? String ?? ""
        self.uid = dict["uid"] as? String ?? ""
        self.phone = dict["phoneNumber"] as? String ?? ""
    }
}
