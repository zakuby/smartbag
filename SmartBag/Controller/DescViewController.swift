//
//  DescViewController.swift
//  SmartBag
//
//  Created by admin on 03/12/17.
//  Copyright © 2017 indosystem. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class DescViewController: UIViewController {

    @IBOutlet weak var descTitle: UITextField!
    @IBOutlet weak var descText: UITextView!
    @IBOutlet weak var descImage: UIImageView!
    var getID: String?
    let rootRef = Database.database().reference()
    
    @IBAction func saveButton(_ sender: Any) {
        let idRef = rootRef.child("inventory").child(getID!)
        idRef.updateChildValues(["deskripsi" : self.descText.text ?? "Deskripsi Barang"])
        idRef.updateChildValues(["nama" : self.descTitle.text?.uppercased() ?? "NAMA BARANG"])
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        let idRef = rootRef.child("inventory").child(getID!)
        idRef.observe(.value) { (data) in
            if let dictionary = data.value as? [String: Any]{
                
                if dictionary["nama"] != nil{
                    self.descTitle.text = dictionary["nama"]! as? String
                }
                
                if dictionary["imageUrl"] != nil{
                    let url = URL(string: (dictionary["imageUrl"]! as? String)!)
                    self.descImage.kf.setImage(with: url)
                }
                
                if dictionary["deskripsi"] != nil{
                    self.descText.text = dictionary["deskripsi"]! as? String
                }
                
            }
        }
        descText.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        descText.textContainer.lineFragmentPadding = 0
        descText.textContainerInset = .zero
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
