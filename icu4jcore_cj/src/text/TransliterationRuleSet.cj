package icu4cj.text

class TransliterationRuleSet {
    private var ruleVector: ArrayList<TransliterationRule>

    private var maxContextLength: Int32 = 0

    private var rules: Array<TransliterationRule>

    private var index: Array<Int32>

    public init() {
        ruleVector = ArrayList<TransliterationRule>()
        maxContextLength = 0
    }

    public func getMaximumContextLength(): Int32 {
        return maxContextLength
    }

    public func addRule(rule: TransliterationRule): Unit {
        ruleVector.append(rule)
        let len: Int32
        if ((match (0) { case _ => len = rule.getAnteContextLength(); len }) > maxContextLength) {
            maxContextLength = len
        }
        rules = None
    }

    public func freeze(): Unit {
        let n = Int32(ruleVector.size)
        index = Array<Int32>(257) { _ => 0 }
        let v = ArrayList<TransliterationRule>(Int64(2 * n))
        let indexValue = Array<Int32>(Int64(n)) { _ => 0 }
        } while (false)
                        } else {
                            let r = ruleVector[Int64(j)]
                            if (r.matchesIndexValue(x)) {
                                v.append(r)
                            }
                        }
                        j++
                    }
                } while (false)
                x++
            }
        } while (false)
        index[256] = Int32(v.size)
        rules = Array<TransliterationRule>(v.size)
        v.toArray(rules)
        var errors: StringBuilder
                                    errors.append("\n")
                                }
                                errors.append("Rule " + r1.asString() + " masks " + r2.asString())
                            }
                            k++
                        }
                        j++
                    }
                } while (false)
                x++
            }
        } while (false)
        if (errors.isSome()) {
            throw IllegalArgumentException(errors.toString())
        }
    }

    public func transliterate(text: Replaceable, pos: Transliterator_Position, incremental: Bool): Bool {
        let indexByte = text.char32At(pos.start) & 255
        var i = index[Int64(indexByte)]
        while (i < index[Int64(indexByte + 1)]) {
            let m = rules[Int64(i)].matchAndReplace(text, pos, incremental)
            match (m) {
                case 2 =>
                    if (Transliterator.DEBUG) {
                        println((if (incremental) { "Rule.i: match " } else { "Rule: match " }) + (rules[Int64(i)].toRule(true)) + " => " + (UtilityExtensions.formatInput(text, pos)))
                    }
                    return true
                case 1 =>
                    if (Transliterator.DEBUG) {
                        println((if (incremental) { "Rule.i: partial match " } else { "Rule: partial match " }) + (rules[Int64(i)].toRule(true)) + " => " + (UtilityExtensions.formatInput(text, pos)))
                    }
                    return false
                case _ => if (Transliterator.DEBUG) {
                    println("Rule: no match " + rules[Int64(i)].asString())
                }
            }
            i++
        }
        pos.start += UTF16.getCharCount(text.char32At(pos.start))
        if (Transliterator.DEBUG) {
            println((if (incremental) { "Rule.i: no match => " } else { "Rule: no match => " }) + (UtilityExtensions.formatInput(text, pos)))
        }
        return true
    }

    public func toRules(escapeUnprintable: Bool): String {
        var i: Int32 = 0
        let count = Int32(ruleVector.size)
        let ruleSource = StringBuilder()
        i = 0
        while (i < count) {
            if (i != 0) {
                ruleSource.append('\n')
            }
            let r = ruleVector[Int64(i)]
            ruleSource.append(r.toRule(escapeUnprintable))
            i++
        }
        return ruleSource.toString()
    }

    public func addSourceTargetSet(filter: UnicodeSet, sourceSet: UnicodeSet, targetSet: UnicodeSet): Unit {
        let currentFilter = UnicodeSet(filter)
        let revisiting = UnicodeSet()
        let count = Int32(ruleVector.size)
        var i = 0
        while (i < count) {
            let r = ruleVector[Int64(i)]
            r.addSourceTargetSet(currentFilter, sourceSet, targetSet, revisiting.clear())
            currentFilter.addAll(revisiting)
            i++
        }
    }
}
