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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        observerUserInventory()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setupCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        
        collectionViews = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionViews.contentInset = UIEdgeInsets(top: 22, left: 0, bottom: 55, right: 0)
        collectionViews.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionViews.showsVerticalScrollIndicator = false
        collectionViews.register(inventoryListCollectionViewCell.self, forCellWithReuseIdentifier: "inventoryCell")
        collectionViews.delegate = self
        collectionViews.dataSource = self
        collectionViews.backgroundColor = UIColor.white.withAlphaComponent(0)
        view.addSubview(collectionViews)
        collectionViews.translatesAutoresizingMaskIntoConstraints = false
        collectionViews.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionViews.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        collectionViews.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionViews.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10).isActive = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    func observerUserInventory(){
        let ref = Database.database().reference().child("inventory")
        ref.observe(.childAdded, with: { (snapshot) in
            let inventoryID = snapshot.key
            let inventoryReference = Database.database().reference().child("inventory").child(inventoryID)
            
            inventoryReference.observe(.value, with: { (snapshot) in
                let idTag = snapshot.key
                print(idTag)
                if let lJsonArray = snapshot.value{
                    let data = Mapper<Inventory>().map(JSONObject: lJsonArray)
                    print(lJsonArray)
                    if let index:Int = self.inventorys.index(where: {$0.ID == idTag || $0.status == 0}) {
                        self.inventorys.remove(at: index)
                    }
                    if data?.status != 0{
                        self.inventorys.append(InventoryList(desc: data?.deskripsi ?? "Deskripsi Barang",imgUrl: data?.imageUrl ?? "",name: data?.name ?? "" ,inventID: idTag, stat: (data?.status)!, toDay: data?.timeOutDay!, toMonth: data?.timeOutMonth!, toYear: data?.timeOutYear!, toHour: data?.timeOutHour!, toMinute: data?.timeOutMinute!, toSecond: data?.timeOutSecond!, tiDay: data?.timeInDay!, tiMonth: data?.timeInMonth!, tiYear: data?.timeInYear!, tiHour: data?.timeInHour!, tiMinute: data?.timeInMinute, tiSecond: data?.timeInSecond!))
                    }
                    print(data?.timeInSecond)
                    DispatchQueue.main.async(execute: {
                        self.collectionViews.reloadData()
                    })
                }
            })
        })
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
        
        inventoryCell.imageView.kf.setImage(with: url)
        inventoryCell.titleLabel.text = inventoryrData.nama!
        inventoryCell.descLabel.text = inventoryrData.deskripsi
        inventoryCell.expiryDate.text = "Time In: " + inventoryrData.timeInTime!
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

