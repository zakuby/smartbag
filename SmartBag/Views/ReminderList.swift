//
//  ReminderList.swift
//  SmartBag
//
//  Created by admin on 11/12/17.
//  Copyright © 2017 indosystem. All rights reserved.
//

import UIKit

protocol reminderListCollectionViewCellDelegate {
    func deleteButton(forCell: reminderListCollectionViewCell)
    func editButton(forCell: reminderListCollectionViewCell)
}


class reminderListCollectionViewCell: UICollectionViewCell {
    
    var delegate: reminderListCollectionViewCellDelegate? = nil
    var date: String?
    
    let descLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var deleteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var editButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    
    override func awakeFromNib() {
        
        contentView.layer.shadowColor = UIColor(red: 226/255, green: 230/255, blue: 239/255, alpha: 1).cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowRadius = 4 //Here your control your blur
        contentView.layer.masksToBounds = false
        contentView.layer.cornerRadius = 5
        contentView.backgroundColor = UIColor.white
        
        contentView.addSubview(descLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(deleteButton)
        contentView.addSubview(editButton)
        
        deleteButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
        deleteButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5).isActive = true
        deleteButton.backgroundColor = UIColor.red
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.layer.cornerRadius = 3
        deleteButton.clipsToBounds = true
        deleteButton.addTarget(self, action: #selector(deletePressed), for: .touchUpInside)
        
        editButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        editButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        editButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
        editButton.rightAnchor.constraint(equalTo: deleteButton.leftAnchor, constant: -5).isActive = true
        editButton.backgroundColor = UIColor.orange
        editButton.setTitle("Edit", for: .normal)
        editButton.layer.cornerRadius = 3
        editButton.clipsToBounds = true
        editButton.addTarget(self, action: #selector(editPressed), for: .touchUpInside)
        
        titleLabel.textColor = UIColor(red: 64/255, green: 196/255, blue: 142/255, alpha: 1)
        titleLabel.text = "Worth"
        titleLabel.font = UIFont.init(name: "GothamBook", size: 12)
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
        titleLabel.numberOfLines = 1
        
        
        descLabel.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        descLabel.font = UIFont.init(name: "GothamMedium", size: 12)
        descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        descLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        descLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5).isActive = true
        //        descLabel.adjustsFontSizeToFitWidth = true
        descLabel.sizeToFit()
        descLabel.numberOfLines = 0
        
    }
    
    @objc func deletePressed(){
        delegate?.deleteButton(forCell: self)
        
    }
    
    @objc func editPressed(){
        delegate?.editButton(forCell: self)
    }
    
}
