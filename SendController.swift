//
//  SendController.swift
//  pseat3
//
//  Created by Tae Gyu Park on 11/9/16.
//  Copyright © 2016  UNO. All rights reserved.
//
//
//  SendController.swift
//  pseat3
//
//  Created by Tae Gyu Park on 11/7/16.
//  Copyright © 2016  UNO. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import MessageUI

protocol SendControllerDelegate {
    func didFetchContacts(contacts: [CNContact])
}

class SendController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, CNContactPickerDelegate, MFMessageComposeViewControllerDelegate  {
    
    var delegate: SendControllerDelegate!
    
 
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var addr: UITextView!
    
    var feedItems: NSMutableArray = NSMutableArray() // for name
    var phoneNumberList: NSMutableArray = NSMutableArray() // for phoneNumber
    
    var pName: String!
    var pAddr: String!
    
    var contacts = [CNContact]()
    
    @IBOutlet weak var listTableView: UITableView!
    
    override func viewDidLoad() {
        
        self.navigationController!.navigationBar.tintColor = UIColor.blackColor();
        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor();
        
        super.viewDidLoad()
        name.text = pName
        addr.text = pAddr
        
        self.listTableView.dataSource = self
        self.listTableView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func showContacts(sender: AnyObject) {
        let contactPickerViewController = CNContactPickerViewController()
        contactPickerViewController.delegate = self
        presentViewController(contactPickerViewController, animated: true, completion: nil)
        //navigationController?.presentViewController(contactPickerViewController, animated: true, completion: nil)
        example5()
    }
    
    //allows multiple selection mixed with contactPicker:didSelectContacts:
    func example5(){
        let controller = CNContactPickerViewController()
        controller.delegate = self
        navigationController?.presentViewController(controller,animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of feed items
        return feedItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier: String = "Cell"
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
        cell.textLabel!.text = feedItems[indexPath.row] as! String
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow!;
        let currentCell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell!;
    }
    
    //for delete
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    //for delete
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            feedItems.removeObjectAtIndex(indexPath.row)
            phoneNumberList.removeObjectAtIndex(indexPath.row)
            self.listTableView.reloadData()
        }
    }
    
    func itemsDownloaded(items: NSMutableArray) {
        self.listTableView.reloadData()
    }
    
    func contactPicker(picker: CNContactPickerViewController, didSelectContacts contacts: [CNContact]) {
        print("Selected \(contacts.count) contacts")
        
        contacts.forEach {
            contact in
            for number in contact.phoneNumbers {
                if contact.familyName=="" {
                    feedItems.addObject(contact.givenName)
                }else if contact.familyName != ""{
                    feedItems.addObject(contact.familyName+contact.givenName)
                }
                let phoneNumber = (number.value as! CNPhoneNumber).valueForKey("digits") as! String
                phoneNumberList.addObject(phoneNumber)
            }
        }
        for element in feedItems{
            print(element, terminator : " ")
        }
        for element in phoneNumberList{
            print(element, terminator : " ")
        }
        itemsDownloaded(feedItems)
    }
    
   
    
    @IBAction func sendText(sender: UIButton) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            //보낼 메세지 문구
            controller.body = pName + ", " + pAddr
            let sendArray = NSArray(array: phoneNumberList) as? [String]
            controller.recipients = sendArray
            controller.messageComposeDelegate = self
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}