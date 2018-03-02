//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Henry on 03/03/2018.
//  Copyright © 2018 Henry Huang. All rights reserved.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    
    var categoryies = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategoryies() //use defalut value to fetch data
    }

    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categoryies[indexPath.row].name
        
        return cell
    }
    
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //perform segue
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destinationVC = segue.destination as? TodoListViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedCategory = categoryies[indexPath.row]
            }
        }
    }
    
    
    // MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) {
            (action) in
            //waht will happen once the user clicks the Add Item button on UIAlert Button
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            self.categoryies.append(newCategory)
            
            self.saveCategoryies()
        }
        
        //only trigger when user press the button, so can't get data from alertTextField directly
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add New Category"
            textField = alertTextField
        }
        
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    //MARK: - Model Manupulation Methods
    func saveCategoryies() {
        
        do {
            try context.save()
        } catch {
            //writing wrong
            print("Error saving Categoryies \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategoryies(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        
        do {
            categoryies = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
        
    }

  
    
}
