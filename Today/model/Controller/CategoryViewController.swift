//
//  CategoryViewController.swift
//  Today
//
//  Created by Grisha Borodavka on 28/01/2024.
//

import UIKit
import CoreData
class CategoryViewController: UITableViewController {
    
    var categoryArray  = [Category]()
   
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategorys()
    }
    
    func saveData(){
          do{
              //save in core data
              try context.save()
          }catch{
            print("the problem is \(error)")
          }
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //create a cell
        let cell = tableView.dequeueReusableCell(withIdentifier:"CategoryCell", for:indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        

        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       performSegue(withIdentifier: "goToItems", sender: self)
       // context.delete(categoryArray[indexPath.row])
       // categoryArray.remove(at: indexPath.row)
        
        //make beutiful animation
        tableView.deselectRow(at: indexPath, animated: true )
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems" {
            let destinationVC = segue.destination as! ToDoList
            
            if let indexPath = tableView.indexPathForSelectedRow{
                destinationVC.selectedCategory = categoryArray[indexPath.row]
            }
        }
    }
    
    @IBAction func AddPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        //make alert
        let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { action in
            
            let newItem = Category(context: self.context)
            newItem.name = textField.text!
            
            self.categoryArray.append(newItem)
            self.saveData()
        }
       
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert,animated: true,completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return  categoryArray.count // get how many rows we have
    }
    func loadCategorys(with request : NSFetchRequest<Category> = Category.fetchRequest()){
        do{
            //try to get array of ToDo
            //data from context and type is from request
            categoryArray = try context.fetch(request)
        }
        catch{
            print("problem is \(error)")
        }
        tableView.reloadData()
    }

}
