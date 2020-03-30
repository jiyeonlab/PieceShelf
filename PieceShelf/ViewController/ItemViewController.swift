//
//  ItemViewController.swift
//  PieceShelf
//
//  Created by JiyeonKim on 2020/03/30.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit
import Firebase

class ItemViewController: UIViewController {

    // MainVC로 부터 전달받은 해당 Item의 data 정보
    var data: [String:Any]?
    var catecory: String?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageViewHeight.constant = view.bounds.height / 1.8
        
        fetchImg()
        
        print("ITEM VIEW CONTROLLER")
    }
    
    func fetchImg() {
        
        guard let thumbnailString = data?["Thumbnail"] as? String else { return }
        
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
