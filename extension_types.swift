
import Cocoa

extension NSRegularExpression {

    func findRanges(string: String, rangeNames: [String]) -> [String: String] {
        var result: [String: String] = [:]
        if let matchesResult = self.firstMatch(in: string, range: NSRange(location: 0, length: string.count)) {
            for rangeName in rangeNames {
                let matchesRange = matchesResult.range(withName: rangeName)
                if matchesRange.location != NSNotFound {
                    if let finalRange = Range(matchesRange, in: string) {
                        result[rangeName] = String(
                            string[finalRange]
                        )
                    }
                }
            }
        }
        return result
    }

}

extension String {

    func hasWwwPrefix() -> Bool {
        return self.hasPrefix("www.")
    }

    func deleteWwwPrefixIfExists() -> String {
        if self.hasWwwPrefix() {
            let from = self.index(self.startIndex, offsetBy: 4)
            return String(
                self[from...]
            )
        } else {
            return self;
        }
    }

    func domainNameValidate() -> Bool {
        if self.count < 1 || self.count > 63 || self.contains("..") || self.contains("---") {
            return false
        }

        let regex = try! NSRegularExpression(pattern:
            "^[a-z0-9]$"         + "|" +
            "^[a-z0-9][a-z0-9]$" + "|" +
            "^[a-z0-9][a-z0-9\\-]{0,61}[a-z0-9]$"
        )

        let parts = self.split(
            separator: ".",
            maxSplits: 10,
            omittingEmptySubsequences: false
        )

        for part in parts {
            let regexMatches = regex.matches(in: String(part), range: NSRange(location: 0, length: part.count))
            if regexMatches.count != 1 {
                return false
            }
        }

        return true
    }

    func decodePunycode() -> String {
        let decodePart = { (string: String) -> String in
            let regex = try! NSRegularExpression(pattern: "^xn--" + "((?<ascii>[a-z0-9\\-]+)\\-|)" + "(?<codes>[a-z0-9]+)" + "$")
            let regexMatches = regex.findRanges(string: string, rangeNames: ["ascii", "codes"])
            let ascii = regexMatches["ascii"] ?? ""
            let codes = regexMatches["codes"] ?? ""
            if !codes.isEmpty {
                let base        = 36  // base value for Punycode encoding, representing the number of valid characters
                let tMin        = 1   // minimum threshold for the number of characters to be encoded
                let tMax        = 26  // maximum threshold for the number of characters to be encoded
                let damp        = 700 // damping factor used in the adaptation of the bias
                let skew        = 38  // skew value used in the adaptation of the bias
                var bias        = 72  // initial bias value for the encoding process
                var newCharCode = 128 // initial value for the encoded characters

                enum DivisionError: Error {
                    case divisionByZero
                }

                let decodeWeight = { (char: Character) -> Int? in
                    switch char {
                        case "a": return 0;   case "k": return 10;   case "u": return 20;   case "0": return 26;
                        case "b": return 1;   case "l": return 11;   case "v": return 21;   case "1": return 27;
                        case "c": return 2;   case "m": return 12;   case "w": return 22;   case "2": return 28;
                        case "d": return 3;   case "n": return 13;   case "x": return 23;   case "3": return 29;
                        case "e": return 4;   case "o": return 14;   case "y": return 24;   case "4": return 30;
                        case "f": return 5;   case "p": return 15;   case "z": return 25;   case "5": return 31;
                        case "g": return 6;   case "q": return 16;                          case "6": return 32;
                        case "h": return 7;   case "r": return 17;                          case "7": return 33;
                        case "i": return 8;   case "s": return 18;                          case "8": return 34;
                        case "j": return 9;   case "t": return 19;                          case "9": return 35;   default: return nil
                    }
                }

                let adaptBias = { (delta: Int, numberOfPoints: Int, firstTime: Bool) throws -> Int in
                    var delta = delta
                    var k = 0
                    if firstTime {delta /= damp}
                    else         {delta /= 2}
                    delta += delta / numberOfPoints
                    while delta > ((base - tMin) * tMax) / 2 {
                        delta /= base - tMin
                        k     += base
                    }
                    guard delta + skew != 0 else {
                        throw DivisionError.divisionByZero
                    }
                    return k + ((base - tMin + 1) * delta) / (delta + skew)
                }

                let decodeCore = { (ascii: String, codes: String) -> String? in
                    var result: [Character] = [] + ascii
                    var codes = codes
                    var position = 0
                    while !codes.isEmpty {
                        let oldPosition = position
                        var weight = 1
                        var k = base
                        repeat {
                            let code = codes.removeFirst()
                            guard let digit = decodeWeight(code) else {
                                return nil
                            }
                            position += digit * weight
                            let t = k <= bias        ? tMin :
                                   (k >= bias + tMax ? tMax : k - bias)
                            if digit < t {
                                break
                            }
                            weight *= base - t
                            k      += base
                        } while !codes.isEmpty
                        do {
                            bias = try adaptBias(position - oldPosition, result.count + 1, oldPosition == 0)
                        } catch {
                            return nil
                        }
                        newCharCode += position / (result.count + 1)
                        position    %=            (result.count + 1)
                        guard newCharCode >= 0x80, let scalar = UnicodeScalar(newCharCode) else {
                            return nil
                        }
                        guard Character(scalar).isLetter ||
                              Character(scalar).isNumber else {
                            return nil
                        }
                        result.insert(Character(scalar), at: position)
                        position += 1
                    }
                    return String(result)
                }

                let result = decodeCore(ascii, codes)
                if result != nil && ascii == result! { // if no effects
                    return string
                }
                return result ?? string
            }
            // if no codes
            return string
        }

        // main functionality
        if self.contains("xn--") {
            if self.contains(".") {
                let parts = self.split(separator: ".")
                var decodedResults: [String] = []
                for part in parts {
                    if part.contains("xn--") {decodedResults.append(decodePart(String(part)))}
                    else                     {decodedResults.append(           String(part)) }
                }
                return decodedResults.joined(
                    separator: "."
                )
            } else {
                return decodePart(self)
            }
        }

        // if no effects
        return self
    }



 /* ###################
    ### DEVELOPMENT ###
    ################### */

    #if DEBUG

    static func test_domainNameValidate() {
        let domainNames = [
            "0"                                 : true, // local DNS
            "x"                                 : true, // local DNS
            "domain"                            : true, // local DNS
            "sub3.sub2.sub1.d--o--m--a--i--n"   : true, // local DNS
            "sub3.sub2.sub1.d--o--m--a--i--n.by": true,
            "x.com"                             : true,
            "0.x.com"                           : true,
            "127.0.0.1"                         : true,
            "x.127.0.0.1"                       : true, // local DNS
            "0.127.0.0.1"                       : true, // local DNS
         // ============================================
            ""                                  : false,
            "-"                                 : false,
            "."                                 : false,
            "домен"                             : false,
            ".domain"                           : false,
            "domain."                           : false,
            "domain..name"                      : false,
            "-domain"                           : false,
            "domain-"                           : false,
            "domain---name"                     : false,
            "0123456789-0123456789-0123456789-0123456789-0123456789-01234567": true,
            "0123456789-0123456789-0123456789-0123456789-0123456789-0123456789": false,
        ]

        for name in domainNames {
            let result = name.key.domainNameValidate()
            if (result) == name.value {print("\(name.key) → \(result) | OK")}
            if (result) != name.value {print("\(name.key) → \(result) | ERROR")}
        }
    }

    static func test_decodePunycode() {
        let words = [
            "xn--90a"                    : "б"            ,
            "xn----9sb"                  : "б-"           ,
            "xn----btb"                  : "-б"           ,
            "xn--80acde"                 : "абвг"         ,
            "abcd"                       : "abcd"         ,
            "xn--abcd-u8d"               : "ёabcd"        ,
            "xn--"                       : "xn--"         , // wrong by syntax (ascii part = n/a, codes part = n/a)
            "xn---"                      : "xn---"        , // wrong by syntax (ascii part = n/a, codes part = n/a)
            "xn--y"                      : "xn--y"        , // wrong by value
            "xn----"                     : "xn----"       , // wrong by syntax (ascii part = "-", codes part = n/a)
            "xn--y-"                     : "xn--y-"       , // wrong by syntax (ascii part = "y", codes part = n/a)
            "xn---y"                     : "xn---y"       , // wrong by syntax (ascii part = n/a, codes part = "y")
            "xn--y-z"                    : "xn--y-z"      , // wrong by value
            "xn--abcd-v8d"               : "aёbcd"        ,
            "xn--abcd-w8d"               : "abёcd"        ,
            "xn--abcd-x8d"               : "abcёd"        ,
            "xn--abcd-y8d"               : "abcdё"        ,
            "a-b-c-d"                    : "a-b-c-d"      ,
            "xn--a-b-c-d-lng"            : "ёa-b-c-d"     ,
            "xn--a-b-c-d-mng"            : "aё-b-c-d"     ,
            "xn--a-b-c-d-nng"            : "a-ёb-c-d"     ,
            "xn--a-b-c-d-ong"            : "a-bё-c-d"     ,
            "xn--a-b-c-d-png"            : "a-b-ёc-d"     ,
            "xn--a-b-c-d-qng"            : "a-b-cё-d"     ,
            "xn--a-b-c-d-rng"            : "a-b-c-ёd"     ,
            "xn--a-b-c-d-sng"            : "a-b-c-dё"     ,
            "xn---a-b-c-d-vbhklm5q"      : "ёпрст-a-b-c-d",
            "xn--a-b-c-d--3bhklm5q"      : "a-b-c-d-ёпрст",
            "xn--r1aadaaghijkl"          : "ттуууфхцчшщ"  ,
            "xn--bcher-kva"              : "bücher"       ,
            "xn--90ais"                  : "бел"          ,
            "xn--80abnmycp7evc"          : "обращения"    ,
            "xn--80abnmycp7evc.xn--90ais": "обращения.бел",
            "обращения.xn--90ais"        : "обращения.бел",
            "xn--80abnmycp7evc.бел"      : "обращения.бел",
        ]

        for word in words {
            let decodeValue = word.key.decodePunycode()
            if (decodeValue) == word.value {print("\(word.key) → \(decodeValue) | OK")}
            if (decodeValue) != word.value {print("\(word.key) → \(decodeValue) | ERROR")}
        }

        let symbols = [
            "a", "k", "u", "0",
            "b", "l", "v", "1",
            "c", "m", "w", "2",
            "d", "n", "x", "3",
            "e", "o", "y", "4",
            "f", "p", "z", "5",
            "g", "q", "-", "6",
            "h", "r",      "7",
            "i", "s",      "8",
            "j", "t",      "9",
        ]

        for _ in 0...100 {
            var word = ""
            for _ in 0...Int.random(in: 3..<65) {
                word += symbols.randomElement()!
            }
            print(
                word.decodePunycode()
            )
        }

        print("test done")

    }

    #endif

}
