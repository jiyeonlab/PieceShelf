//
//  ShowAllViewController.swift
//  PieceShelf
//
//  Created by JiyeonKim on 2020/03/29.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit
import Firebase

class DetailViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var catecoryTitle: String?
    var itemsList: [[String:Any]]?
    
    // 한 줄에 collection cell을 몇 개 넣을건지
    let itemsPerRows: CGFloat = 3.0
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var storageCount = 0
    var isStorageComplete = false
    var isNormalComplete = false
    @IBOutlet weak var indicatorBackView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.navigationBar.prefersLargeTitles = false
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        guard let title = catecoryTitle else { return }
        navigationItem.title = title
        
        // 현재 카테고리에 해당하는 db를 계속 observing
        observeInCatecory()

        guard let items = itemsList, items.count != 0 else {
            activityIndicator.stopAnimating()
            return
        }
        
        activityIndicator.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let items = itemsList, items.count != 0 else { return }
        
        for item in items {
            if let value = item.first(where: { $0.key == "Thumbnail" })?.value as? String {
                if value.hasPrefix("Photo_"){
                    storageCount += 1
                }
            }
          
        }

        print("스토리지 갯수 \(storageCount)")
    }
    
    func configIndicator(){
        if storageCount > 0 {
            if isStorageComplete && isNormalComplete {
                indicatorBackView.backgroundColor = .clear
                activityIndicator.stopAnimating()
            }
        }else{
            if isNormalComplete {
                indicatorBackView.backgroundColor = .clear
                activityIndicator.stopAnimating()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowSelectedItem" {
            print("!!!!")
            guard let itemVC = segue.destination as? ItemViewController else {
                return
            }
            
            itemVC.catecory = catecoryTitle
            
            guard let index = sender as? Int else {
                return
            }
            
            itemVC.data = itemsList?[index]
        }

    }
    
    func observeInCatecory(){
        guard let catecory = catecoryTitle else { return }
        Database.database().reference().child("UserData").child(catecory).observe(.value) { snapshot in
            
            self.itemsList?.removeAll()
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
                let value = snap.value as! [String:Any]

                if key != "Default" {
                    self.itemsList?.append(value)
                }
                
                self.collectionView.reloadData()
            }
        }
    }
}

extension DetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailCollectionViewCell.identifier, for: indexPath) as? DetailCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        guard let imgURL = itemsList?[indexPath.item].first(where: { $0.key == "Thumbnail" })?.value as? String else {
            return UICollectionViewCell()
        }
        
        if imgURL.hasPrefix("Photo_"){
            guard let catecory = catecoryTitle else { return UICollectionViewCell() }
            let islandRef = Storage.storage().reference().child(catecory).child(imgURL)
            islandRef.getData(maxSize: 1*1024*1024) { (data, error) in
                if let error = error {
                    print("다운로드 에러 \(error)")
                }else{
                    
                    if let index = collectionView.indexPath(for: cell) {
                        if index.item == indexPath.item {
                            self.isStorageComplete = true
                            self.configIndicator()
                            let img = UIImage(data: data!)
                            cell.imageView.image = img
                        }
                    }
                    
                }
            }
        }else{
            DispatchQueue.global().async {
                guard let url = URL(string: imgURL) else {
                    return
                }
                guard let data = try? Data(contentsOf: url) else {
                    return
                }
                
                DispatchQueue.main.async {
                    if let index = collectionView.indexPath(for: cell){
                        if index.item == indexPath.item {
                            self.isNormalComplete = true
                            self.configIndicator()
                            cell.imageView.image = UIImage(data: data)
                        }
                    }
                }
            }
            
        }
        
        return cell
    }
}

extension DetailViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        performSegue(withIdentifier: "ShowSelectedItem", sender: indexPath.item)
    }
}

// UICollectionViewFlowLayout
extension DetailViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constant.cellSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.bounds.width - (Constant.cellSpacing * 2)
        let widthPerItems = width / itemsPerRows

        let height = widthPerItems * Constant.itemsRatio

        return CGSize(width: widthPerItems, height: height)
    }
}
