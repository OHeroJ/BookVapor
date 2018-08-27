//
//  NotifyService.swift
//  App
//
//  Created by laijihua on 2018/8/27.
//

import Foundation

final class NotifyService {

    /// 往Notify表中插入一条公告记录
    func createAnnouce(content: String, sender: User.ID) {

    }

    /// 往Notify表中插入一条提醒记录
    func createRemind(target: Int, targetType: String, action: String, sender: User.ID, content: String) {

    }

    /// 往Notify表中插入一条信息记录
    /// 往UserNotify表中插入一条记录，并关联新建的Notify
    func createMessage(content: String, sender: User.ID, receiver: User.ID) {

    }

    /// 从UserNotify中获取最近的一条公告信息的创建时间
    /// 用lastTime作为过滤条件，查询Notify的公告信息
    /// 新建UserNotify并关联查询出来的公告信息
    func pullAnnounce(user: User.ID) {

    }

    /// 查询用户的订阅表，得到用户的一系列订阅记录
    /// 通过每一条的订阅记录的target、targetType、action、createdAt去查询Notify表，获取订阅的Notify记录。（注意订阅时间必须早于提醒创建时间）
    /// 查询用户的配置文件SubscriptionConfig，如果没有则使用默认的配置DefaultSubscriptionConfig
    /// 使用订阅配置，过滤查询出来的Notify
    /// 使用过滤好的Notify作为关联新建UserNotify
    func pullRemind(user: User.ID) {

    }

    /// 通过reason，查询NotifyConfig，获取对应的动作组:actions
    /// 遍历动作组，每一个动作新建一则Subscription记录
    func subscribe(user: User.ID, target: Int, targetType: String, reason: String) {

    }

    //// 删除user、target、targetType对应的一则或多则记录
    func cancelSubscription(user: User.ID, target: Int, targetType: String) {

    }

    //// 查询SubscriptionConfig表，获取用户的订阅配置
    func getSubscriptionConfig(userId: User.ID) {

    }

    /// 更新用户的SubscriptionConfig记录
    func updateSubscriptionConfig(userId: User.ID) {

    }

    /// 获取用户的消息列表
    func getUserNotify(userId: User.ID) {

    }

    /// 更新指定的notify，把isRead属性设置为true
    func read(user: User, notifyIds:[Notify.ID]) {

    }
}
