//
//  FirestoreService.swift
//  ml-image-app
//
//  Created by Levi Davis on 12/9/19.
//  Copyright © 2019 Levi Davis. All rights reserved.
//

import Foundation
import FirebaseFirestore
 
fileprivate enum FirestoreCollections: String {
    case users
    case posts
}

enum SortingCriteria: String {
    case fromNewestToOldest = "dateCreated"
    var shouldSortDescending: Bool {
        switch self {
        case .fromNewestToOldest:
            return true
        }
    }
}

class FirestoreService {
    static let manager = FirestoreService()
    
    private let db = Firestore.firestore()
    
//    MARK: - AppUsers
    
    func createAppUser(user: AppUser, completion: @escaping (Result <(), Error>) -> ()) {
        var fields: [String: Any] = user.fieldsDict
        fields["dateCreated"] = Date()
        db.collection(FirestoreCollections.users.rawValue).document(user.uid).setData(fields) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updateCurrentUser(userName: String? = nil, completion: @escaping (Result <(), Error>) -> ()) {
        guard let userID = FirebaseAuthService.manager.currentUser?.uid else {return}
        var updateFields = [String: Any]()
        
        if let user = userName {
            updateFields["userName"] = user
        }
        
        db.collection(FirestoreCollections.users.rawValue).document(userID).updateData(updateFields) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func getAllUsers(completion: @escaping (Result <[AppUser], Error>) -> ()) {
        db.collection(FirestoreCollections.users.rawValue).getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                let users = snapshot?.documents.compactMap({ (snapshot) -> AppUser? in
                    let userID = snapshot.documentID
                    let user = AppUser(from: snapshot.data(), id: userID)
                    return user
                })
                completion(.success(users ?? []))
            }
        }
    }
    
//    MARK: - Posts
    
    func createPost(post: Post, completion: @escaping (Result <(), Error>) -> ()) {
        var fields = post.fieldsDict
        fields["dateCreated"] = Date()
        db.collection(FirestoreCollections.posts.rawValue).addDocument(data: fields) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func getAllPosts(sortingCriteria: SortingCriteria? = nil, completion: @escaping (Result <[Post], Error>) -> ()) {
        let completionHandler: FIRQuerySnapshotBlock = {(snapshot, error) in
            if let error = error {completion(.failure(error))} else {
                let posts = snapshot?.documents.compactMap({ (snapshot) -> Post? in
                    let postID = snapshot.documentID
                    let post = Post(from: snapshot.data(), id: postID)
                    return post
                })
                completion(.success(posts ?? []))
            }
        }
        
        let collection = db.collection(FirestoreCollections.posts.rawValue)
        if let sortingCriteria = sortingCriteria {
            let query = collection.order(by: sortingCriteria.rawValue, descending: sortingCriteria.shouldSortDescending)
            query.getDocuments(completion: completionHandler)
        } else {
            collection.getDocuments(completion: completionHandler)
        }
        
    }
    
    func getUserPosts(for userID: String, completion: @escaping (Result <[Post], Error>) -> ()) {
        db.collection(FirestoreCollections.posts.rawValue).whereField("creatorID", isEqualTo: userID).getDocuments { (snapshot, error) in
            if let error = error {completion(.failure(error))} else {
                let posts = snapshot?.documents.compactMap({ (snapshot) -> Post? in
                    let postID = snapshot.documentID
                    let post = Post(from: snapshot.data(), id: postID)
                    return post
                })
                completion(.success(posts ?? []))
            }
        }
    }
    private init(){}
}
