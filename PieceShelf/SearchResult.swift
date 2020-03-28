//
//  SearchResult.swift
//  PieceShelf
//
//  Created by JiyeonKim on 2020/03/28.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import Foundation

// 검색 API로 부터 받아온 JSON 파일을 파싱하기 위한 구조체

struct SearchResult: Codable {
    let display: Int?
    let items: [ImgItem]
    let lastBuildDate: String?
    let start: Int?
    let total: Int?
}

struct ImgItem: Codable {
    let link: String?
    let sizeheight: String?
    let sizewidth: String?
    let thumbnail: String?
    let title: String?
}

/*

[Result]: success({
    display = 2;
    items =     (
                {
            link = "https://www.apple.com/jp/apple-events/october-2016/meta/og.png?201806191031";
            sizeheight = 630;
            sizewidth = 1200;
            thumbnail = "https://search.pstatic.net/sunny/?src=https://www.apple.com/jp/apple-events/october-2016/meta/og.png?201806191031&type=b150";
            title = "Apple\U306e\U30a4\U30d9\U30f3\U30c8 - Keynote 2016\U5e7410\U6708 - Apple\Uff08\U65e5\U672c\Uff09Apple\U306e\U30a4\U30d9\U30f3\U30c8 - Keynote 2016\U5e7410\U6708";
        },
                {
            link = "http://imgnews.naver.net/image/091/2018/10/30/PEP20181030155901848_P2_20181030232014012.jpg";
            sizeheight = 367;
            sizewidth = 500;
            thumbnail = "https://search.pstatic.net/common/?src=http://imgnews.naver.net/image/091/2018/10/30/PEP20181030155901848_P2_20181030232014012.jpg&type=b150";
            title = "USA APPLE EVENT";
        }
    );
    lastBuildDate = "Fri, 27 Mar 2020 01:38:26 +0900";
    start = 1;
    total = 4191247;
})
*/
