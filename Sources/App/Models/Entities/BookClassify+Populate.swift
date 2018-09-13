//
//  BookClassify+Populate.swift
//  App
//
//  Created by laijihua on 2018/9/13.
//
import Vapor
import FluentPostgreSQL

/// 数据填充
final class PopulateBookClassifyForms: Migration {
    typealias Database = PostgreSQLDatabase

    static let categories = [
        "文学小说": [
            "恐怖/惊悚小说",
            "悬疑推理小说",
            "翻译文学",
            "科幻小说",
            "历史武侠",
            "古典文学",
            "言情小说",
            "现代文学",
            "现代小说",
            "儿童文学"
        ],
        "轻小说/漫画": [
            "历史战役漫画","图文书/绘本","华文轻小说", "奇幻/魔法漫书", "动作冒险漫画", "悬疑推理漫画", "BL/GL", "日本轻小说", "运动/竞技漫画", "科幻漫画", "灵异漫画"],
        "心理/宗教": ["励志/散文", "人际关系", "两性/家庭关系", "宗教命理", "心理学", "个人成长"],
        "知识学习": ["韩语", "中文", "日语", "外语", "英语", "语言能力", "电脑资讯", "音乐"],
        "商业理财": ["电子商务", "成功法", "管理", "经济", "传记", "投资理财", "广告/业务", "职场"],
        "人文史地": ["中国历史", "哲学", "当代", "世界历史", "逻辑/思考"],
        "社会科学": ["社会议题", "文化研究", "新闻学", "报道文学", "性别研究", "政治", "军事"],
        "艺术设计": ["室内设计", "电影", "摄影", "戏剧", "设计", "绘图", "建筑", "收藏鉴赏"],
        "生活风格/饮食": ["休闲", "居家生活", "个人护理", "宠物", "户外", "手作", "食谱", "饮食文化"],
        "教科读物": ["小学", "初中", "高中", "大学"],
        "旅游": ["中国", "旅游文学", "美洲", "欧洲", "非洲/大洋洲", "亚洲", "主题旅游"],
        "自然科普":["应用科学", "工程", "天文学"],
        "计算机": ["程序设计", "期刊", "操作系统", "基础知识"]
    ]

    static func getHeadId(on connection: PostgreSQLConnection, title: String) ->  Future<BookClassify.ID> {
        let cat = BookClassify(name: title, parentId: 0, path: "0")
        return cat.create(on: connection).map { classi in
            return classi.id!
        }
    }

    static func creatSubCategory(headId:BookClassify.ID, title: String, conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        let subs = categories[title] ?? []
        let subfutures = subs.compactMap { item in
            return BookClassify(name: item, parentId: headId, path: "\(headId)").create(on: conn)
                .map(to:Void.self, {_ in return})
        }
        return Future<Void>.andAll(subfutures, eventLoop: conn.eventLoop)
    }



    static func searchCateId(title: String, conn: PostgreSQLConnection) -> Future<BookClassify.ID> {
        return BookClassify.query(on: conn)
            .filter(\BookClassify.name == title)
            .first()
            .unwrap(or: FluentError(identifier: "PopulateBookClassifyForms_noSuchHeat", reason: "PopulateBookClassifyForms_noSuchHeat"))
            .map { return $0.id! }
    }

    static func deleteCates(on conn:PostgreSQLConnection, heatName: String, subcates: [String]) -> EventLoopFuture<Void> {
        return searchCateId(title: heatName, conn: conn).flatMap(to: Void.self) { heatId in
            let futures = subcates.map { name in
                return BookClassify.query(on: conn).filter(\.name == name).delete()
            }
            return Future<Void>.andAll(futures, eventLoop: conn.eventLoop)
        }
    }

    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        let keys = categories.keys

        let futures = keys.map { title -> EventLoopFuture<Void> in
            let future = getHeadId(on: conn, title: title)
                .flatMap { headId -> EventLoopFuture<Void> in
                    return creatSubCategory(headId: headId, title: title, conn: conn)
            }
            return future
        }
        return Future<Void>.andAll(futures, eventLoop: conn.eventLoop)
    }


    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        let futures = categories.map { (arg) -> EventLoopFuture<Void> in
            let (name, touples) = arg
            let allFut =  deleteCates(on: conn, heatName: name, subcates: touples).always {
                _ = BookClassify.query(on: conn).filter(\.name == name).delete()
            }
            return allFut
        }
        return Future<Void>.andAll(futures, eventLoop: conn.eventLoop)
    }

}
