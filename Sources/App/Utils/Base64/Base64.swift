//
//  base64.swift
//  unchained
//
//  Created by Johannes Schriewer on 13/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

/// Base64 alphabet
public enum Base64Alphabet: String {
    /// default alphabet
    case `default`       = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

    /// URL type alphabet
    case url           = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"

    /// XML name alphabet
    case xmlName       = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.-"

    /// XML identifier alphabet
    case xmlIdentifier = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_:"

    /// alphabet for file names
    case filename      = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+-"

    /// alphabet for regular expressions
    case regEx         = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!-"
}

/// Base64 decoding and encoding
public class Base64 {

    /// Encode data with Base64 encoding
    ///
    /// - parameter data: data to encode
    /// - parameter linebreak: (optional) number of characters after which to insert a linebreak. (Value rounded to multiple of 4)
    /// - parameter alphabet: (optional) Base64 alphabet to use
    /// - returns: Base64 string with padding
    public class func encode(data: [UInt8], linebreak: Int? = nil, alphabet: Base64Alphabet = .default) -> String {

        // Build lookup table from alphabet
        let lookup = alphabet.rawValue.utf8.map { c -> UnicodeScalar in
            return UnicodeScalar(c)
        }

        // round linebreak value to quads
        var breakQuads: Int = 0
        if let linebreak = linebreak {
            breakQuads = (linebreak / 4) * 4
        }

        // encode full triplets to quads
        var outData = ""
        outData.reserveCapacity(data.count / 3 * 4 + 4)
        for i in 0..<(data.count / 3) {
            if (breakQuads > 0) && (i > 0) && ((i * 4) % breakQuads == 0) {
                outData.append("\r\n")
            }

            let d1 = data[i * 3]
            let d2 = data[i * 3 + 1]
            let d3 = data[i * 3 + 2]

            let o1 = (d1 >> 2) & 0x3f
            let o2 = ((d1 << 4) + (d2 >> 4)) & 0x3f
            let o3 = ((d2 << 2) + (d3 >> 6)) & 0x3f
            let o4 = d3 & 0x3f

            outData.unicodeScalars.append(lookup[Int(o1)])
            outData.unicodeScalars.append(lookup[Int(o2)])
            outData.unicodeScalars.append(lookup[Int(o3)])
            outData.unicodeScalars.append(lookup[Int(o4)])
        }

        // calculate leftover bytes
        let overhang = data.count - ((data.count / 3) * 3)
        if overhang > 0 {
            if (breakQuads > 0) && (((data.count / 3) * 4) % breakQuads == 0) {
                outData.append("\r\n")
            }
        }

        if overhang == 1 {
            // one byte left, pad with two equal signs
            let d1 = data[data.count - 1]

            let o1 = (d1 >> 2) & 0x3f
            let o2 = (d1 << 4) & 0x3f

            outData.unicodeScalars.append(lookup[Int(o1)])
            outData.unicodeScalars.append(lookup[Int(o2)])
            outData.unicodeScalars.append(UnicodeScalar(61)) // =
            outData.unicodeScalars.append(UnicodeScalar(61)) // =
        } else if overhang == 2 {
            // two bytes left, pad with one equal sign
            let d1 = data[data.count - 2]
            let d2 = data[data.count - 1]

            let o1 = (d1 >> 2) & 0x3f
            let o2 = ((d1 << 4) + (d2 >> 4)) & 0x3f
            let o3 = (d2 << 2) & 0x3f

            outData.unicodeScalars.append(lookup[Int(o1)])
            outData.unicodeScalars.append(lookup[Int(o2)])
            outData.unicodeScalars.append(lookup[Int(o3)])
            outData.unicodeScalars.append(UnicodeScalar(61)) // =
        }

        return outData
    }

    /// Decode Base64 encoded data
    ///
    /// - parameter data: data to decode
    /// - parameter alphabet: (optional) Base64 alphabet to use
    /// - returns: decoded data
    public class func decode(data: [UInt8], alphabet: Base64Alphabet = .default) -> [UInt8] {
        // build lookup table for decoding
        var lookup = [UInt8](repeating: 64, count: 255)
        let alpha = alphabet.rawValue.utf8
        var idx = alpha.startIndex
        for i in 0..<alpha.count {
            lookup[Int(alpha[idx])] = UInt8(i)
            idx = alpha.index(after: idx)
        }

        // reserve outData
        var outData = [UInt8]()
        outData.reserveCapacity(data.count / 4 * 3)

        // reserve work mem
        var din = [UInt8]()
        din.reserveCapacity(4)

        // decode quads to triplets
        var gen = data.makeIterator()
        while let d = gen.next() {
            let val = lookup[Int(d)]
            if val <= 63 {
                din.append(val)
            }

            if din.count == 4 {
                let o1 = (din[0] << 2) + (din[1] >> 4)
                let o2 = (din[1] << 4) + (din[2] >> 2)
                let o3 = (din[2] << 6) + din[3]
                outData.append(o1)
                outData.append(o2)
                outData.append(o3)
                din.removeAll()
            }
        }

        // if data was not a full quad, assume padding
        if din.count > 0 {
            if din.count == 2 {
                let o1 = (din[0] << 2) + (din[1] >> 4)
                let o2 = (din[1] << 4)

                outData.append(o1)
                outData.append(o2)
            } else if din.count == 3 {
                let o1 = (din[0] << 2) + (din[1] >> 4)
                let o2 = (din[1] << 4) + (din[2] >> 2)
                let o3 = (din[2] << 6)

                outData.append(o1)
                outData.append(o2)
                outData.append(o3)
            }
        }

        return outData
    }

    /// Encode string with Base64 encoding
    ///
    /// - parameter string: string to encode
    /// - parameter linebreak: (optional) number of characters after which to insert a linebreak. (Value rounded to multiple of 4)
    /// - parameter alphabet: (optional) Base64 alphabet to use
    /// - returns: Base64 string with padding
    public class func encode(string: String, linebreak: Int? = nil, alphabet: Base64Alphabet = .default) -> String {
        return Base64.encode(data: string.utf8.map({ c -> UInt8 in
            return c
        }), linebreak: linebreak, alphabet: alphabet)
    }

    /// Decode Base64 encoded string
    ///
    /// - parameter string: string to decode
    /// - parameter alphabet: (optional) Base64 alphabet to use
    /// - returns: decoded data
    public class func decode(string: String, alphabet: Base64Alphabet = .default) -> [UInt8] {
        return Base64.decode(data: string.utf8.map({ c -> UInt8 in
            return c
        }), alphabet: alphabet)
    }
}

