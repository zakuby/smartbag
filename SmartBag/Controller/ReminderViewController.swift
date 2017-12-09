//
//  ReminderViewController.swift
//  SmartBag
//
//  Created by admin on 08/12/17.
//  Copyright © 2017 indosystem. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import ObjectMapper

class ReminderViewController: UIViewController {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var dateTxtField: UITextField!
    let rootRef = Database.database().reference()
    
    @IBAction func addTask(_ sender: Any) {
        
        if dateTxtField.text == ""{
            return
        }
        let idRef = rootRef.child("reminders").child(dateTxtField.text!)
        if addID.isEmpty == false {
            idRef.removeValue()
            for element in addID{
                idRef.updateChildValues([element : 1])
            }
        }
        if removeID.isEmpty == false {
            for element in removeID{
                idRef.child(element).removeValue()
            }
            removeID.removeAll()
        }
        
    }
    let datePicker = UIDatePicker()
    @IBOutlet weak var whatLabel: UILabel!
    var inventorys = [InventoryList]()
    var inventorysDictionary = [String: Inventory]()
    var collectionViews: UICollectionView!
    var addID = [String]()
    var removeID = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupCollectionView()
        observerUserInventory()
        createDatePicker()
        // Do any additional setup after loading the view.
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        print(textField.text)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        
        collectionViews = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionViews.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionViews.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionViews.showsVerticalScrollIndicator = false
        collectionViews.register(inventoryReminderCollectionViewCell.self, forCellWithReuseIdentifier: "inventoryReminder")
        collectionViews.delegate = self
        collectionViews.dataSource = self
        collectionViews.backgroundColor = UIColor.white.withAlphaComponent(0)
        view.addSubview(collectionViews)
        collectionViews.translatesAutoresizingMaskIntoConstraints = false
        collectionViews.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -10).isActive = true
        collectionViews.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        collectionViews.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionViews.topAnchor.constraint(equalTo: whatLabel.bottomAnchor, constant: 10).isActive = true
        
    }
    
    func observerUserInventory(){
        let ref = Database.database().reference().child("inventory")
        ref.observe(.childAdded, with: { (snapshot) in
            let inventoryID = snapshot.key
            let inventoryReference = Database.database().reference().child("inventory").child(inventoryID)
            
            inventoryReference.observe(.value, with: { (snapshot) in
                let idTag = snapshot.key
                if let lJsonArray = snapshot.value{
                    let data = Mapper<Inventory>().map(JSONObject: lJsonArray)
                    if let index:Int = self.inventorys.index(where: {$0.ID == idTag}) {
                        self.inventorys.remove(at: index)
                        
                    }
                    self.inventorys.append(InventoryList(added: false, desc: data?.deskripsi ?? "Deskripsi Barang",imgUrl: data?.imageUrl ?? "",name: data?.name ?? "Nama Barang" ,inventID: idTag, stat: (data?.status)!, toDay: data?.timeOutDay! ?? 0, toMonth: data?.timeOutMonth! ?? 0, toYear: data?.timeOutYear! ?? 0, toHour: data?.timeOutHour! ?? 0, toMinute: data?.timeOutMinute! ?? 0, toSecond: data?.timeOutSecond! ?? 0, tiDay: data?.timeInDay!, tiMonth: data?.timeInMonth!, tiYear: data?.timeInYear!, tiHour: data?.timeInHour!, tiMinute: data?.timeInMinute, tiSecond: data?.timeInSecond!))
                    
                    DispatchQueue.main.async(execute: {
                        self.collectionViews.reloadData()
                    })
                }
            })
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    func createDatePicker(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let currentDate = NSDate()
        let dateComponents = NSDateComponents()
        let minDate = calendar.date(byAdding: dateComponents as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))
        
        dateComponents.month = 3 //or you can change month = day(90)
        
        let maxDate = calendar.date(byAdding: dateComponents as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))
        datePicker.datePickerMode = .date
        datePicker.backgroundColor = UIColor.white
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        doneButton.tintColor = UIColor.black
        toolbar.setItems([doneButton], animated: false)
        
        dateTxtField.inputAccessoryView = toolbar
        dateTxtField.inputView = datePicker
        
    }
    
    @objc func donePressed(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateTxtField.text = dateFormatter.string(from: datePicker.date)
        observerUserDate(date: dateTxtField.text!)
        self.view.endEditing(true)
    }
    
    func observerUserDate(date: String){
        let dateRef = Database.database().reference().child("reminders")
        dateRef.observe(.value) { (snapshot) in
            if snapshot.hasChild(date){
                print("there is reminder")
                dateRef.child(date).observe(.childAdded, with: { (snapshot) in
                    let inventoryID = snapshot.key
                    print(snapshot.value)
                    let inventoryReference = Database.database().reference().child("inventory").child(inventoryID)
                    
                    inventoryReference.observe(.value, with: { (snapshot) in
                        let idTag = snapshot.key
                        if let lJsonArray = snapshot.value{
                            let data = Mapper<Inventory>().map(JSONObject: lJsonArray)
                            print(lJsonArray)
                            if let index:Int = self.inventorys.index(where: {$0.ID == idTag}) {
                                self.inventorys[index].isAdded = true
                            }
                            DispatchQueue.main.async(execute: {
                                self.collectionViews.reloadData()
                            })
                        }
                    })
                })
            }else{
                for element in self.inventorys{
                    element.isAdded = false
                }
                DispatchQueue.main.async(execute: {
                    self.collectionViews.reloadData()
                })
            }
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ReminderViewController: UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    //Specifying the number of sections in the Collection View
    func numberOfSections(in collectionView: UICollectionView)-> Int {
        return 1
    }
    //Specifying the number of cells in the Collection View
    func collectionView(_ collectionView:UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return inventorys.count
    }
    
    //Method to dequeue the cell and set it up
    func collectionView(_ collectionView:UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "inventoryReminder", for: indexPath) as! inventoryReminderCollectionViewCell
        cell.awakeFromNib()
        cell.delegate = self as? inventoryReminderCollectionViewCellDelegate
        return cell
    }
    
    //Method to populate the data of a given cell
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let inventoryrData = inventorys[indexPath.row]
        let inventoryCell = cell as! inventoryReminderCollectionViewCell
        let url = URL(string: inventoryrData.imageUrl!)
        if inventoryrData.isAdded!{
            inventoryCell.button.backgroundColor = UIColor.red
            inventoryCell.button.setTitle("Remove", for: .normal)
            inventoryCell.buttonChanged = true
        }else if !inventoryrData.isAdded!{
            inventoryCell.button.backgroundColor = UIColor.green
            inventoryCell.button.setTitle("Add", for: .normal)
            inventoryCell.buttonChanged = false
        }
        inventoryCell.ID = inventoryrData.ID
        inventoryCell.imageView.kf.setImage(with: url)
        inventoryCell.titleLabel.text = inventoryrData.nama!
        inventoryCell.descLabel.text = inventoryrData.deskripsi
    }
    //Set the size of cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionViews.frame.width / 1.15, height: 147)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let inventData = inventorys[indexPath.row]
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let result = formatter.string(from: date)
        print(result)
        print(inventData.ID!)
    }
    
}

extension ReminderViewController: inventoryReminderCollectionViewCellDelegate {
    func changeColorOfButton(forCell: inventoryReminderCollectionViewCell){
        let ID = forCell.ID
        if let index:Int = self.addID.index(where: {$0 == ID}) {
            self.addID.remove(at: index)
        }
        if let index:Int = self.removeID.index(where: {$0 == ID}) {
            self.removeID.remove(at: index)
        }
        if !forCell.buttonChanged{
            forCell.button.backgroundColor = UIColor.red
            forCell.button.setTitle("Remove", for: .normal)
            forCell.buttonChanged = !forCell.buttonChanged
            self.addID.append(ID!)
            if let index:Int = self.inventorys.index(where: {$0.ID == ID}) {
                self.inventorys[index].isAdded = true
            }
        }else{
            forCell.button.backgroundColor = UIColor.green
            forCell.button.setTitle("Add", for: .normal)
            forCell.buttonChanged = !forCell.buttonChanged
            self.removeID.append(ID!)
            if let index:Int = self.inventorys.index(where: {$0.ID == ID}) {
                self.inventorys[index].isAdded = false
            }
        }
    }
}
