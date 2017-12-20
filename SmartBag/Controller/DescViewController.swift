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

    @IBAction func changeImage(_ sender: Any) {
    }
    @IBOutlet weak var changeImageButton: UIButton!
    @IBOutlet weak var descTitle: UITextField!
    @IBOutlet weak var descText: UITextView!
    @IBOutlet weak var descImage: UIImageView!
    var getID: String?
    let rootRef = Database.database().reference()
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let idRef = rootRef.child("inventory").child(getID!)
        idRef.updateChildValues(["deskripsi" : self.descText.text ?? "Deskripsi Barang"])
        idRef.updateChildValues(["nama" : self.descTitle.text?.uppercased() ?? "NAMA BARANG"])
        createAlert(titleText: "Succes", messageText: "Update Succesful")
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
                }else{
                    let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/smartbag-b64b8.appspot.com/o/noimage.png?alt=media&token=91a48b54-6e2e-43d1-8274-c66d2c679ee1")
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
