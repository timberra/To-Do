//
//  NewViewController.swift
//  To-Do
//
//  Created by liga.griezne on 05/11/2023.
//

import UIKit
import CoreData
class NewViewController: UIViewController {
    var managedObjectContext: NSManagedObjectContext?
    var toDoLists = [ToDo]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .green
        
        let label = UILabel()
        label.text = "This is the second view"
        label.frame = CGRect(x: 100, y: 200, width: 200, height: 40)
        view.addSubview(label)
        
        let deleteAllButton = UIBarButtonItem(title: "Delete All", style: .plain, target: self, action: #selector(deleteAllData))
        navigationItem.rightBarButtonItems = [deleteAllButton]
            }
        
    @objc func deleteAllData() {
        
        let contex = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDo")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try contex.execute(deleteRequest)
            try contex.save()
            print("All data deleted successfully")
            
            if let ToDoTableViewController = self.navigationController?.viewControllers.first as? ToDoTableViewController {
                ToDoTableViewController.refreshData()
            }
        } catch {
            print("Error")
        }
        
        
    

        
     

        // Do any additional setup after loading the view.
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
