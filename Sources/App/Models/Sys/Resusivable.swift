//
//  Resusivable.swift
//  App
//
//  Created by laijihua on 2018/7/15.
//

import Vapor
import FluentPostgreSQL

protocol ModelPublicable: Content {
    var children: [Self] {get set}
}

protocol ModelResusivable: PostgreSQLModel {
    associatedtype Public: ModelPublicable
    var parentId:Self.ID {get}

    func convertToPublic(childrens: [Public]) -> Public
}

extension RouteCollection {
    func generateModelTree<T>(parentId: T.ID, originArray:[T]) -> [T.Public] where T: ModelResusivable {
        let firstParents = originArray.filter({ $0.parentId == parentId})
        let originArr = Array(originArray.drop(while: {$0.parentId == parentId}))
        if (firstParents.count > 0) {
            return firstParents.map { (menu) ->  T.Public in
                return menu.convertToPublic(childrens: generateModelTree(parentId: menu.id!, originArray: originArr))
            }
        } else {
            return []
        }
    }
}
