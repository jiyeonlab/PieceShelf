//
//  WebSearchViewController.swift
//  PieceShelf
//
//  Created by JiyeonKim on 2020/03/28.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit
import Alamofire

class WebSearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // collectionView에 띄우기 위한 이미지 thumbnail 저장
    var thumbnail: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 화면이 뜨면, 키보드를 저절로 띄우게 하기 위함.
        searchBar.becomeFirstResponder()
    }
    
    @IBAction func tappedBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension WebSearchViewController: UISearchBarDelegate {
    
    // 키보드에서 search 버튼을 눌렀을 경우.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let keyword = searchBar.text else {
            return
        }
        print("검색할 키워드 = \(keyword)")

        // 키워드를 utf-8로 인코딩하여 요청하기 위해 필요한 과정.
        let urlString = "https://openapi.naver.com/v1/search/image?query=" + "\(keyword)" + "&display=50&start=1&sort=sim"
        guard let encodingString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        guard let url = URL(string: encodingString) else {
            return
        }
        
        let headers: HTTPHeaders = ["Content-Type" : "plain/text",
                                    "X-Naver-Client-Id": APIKey.shared.clientID,
                                    "X-Naver-Client-Secret":APIKey.shared.cliendPW]
        
        // AF Request
        AF.request(url, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                do{
                    let data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)

                    let result = try JSONDecoder().decode(SearchResult.self, from: data)
                    
                    self.thumbnail.removeAll()
                    
                    result.items.forEach { index in
                        self.thumbnail.append(index.thumbnail ?? "")
                    }
                    
                }catch let error{
                    print("에러 1 : \(error.localizedDescription)")
                }
                
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
