//
//  ViewController.swift
//  Today
//
//  Created by Grisha Borodavka on 16/01/2024.
//
import UIKit
import CoreData
class ToDoList: UITableViewController  {
    
    var itemArray  = [ToDo]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory : Category?{
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
     super.viewDidLoad()
        
        searchBar.delegate = self
       
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
        let cell = tableView.dequeueReusableCell(withIdentifier:"ToDoItemCell", for:indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        
        // value = condittion ? true : false
        cell.accessoryType = itemArray[indexPath.row].done  ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
        saveData()
        //make beutiful animation
        tableView.deselectRow(at: indexPath, animated: true )
    }
   
    @IBAction func AddButton(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        //make alert
        let alert = UIAlertController(title: "Add new ToDoey", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) { action in
            
            let newItem = ToDo(context: self.context)
            newItem.done = false
            newItem.title = textField.text!
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
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
       return  itemArray.count // get how many rows we have
    }
        
    func loadItems(with request : NSFetchRequest<ToDo> = ToDo.fetchRequest(), predicate: NSPredicate? = nil ){
      
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@" , selectedCategory!.name!)
        
        if let addtionalPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,addtionalPredicate])
        }else{
            request.predicate = categoryPredicate
        }
        
        do{
            //try to get array of ToDo
            //data from context and type is from request
           itemArray = try context.fetch(request)
        }
        catch{
            print("problem is \(error)")
        }
        tableView.reloadData()
    }
}
extension ToDoList :  UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       
        let request = ToDo.fetchRequest()
        
      let predicate = NSPredicate(format:"title CONTAINS[cd] %@" ,searchBar.text! )
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
      loadItems(with: request,predicate: predicate)

    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
          
        }
    }
}

