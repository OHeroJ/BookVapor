//
//  Either.swift
//  App
//
//  Created by laijihua on 2018/9/5.
//

import Foundation

enum Either<T, U> {
    case left(T)
    case right(U)
}

extension Either: EitherProtocol {
    static func toLeft(_ value: T) -> Either {
        return .left(value)
    }

    static func toRight(_ value: U) -> Either {
        return .right(value)
    }

    func either<Result>(ifLeft: (T) throws -> Result, ifRight: (U) throws -> Result) rethrows -> Result {
        switch self {
        case let .left(x):
            return try ifLeft(x)
        case let .right(x):
            return try ifRight(x)
        }
    }
}


extension Either {
    func map<V>(_ transform: (U) -> V) -> Either<T, V> {
        return flatMap { .right(transform($0)) }
    }

    /// Returns the result of applying `transform` to `Right` values, or re-wrapping `Left` values.
    func flatMap<V>(_ transform: (U) -> Either<T, V>) -> Either<T, V> {
        return either(
            ifLeft: Either<T, V>.left,
            ifRight: transform)
    }

    /// Maps `Left` values with `transform`, and re-wraps `Right` values.
    func mapLeft<V>(_ transform: (T) -> V) -> Either<V, U> {
        return flatMapLeft { .left(transform($0)) }
    }

    /// Returns the result of applying `transform` to `Left` values, or re-wrapping `Right` values.
    func flatMapLeft<V>(_ transform: (T) -> Either<V, U>) -> Either<V, U> {
        return either(
            ifLeft: transform,
            ifRight: Either<V, U>.right)
    }

    public func bimap<V, W>(leftBy lf: (T) -> V, rightBy rf: (U) -> W) -> Either<V, W> {
        return either(
            ifLeft: { .left(lf($0)) },
            ifRight: { .right(rf($0)) })
    }
}

extension Sequence where Iterator.Element: EitherProtocol {
    /// Select only `Right` instances.
    public var rights: [Iterator.Element.Right] {
        return compactMap { $0.right }
    }

    /// Select only `Left` instances.
    public var lefts: [Iterator.Element.Left] {
        return compactMap { $0.left }
    }
}

extension Either: Codable where T: Codable, U: Codable {
    enum CodingKeys: CodingKey {
        case left
        case right
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .left(let value):
            try container.encode(value, forKey: .left)
        case .right(let value):
            try container.encode(value, forKey: .right)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            let leftValue = try container.decode(T.self, forKey: .left)
            self = .left(leftValue)
        } catch {
            let rightValue = try container.decode(U.self, forKey: .right)
            self = .right(rightValue)
        }
    }

}



precedencegroup Bind {
    associativity: left
    higherThan: DefaultPrecedence
}
infix operator >>- : Bind
func >>- <T, U, V> (either: Either<T, U>, transform: (U) -> Either<T, V>) -> Either<T, V> {
    return either.flatMap(transform)
}


