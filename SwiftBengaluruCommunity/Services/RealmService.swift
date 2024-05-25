//
//  RealmService.swift
//  SwiftBengaluruCommunity
//
//  Created by Amitesh Mani Tiwari on 23/05/24.
//

import RealmSwift

class RealmService {
    static let shared = RealmService()
    private init() {}

    var realm: Realm {
        return try! Realm()
    }

    func add<T: Object>(_ object: T) {
        try! realm.write {
            realm.add(object)
        }
    }

    func delete<T: Object>(_ object: T) {
        try! realm.write {
            realm.delete(object)
        }
    }

    func update(_ block: () -> Void) {
        try! realm.write {
            block()
        }
    }

    func fetchMembers() -> Results<Member> {
        return realm.objects(Member.self)
    }
    
    // Advanced Querying Example
    func fetchRecentMembers() -> Results<Member> {
        let lastYear = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        return realm.objects(Member.self).filter("joinedDate > %@", lastYear).sorted(byKeyPath: "joinedDate", ascending: false)
    }
}

