//
//  EitherProtocol.swift
//  App
//
//  Created by laijihua on 2018/9/5.
//

import Foundation

private func const<T, U>(_ x: T) -> (U) -> T {
    return { _ in x }
}


/// Same associativity and precedence as &&.
infix operator &&& : LogicalConjunctionPrecedence
private func &&& <T, U> (left: T?, right: @autoclosure () -> U?) -> (T, U)? {
    if let x = left, let y = right() {
        return (x, y)
    }
    return nil
}

public protocol EitherProtocol {
    associatedtype Left
    associatedtype Right

    /// Constructs a `Left` instance.
    static func toLeft(_ value: Left) -> Self

    /// Constructs a `Right` instance.
    static func toRight(_ value: Right) -> Self

    /// Returns the result of applying `f` to `Left` values, or `g` to `Right` values.
    func either<Result>(ifLeft: (Left) throws -> Result, ifRight: (Right) throws -> Result) rethrows -> Result
}


extension EitherProtocol {
    /// Returns the value of `Left` instances, or `nil` for `Right` instances.
    var left: Left? {
        return either(ifLeft: Optional<Left>.some, ifRight: const(nil))
    }

    /// Returns the value of `Right` instances, or `nil` for `Left` instances.
    var right: Right? {
        return either(ifLeft: const(nil), ifRight: Optional<Right>.some)
    }

    /// Returns true of `Left` instances, or false for `Right` instances.
    var isLeft: Bool {
        return either(ifLeft: const(true), ifRight: const(false))
    }

    /// Returns true of `Right` instances, or false for `Left` instances.
    var isRight: Bool {
        return either(ifLeft: const(false), ifRight: const(true))
    }
}

extension EitherProtocol where Left: Equatable, Right: Equatable {
    /// Equality (tho not `Equatable`) over `EitherType` where `Left` & `Right` : `Equatable`.
    static func == (lhs: Self, rhs: Self) -> Bool {
        return Self.equivalence(left: ==, right: ==)(lhs, rhs)
    }

    /// Inequality over `EitherType` where `Left` & `Right` : `Equatable`.
    static func != (lhs: Self, rhs: Self) -> Bool {
        return !(lhs == rhs)
    }
}

extension EitherProtocol {
    /// Given equivalent functions for `Left` and `Right`, returns an equivalent function for `EitherProtocol`.
    static func equivalence(left: @escaping (Left, Left) -> Bool, right: @escaping (Right, Right) -> Bool) -> (Self, Self) -> Bool {
        return { a, b in
            (a.left &&& b.left).map(left)
                ??    (a.right &&& b.right).map(right)
                ??    false
        }
    }
}
