//
//  FirebaseAuthService.swift
//  ml-image-app
//
//  Created by Levi Davis on 12/9/19.
//  Copyright © 2019 Levi Davis. All rights reserved.
//

import Foundation
import FirebaseAuth

class FirebaseAuthService {
    static let manager = FirebaseAuthService()
    
    private let auth = Auth.auth()
    
    var currentUser: User? {
        return auth.currentUser
    }
    
    func createNewUser(email: String, password: String, completion: @escaping (Result<User, Error>) -> ()) {
        auth.createUser(withEmail: email, password: password) { (result, error) in
            if let createdUser = result?.user {
                completion(.success(createdUser))
            } else {
                if let error = error {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func updateUserFields(userName: String? = nil, completion: @escaping (Result<(), Error>) -> ()) {
        let changeRequest = auth.currentUser?.createProfileChangeRequest()
        if let userName = userName {
            changeRequest?.displayName = userName
        }
        changeRequest?.commitChanges(completion: { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        })
    }
    
    func loginUser(email: String, password: String, completion: @escaping (Result<(), Error>) -> ()) {
        auth.signIn(withEmail: email, password: password) { (result, error) in
            if result?.user != nil {
                completion(.success(()))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    func logoutUser() {
        do {
            try auth.signOut()
        } catch {
            print(error)
        }
    }
}
