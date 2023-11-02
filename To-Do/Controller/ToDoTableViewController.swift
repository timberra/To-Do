//
//  ToDoTableViewController.swift
//  To-Do
//
//  Created by liga.griezne on 01/11/2023.
//

import UIKit
import CoreData

class ToDoTableViewController: UITableViewController {

    var managedObjectContext: NSManagedObjectContext?
    var toDoLists = [ToDo]()
    var editingIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        tableView.addGestureRecognizer(longPressGesture)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        managedObjectContext = appDelegate.persistentContainer.viewContext
        loadCoreData()
        self.tableView.isEditing = true
    }
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                editingIndexPath = indexPath
                let alertController = UIAlertController(title: "Edit Task", message: "Edit the task title", preferredStyle: .alert)
                alertController.addTextField { textFieldValue in
                    let toDoList = self.toDoLists[indexPath.row]
                    textFieldValue.text = toDoList.item
                }
                alertController.addTextField { subtextFieldValue in
                    let toDoList = self.toDoLists[indexPath.row]
                    subtextFieldValue.text = toDoList.subitem
                }
                let editActionButton = UIAlertAction(title: "Save", style: .default) { _ in
                    if let textField = alertController.textFields?.first,
                       let subtextField = alertController.textFields?.last,
                       let titleText = textField.text,
                       let subtextText = subtextField.text
                    {
                        self.toDoLists[indexPath.row].item = titleText
                        self.toDoLists[indexPath.row].subitem = subtextText
                        self.saveCoreData()
                        self.tableView.reloadData()
                    }
                }
                let cancelActionButton = UIAlertAction(title: "Cancel", style: .destructive)
                alertController.addAction(editActionButton)
                alertController.addAction(cancelActionButton)
                present(alertController, animated: true)
            }
        }
    }
    @IBAction func addNewItemTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Do To List", message: "Do you want to add new item?", preferredStyle: .alert)
        alertController.addTextField { textFieldValue in
            textFieldValue.placeholder = "Your title here..."
        }
        alertController.addTextField { subtextFieldValue in
            subtextFieldValue.placeholder = "Your subtitle here..."
        }
        let addActionButton = UIAlertAction(title: "Add", style: .default) { addActions in
            let textField = alertController.textFields?.first
            let subtitletextField = alertController.textFields?.last

            let entity = NSEntityDescription.entity(forEntityName: "ToDo", in: self.managedObjectContext!)
            let list = NSManagedObject(entity: entity!, insertInto: self.managedObjectContext)
            list.setValue(textField?.text, forKey: "item")
            list.setValue(subtitletextField?.text, forKey: "subitem")
            self.saveCoreData()
        }
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .destructive)
        alertController.addAction(addActionButton)
        alertController.addAction(cancelActionButton)
        present(alertController, animated: true)
    }
    @IBAction func deleteAllDataTapped(_ sender: Any) {
        let confirmAlert = UIAlertController(title: "Delete All ToDo items", message: "Are you sure you want to delete all item?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteAllCoreData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        confirmAlert.addAction(deleteAction)
        confirmAlert.addAction(cancelAction)
        present(confirmAlert, animated: true)
    }
}

// MARK: - CoreData logic
extension ToDoTableViewController {
    func loadCoreData(){
        let request: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        do {
            let result = try managedObjectContext?.fetch(request)
            toDoLists = result ?? []
            self.tableView.reloadData()
        } catch {
            fatalError("Error in loading item into core data")
        }
    }
    func saveCoreData(){
        do {
            try managedObjectContext?.save()
        } catch {
            fatalError("Error in saving item into core data")
        }
        loadCoreData()
    }
    func deleteAllCoreData(){
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ToDo")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try managedObjectContext?.execute(deleteRequest)
            toDoLists.removeAll()
            self.tableView.reloadData()
        }catch {
            fatalError("Error in deleting all item from core data")
        }
    }
}

// MARK: - Table view data source
extension ToDoTableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoLists.count
    }
    
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "toDoCell", for: indexPath)
        let toDoList = toDoLists[indexPath.row]
                cell.textLabel?.text = toDoList.item
                cell.detailTextLabel?.text = toDoList.subitem
        cell.accessoryType = toDoList.completed ? .checkmark : .none
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        toDoLists[indexPath.row].completed = !toDoLists[indexPath.row].completed
        saveCoreData()
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            managedObjectContext?.delete(toDoLists[indexPath.row])
        }
        saveCoreData()
    }
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedItem = toDoLists.remove(at: sourceIndexPath.row)
        toDoLists.insert(movedItem, at: destinationIndexPath.row)
        
        for (index, task) in toDoLists.enumerated() {
            task.order = Int32(index)
        }
        saveCoreData()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
