//
//  ViewController.swift
//  SmartBag
//
//  Created by admin on 11/20/17.
//  Copyright © 2017 indosystem. All rights reserved.
//

import UIKit
import Firebase
import ObjectMapper
import Kingfisher

class ViewController: UIViewController {
    @IBOutlet weak var headerView: UIView!
    var inventorys = [InventoryList]()
    var inventorysDictionary = [String: Inventory]()
    var collectionViews: UICollectionView!
    var collectionViewsTopAnchor: NSLayoutConstraint?
    
    @IBOutlet weak var alertNoReminder: UIView!
    @IBOutlet weak var emptyBag: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupCollectionView()
        observerUserInventory()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        observerUserInventory()
    }
    
    func setupCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        
        collectionViews = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionViews.contentInset = UIEdgeInsets(top: 22, left: 0, bottom: 0, right: 0)
        collectionViews.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionViews.showsVerticalScrollIndicator = false
        collectionViews.register(inventoryListCollectionViewCell.self, forCellWithReuseIdentifier: "inventoryCell")
        collectionViews.delegate = self
        collectionViews.dataSource = self
        collectionViews.backgroundColor = UIColor.white.withAlphaComponent(0)
        view.addSubview(collectionViews)
        collectionViews.translatesAutoresizingMaskIntoConstraints = false
        collectionViews.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        collectionViews.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        collectionViews.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionViewsTopAnchor = collectionViews.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10)
        collectionViewsTopAnchor?.isActive = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    func observeTodayReminder(){
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let date = dateFormatter.string(from: currentDate)
        let dateRef = Database.database().reference().child("reminders")
        dateRef.observe(.value) { (snapshot) in
            if snapshot.hasChild(date){
                self.alertNoReminder.isHidden = true
                self.collectionViewsTopAnchor?.isActive = false
                self.collectionViewsTopAnchor = self.collectionViews.topAnchor.constraint(equalTo: self.headerView.bottomAnchor, constant: 10)
                self.collectionViewsTopAnchor?.isActive = true
                dateRef.child(date).observe(.childAdded, with: { (snapshot) in
                    let inventoryID = snapshot.key
                    let inventoryReference = Database.database().reference().child("inventory").child(inventoryID)
                    
                    inventoryReference.observe(.value, with: { (snapshot) in
                        let idTag = snapshot.key
                        if let lJsonArray = snapshot.value{
                            let data = Mapper<Inventory>().map(JSONObject: lJsonArray)
                            if let index:Int = self.inventorys.index(where: {$0.ID == idTag}) {
                                if self.inventorys[index].status == 0{
//                                    print("You are missing: " + self.inventorys[index].nama!)
                                }else{
//                                    print("Found: " + self.inventorys[index].nama!)
                                }
                            }else{
                                self.inventorys.append(InventoryList(added: false, desc: data?.deskripsi ?? "Deskripsi Barang",imgUrl: data?.imageUrl ?? "https://firebasestorage.googleapis.com/v0/b/smartbag-b64b8.appspot.com/o/noimage.png?alt=media&token=91a48b54-6e2e-43d1-8274-c66d2c679ee1",name: data?.name ?? "Nama Barang" ,inventID: idTag, stat: (data?.status)!, timeOut: data?.timeOut ?? "01-01-1980 00:00:00", timeIn: data?.timeIn ?? "01-01-1980 00:00:00" ))
                            }
                        }
                        DispatchQueue.main.async(execute: {
                            self.collectionViews.reloadData()
                        })
                    })
                })
            }else{
                self.alertNoReminder.isHidden = false
                self.collectionViewsTopAnchor?.isActive = false
                self.collectionViewsTopAnchor = self.collectionViews.topAnchor.constraint(equalTo: self.alertNoReminder.bottomAnchor)
                self.collectionViewsTopAnchor?.isActive = true
            }
        }
    }
    
    func observerUserInventory(){
        let ref = Database.database().reference().child("inventory")
        ref.observe(.childAdded, with: { (snapshot) in
            let inventoryID = snapshot.key
            let inventoryReference = Database.database().reference().child("inventory").child(inventoryID)
            
            inventoryReference.observe(.value, with: { (snapshot) in
                let idTag = snapshot.key
                
                if let lJsonArray = snapshot.value{
                    self.emptyBag.isHidden = true
                    let data = Mapper<Inventory>().map(JSONObject: lJsonArray)
                    if let index:Int = self.inventorys.index(where: {$0.ID == idTag || $0.status == 0 && $0.isAdded == true}) {
                        self.inventorys.remove(at: index)
                    }
                    if data?.status != 0{
                        self.inventorys.append(InventoryList(added: true, desc: data?.deskripsi ?? "Deskripsi Barang",imgUrl: data?.imageUrl ?? "https://firebasestorage.googleapis.com/v0/b/smartbag-b64b8.appspot.com/o/noimage.png?alt=media&token=91a48b54-6e2e-43d1-8274-c66d2c679ee1",name: data?.name ?? "Nama Barang" ,inventID: idTag, stat: (data?.status)!, timeOut: data?.timeOut ?? "01-01-1980 00:00:00", timeIn: data?.timeIn ?? "01-01-1980 00:00:00" ))
                    }
                    if self.inventorys.isEmpty{
                        self.emptyBag.isHidden = false
                    }else{
                        self.emptyBag.isHidden = true

                    }
                    DispatchQueue.main.async(execute: {
                        self.collectionViews.reloadData()
                    })
                }
            })
        })
        observeTodayReminder()

    }
}


extension ViewController: UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "inventoryCell", for: indexPath) as! inventoryListCollectionViewCell
        cell.awakeFromNib()
        cell.delegate = self as? inventoryListCollectionViewCellDelegate
        return cell
    }
    
    //Method to populate the data of a given cell
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let inventoryrData = inventorys[indexPath.row]
        let inventoryCell = cell as! inventoryListCollectionViewCell
        let url = URL(string: inventoryrData.imageUrl!)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let dateIn = dateFormatter.date(from: inventoryrData.timeInDate!)
        dateFormatter.dateFormat = "HH:mm:ss"
        let newTimeIn = dateFormatter.string(from: dateIn!)
        //check if item is missing
        if inventoryrData.isAdded!{
            inventoryCell.layer.shadowColor = UIColor(red: 226/255, green: 230/255, blue: 239/255, alpha: 1).cgColor
            inventoryCell.layer.shadowOffset = CGSize(width: 0, height: 1)
            inventoryCell.layer.shadowOpacity = 1
            inventoryCell.layer.shadowRadius = 4 //Here your control your blur
            inventoryCell.layer.masksToBounds = false
            inventoryCell.layer.cornerRadius = 5
            inventoryCell.backgroundColor = UIColor.white
            inventoryCell.missingView.isHidden = true
            inventoryCell.exclamationView.isHidden = true
            inventoryCell.exclamationLabel.isHidden = true
        }else{
            inventoryCell.layer.shadowColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1).cgColor
            inventoryCell.layer.shadowOffset = CGSize(width: 0, height: 4)
            inventoryCell.layer.shadowOpacity = 1
            inventoryCell.layer.shadowRadius = 3 //Here your control your blur
            inventoryCell.layer.masksToBounds = false
            inventoryCell.layer.cornerRadius = 5
            inventoryCell.missingView.isHidden = false
            inventoryCell.exclamationView.isHidden = false
            inventoryCell.exclamationLabel.isHidden = false
        }
        
        if inventoryrData.nama?.uppercased() == "NAMA BARANG"{
            inventoryCell.newItemView.image = UIImage(named: "rectangleGold")
            inventoryCell.newItemLabel.text = "NEW ITEM !"
        }else{
            inventoryCell.newItemView.image = nil
            inventoryCell.newItemLabel.text = ""
        }
        
        inventoryCell.imageView.kf.setImage(with: url)
        inventoryCell.titleLabel.text = inventoryrData.nama!
        inventoryCell.descLabel.text = inventoryrData.deskripsi
        inventoryCell.expiryDate.text = "Time In: " + newTimeIn
    }
    //Set the size of cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionViews.frame.width / 1.15, height: 147)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let Storyboard = UIStoryboard(name: "Main", bundle: nil)
        let descView = Storyboard.instantiateViewController(withIdentifier: "DescViewController") as! DescViewController
        let inventData = inventorys[indexPath.row]

        descView.getID = inventData.ID
        print(inventData.ID)
        present(descView, animated: true, completion: nil)
    }
    
}

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        
        
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func getTopViewController() -> UIViewController?{
        if var topController = UIApplication.shared.keyWindow?.rootViewController
        {
            while (topController.presentedViewController != nil)
            {
                topController = topController.presentedViewController!
            }
            return topController
        }
        return nil
    }
    
    func createAlert(titleText: String, messageText: String){
        let alert = UIAlertController(title: titleText, message: messageText, preferredStyle: .alert)
        let cancelOption = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        })
        cancelOption.setValue(UIColor.init(red: 42/255, green: 147/255, blue: 137/255, alpha: 1), forKey: "titleTextColor")
        alert.addAction(cancelOption)
        
        self.getTopViewController()?.present(alert, animated: true, completion:  nil)
    }
    
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}
