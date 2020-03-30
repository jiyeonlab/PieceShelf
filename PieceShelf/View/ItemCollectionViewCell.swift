//
//  ItemCollectionViewCell.swift
//  PieceShelf
//
//  Created by JiyeonKim on 2020/03/30.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit
import Firebase

class ItemCollectionViewCell: UICollectionViewCell {

    static let identifier = "ItemCollectionViewCell"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    var data: [String:Any]?
    var catecory: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imageView.layer.cornerRadius = 2
        imageView.clipsToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let itemTitle = data?["Title"] as? String else { return }
        guard let thumbnailString = data?["Thumbnail"] as? String else { return }
        
        title.text = itemTitle
//        title.adjustsFontSizeToFitWidth = true
        
        // thumbnail의 경우, storage에 저장된 경우를 걸러야 함.
        if thumbnailString.hasPrefix("Photo_"){
            // TODO: Storage에서 불러와야
            guard let catecory = catecory else { return }
            let islandRef = Storage.storage().reference().child(catecory).child(thumbnailString)
            islandRef.getData(maxSize: 1*1024*1024) { (data, error) in
                if let error = error {
                    print("다운로드 에러 \(error)")
                }else{
                    let img = UIImage(data: data!)
                    self.imageView.image = img
                }
            }
        }else{
            DispatchQueue.global().async {
                guard let thumbnailURL = URL(string: thumbnailString) else {
                    return
                }
                guard let thumbnail = try? Data(contentsOf: thumbnailURL) else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: thumbnail)
                }
            }
        }
    }
}
