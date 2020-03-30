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
                    let img = UIImage(data: data!)
                    cell.imageView.image = img
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
                    cell.imageView.image = UIImage(data: data)
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
