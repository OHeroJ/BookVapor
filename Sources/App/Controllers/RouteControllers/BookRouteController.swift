//
//  BookController.swift
//  App
//
//  Created by laijihua on 2018/6/27.
//

import Vapor
import FluentPostgreSQL
import Pagination

final class BookRouteController: RouteCollection {
    func boot(router: Router) throws {
        let group = router.grouped("api", "book")
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let authGroup = group.grouped([tokenAuthMiddleware, guardAuthMiddleware])
        authGroup.post(BookCreateContainer.self, at:"create", use: createBookHandler) // 创建书籍
        authGroup.post(BookUpdateContainer.self, at:"update", use: updateBookHandler) // 编辑书籍

        authGroup.post(Comment.self, at:"comment", use: commentBookHandle)

        group.get("list", use: listBooksHandle)
        group.get("comments", use: listCommentsHandle)
    }
}

extension BookRouteController {

    /// 评论列表
    func listCommentsHandle(_ request: Request) throws -> Future<Response> {
        let container = try request.query.decode(BookCommentListContainer.self)
        return try Comment
            .query(on: request)
            .filter(\.bookId == container.bookId)
            .paginate(for: request)
            .flatMap{ pages in
                return try JSONContainer.init(data: pages).encode(for: request)
            }
    }

    /// 创建评论
    func commentBookHandle(_ request: Request, container: Comment) throws -> Future<Response> {
        let user = try request.requireAuthenticated(User.self)
        guard let userId = user.id , userId == container.userId else {
            return try request.makeErrorJson(message: "用户不存在")
        }
        let comment = Comment(bookId: container.bookId, userId: userId, content: container.content)
        // TODO: 推送 + 消息
        return try comment.create(on: request).makeJsonResponse(on: request)
    }

    /// 首页书籍列表
    func listBooksHandle(_ request: Request) throws -> Future<Response>  {
        return try Book
            .query(on: request)
            .paginate(for: request)
            .makeJsonResponse(on: request)
    }

    /// 书籍的编辑
    func updateBookHandler(_ request: Request, container: BookUpdateContainer) throws -> Future<Response> {
        let user = try request.requireAuthenticated(User.self)
        guard let userId = user.id, userId == container.id else {
            return try request.makeErrorJson(message: "这本书不是您的，不能编辑")
        }
        return Book
            .find(container.id, on: request)
            .flatMap { book in
                guard let tBook = book else {
                    return try request.makeErrorJson(message: "书籍不存在")
                }

                tBook.covers = container.convers ?? tBook.covers
                tBook.detail = container.detail ?? tBook.detail
                tBook.price = container.price ?? tBook.price
                return try tBook.update(on: request).makeJsonResponse(on: request)
        }
    }

    /// 创建书籍
    func createBookHandler(_ request: Request, container: BookCreateContainer) throws -> Future<Response> {
        let user = try request.requireAuthenticated(User.self)
        guard let userId = user.id else {
            return try request.makeErrorJson(message: "认证失败")
        }
        let book = Book(isbn: container.isbn,
                        name: container.name,
                        author: container.author,
                        price: container.price,
                        detail: container.detail,
                        covers: container.convers,
                        repCount: 0,
                        comCount: 0,
                        collCount: 0,
                        state: Book.State.check,
                        doubanPrice: container.doubanPrice,
                        doubanGrade: container.doubanGrade,
                        createId: userId,
                        classifyId: container.classifyId,
                        priceUintId: container.priceUintId)
        return try book.create(on:request).makeJsonResponse(on: request)
    }
}



