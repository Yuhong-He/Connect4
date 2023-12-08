//
//  TableViewController.swift
//  Connect4
//
//  Created by Yuhong He on 06/12/2023.
//

import UIKit
import CoreData
import Alpha0C4

// MARK: - NSFetchedResultsController

class TableViewController: UITableViewController
{
    var fetchedResultsController: NSFetchedResultsController<CoreDataSession>!
     
    func initializeFetchedResultsController() {
        let request = NSFetchRequest(entityName: "CoreDataSession") as! NSFetchRequest<CoreDataSession>
        let timestampSort = NSSortDescriptor(key: "timestamp", ascending: false)
        request.sortDescriptors = [timestampSort]
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let moc = appDelegate.persistentContainer.viewContext

        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do { try fetchedResultsController.performFetch() }
        catch { fatalError("Failed to initialize FetchedResultsController: \(error)") }
    }
    
    @IBAction func deleteAll(_ sender: Any) {
        confirmDeleteMsg(title: "Delete All", message: "Confirm delete all records?") {
            if let allItems = self.fetchedResultsController.fetchedObjects?.enumerated() {
                for (_,item) in allItems {
                    let moc = item.managedObjectContext
                    moc?.delete(item)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFetchedResultsController()
    }
}

// MARK: - Data Source

extension TableViewController {

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryItemView", for: indexPath) as! HistoryItemView

        // Set up the cell
        guard let sessionItem = self.fetchedResultsController?.object(at: indexPath) else {
            fatalError("Attempt to configure cell without a managed object")
        }
        cell.contentView.backgroundColor = indexPath.row % 2 == 0 ? .white : UIColor.lightGray.withAlphaComponent(0.5)
        cell.startLabel.text = sessionItem.botIsFirst ? "Bot starts" : "User starts"
        cell.startLabel.textColor = sessionItem.botIsFirst ? botDiscContentColor : userDiscBorderColor
        cell.startLabel.font = UIFont(name: "AmericanTypewriter-Bold", size: 20.0)
        if sessionItem.discCount == 42 {
            cell.winnerLabel.text = "Draw"
            cell.winnerLabel.textColor = .black
        } else if sessionItem.botIsFirst { // bot start
            if sessionItem.discCount % 2 == 0 {
                cell.winnerLabel.text = "User wins!"
                cell.winnerLabel.textColor = userDiscBorderColor
            } else {
                cell.winnerLabel.text = "Bot wins!"
                cell.winnerLabel.textColor = botDiscContentColor
            }
        } else { // user start
            if sessionItem.discCount % 2 == 0 {
                cell.winnerLabel.text = "Bot wins!"
                cell.winnerLabel.textColor = botDiscContentColor
            } else {
                cell.winnerLabel.text = "User wins!"
                cell.winnerLabel.textColor = userDiscBorderColor
            }
        }
        cell.winnerLabel.font = UIFont(name: "AmericanTypewriter-Bold", size: 20.0)
        gameboardPreview(sessionItem: sessionItem, cell: cell)
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            confirmDeleteMsg(title: "Delete", message: "Confirm delete") {
                if let item = self.fetchedResultsController?.object(at: indexPath), let moc = item.managedObjectContext {
                    moc.delete(item)
                }
            }
        }
    }
    
    func gameboardPreview(sessionItem: CoreDataSession, cell: HistoryItemView)  {
        let gameBoardView = cell.gameBoardView!
        let maskShapeLayer = cell.maskShapeLayer
        //Since cells are reused, it is important to remove the last
        maskShapeLayer.removeFromSuperlayer()
        maskShapeLayer.frame = gameBoardView.bounds
        
        let itemW = (gameBoardView.bounds.width) / 7.0
        let itemH = (gameBoardView.bounds.height) / 6.0
        let discW = itemW - 4
        let discH = itemH - 4
        var subMaskShapeLayerList = [CAShapeLayer]()
        for i in 0 ..< 42 {
            let subMaskShapeLayer = CAShapeLayer()
            let rect = CGRect(x: 2 + itemW * Double((i % 7)), y: 2 + itemH * Double(i / 7), width: discW, height: discH)
            let discPath = UIBezierPath(roundedRect: rect, cornerRadius: discW / 2.0)
            subMaskShapeLayer.path = discPath.cgPath
            subMaskShapeLayer.fillColor = UIColor.white.cgColor // disc background color is white (no disc on the hole)
            maskShapeLayer.addSublayer(subMaskShapeLayer)
            subMaskShapeLayerList.append(subMaskShapeLayer)
        }
        // Get disc position data
        if let discs = sessionItem.discs?.objectEnumerator().allObjects as? [CoreDataDisc]{
            var firstPlayerColor: UIColor!
            var secondPlayerColor: UIColor!
            (firstPlayerColor, secondPlayerColor) = sessionItem.botIsFirst ? (botDiscContentColor, userDiscContentColor) : (userDiscContentColor, botDiscContentColor)
            for disc in discs {
                //Reference conversion disc.row disc.column is from the bottom left corner, to convert to top left index
                let i = ((6 - disc.row) * 7 + disc.column) - 1
                if i < 42 {
                    let myColor = disc.index % 2 == 1 ? firstPlayerColor : secondPlayerColor
                    subMaskShapeLayerList[Int(i)].fillColor = myColor?.cgColor
                }
            }
        }
        gameBoardView.layer.addSublayer(maskShapeLayer)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
     
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        @unknown default:
            break
        }
    }
     
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            break
        }
    }
     
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

extension TableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailPage",
           let vc = segue.destination as? ReplayViewController,
           let indexPath = self.tableView.indexPathForSelectedRow,
           let sessionItem = self.fetchedResultsController?.object(at: indexPath){
            vc.hidesBottomBarWhenPushed = true
            vc.sessionItem = sessionItem
        }
    }
}
