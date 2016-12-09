//
//  ContactViewController.swift
//  pseat3
//
//  Created by Tae Gyu Park on 11/6/16.
//  Copyright © 2016  UNO. All rights reserved.
//


import UIKit
import Contacts
import ContactsUI


protocol ContactViewControllerDelegate {
    func didFetchContacts(contacts: [CNContact])
}


class ContactViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, CNContactPickerDelegate {
    
   
    
    var currentlySelectedMonthIndex = 1
    
    var delegate: ContactViewControllerDelegate!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "performDoneItemTap")
        navigationItem.rightBarButtonItem = doneBarButtonItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: IBAction functions
    
    @IBAction func showContacts(sender: AnyObject) {
        let contactPickerViewController = CNContactPickerViewController()
        
        contactPickerViewController.predicateForEnablingContact = NSPredicate(format: "birthday != nil")
        
        contactPickerViewController.delegate = self
        
        presentViewController(contactPickerViewController, animated: true, completion: nil)
    }
    
    
    // MARK: UIPickerView Delegate and Datasource functions
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentlySelectedMonthIndex = row + 1
    }
    
    // MARK: CNContactPickerDelegate function
    
    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {
        delegate.didFetchContacts([contact])
        navigationController?.popViewControllerAnimated(true)
    }
    
}
