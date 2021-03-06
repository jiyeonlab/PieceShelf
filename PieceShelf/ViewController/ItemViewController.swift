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
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var memoView: UITextView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityBackView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageViewHeight.constant = view.frame.height / Constant.itemHeightRatio
        
        fetchImg()
        
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        configLabel()
        configMemo()
        
        activityIndicator.startAnimating()
    }
    
    func configLabel(){
        guard let title = data?.first(where: { $0.key == "Title" })?.value as? String else {
            return
        }
        guard let date = data?.first(where: { $0.key == "Date" })?.value as? String else{
            return
        }
        titleLabel.text = title
        dateLabel.text = date
    }
    
    func configMemo() {
        guard let memo = data?.first(where: { $0.key == "Memo" })?.value as? String else{
            return
        }
        memoView.text = memo
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
                    self.activityBackView.backgroundColor = .clear
                    self.activityIndicator.stopAnimating()
                    
                    guard let imgData = data else { return }
                    let img = UIImage(data: imgData)
                    self.imageView.image = img
                }
            }
        }else{
            DispatchQueue.global().async {
               
                let imgData = requestImgData(url: thumbnailString)
                
                DispatchQueue.main.async {
                    self.activityBackView.backgroundColor = .clear
                    self.activityIndicator.stopAnimating()
                    self.imageView.image = UIImage(data: imgData)
                }
            }
        }
    }
    
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // DB에 해당 아이템 삭제하기
    @IBAction func deleteItem(_ sender: Any) {
        guard let catecoryName = catecory else { return }
        guard let title = titleLabel.text else { return }
        
        let alert = UIAlertController(title: "항목 삭제", message: "정말 삭제하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .default, handler: nil))
       
        alert.addAction(UIAlertAction(title: "삭제", style: .default, handler: { _ in
            let deleteRef = Database.database().reference().child("UserData").child(catecoryName)
            deleteRef.child(title).removeValue()
            
            self.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true)
    }
    
}
