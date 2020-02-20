//
//  CreateVC.swift
//  Local Notifications Lab
//
//  Created by Tsering Lama on 2/20/20.
//  Copyright © 2020 Tsering Lama. All rights reserved.
//

import UIKit

protocol CreateVCDelegate: AnyObject {
    func didCreate(createVC: CreateVC)
}

class CreateVC: UIViewController {
    
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    
    weak var delegate: CreateVCDelegate?
    
    private var userSeconds = 0.0
    
    private var timeInterval: TimeInterval = Date().timeIntervalSinceNow
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    var hour: Int = 0
    var minutes: Int = 0
    var seconds: Int = 0
    
    private func createNotification() {
        let content = UNMutableNotificationContent()
        content.title = titleText.text ?? "No title"
        content.body = "Local Notification"
        content.sound = .default
        
        let identifier = UUID().uuidString
        
        if let imageURL = Bundle.main.url(forResource: "apple", withExtension: "png") {
            do {
                let attachment = try UNNotificationAttachment(identifier: identifier, url: imageURL, options: nil)
                content.attachments = [attachment]
            } catch {
                print(error)
            }
        } else {
            print("no image found")
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval + userSeconds, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print(error)
            } else {
                print("request was added")
            }
        }
    }
    
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        createNotification()
        delegate?.didCreate(createVC: self)
        dismiss(animated: true)
    }
}

extension CreateVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // https://stackoverflow.com/questions/47844460/how-have-hourminutesseconds-in-date-picker-swift

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 25
        case 1, 2:
            return 60
        default:
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerView.frame.size.width/3
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(row) Hr"
        case 1:
            return "\(row) Min"
        case 2:
            return "\(row) Sec"
        default:
            return ""
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            hour = row
            userSeconds += Double(row) * 3600
            print(row)
        case 1:
            minutes = row
            userSeconds += Double(row) * 60
        case 2:
            seconds = row
            userSeconds += Double(row) * 1
        default:
            break;
        }
    }
}
