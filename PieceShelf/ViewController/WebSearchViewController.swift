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
    
    // SendThumbnailDelegate 변수
    var sendThumbnailDelegate: SendThumbnailDelegate?
    
    // 한 줄에 collection cell을 몇 개 넣을건지
    let itemsPerRows: CGFloat = 3.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        
        collectionView.dataSource = self
        collectionView.delegate = self
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
        let urlString = "https://openapi.naver.com/v1/search/image?query=" + "\(keyword)" + "&display=100&start=1&sort=sim"
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
//                        self.thumbnail.append(index.thumbnail ?? "")
                        self.thumbnail.append(index.link ?? "")
                    }
                    self.collectionView.reloadData()
                }catch let error{
                    print("에러 1 : \(error.localizedDescription)")
                }
                
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

extension WebSearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thumbnail.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThumbnailCollectionViewCell.identifier, for: indexPath)
        
        guard let thumbnailCell = cell as? ThumbnailCollectionViewCell else {
            return cell
        }
        
        let thumbnailInfo = thumbnail[indexPath.item]
        
        // 기존에 있는 이미지를 없앰.
        thumbnailCell.imageView.image = nil
        
        DispatchQueue.global().async {
            guard let thumbnailURL = URL(string: thumbnailInfo) else {
                return
            }
            guard let thumbnail = try? Data(contentsOf: thumbnailURL) else {
                return
            }
            
            DispatchQueue.main.async {
//                if let index = collectionView.indexPath(for: thumbnailCell) {
//                    if index.item == indexPath.item {
//                        thumbnailCell.imageView.image = UIImage(data: thumbnail)
//                    }
//                }
                thumbnailCell.imageView.image = UIImage(data: thumbnail)

            }
        }
        
        return thumbnailCell
    }
    
    
}

extension WebSearchViewController: UICollectionViewDelegate {
    
    // CollectionView에서 Cell을 선택했을 때, 호출되는 메소드
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedThumbnail = thumbnail[indexPath.item]
        
        sendThumbnailDelegate?.sendThumbnail(url: selectedThumbnail)
        
        // WebSearchVC를 dismiss하여, AddVC로 감.
        dismiss(animated: true, completion: nil)
    }
}

// UICollectionViewFlowLayout
extension WebSearchViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        print("Flow Layout")
//        let width = view.frame.width
        let width = collectionView.bounds.width
        let widthPerItems = width / itemsPerRows

        let height = widthPerItems * 1.4

        return CGSize(width: widthPerItems, height: height)
    }
    }

// WebSearchVC에서 선택한 썸네일을 AddVC에 띄워주기 위해 선언한 Delegate 프로토콜
protocol SendThumbnailDelegate {
    func sendThumbnail(url: String)
}
