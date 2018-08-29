//
//  Validator+Password.swift
//  App
//
//  Created by laijihua on 2018/6/16.
//

import Foundation
import Validation

fileprivate struct PasswordValidator: ValidatorType {
    private var asciiValidator: Validator = .ascii
    private var lengthValidator: Validator<String> = Validator.count(8...)
    private var numberValidator: Validator<String> = Validator.containsCharacterFrom(set: .decimalDigits)
    private var lowercaseValidator: Validator<String> = Validator.containsCharacterFrom(set: .lowercaseLetters)
    private var uppercaseValidator: Validator<String> = Validator.containsCharacterFrom(set: .uppercaseLetters)

    var validatorReadable: String { return "a valid password of 8 or more ASCII characters" }

    init() {}

    func validate(_ s: String) throws {
        try asciiValidator.validate(s)
        try lengthValidator.validate(s)
        try numberValidator.validate(s)
        try lowercaseValidator.validate(s)
        try uppercaseValidator.validate(s)
    }
}

fileprivate struct ContainsCharacterFromSetValidator: ValidatorType {
    private let characterSet: CharacterSet
    var validatorReadable: String { return "a valid string consisting of at least one character from a given set"}

    init(characterSet: CharacterSet) {
        self.characterSet = characterSet
    }

    func validate(_ data: String) throws {
        guard let _ = data.rangeOfCharacter(from: characterSet) else {
            throw BasicValidationError("does not contain a member of character set: \(characterSet.description)")
        }
    }
}

extension Validator where T == String {
    static var password: Validator<T> {
        return PasswordValidator().validator()
    }

    static func containsCharacterFrom(set: CharacterSet) -> Validator<T> {
        return ContainsCharacterFromSetValidator(characterSet: set).validator()
    }
}
