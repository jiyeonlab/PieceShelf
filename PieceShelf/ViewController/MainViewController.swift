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
        
        tableView.dataSource = self
        
        // MainSectionTableViewCell의 xib를 등록.
        let nibName = UINib(nibName: "MainSectionTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: MainSectionTableViewCell.identifier)
        
        Catecory.shared.observeCatecory()
        
        // Catecory List가 다 받아지면 노티 받기 위함.
        NotificationCenter.default.addObserver(self, selector: #selector(showCatecory(_:)), name: LoadCatecoryListNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @objc func showCatecory(_ notification: Notification) {
        catecory = Catecory.shared.catecoryList
        tableView.reloadData()
    }
    
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catecory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainSectionTableViewCell.identifier, for: indexPath) as? MainSectionTableViewCell else {
            return UITableViewCell()
        }
        
        cell.presentDelegate = self
        cell.catecoryName.text = catecory[indexPath.row]
        return cell
    }
    
    
}

// UITableViewCell의 xib에서 버튼을 누르면, DetailVC를 열게 하려고 채택.
extension MainViewController: PresentDelegate {
    
    func loadNewVC(by catecory: String) {
        guard let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailVC") as? DetailViewController else {
            return
        }
        
        detailVC.catecoryTitle = catecory
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
