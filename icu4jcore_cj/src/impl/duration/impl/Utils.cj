package icu4cj.impl.duration.impl


public class Utils {

    public static func localeFromString(s: String): Locale {
        var language = s
        var region: String = ""
        var variant: String = ""
        var x = indexOfWrap(language.indexOf("_"))
        if (x != -1) {
            region = language[Int64(x + 1)..]
            language = language[0..Int64(x)]
        }
        x = indexOfWrap(region.indexOf("_"))
        if (x != -1) {
            variant = region[Int64(x + 1)..]
            region = region[0..Int64(x)]
        }
        return Locale(language, region, variant)
    }

    public static func chineseNumber(n: Int64, zh: Utils_ChineseDigits): String {
        var tempn = n
        if (tempn < 0) {
            tempn = -tempn
        }
        if (tempn <= 10) {
            if (tempn == 2) {
                return zh.liang.toString()
            }
            return zh.digits[Int64(Int32(tempn))].toString()
        }
        let buf = Array<Char>(40) { _ => '\u{0000}' }
        let digits: Array<Char> = tempn.toString().toRuneArray()
        var inZero = true
        var forcedZero = false
        var x = Int32(buf.size)
                    u++
                } else {
                    buf[Int64(match (0) { case _ => x--; x })] = zh.units[Int64(match (0) { case _ => u++; u - 1 })]
                    if (u == 3) {
                        u = -1
                        l++
                    }
                }
                let d = 
                if (d == 0) {
                    if (x < Int32(buf.size) - 1 && u != 0) {
                        buf[Int64(x)] = '*'
                    }
                    if (inZero || forcedZero) {
                        buf[Int64(match (0) { case _ => x--; x })] = '*'
                    } else {
                        buf[Int64(match (0) { case _ => x--; x })] = zh.digits[0]
                        inZero = true
                        forcedZero = u == 1
                    }
                } else {
                    inZero = false
                    buf[Int64(match (0) { case _ => x--; x })] = zh.digits[Int64(d)]
                }
            }
        } while (false)
        if (tempn > 1000000) {
            var last = true
            var i = Int32(buf.size) - 3
                i -= 8
                last = !last
            } while (i > x)
            i = Int32(buf.size) - 7
                i -= 8
                last = !last
            } while (i > x)
            if (tempn >= 100000000) {
                i = Int32(buf.size) - 8
                        j--
                    }
                    if (empty) {
                        if (buf[Int64(i + 1)] != '*' && buf[Int64(i + 1)] != zh.digits[0]) {
                            buf[Int64(i)] = zh.digits[0]
                        } else {
                            buf[Int64(i)] = '*'
                        }
                    }
                    i -= 8
                } while (i > x)
            }
        }
                if (i < Int32(buf.size) - 1 && buf[Int64(i + 1)] == zh.units[0]) {
                    continue
                }
                if (i > x && (buf[Int64(i - 1)] == zh.units[0] || buf[Int64(i - 1)] == zh.digits[0] || buf[Int64(i - 1)] == '*')) {
                    continue
                }
                buf[Int64(i)] = zh.liang
                i++
            }
        } while (false)
        if (buf[Int64(x)] == zh.digits[1] && (zh.ko || buf[Int64(x + 1)] == zh.units[0])) {
            x++
        }
        var w = x
        var r = x
        while (r < Int32(buf.size)) {
            if (buf[Int64(r)] != '*') {
                buf[Int64(match (0) { case _ => w++; w - 1 })] = buf[Int64(r)]
            }
            r++
        }
        return String(buf)[Int64(x)..Int64(x) + Int64(w - x)]
    }
}


public class Utils_ChineseDigits {
    let digits: Array<Char>

    let units: Array<Char>

    let levels: Array<Char>

    let liang: Char

    let ko: Bool

    init(digits: String, units: String, levels: String, liang: Char, ko: Bool) {
        this.digits = digits.toRuneArray()
        this.units = units.toRuneArray()
        this.levels = levels.toRuneArray()
        this.liang = liang
        this.ko = ko
    }

    public static let DEBUG = Utils_ChineseDigits("0123456789s", "sbq", "WYZ", 'L', false)

    public static let TRADITIONAL = Utils_ChineseDigits("\u{96f6}\u{4e00}\u{4e8c}\u{4e09}\u{56db}\u{4e94}\u{516d}\u{4e03}\u{516b}\u{4e5d}\u{5341}", "\u{5341}\u{767e}\u{5343}", "\u{842c}\u{5104}\u{5146}", '\u{5169}', false)

    public static let SIMPLIFIED = Utils_ChineseDigits("\u{96f6}\u{4e00}\u{4e8c}\u{4e09}\u{56db}\u{4e94}\u{516d}\u{4e03}\u{516b}\u{4e5d}\u{5341}", "\u{5341}\u{767e}\u{5343}", "\u{4e07}\u{4ebf}\u{5146}", '\u{4e24}', false)

    public static let KOREAN = Utils_ChineseDigits("\u{c601}\u{c77c}\u{c774}\u{c0bc}\u{c0ac}\u{c624}\u{c721}\u{ce60}\u{d314}\u{ad6c}\u{c2ed}", "\u{c2ed}\u{bc31}\u{cc9c}", "\u{b9cc}\u{c5b5}", '\u{c774}', true)
}
