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
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
}
