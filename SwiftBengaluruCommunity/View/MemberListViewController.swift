//
//  MemberListViewController.swift
//  SwiftBengaluruCommunity
//
//  Created by Amitesh Mani Tiwari on 23/05/24.
//

import UIKit
import RealmSwift

class MemberListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var tableView: UITableView!
    private var viewModel: MemberViewModel!
    private var membersNotificationToken: NotificationToken?
    private var recentMembersNotificationToken: NotificationToken?
    private var recentMembers: Results<Member>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel = MemberViewModel()
        
        observeMembers()
    }
    
    deinit {
        membersNotificationToken?.invalidate()
        recentMembersNotificationToken?.invalidate()
    }
    
    private func setupUI() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMember)),
            UIBarButtonItem(title: "Recent", style: .plain, target: self, action: #selector(showRecentMembers))
        ]
    }
    
    private func observeMembers() {
        membersNotificationToken = viewModel.members.observe { [weak self] changes in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                tableView.beginUpdates()
                tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                tableView.endUpdates()
            case .error(let error):
                fatalError("\(error)")
            }
        }
    }
    
    private func observeRecentMembers() {
        recentMembersNotificationToken = recentMembers?.observe { [weak self] changes in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                tableView.beginUpdates()
                tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                tableView.endUpdates()
            case .error(let error):
                fatalError("\(error)")
            }
        }
    }
    
    @objc private func addMember() {
        let alert = UIAlertController(title: "Add Member", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Full Name" }
        alert.addTextField { $0.placeholder = "Email" }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let fullName = alert.textFields?[0].text, let email = alert.textFields?[1].text else { return }
            self?.viewModel.addMember(fullName: fullName, email: email)
        }
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func showRecentMembers() {
        recentMembersNotificationToken?.invalidate()
        recentMembers = viewModel.fetchRecentMembers()
        observeRecentMembers()
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentMembers?.count ?? viewModel.members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let member: Member
        if let recentMembers = recentMembers {
            member = recentMembers[indexPath.row]
        } else {
            member = viewModel.members[indexPath.row]
        }
        cell.textLabel?.text = member.fullName
        cell.detailTextLabel?.text = member.email
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let member: Member
            if let recentMembers = recentMembers {
                member = recentMembers[indexPath.row]
            } else {
                member = viewModel.members[indexPath.row]
            }
            viewModel.deleteMember(member: member)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let member: Member
        if let recentMembers = recentMembers {
            member = recentMembers[indexPath.row]
        } else {
            member = viewModel.members[indexPath.row]
        }
        let alert = UIAlertController(title: "Update Member", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.text = member.fullName }
        alert.addTextField { $0.text = member.email }
        
        let updateAction = UIAlertAction(title: "Update", style: .default) { [weak self] _ in
            guard let fullName = alert.textFields?[0].text, let email = alert.textFields?[1].text else { return }
            self?.viewModel.updateMember(member: member, fullName: fullName, email: email)
            // Reload table view to reflect the changes immediately
            self?.tableView.reloadData()
        }
        alert.addAction(updateAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
