//
//  Post.swift
//  ml-image-app
//
//  Created by Levi Davis on 12/9/19.
//  Copyright © 2019 Levi Davis. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Post {
    let photoURL: String
    let id: String
    let creatorID: String
    let dateCreated: Date?
    
    init(photoURL: String, creatorID: String, dateCreated: Date? = nil) {
        self.photoURL = photoURL
        self.id = UUID().description
        self.creatorID = creatorID
        self.dateCreated = dateCreated
    }
    
    init?(from dict: [String: Any], id: String) {
        guard let photoURL = dict["photoURL"] as? String,
        let creatorID = dict["creatorID"] as? String,
        let dateCreated = (dict["dateCreated"] as? Timestamp)?.dateValue() else {return nil}
        
        self.photoURL = photoURL
        self.creatorID = creatorID
        self.dateCreated = dateCreated
        self.id = id
    }
    
    var fieldsDict: [String: Any] {
        return ["photoURL": self.photoURL, "creatorID": self.creatorID]
    }
}
