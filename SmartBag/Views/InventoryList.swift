//
//  InventoryList.swift
//  SmartBag
//
//  Created by admin on 11/20/17.
//  Copyright © 2017 indosystem. All rights reserved.
//

import UIKit

protocol inventoryListCollectionViewCellDelegate {
    func changeColorOfButton(forCell: inventoryListCollectionViewCell)
}


class inventoryListCollectionViewCell: UICollectionViewCell {
    
    
    
    var delegate: inventoryListCollectionViewCellDelegate? = nil
    
    let expiryDate:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    let descLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let exclamationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    let imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let titleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let exclamationView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let descView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let missingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    override func awakeFromNib() {
        
        contentView.layer.shadowColor = UIColor(red: 226/255, green: 230/255, blue: 239/255, alpha: 1).cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowRadius = 4 //Here your control your blur
        contentView.layer.masksToBounds = false
        contentView.layer.cornerRadius = 5
        contentView.backgroundColor = UIColor.white
        
        contentView.addSubview(missingView)
        contentView.addSubview(imageView)
        contentView.addSubview(expiryDate)
        contentView.addSubview(descLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(exclamationLabel)
        contentView.addSubview(exclamationView)
        
        
        missingView.clipsToBounds = true
        missingView.isHidden = true
        missingView.translatesAutoresizingMaskIntoConstraints = false
        missingView.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
        missingView.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        missingView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        missingView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        missingView.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 0.6)
        
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.45).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        
        exclamationView.clipsToBounds = true
        exclamationView.isHidden = true
        exclamationView.image = UIImage(named: "exclamation")
        exclamationView.translatesAutoresizingMaskIntoConstraints = false
        exclamationView.contentMode = .scaleToFill
        exclamationView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        exclamationView.widthAnchor.constraint(equalToConstant: 75).isActive = true
        exclamationView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        exclamationView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        titleLabel.textColor = UIColor(red: 64/255, green: 196/255, blue: 142/255, alpha: 1)
        titleLabel.text = "Worth"
        titleLabel.font = UIFont.init(name: "GothamBook", size: 12)
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 26).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 16).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
        titleLabel.numberOfLines = 2
        
        exclamationLabel.isHidden = true
        exclamationLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        exclamationLabel.text = "MISSING !"
        exclamationLabel.font = UIFont.init(name: "GothamBook", size: 32)
        exclamationLabel.topAnchor.constraint(equalTo: exclamationView.bottomAnchor, constant: 10).isActive = true
        exclamationLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        exclamationLabel.numberOfLines = 1
        
        descLabel.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        descLabel.font = UIFont.init(name: "GothamMedium", size: 12)
        descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        descLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 16).isActive = true
        descLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5).isActive = true
        //        descLabel.adjustsFontSizeToFitWidth = true
        descLabel.sizeToFit()
        descLabel.numberOfLines = 3
        
        expiryDate.textColor = UIColor.gray
        expiryDate.font = UIFont.init(name: "GothamBook", size: 12)
        expiryDate.heightAnchor.constraint(equalToConstant: 12).isActive = true
        expiryDate.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -11).isActive = true
        expiryDate.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 16).isActive = true
        expiryDate.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -14).isActive = true
        expiryDate.adjustsFontSizeToFitWidth = true
        expiryDate.sizeToFit()
        expiryDate.numberOfLines = 1
    }
    
}

