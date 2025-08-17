package icu4cj.text

class RBNFChinesePostProcessor <: RBNFPostProcessor {

    private var longForm: Bool = false

    private var format: Int32 = 0

    private static let rulesetNames: Array<String> = ["%traditional", "%simplified", "%accounting", "%time"]

    public override func initself(formatter: RuleBasedNumberFormat, rules: String): Unit { }

    public override func process(buf: StringBuilder, ruleSet: NFRuleSet): Unit {
        let name = ruleSet.getName()
                i++
            }
        } while (false)
        if (longForm) {
            } while (false)
            return
        }
        let DIAN = "\u{9ede}"
        let markers: Array<Array<String>> = [["\u{842c}", "\u{5104}", "\u{5146}", "\u{3007}"], ["\u{4e07}", "\u{4ebf}", "\u{5146}", "\u{3007}"], ["\u{842c}", "\u{5104}", "\u{5146}", "\u{96f6}"]]
                    i++
                }
            } while (false)
        } while (false)
        var x = buf.indexOf(DIAN)
        if (x == -1) {
            x = Int32(buf.size)
        }
        var s = 0
        var n = -1
        let ling = markers[Int64(format)][3]
        while (x >= 0) {
            let m = buf.lastIndexOf("|", x)
            let nn = buf.lastIndexOf(ling, x)
            var ns = 0
            if (nn > m) {
                ns = if (nn > 0 && buf.get(Int64(nn - 1)) != '*') { 2 } else { 1 }
            }
            x = m - 1
            match (s * 3 + ns) {
                case 0 =>
                    s = ns
                    n = -1
                case 1 =>
                    s = ns
                    n = nn
                case 2 =>
                    s = ns
                    n = -1
                case 3 =>
                    s = ns
                    n = -1
                case 4 =>
                    buf.delete(nn - 1, nn + Int32(ling.size))
                    s = 0
                    n = -1
                case 5 =>
                    buf.delete(n - 1, n + Int32(ling.size))
                    s = ns
                    n = -1
                case 6 =>
                    s = ns
                    n = -1
                case 7 =>
                    buf.delete(nn - 1, nn + Int32(ling.size))
                    s = 0
                    n = -1
                case 8 =>
                    s = ns
                    n = -1
                case _ => throw Exception()
            }
        }
            }
        } while (false)
    }
}
