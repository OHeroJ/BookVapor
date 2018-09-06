//
//  NotifyService.swift
//  App
//
//  Created by laijihua on 2018/8/27.
//

import Foundation
import Vapor

import Fluent
import FluentPostgreSQL
import Pagination

final class NotifyService {

    /// 往Notify表中插入一条公告记录
    func createAnnouce(content: String, sender: User.ID, on reqeust: Request) throws -> Future<Response> {
        let notify = Notify(type: Notify.announce, target: nil, targetType: nil, action: nil, sender: sender, content: content)
        return try notify.create(on: reqeust).makeJson(on: reqeust)
    }

    /// 往Notify表中插入一条提醒记录
    func createRemind(target: Int, targetType: String, action: String, sender: User.ID, content: String, on reqeust: Request) throws -> Future<Response> {
        let notify = Notify(type: Notify.remind, target: target, targetType: targetType, action: action, sender: sender, content: content)
        return try notify.create(on: reqeust).makeJson(on: reqeust)
    }

    /// 往Notify表中插入一条信息记录
    /// 往UserNotify表中插入一条记录，并关联新建的Notify
    func createMessage(content: String, sender: User.ID, receiver: User.ID, on reqeust: Request) throws -> Future<Response> {
        let notify = Notify(type: Notify.message, target: nil, targetType: nil, action: nil, sender: sender, content: content)
        return notify
            .create(on: reqeust)
            .flatMap { (noti) in
                let notid = try noti.requireID()
                let userNotify = UserNotify(userId: sender, notifyId: notid, notifyType: noti.type)
                let _ = userNotify.create(on: reqeust)
                return try reqeust.makeJson(noti)
            }
    }

    /// 从UserNotify中获取最近的一条公告信息的创建时间
    /// 用lastTime作为过滤条件，查询Notify的公告信息
    /// 新建UserNotify并关联查询出来的公告信息
    func pullAnnounce(userId: User.ID, on request: Request) throws -> Future<Response> {
        return UserNotify
            .query(on: request)
            .filter(\.userId == userId)
            .filter(\UserNotify.notifyType == Notify.announce)
            .sort(\UserNotify.createdAt, .descending)
            .first()
            .flatMap { usernoti in
                guard let existUsernoti = usernoti,
                    let lastTime = existUsernoti.createdAt else {
                    return try request.makeJson()
                }

                return Notify
                    .query(on: request)
                    .filter(\.type == Notify.announce)
                    .filter(\.createdAt > lastTime)
                    .all()
                    .flatMap{ noties in
                        noties.forEach({ (notify) in
                            guard let notiyId = notify.id else {return}
                            let userNoti = UserNotify(userId: userId, notifyId: notiyId, notifyType: notify.type)
                            _ = userNoti.create(on: request)
                        })
                        return try request.makeJson(noties)
                    }
        }

    }

    /// 查询用户的订阅表，得到用户的一系列订阅记录
    /// 通过每一条的订阅记录的target、targetType、action、createdAt去查询Notify表，获取订阅的Notify记录。（注意订阅时间必须早于提醒创建时间）
    /// 查询用户的配置文件SubscriptionConfig，如果没有则使用默认的配置DefaultSubscriptionConfig
    /// 使用订阅配置，过滤查询出来的Notify
    /// 使用过滤好的Notify作为关联新建UserNotify
    func pullRemind(userId: User.ID, on request: Request) throws -> Future<Response> {
        return Subscription
            .query(on: request)
            .filter(\.userId == userId)
            .all()
            .flatMap { subs in
                // 二维数组
                let noties = subs.compactMap { sub in
                    return Notify
                        .query(on: request)
                        .filter(\Notify.type == sub.target)
                        .filter(\Notify.targetType == sub.targetType)
                        .filter(\Notify.action == sub.action)
                        .filter(\Notify.createdAt > sub.createdAt)
                        .all()
                }

                var notifyArr = [Notify]()
                noties.forEach({ (notifyF) in
                    let _ = notifyF.flatMap { notis -> EventLoopFuture<Response> in
                        notis.forEach({ (notify) in
                            guard let notiyId = notify.id else {return}
                            notifyArr.append(notify)
                            let userNoti = UserNotify(userId: userId, notifyId: notiyId, notifyType: notify.type)
                            let _ = userNoti.create(on: request)
                        })
                        return try request.makeJson()
                    }
                })
                return try request.makeJson(notifyArr)
            }
    }


    /// 通过reason，查询reasonAction，获取对应的动作组:actions
    /// 遍历动作组，每一个动作新建一则Subscription记录
    func subscribe(user: User.ID, target: Int, targetType: String, reason: String, on reqeust: Request) throws -> Future<Response>{
        let reasonAction: [String: [String]] = [
            "create_topic": ["like", "comment"],
            "like_replay": ["comment"]
        ]
        guard let actions = reasonAction[reason] else {throw ApiError(code: .resonNotExist)}
        actions.forEach { action in
            let subscribe = Subscription(target: target, targetType: targetType, userId: user, action: action)
            let _ = subscribe.create(on: reqeust).map(to: Void.self, { _ in return})
        }
        return try reqeust.makeJson()
    }

    //// 删除user、target、targetType对应的一则或多则记录
    func cancelSubscription(userId: User.ID, target: Int, targetType: String, on reqeust: Request) throws -> Future<Response> {
        return try Subscription.query(on: reqeust)
            .filter(\.userId == userId)
            .filter(\.target == target)
            .filter(\.targetType == targetType)
            .delete()
            .makeJson(request: reqeust)
    }

    //// 查询SubscriptionConfig表，获取用户的订阅配置
    func getSubscriptionConfig(userId: User.ID, on reqeust: Request) throws -> Future<Response> {
        return try Subscription.query(on: reqeust)
            .filter(\.userId == userId)
            .all()
            .makeJson(on: reqeust)
    }

    /// 获取用户的消息列表
    func getUserNotify(userId: User.ID, on reqeust: Request) throws -> Future<Response>{
        return try UserNotify
            .query(on: reqeust)
            .filter(\UserNotify.userId == userId)
            .sort(\UserNotify.createdAt)
            .paginate(for: reqeust)
            .map {$0.response()}
            .makeJson(on: reqeust)
    }

    /// 更新指定的notify，把isRead属性设置为true
    func read(user: User, notifyIds:[Notify.ID], on reqeust: Request) throws -> Future<Void>{
        return UserNotify
            .query(on: reqeust)
            .filter(\UserNotify.notifyId ~~ notifyIds)
            .update(\UserNotify.isRead, to: true)
            .all()
            .map(to: Void.self, { _ in Void()})
    }
}
