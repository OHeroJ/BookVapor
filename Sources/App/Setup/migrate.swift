//
//  migrate.swift
//  App
//
//  Created by laijihua on 2018/8/29.
//

import Vapor
import FluentPostgreSQL //use your database driver here

public func migrate(migrations: inout MigrationConfig) throws {
    migrations.add(model: Organization.self, database: .psql)
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Menu.self, database: .psql)
    migrations.add(model: Role.self, database: .psql)
    migrations.add(model: OpLog.self, database: .psql)
    migrations.add(model: Right.self, database: .psql)
    migrations.add(model: Group.self, database: .psql)
    migrations.add(model: RoleRight.self, database: .psql)
    migrations.add(model: GroupRight.self, database: .psql)
    migrations.add(model: GroupRole.self, database: .psql)
    migrations.add(model: UserRight.self, database: .psql)
    migrations.add(model: UserRole.self, database: .psql)
    migrations.add(model: UserGroup.self, database: .psql)
    migrations.add(model: AccessToken.self, database: .psql)
    migrations.add(model: RefreshToken.self, database: .psql)
    migrations.add(model: Friend.self, database: .psql)
    migrations.add(model: PriceUnit.self, database: .psql)
    migrations.add(model: BookClassify.self, database: .psql)
    migrations.add(model: Book.self, database: .psql)
    migrations.add(model: ActiveCode.self, database: .psql)
    migrations.add(model: Feedback.self, database: .psql)
    migrations.add(model: MessageBoard.self, database: .psql)
    migrations.add(model: WishBook.self, database: .psql)
    migrations.add(model: WishBookComment.self, database: .psql)
    migrations.add(model: PriceUnit.self, database: .psql)
    migrations.add(model: Notify.self, database: .psql)
    migrations.add(model: UserNotify.self, database: .psql)
    migrations.add(model: Subscription.self, database: .psql)
    migrations.add(model: UserAuth.self, database: .psql)

    // Populate
    migrations.add(migration: PopulateOrganizationForms.self, database: .psql)
    migrations.add(migration: PopulateMenuForms.self, database: .psql)
    migrations.add(migration: PopulateBookClassifyForms.self, database: .psql)
}
