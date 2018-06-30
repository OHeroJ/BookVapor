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
        authGroup.post(BookCreateContainer.self, at:"create", use: createBookHandler)
        authGroup.post(Comment.self, at:"comment", use: commentBookHandle)
        group.get("list", use: listBooksHandle)
        group.get("comments", use: listCommentsHandle)
    }
}

extension BookRouteController {

    /// 评论列表
    func listCommentsHandle(_ request: Request) throws -> Future<JSONContainer<Paginated<Comment>>> {
        let container = try request.query.decode(BookCommentListContainer.self)
        return try Comment
            .query(on: request)
            .filter(\.bookId == container.bookId)
            .paginate(for: request)
            .convertToCustomContainer()
    }

    /// 创建评论
    func commentBookHandle(_ request: Request, container: Comment) throws -> Future<JSONContainer<Comment>> {
        let user = try request.requireAuthenticated(User.self)
        guard let userId = user.id , userId == container.userId else {
            throw Abort(.badRequest, reason: "用户不存在")
        }
        let comment = Comment(bookId: container.bookId, userId: userId, content: container.content)

        // TODO: 推送 + 消息
        return comment.create(on: request).convertToCustomContainer()
    }

    /// 首页书籍列表
    func listBooksHandle(_ request: Request) throws -> Future<JSONContainer<Paginated<Book>>>  {
        return try Book
            .query(on: request)
            .paginate(for: request)
            .convertToCustomContainer()
    }

    /// 创建书籍
    func createBookHandler(_ request: Request, container: BookCreateContainer) throws -> Future<JSONContainer<Book>> {
        let user = try request.requireAuthenticated(User.self)
        guard let userId = user.id else {
            throw Abort(.badRequest, reason: "认证失败", identifier: nil)
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
        return book.create(on:request).convertToCustomContainer()
    }
}



