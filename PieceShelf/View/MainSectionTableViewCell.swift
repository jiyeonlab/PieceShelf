//
//  MainSectionTableViewCell.swift
//  PieceShelf
//
//  Created by JiyeonKim on 2020/03/29.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit

class MainSectionTableViewCell: UITableViewCell {
    
    static let identifier = "MainSectionTableViewCell"
    @IBOutlet weak var catecoryName: UILabel!
    
    // presentDelegate 변수
    var presentDelegate: PresentDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.dataSource = self
        
        let nibName = UINib(nibName: "ItemCollectionViewCell", bundle: nil)
        collectionView.register(nibName, forCellWithReuseIdentifier: ItemCollectionViewCell.identifier)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func showDetailVC(_ sender: Any) {

        guard let catecory = catecoryName.text else { return }
        presentDelegate?.loadNewVC(by: catecory)
    }
    
}

extension MainSectionTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCollectionViewCell.identifier, for: indexPath)
        
        return cell
    }
    
}

// detailVC를 열기 위한 Delegate
protocol PresentDelegate {
    func loadNewVC(by catecory: String)
}
