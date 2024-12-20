//
//  UserManager.swift
//  Book Spot iOS
//
//  Created by Wilmer Ocampo on 19/12/24.
//


import FirebaseAuth

class UserManager {
    
    static func getCurrentUserID() -> String? {
        if let user = Auth.auth().currentUser {
            return user.uid
        }
        return nil
    }
}
