//
//  ViewController.swift
//  Local Notifications Lab
//
//  Created by Tsering Lama on 2/20/20.
//  Copyright © 2020 Tsering Lama. All rights reserved.
//

import UIKit
import UserNotifications

class MainVC: UIViewController {
    
    @IBOutlet weak var tableVIew: UITableView!
    
    private var notifications = [UNNotificationRequest]() {
        didSet {
            DispatchQueue.main.async {
                self.tableVIew.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableVIew.dataSource = self
        center.delegate = self
        getRefresh()
        refreshControl.addTarget(self, action: #selector(loadNotifications), for: .valueChanged)
        checkForAutho()
        loadNotifications()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nvc = segue.destination as? UINavigationController, let createVC = nvc.viewControllers.first as? CreateVC else {
            fatalError()
        }
        createVC.delegate = self
    }
    
    private var refreshControl: UIRefreshControl!
    
    private let pendingNotifications = PendingNotifications()
    
    private let center = UNUserNotificationCenter.current()
    
    private func getRefresh() {
        refreshControl = UIRefreshControl()
        tableVIew.refreshControl = refreshControl
        loadNotifications()
    }
    
    private func checkForAutho() {
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                print("app is authorized")
            } else {
                self.requestNotification()
            }
        }
    }
    
    private func requestNotification() {
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if let error = error {
                print("error requesting authorization: \(error)")
                return
            }
            if granted {
                print("granted")
            } else {
                print("denied")
            }
        }
    }
    
    @objc
    private func loadNotifications() {
        pendingNotifications.getPendingNotifications { (request) in
            self.notifications = request
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }
}

extension MainVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "makeCell", for: indexPath)
        let aNotification = notifications[indexPath.row]
        cell.textLabel?.text = aNotification.content.title
        cell.detailTextLabel?.text = aNotification.content.body
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeNotification(indexPath: indexPath)
        }
    }
    
    private func removeNotification(indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        let identifier = notification.identifier
        // remove from UNNotificationCenter
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        
        // remove from array of notification
        notifications.remove(at: indexPath.row)
        
        // remove from tableview
        tableVIew.deleteRows(at: [indexPath], with: .automatic)
    }
}

extension MainVC: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}

extension MainVC: CreateVCDelegate {
    func didCreate(createVC: CreateVC) {
        loadNotifications()
    }
}

