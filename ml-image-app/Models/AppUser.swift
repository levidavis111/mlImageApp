//
//  AppUser.swift
//  ml-image-app
//
//  Created by Levi Davis on 12/9/19.
//  Copyright © 2019 Levi Davis. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct AppUser {
    let email: String?
    let uid: String
    let userName: String?
    let dateCreated: Date?
    
    init(from user: User) {
        self.email = user.email
        self.uid = user.uid
        self.userName = user.displayName
        self.dateCreated = user.metadata.creationDate
    }
    
    init?(from dict: [String: Any], id: String) {
        guard let userName = dict["userName"] as? String,
        let email = dict["email"] as? String,
        let dateCreated = (dict["dateCreated"] as? Timestamp)?.dateValue() else {return nil}
        
        self.userName = userName
        self.email = email
        self.uid = id
        self.dateCreated = dateCreated
    }
    
    var fieldsDict: [String: Any] {
        return ["userName":self.userName ?? "", "email":self.email ?? ""]
    }
}
