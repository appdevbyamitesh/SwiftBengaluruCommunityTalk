//
//  Member.swift
//  SwiftBengaluruCommunity
//
//  Created by Amitesh Mani Tiwari on 23/05/24.
//

import RealmSwift

class Member: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var fullName = ""  // Renamed from 'name' to 'fullName'
    @objc dynamic var email = ""
    @objc dynamic var joinedDate = Date()
    @objc dynamic var adress = "" // new property
    
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
