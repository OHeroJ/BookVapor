//
//  BookListContainer.swift
//  App
//
//  Created by laijihua on 2018/7/16.
//

import Vapor

struct BookListContainer: Content {
    var type: Int? // 类型
    var sort: Int? // 排序
}

extension BookListContainer {
    enum BookListType: Int {
        case hot = 0 // 热榜
        case new = 1 // 新书
    }

    var bType: BookListType {
        guard let tt = type else {return .hot}
        switch tt {
        case 0: return .hot
        case 1: return .new
        default: return .hot 
        }
    }
}
