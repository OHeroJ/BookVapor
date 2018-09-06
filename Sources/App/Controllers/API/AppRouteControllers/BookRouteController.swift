//
//  BookController.swift
//  App
//
//  Created by laijihua on 2018/6/27.
//

import Vapor
import FluentPostgreSQL
import Pagination
import Fluent

final class BookRouteController: RouteCollection {
    func boot(router: Router) throws {
        let group = router.grouped("api", "book")
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let authGroup = group.grouped([tokenAuthMiddleware, guardAuthMiddleware])
        authGroup.post(BookCreateContainer.self, at:"create", use: createBookHandler) // 创建书籍
        authGroup.post(BookUpdateContainer.self, at:"update", use: updateBookHandler) // 编辑书籍
        authGroup.post(Comment.self, at:"comment", use: commentBookHandle)  // 评论
        authGroup.post(BookCheckContainer.self, at:"check", use: checkBookHandle) // 书籍审核
        /// 获取全部书籍
        group.get("list", use: listBooksHandle)

        /// 获取书本的评论
        group.get("comments", use: listCommentsHandle)

    }
}

extension BookRouteController {

    /// 书籍审核
    func checkBookHandle(_ request: Request, container: BookCheckContainer) throws -> Future<Response> {
        // 审核成功与失败需要给到消息系统
        let _ = try request.requireAuthenticated(User.self)
        return Book
            .find(container.id, on: request)
            .unwrap(or: ApiError(code: .bookNotExist))
            .flatMap { book in
                book.state = container.state
                return try book.update(on: request).makeJson(on: request)
        }
    }


    /// 评论列表
    func listCommentsHandle(_ request: Request) throws -> Future<Response> {
        let container = try request.query.decode(BookCommentListContainer.self)
        return try Comment
            .query(on: request)
            .filter(\.bookId == container.bookId)
            .paginate(for: request)
            .map {$0.response()}
            .makeJson(on: request)
    }

    /// 创建评论
    func commentBookHandle(_ request: Request, container: Comment) throws -> Future<Response> {
        let user = try request.requireAuthenticated(User.self)
        guard let userId = user.id , userId == container.userId else {
            throw ApiError(code: .userNotExist)
        }
        let comment = Comment(bookId: container.bookId, userId: userId, content: container.content)
        // TODO: 推送 + 消息
        return try comment.create(on: request).makeJson(on: request)
    }

    /// 获取书籍列表, page=1&per=10
    func listBooksHandle(_ request: Request) throws -> Future<Response>  {
        let filters = try request.query.decode(BookListContainer.self)
        var orderBys:[PostgreSQLOrderBy] = [.orderBy(PostgreSQLExpression.column(PostgreSQLColumnIdentifier.keyPath(\Book.createdAt)), .ascending)]

        switch filters.bType {
        case .hot:
            orderBys = [.orderBy(PostgreSQLExpression.column(PostgreSQLColumnIdentifier.keyPath(\Book.commentCount)), .ascending)]
        case .new:
            break
        }

        return try Book
            .query(on: request)
            .filter(\.state ~~ [.putaway, .soldout])
            .paginate(for: request, orderBys)
            .map {$0.response()}
            .makeJson(on: request)
    }


    /// 书籍的编辑， 只有是用户的书籍才能编辑
    func updateBookHandler(_ request: Request, container: BookUpdateContainer) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return Book
            .find(container.id, on: request)
            .unwrap(or: ApiError(code: .bookNotExist))
            .flatMap { book in
                book.covers = container.convers ?? book.covers
                book.detail = container.detail ?? book.detail
                book.price = container.price ?? book.price
                return try book.update(on: request).makeJson(on: request)
        }
    }

    /// 创建书籍
    func createBookHandler(_ request: Request, container: BookCreateContainer) throws -> Future<Response> {
        let user = try request.requireAuthenticated(User.self)
        let userId = try user.requireID()
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
        return try book
            .create(on:request)
            .makeJson(on: request)
    }
}



