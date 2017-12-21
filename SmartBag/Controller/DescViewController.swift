//
//  DescViewController.swift
//  SmartBag
//
//  Created by admin on 03/12/17.
//  Copyright © 2017 indosystem. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import Kingfisher

class DescViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }

        if let selectedImage = selectedImageFromPicker {
            descImage.image = selectedImage
            imageChanged = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeImage(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    @IBOutlet weak var changeImageButton: UIButton!
    @IBOutlet weak var descTitle: UITextField!
    @IBOutlet weak var descText: UITextView!
    @IBOutlet weak var descImage: UIImageView!
    var getID: String?
    var imageChanged = false
    let rootRef = Database.database().reference()
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let idRef = rootRef.child("inventory").child(getID!)
        if imageChanged {
            let imageName = getID
            let storageRef = Storage.storage().reference().child("images").child("\(imageName!).png")
            if let uploadData = UIImageJPEGRepresentation(self.descImage.image!, 0.1) {
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, errMsg) in
                    if errMsg != nil{
                        print(errMsg!)
                        return
                    }
                    if let imageUrl = metadata?.downloadURL()?.absoluteString{
                        idRef.updateChildValues(["deskripsi" : self.descText.text ?? "Deskripsi Barang"])
                        idRef.updateChildValues(["nama" : self.descTitle.text?.uppercased() ?? "NAMA BARANG"])
                        idRef.updateChildValues(["imageUrl" : imageUrl])
                        self.createAlert(titleText: "Succes", messageText: "Update Succesful")
                    }
                })
            }
            
        }else{
            let idRef = rootRef.child("inventory").child(getID!)
            idRef.updateChildValues(["deskripsi" : self.descText.text ?? "Deskripsi Barang"])
            idRef.updateChildValues(["nama" : self.descTitle.text?.uppercased() ?? "NAMA BARANG"])
            createAlert(titleText: "Succes", messageText: "Update Succesful")
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        changeImageButton.layer.shadowColor = UIColor.black.cgColor
        changeImageButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        changeImageButton.layer.shadowOpacity = 0.5
        changeImageButton.layer.shadowRadius = 1
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
