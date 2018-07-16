//
//  BookCreateContainer.swift
//  App
//
//  Created by laijihua on 2018/6/27.
//

import Vapor

struct BookCreateContainer: Content {
    var isbn: String
    var name: String
    var author: String
    var price: Double
    var detail: String
    var convers: [String]
    var doubanPrice: Double
    var doubanGrade: Double
    var classifyId: BookClassify.ID
    var priceUintId: PriceUnit.ID
}

struct BookUpdateContainer: Content {
    var id: Book.ID
    var price: Double?
    var detail: String?
    var convers: [String]?
}
