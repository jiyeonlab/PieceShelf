//
//  MainViewController.swift
//  PieceShelf
//
//  Created by JiyeonKim on 2020/03/28.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var catecory: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        
        Catecory.shared.observeCatecory()
        
        // Catecory List가 다 받아지면 노티 받기 위함.
        NotificationCenter.default.addObserver(self, selector: #selector(showCatecory(_:)), name: LoadCatecoryListNotification, object: nil)
    }
    
    @objc func showCatecory(_ notification: Notification) {
        catecory = Catecory.shared.catecoryList
        tableView.reloadData()
    }
    
}
