//
//  MassMessageViewController.swift
//  Apex Baseball
//
//  Created by Daniel Ydens on 10/7/20.
//  Copyright © 2020 Daniel Ydens. All rights reserved.
//

import UIKit
import FirebaseFirestore

class MassMessageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var massMessagesTableView: UITableView!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    let db = Firestore.firestore()
    var reminders :  [Reminder] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "ErasITC-Medium", size: 15)!], for: UIControl.State.normal)
        massMessagesTableView.delegate = self
        massMessagesTableView.dataSource = self
        massMessagesTableView.register(UINib(nibName: "MassMessagesTableViewCell", bundle: nil), forCellReuseIdentifier: "MassMessagesTableViewCell")
        getReminders()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
    self.navigationController?.popViewController(animated: true)
    }
    func getReminders() {
        db.collection("massCommunication").order(by: "timeStamp").getDocuments { (snapshot, error) in
            if error != nil {
                print(error!)
                return
            }
            else{
                self.reminders.removeAll()
                for document in snapshot!.documents.reversed(){
                    let reminder = Reminder()
                    if let message = document.get("message") as? String {
                        reminder.message = message
                    }
                    if let title = document.get("title") as? String {
                        reminder.title = title
                    }
                    if let timeStamp = document.get("timeStamp") as? Int {
                        reminder.time = timeStamp
                    }
                    self.reminders.append(reminder)
                }
                self.massMessagesTableView.reloadData()
                //self.scrollToBottom()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.massMessagesTableView.setEmptyMessage("No current reminders. Check back later for more.")
        return reminders.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = massMessagesTableView.dequeueReusableCell(withIdentifier: "MassMessagesTableViewCell", for: indexPath) as! MassMessagesTableViewCell
        print("title: ", reminders[indexPath.row].title)
        cell.titleLabel.text = reminders[indexPath.row].title
        
        cell.messageLabel.text = reminders[indexPath.row].message
        
        let timeNum = Double(reminders[indexPath.row].time)
        let date = Date(timeIntervalSince1970: timeNum)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = .current
        let localDate = dateFormatter.string(from: date)
        cell.dateLabel.text = localDate
        
        
        
        return cell
    }
    
//    func scrollToBottom(){
//        DispatchQueue.main.async {
//         let indexPath = IndexPath(row: self.reminders.count-1, section: 0)
//         self.massMessagesTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//        }
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
