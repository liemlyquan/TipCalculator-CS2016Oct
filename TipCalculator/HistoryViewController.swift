//
//  HistoryViewController.swift
//  TipCalculator
//
//  Created by Liem Ly Quan on 9/29/16.
//  Copyright © 2016 liemlyquan. All rights reserved.
//
import CoreData
import UIKit

class HistoryViewController: UITableViewController {
    var billList = [NSManagedObject]()
    var managedContext: NSManagedObjectContext = NSManagedObjectContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initData(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Bill")
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            billList = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return billList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HistoryTableViewCell", forIndexPath: indexPath) as! HistoryTableViewCell
        let amount = billList[indexPath.row].valueForKey("amount")?.floatValue
        guard let amountUnwrapped = amount as Float! else {
            return cell
        }
        let tipPercent = billList[indexPath.row].valueForKey("tipPercent")?.floatValue
        guard let tipPercentUnwrapped = tipPercent as Float! else {
            return cell
        }
        
        let numberOfPeople = billList[indexPath.row].valueForKey("numberOfPeople")?.integerValue
        guard let numberOfPeopleUnwrapped = numberOfPeople as Int! else {
            return cell
        }
        
        let total = amountUnwrapped * Float(1 + tipPercentUnwrapped / 100.0)
        let titleText = "$\(total)"
        let subtitleText = "The bill amount is \(amountUnwrapped)\n" +
                    "Tipped \(tipPercentUnwrapped)%\n" +
                    "Shared by \(numberOfPeopleUnwrapped) people"
        
        cell.cellTitleLabel.text = titleText
        cell.cellSubtitleLabel.text = subtitleText
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete){
            managedContext.deleteObject(billList[indexPath.row])
            billList.removeAtIndex(indexPath.row)
            tableView.reloadData()
        }
    }
}
