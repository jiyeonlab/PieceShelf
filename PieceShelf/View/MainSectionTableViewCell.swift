//
//  MainSectionTableViewCell.swift
//  PieceShelf
//
//  Created by JiyeonKim on 2020/03/29.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit
import Firebase

class MainSectionTableViewCell: UITableViewCell {
    
    static let identifier = "MainSectionTableViewCell"
    @IBOutlet weak var catecoryName: UILabel!
    
    // presentDelegate 변수
    var presentDelegate: PresentDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // 현재 카테고리에 있는 title 저장
    var items = [[String:Any]]()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let nibName = UINib(nibName: "ItemCollectionViewCell", bundle: nil)
        collectionView.register(nibName, forCellWithReuseIdentifier: ItemCollectionViewCell.identifier)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func showDetailVC(_ sender: Any) {

        guard let catecory = catecoryName.text else { return }
        
        // 전체보기 버튼을 누르면, 카테고리 이름과 그 카테고리 안에 있는 데이터를 함께 보내줌.
        presentDelegate?.loadNewVC(by: catecory, with: items)
    }
    
    // 해당하는 카테고리의 데이터를 불러옴
    func fetchData(from currentCatecory: String) {
                
        Database.database().reference().child("UserData").child(currentCatecory).observeSingleEvent(of: .value) { (snapshot) in
//            do {
//                let data = try JSONSerialization.data(withJSONObject: snapshot.value, options: [])
//                let userData = try JSONDecoder().decode([UserData].self, from: data)
//                print("받은 데이터 정보 \(userData)")
//
//
//            }catch let error {
//                print("Fetch Error \(error)")
//            }
            
            self.items.removeAll()
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
                let value = snap.value as! [String:Any]

                if key != "Default" {
                    self.items.append(value)
                }
            }
            print(self.items)
            self.collectionView.reloadData()
        }
    }
}

extension MainSectionTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCollectionViewCell.identifier, for: indexPath) as? ItemCollectionViewCell else { return UICollectionViewCell() }
        
        cell.data = items[indexPath.item]
        
        // storage 검색을 위해 카테고리 값도 넘겨줘야함.
        cell.catecory = catecoryName.text
        
        return cell
    }
    
}

extension MainSectionTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("현재 카테고리 \(catecoryName.text!)")
        print("____________________________ \(items[indexPath.item])")
        
        guard let catecory = catecoryName.text else { return }
        presentDelegate?.openItemVC(by: catecory, with: items[indexPath.item])
        
    }
}

// detailVC를 열기 위한 Delegate
protocol PresentDelegate {
    func loadNewVC(by catecory: String, with data: [[String: Any]])
    
    // collection cell이 눌리면, itemVC를 열기 위해 추가.
    func openItemVC(by catecory: String, with data: [String:Any])
}
