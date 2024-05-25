//
//  MemberViewModel.swift
//  SwiftBengaluruCommunity
//
//  Created by Amitesh Mani Tiwari on 24/05/24.
//

import RealmSwift

class MemberViewModel {
    var members: Results<Member> {
        return RealmService.shared.fetchMembers()
    }
    
    func addMember(fullName: String, email: String) {
        let member = Member()
        member.fullName = fullName
        member.email = email
        RealmService.shared.add(member)
    }
    
    func deleteMember(member: Member) {
        RealmService.shared.delete(member)
    }
    
    func updateMember(member: Member, fullName: String, email: String) {
        RealmService.shared.update {
            member.fullName = fullName
            member.email = email
        }
    }
    
    // Fetch recent members for the last year
    func fetchRecentMembers() -> Results<Member> {
        return RealmService.shared.fetchRecentMembers()
    }
}



