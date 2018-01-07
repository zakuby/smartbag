//
//  RemiderListViewController.swift
//  SmartBag
//
//  Created by admin on 10/12/17.
//  Copyright © 2017 indosystem. All rights reserved.
//

import UIKit
import Firebase
import ObjectMapper


class ReminderListViewController: UIViewController {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var emptyReminder: UIView!
    var collectionViews: UICollectionView!
    var reminders = [ReminderList]()
    var reminderDates = [String]()
    let rootRef = Database.database().reference()

    @IBOutlet weak var addButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
//        observerUserReminder()
        setupCollectionView()
    }
    override func viewDidAppear(_ animated: Bool) {
        observerUserReminder()
    }

    func setupCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        
        collectionViews = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionViews.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        collectionViews.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionViews.showsVerticalScrollIndicator = false
        collectionViews.register(reminderListCollectionViewCell.self, forCellWithReuseIdentifier: "reminderCell")
        collectionViews.delegate = self
        collectionViews.dataSource = self
        collectionViews.backgroundColor = UIColor.white.withAlphaComponent(0)
        view.addSubview(collectionViews)
        collectionViews.translatesAutoresizingMaskIntoConstraints = false
        collectionViews.bottomAnchor.constraint(equalTo: addButton.topAnchor).isActive = true
        collectionViews.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        collectionViews.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionViews.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10).isActive = true
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
        //rootRef.removeAllObservers()
    }
    
    func observerUserReminder(){
        //check if there is no reminder
        rootRef.observe(.value) { (snapshot) in
            if !snapshot.hasChild("reminders"){
                self.emptyReminder.isHidden = false
            }
            DispatchQueue.main.async(execute: {
                self.collectionViews.reloadData()
            })
        }
        reminders.removeAll()
        let ref = rootRef.child("reminders")
        ref.observe(.childAdded, with: { (snapshot) in
            let reminderDate = snapshot.key
            let reminderReference = self.rootRef.child("reminders").child(reminderDate)
            reminderReference.observe(.childAdded, with: { (snapshot) in
                let inventoryID = snapshot.key
                let inventoryReference = self.rootRef.child("inventory").child(inventoryID)
                
                inventoryReference.observe(.value, with: { (snapshot) in
                    if let lJsonArray = snapshot.value{
                        let data = Mapper<Reminder>().map(JSONObject: lJsonArray)
                        self.reminderDates.append((data?.name)!)
                        if let index:Int = self.reminders.index(where: {$0.dates == reminderDate}) {
                            self.reminders[index].nama?.append((data?.name)!)
                        }else{
                            self.reminders.append(ReminderList(date: reminderDate, name: self.reminderDates))
                        }
                        self.reminderDates.removeAll()
                    }
                    if self.reminders.isEmpty{
                        self.emptyReminder.isHidden = false
                    }else{
                        self.emptyReminder.isHidden = true
                        
                    }
                    DispatchQueue.main.async(execute: {
                        self.collectionViews.reloadData()
                    })
                })
                
            })

        })
    }

}

extension ReminderListViewController: UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    //Specifying the number of sections in the Collection View
    func numberOfSections(in collectionView: UICollectionView)-> Int {
        return 1
    }
    //Specifying the number of cells in the Collection View
    func collectionView(_ collectionView:UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return reminders.count
    }
    
    //Method to dequeue the cell and set it up
    func collectionView(_ collectionView:UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reminderCell", for: indexPath) as! reminderListCollectionViewCell
        cell.awakeFromNib()
        cell.delegate = self as? reminderListCollectionViewCellDelegate
        return cell
    }
    
    //Method to populate the data of a given cell
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let reminderData = reminders[indexPath.row]
        let reminderCell = cell as! reminderListCollectionViewCell
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let reminderDate = dateFormatter.date(from: reminderData.dates!)
        dateFormatter.dateFormat = "dd MMMM yyyy"
        let newDate = dateFormatter.string(from: reminderDate!)
        
        reminderCell.descLabel.text = ""
        if reminderData.nama?.count == 1{
            reminderCell.descLabel.text = "• " + (reminderData.nama?[0].capitalized)!
        }else{
            for element in reminderData.nama!{
                reminderCell.descLabel.text = reminderCell.descLabel.text! + "• " + element.capitalized + "\n"
            }
        }
        
        reminderCell.date = reminderData.dates
        reminderCell.titleLabel.text = newDate
        
    }
    //Set the size of cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let reminderData = reminders[indexPath.row]
        return CGSize(width: collectionViews.frame.width / 1.15, height: CGFloat(30 + (20 * (reminderData.nama?.count)!)))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}

extension ReminderListViewController: reminderListCollectionViewCellDelegate {

    func deleteButton(forCell: reminderListCollectionViewCell) {
        let idRef = rootRef.child("reminders").child(forCell.date!)
        idRef.removeValue()
        observerUserReminder()
    }
    
    func editButton(forCell: reminderListCollectionViewCell) {
        let Storyboard = UIStoryboard(name: "Main", bundle: nil)
        let descView = Storyboard.instantiateViewController(withIdentifier: "ReminderViewController") as! ReminderViewController
        descView.getDate = forCell.date
        present(descView, animated: true, completion: nil)
    }
    
}
