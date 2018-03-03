//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Henry on 03/03/2018.
//  Copyright © 2018 Henry Huang. All rights reserved.
//

import UIKit
import SwipeCellKit

//MARK: - Swipe Cell Delegate Methods


class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //make sure height is adequate for delete button
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
    }
    
    //MARK: - TableView DataSources Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        return cell
    }
    

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            
            self.updateModel(at: indexPath)
            
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "Delete-Icon")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
    func updateModel(at indexPath: IndexPath) {
        //update the data model
    }

}
