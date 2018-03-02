//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    
    // Declare instance variables
    var messageArray: [Message] = [Message]()   //create a empty array
    
    
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the delegate and datasource
        messageTableView.delegate = self
        messageTableView.dataSource = self

        //Set the delegate of the text field
        messageTextfield.delegate = self
        
        
        //Set the tapGesture
        let tapGesture = UITapGestureRecognizer(target: self, action:
            #selector(tableViewTapped)
        )
        messageTableView.addGestureRecognizer(tapGesture)
        
        //Register MessageCell.xib file
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil) , forCellReuseIdentifier: "customMessageCell")
        
        //declare the tableview size
        configureTableView()
        
        //put the message to the tableView
        retrieveMessages()
        
        //delete the Tableview line
        messageTableView.separatorStyle = .none
    }

    
    
    //MARK: - TableView DataSource Methods
    ///////////////////////////////////////////
    
    
    //Declare cellForRowAtIndexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
            
        //let messageArray = ["First Message", "Second Message", "Third Message"]
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        //seperate the mesaage background color
        if cell.senderUsername.text == Auth.auth().currentUser?.email as String! {
            //Message We sent
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
        } else {
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        }
        
        
        return cell
        
        
    }
    
    
    //Declare numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    
    //Declare tableViewTapped
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    
    
    //Declare configureTableView
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    
    
    
    //MARK:- TextField Delegate Methods
    ///////////////////////////////////////////
    

    
    //Declare textFieldDidBeginEditing
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //have the animation to layout
        UIView.animate(withDuration: 0.5, animations: {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        })
    }
    
    
    
    //Declare textFieldDidEndEditing
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //have the animation to layout
        UIView.animate(withDuration: 0.5, animations: {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        })
    }

    
    
    //MARK: - Send & Recieve from Firebase
    ///////////////////////////////////////////
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        //close keyboard
        messageTextfield.endEditing(true)
        
        //Send the message to Firebase and save it in our database
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let messageDB = Database.database().reference().child("Messages")
        
        let messageDicitionary = ["Sender": Auth.auth().currentUser?.email,
                                  "MessageBody": messageTextfield.text!]
        
        messageDB.childByAutoId().setValue(messageDicitionary) {
            (error, reference) in
            
            if error != nil {
                print("error!")
            } else {
                //success save the message
                
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text! = ""
            }
            
        }
        
    }
    
    //TODO: Create the retrieveMessages method here:
    
    func retrieveMessages() {
        
        let messageDB = Database.database().reference().child("Messages")
        
        messageDB.observe(.childAdded) { (snapshot) in
            let snapShotValue = snapshot.value as! Dictionary<String, String>
            
            let text = snapShotValue["MessageBody"]!
            let sender = snapShotValue["Sender"]!
            
            let message = Message()
            message.messageBody = text
            message.sender = sender
            
            self.messageArray.append(message)
            
            //reload the message to tableView
            self.configureTableView()
            self.messageTableView.reloadData()
        }
        
    }

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //Log out the user and send them back to WelcomeViewController
        do {
            try Auth.auth().signOut()
            //go back to register controller
            navigationController?.popToRootViewController(animated: true)
        }
        catch {
            print("Error, There was a problem singing out.")
        }
        
    }
    


}
