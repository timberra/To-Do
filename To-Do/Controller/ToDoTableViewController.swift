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
    private var cellID = "toDoCell"
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/YY HH:mm"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        managedObjectContext = appDelegate.persistentContainer.viewContext
        loadCoreData()
        setupView()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc func addNewItem(){
        print("clicked")
        let alertController = UIAlertController(title: "To Do List", message: "Do you want to add new item?", preferredStyle: .alert)
        alertController.addTextField { textFieldValue in
            textFieldValue.placeholder = "Your title here..."
            print(textFieldValue)
        }
        
        
        let addActionButton = UIAlertAction(title: "Add", style: .default) { addActions in
            let textField = alertController.textFields?.first
            
            let entity = NSEntityDescription.entity(forEntityName: "ToDo", in: self.managedObjectContext!)
            let list = NSManagedObject(entity: entity!, insertInto: self.managedObjectContext)
            
            list.setValue(textField?.text, forKey: "item")
            self.saveCoreData()
        }
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .destructive)
        
        alertController.addAction(addActionButton)
        alertController.addAction(cancelActionButton)
        present(alertController, animated: true)
    
    }
    
//    @objc func deleteAll() {
//        let alertController = UIAlertController(title: "To Do list", message: "Do you want to delete all core data?", preferredStyle: .alert)
//        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
//                    self.refreshData()
//                }
//                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//                alertController.addAction(deleteAction)
//                alertController.addAction(cancelAction)
//                present(alertController, animated: true)
//        }
    
    @objc func longPress(sender: UILongPressGestureRecognizer){
        if sender.state == UIGestureRecognizer.State.began {
            let touchPath = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPath){
                let currentDate = dateFormatter.string(from: Date())
                print(indexPath)
                basicActionSheet(title: toDoLists[indexPath.row].item, message: "Created: \(currentDate)")
            }
        }
    }
        
    private func setupView() {
        view.backgroundColor = .secondarySystemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
            
        let addBarButtonItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addNewItem))
            self.navigationItem.rightBarButtonItem  = addBarButtonItem
            
        let openBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openNewView))
            self.navigationItem.leftBarButtonItem = openBarButtonItem
            
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
            view.addGestureRecognizer(longPressRecognizer)
   
        setupNavigationBarView()
    }
     
    @objc func openNewView() {
        let newViewController = NewViewController()
        navigationController?.pushViewController(newViewController, animated: true)

    }
    
    private func setupNavigationBarView() {
        title = "To Do"
        let titleImage = UIImage(systemName: "bag.badge.plus")
        let imageView = UIImageView(image: titleImage)
        self.navigationItem.titleView = imageView
            
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.label]
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .label
    }
}

extension UITableView {
    func setEmptyView(title: String, message: String) {
            
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
            
        let titleLabel = UILabel()
        let messageLabel = UILabel()
            
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
            
        titleLabel.textColor = UIColor.label
        titleLabel.font = UIFont(name: "Futura-Bold", size: 18)
            
        messageLabel.textColor = UIColor.secondaryLabel
        messageLabel.font = UIFont(name: "Kefa", size: 16)
            
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
            
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
            
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 0).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: 0).isActive = true
            
        titleLabel.text = title
        messageLabel.text = message
            
        messageLabel.numberOfLines = 2
        messageLabel.textAlignment = .center
            
        self.backgroundView = emptyView
            
    }
        
    func restoreTableViewStyle(){
        self.backgroundView = nil
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

@objc func refreshData() {let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ToDo")
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    do {
        try managedObjectContext?.execute(deleteRequest)
        toDoLists.removeAll()
        self.tableView.reloadData()
    }catch {
        fatalError("Error in deleting all item from core data")
    }
}

func basicActionSheet(title: String?, message: String?) {
    let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
    
    actionSheet.overrideUserInterfaceStyle = .dark
    actionSheet.addAction(cancelAction)
    self.present(actionSheet, animated: true)
}

}

// MARK: - Table view data source
extension ToDoTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if toDoLists.count == 0 {
            tableView.setEmptyView(title: "Your To Do is Empty", message: "Please press Add to create a new to do item")
        } else {
            tableView.restoreTableViewStyle()
        }
        
        return toDoLists.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let toDoList = toDoLists[indexPath.row]
        cell.textLabel?.text = toDoList.item
        cell.accessoryType = toDoList.completed ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        toDoLists[indexPath.row].completed = !toDoLists[indexPath.row].completed
        saveCoreData()
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            managedObjectContext?.delete(toDoLists[indexPath.row])
        }
        saveCoreData()
    }
    
}



//    var managedObjectContext: NSManagedObjectContext?
//    var toDoLists = [ToDo]()
//    var editingIndexPath: IndexPath?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
//        tableView.addGestureRecognizer(longPressGesture)
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
//        managedObjectContext = appDelegate.persistentContainer.viewContext
//        loadCoreData()
//        self.tableView.isEditing = true
//    }
//    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
//        if gestureRecognizer.state == .began {
//            let touchPoint = gestureRecognizer.location(in: tableView)
//            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
//                editingIndexPath = indexPath
//                let alertController = UIAlertController(title: "Edit Task", message: "Edit the task title", preferredStyle: .alert)
//                alertController.addTextField { textFieldValue in
//                    let toDoList = self.toDoLists[indexPath.row]
//                    textFieldValue.text = toDoList.item
//                }
//                alertController.addTextField { subtextFieldValue in
//                    let toDoList = self.toDoLists[indexPath.row]
//                    subtextFieldValue.text = toDoList.subitem
//                }
//                let editActionButton = UIAlertAction(title: "Save", style: .default) { _ in
//                    if let textField = alertController.textFields?.first,
//                       let subtextField = alertController.textFields?.last,
//                       let titleText = textField.text,
//                       let subtextText = subtextField.text
//                    {
//                        self.toDoLists[indexPath.row].item = titleText
//                        self.toDoLists[indexPath.row].subitem = subtextText
//                        self.saveCoreData()
//                        self.tableView.reloadData()
//                    }
//                }
//                let cancelActionButton = UIAlertAction(title: "Cancel", style: .destructive)
//                alertController.addAction(editActionButton)
//                alertController.addAction(cancelActionButton)
//                present(alertController, animated: true)
//            }
//        }
//    }
//    @IBAction func addNewItemTapped(_ sender: Any) {
//        let alertController = UIAlertController(title: "Do To List", message: "Do you want to add new item?", preferredStyle: .alert)
//        alertController.addTextField { textFieldValue in
//            textFieldValue.placeholder = "Your title here..."
//        }
//        alertController.addTextField { subtextFieldValue in
//            subtextFieldValue.placeholder = "Your subtitle here..."
//        }
//        let addActionButton = UIAlertAction(title: "Add", style: .default) { addActions in
//            let textField = alertController.textFields?.first
//            let subtitletextField = alertController.textFields?.last
//
//            let entity = NSEntityDescription.entity(forEntityName: "ToDo", in: self.managedObjectContext!)
//            let list = NSManagedObject(entity: entity!, insertInto: self.managedObjectContext)
//            list.setValue(textField?.text, forKey: "item")
//            list.setValue(subtitletextField?.text, forKey: "subitem")
//            self.saveCoreData()
//        }
//        let cancelActionButton = UIAlertAction(title: "Cancel", style: .destructive)
//        alertController.addAction(addActionButton)
//        alertController.addAction(cancelActionButton)
//        present(alertController, animated: true)
//    }
//    @IBAction func deleteAllDataTapped(_ sender: Any) {
//        let confirmAlert = UIAlertController(title: "Delete All ToDo items", message: "Are you sure you want to delete all item?", preferredStyle: .alert)
//        
//        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
//            self.deleteAllCoreData()
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        confirmAlert.addAction(deleteAction)
//        confirmAlert.addAction(cancelAction)
//        present(confirmAlert, animated: true)
//    }
//}
//
//// MARK: - CoreData logic
//extension ToDoTableViewController {
//    func loadCoreData(){
//        let request: NSFetchRequest<ToDo> = ToDo.fetchRequest()
//        do {
//            let result = try managedObjectContext?.fetch(request)
//            toDoLists = result ?? []
//            self.tableView.reloadData()
//        } catch {
//            fatalError("Error in loading item into core data")
//        }
//    }
//    func saveCoreData(){
//        do {
//            try managedObjectContext?.save()
//        } catch {
//            fatalError("Error in saving item into core data")
//        }
//        loadCoreData()
//    }
//    func deleteAllCoreData(){
//        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ToDo")
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//        do {
//            try managedObjectContext?.execute(deleteRequest)
//            toDoLists.removeAll()
//            self.tableView.reloadData()
//        }catch {
//            fatalError("Error in deleting all item from core data")
//        }
//    }
//}
//
//// MARK: - Table view data source
//extension ToDoTableViewController {
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return toDoLists.count
//    }
//    
// 
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "toDoCell", for: indexPath)
//        let toDoList = toDoLists[indexPath.row]
//                cell.textLabel?.text = toDoList.item
//                cell.detailTextLabel?.text = toDoList.subitem
//        cell.accessoryType = toDoList.completed ? .checkmark : .none
//        return cell
//    }
// 
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        toDoLists[indexPath.row].completed = !toDoLists[indexPath.row].completed
//        saveCoreData()
//    }
//    /*
//    // Override to support conditional editing of the table view.
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable.
//        return true
//    }
//    */
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // Delete the row from the data source
//            managedObjectContext?.delete(toDoLists[indexPath.row])
//        }
//        saveCoreData()
//    }
//    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the item to be re-orderable.
//        return true
//    }
//    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        let movedItem = toDoLists.remove(at: sourceIndexPath.row)
//        toDoLists.insert(movedItem, at: destinationIndexPath.row)
//        
//        for (index, task) in toDoLists.enumerated() {
//            task.order = Int32(index)
//        }
//        saveCoreData()
//    }
//    
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//}

