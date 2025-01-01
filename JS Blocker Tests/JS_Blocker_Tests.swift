
import Testing

struct JS_Blocker_Tests {

    @Test func domainNameValidate() async throws {
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
            let received = name.key.domainNameValidate()
            let expected = name.value
            print("item '\(name.key)'")
            #expect(expected == received)
        }
    }

    @Test func decodePunycode() async throws {
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
            let received = word.key.decodePunycode()
            let expected = word.value
            print("item '\(word.key)'")
            #expect(expected == received)
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
                "demo: " + word.decodePunycode()
            )
        }
    }

}
