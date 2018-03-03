//
//  ViewController.swift
//  Todoey
//
//  Created by Henry on 02/03/2018.
//  Copyright © 2018 Henry Huang. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory: Category? {
        //trigger when get the value
        didSet {
            loadItems() //use defalut value to fetch data
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = selectedCategory!.name

        guard let colourHex = selectedCategory?.colour else {
            fatalError("colourHex does not exist.")
        }
            
       updateNavBar(withHexCode: colourHex)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateNavBar(withHexCode: "1D9BF6")
        
    }
    
    //MARK: - Nave Bar Setup Methods
    
    func updateNavBar(withHexCode colourHexCode: String) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist.")
        }
        
        guard let navBarColor = UIColor(hexString: colourHexCode) else {
            fatalError()
        }
        
        navBar.barTintColor = navBarColor
        
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
        
        searchBar.barTintColor = navBarColor
    }
    
    //MARK: - Tableview Datasource Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            //Ternay operator
            cell.accessoryType = item.done ? .checkmark : .none
            
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage:CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                //set the background Color
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            

        } else {
            cell.textLabel?.text = "No Item Added"
        }
        
        return cell
    }
    
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saveing done status. \(error)")
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)    //make the select gray animated dismiss
        
        
        tableView.reloadData()
    }
    
    
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) {
            (action) in
            //waht will happen once the user clicks the Add Item button on UIAlert Button
            
            //save the item directly to the database
            if let currentCategory = self.selectedCategory {
                
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.done = false
                        newItem.dataCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    //writing wrong
                    print("Error saving Categoryies \(error)")
                }
                
                self.tableView.reloadData()
            }
            
           
        }
        
        //only trigger when user press the button, so can't get data from alertTextField directly
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Model Manupulation Methods
    
    func loadItems() {
        
        if todoItems?.count != 0 {
            todoItems = selectedCategory?.items.sorted(byKeyPath: "dataCreated", ascending: false)
            tableView.reloadData()
        }
        
    }
    
    //MARK: - Delete date from Swipe
    override func updateModel(at indexPath: IndexPath) {
        
        if let itemForDeletion = self.todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(itemForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }
    
    
}

//MARK: - searchBar methods

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // filter the todoitems and realm will auto update data
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dataCreated", ascending: true)
        
        tableView.reloadData()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            
            //show back original lists
            loadItems()
            
            DispatchQueue.main.async {
                //show off the keyboard
                searchBar.resignFirstResponder()
            }
        }
    }
    

}


