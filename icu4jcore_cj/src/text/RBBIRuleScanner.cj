package icu4cj.text


class RBBIRuleScanner {
    private static let kStackSize = 100

    var fRB: RBBIRuleBuilder

    var fScanIndex: Int32 = 0

    var fNextIndex: Int32 = 0

    var fQuoteMode: Bool = false

    var fLineNum: Int32 = 0

    var fCharNum: Int32 = 0

    var fLastChar: Int32 = 0

    var fC: RBBIRuleScanner_RBBIRuleChar = RBBIRuleScanner_RBBIRuleChar()

    var fStack: Array<Int16> = Array<Int16>(Int64(kStackSize)) { _ => 0 }

    var fStackPtr: Int32 = 0

    var fNodeStack: Array<RBBINode> = Array<RBBINode>(Int64(kStackSize))

    var fNodeStackPtr: Int32 = 0

    var fReverseRule: Bool = false

    var fLookAheadRule: Bool = false

    var fNoChainInRule: Bool = false

    var fSymbolTable: RBBISymbolTable

    var fSetTable: HashMap<String, RBBIRuleScanner_RBBISetTableEl> = HashMap<String, RBBIRuleScanner_RBBISetTableEl>()

    var fRuleSets: Array<UnicodeSet> = Array<UnicodeSet>(10)

    var fRuleNum: Int32 = 0

    var fOptionStart: Int32 = 0

    private static var gRuleSet_rule_char_pattern: String = "[^[\\p{Z}\\u{0020}-\\u{007f}]-[\\p{L}]-[\\p{N}]]"

    private static var gRuleSet_name_char_pattern: String = "[_\\p{L}\\p{N}]"

    private static var gRuleSet_digit_char_pattern: String = "[0-9]"

    private static var gRuleSet_name_start_char_pattern: String = "[_\\p{L}]"

    private static var gRuleSet_white_space_pattern: String = "[\\p{Pattern_White_Space}]"

    private static var kAny: String = "any"

    init(rb: RBBIRuleBuilder) {
        fRB = rb
        fLineNum = 1
        fRuleSets[Int64(Int32(RBBIRuleParseTable.kRuleSet_rule_char) - 128)] = UnicodeSet(gRuleSet_rule_char_pattern)
        fRuleSets[Int64(Int32(RBBIRuleParseTable.kRuleSet_white_space) - 128)] = UnicodeSet(gRuleSet_white_space_pattern)
        fRuleSets[Int64(Int32(RBBIRuleParseTable.kRuleSet_name_char) - 128)] = UnicodeSet(gRuleSet_name_char_pattern)
        fRuleSets[Int64(Int32(RBBIRuleParseTable.kRuleSet_name_start_char) - 128)] = UnicodeSet(gRuleSet_name_start_char_pattern)
        fRuleSets[Int64(Int32(RBBIRuleParseTable.kRuleSet_digit_char) - 128)] = UnicodeSet(gRuleSet_digit_char_pattern)
        fSymbolTable = RBBISymbolTable(this)
    }

    public func doParseActions(action: Int32): Bool {
        var n: RBBINode
        var returnVal = true
        match (action) {
            case 11 =>
                pushNewNode(RBBINode.opStart)
                fRuleNum++
            case 14 => fNoChainInRule = true
            case 9 =>
                fixOpStack(RBBINode.precOpCat)
                let operandNode = fNodeStack[Int64(match (0) { case _ => fNodeStackPtr--; fNodeStackPtr + 1 })]
                let orNode = pushNewNode(RBBINode.opOr)
                orNode.fLeftChild = operandNode
                operandNode.fParent = orNode
            case 7 =>
                fixOpStack(RBBINode.precOpCat)
                let operandNode = fNodeStack[Int64(match (0) { case _ => fNodeStackPtr--; fNodeStackPtr + 1 })]
                let catNode = pushNewNode(RBBINode.opCat)
                catNode.fLeftChild = operandNode
                operandNode.fParent = catNode
            case 12 => pushNewNode(RBBINode.opLParen)
            case 10 => fixOpStack(RBBINode.precLParen)
            case 13 => ()
            case 23 =>
                n = fNodeStack[Int64(fNodeStackPtr - 1)]
                n.fFirstPos = fNextIndex
                pushNewNode(RBBINode.opStart)
            case 3 =>
                fixOpStack(RBBINode.precStart)
                let startExprNode = fNodeStack[Int64(fNodeStackPtr - 2)]
                let varRefNode = fNodeStack[Int64(fNodeStackPtr - 1)]
                let RHSExprNode = fNodeStack[Int64(fNodeStackPtr)]
                RHSExprNode.fFirstPos = startExprNode.fFirstPos
                RHSExprNode.fLastPos = fScanIndex
                RHSExprNode.fText = fRB.fRules[Int64(RHSExprNode.fFirstPos)..Int64(RHSExprNode.fLastPos)]
                varRefNode.fLeftChild = RHSExprNode
                RHSExprNode.fParent = varRefNode
                fSymbolTable.addEntry(varRefNode.fText, varRefNode)
                fNodeStackPtr -= 3
                break
            case 4 =>
                fixOpStack(RBBINode.precStart)
                if (fRB.fDebugEnv.isSome() && indexOfWrap(fRB.fDebugEnv.indexOf("rtree")) >= 0) {
                    printNodeStack("end of rule")
                }
                Assert.assrt(fNodeStackPtr == 1)
                var thisRule = fNodeStack[Int64(fNodeStackPtr)]
                if (fLookAheadRule) {
                    let endNode = pushNewNode(RBBINode.endMark)
                    let catNode = pushNewNode(RBBINode.opCat)
                    fNodeStackPtr -= 2
                    catNode.fLeftChild = thisRule
                    catNode.fRightChild = endNode
                    fNodeStack[Int64(fNodeStackPtr)] = catNode
                    endNode.fVal = fRuleNum
                    endNode.fLookAheadEnd = true
                    thisRule = catNode
                }
                thisRule.fRuleRoot = true
                if (fRB.fChainRules && !fNoChainInRule) {
                    thisRule.fChainIn = true
                }
                let destRules = (if (fReverseRule) { RBBIRuleBuilder.fSafeRevTree } else { fRB.fDefaultTree })
                if (fRB.fTreeRoots[Int64(destRules)].isSome()) {
                    thisRule = fNodeStack[Int64(fNodeStackPtr)]
                    let prevRules = fRB.fTreeRoots[Int64(destRules)]
                    let orNode = pushNewNode(RBBINode.opOr)
                    orNode.fLeftChild = prevRules
                    prevRules.fParent = orNode
                    orNode.fRightChild = thisRule
                    thisRule.fParent = orNode
                    fRB.fTreeRoots[Int64(destRules)] = orNode
                } else {
                    fRB.fTreeRoots[Int64(destRules)] = fNodeStack[Int64(fNodeStackPtr)]
                }
                fReverseRule = false
                fLookAheadRule = false
                fNoChainInRule = false
                fNodeStackPtr = 0
            case 19 =>
                error(RBBIRuleBuilder.U_BRK_RULE_SYNTAX)
                returnVal = false
            case 32 => error(RBBIRuleBuilder.U_BRK_RULE_SYNTAX)
            case 29 =>
                let operandNode = fNodeStack[Int64(match (0) { case _ => fNodeStackPtr--; fNodeStackPtr + 1 })]
                let plusNode = pushNewNode(RBBINode.opPlus)
                plusNode.fLeftChild = operandNode
                operandNode.fParent = plusNode
            case 30 =>
                let operandNode = fNodeStack[Int64(match (0) { case _ => fNodeStackPtr--; fNodeStackPtr + 1 })]
                let qNode = pushNewNode(RBBINode.opQuestion)
                qNode.fLeftChild = operandNode
                operandNode.fParent = qNode
            case 31 =>
                let operandNode = fNodeStack[Int64(match (0) { case _ => fNodeStackPtr--; fNodeStackPtr + 1 })]
                let starNode = pushNewNode(RBBINode.opStar)
                starNode.fLeftChild = operandNode
                operandNode.fParent = starNode
            case 18 =>
                n = pushNewNode(RBBINode.setRef)
                let s: String = Char(fC.fChar).toString()
                findSetFor(s, n, None)
                n.fFirstPos = fScanIndex
                n.fLastPos = fNextIndex
                n.fText = fRB.fRules[Int64(n.fFirstPos)..Int64(n.fLastPos)]
                break
            case 2 =>
                n = pushNewNode(RBBINode.setRef)
                findSetFor(kAny, n, None)
                n.fFirstPos = fScanIndex
                n.fLastPos = fNextIndex
                n.fText = fRB.fRules[Int64(n.fFirstPos)..Int64(n.fLastPos)]
                break
            case 22 =>
                n = pushNewNode(RBBINode.lookAhead)
                n.fVal = fRuleNum
                n.fFirstPos = fScanIndex
                n.fLastPos = fNextIndex
                n.fText = fRB.fRules[Int64(n.fFirstPos)..Int64(n.fLastPos)]
                fLookAheadRule = true
            case 24 =>
                n = pushNewNode(RBBINode.tag)
                n.fVal = 0
                n.fFirstPos = fScanIndex
                n.fLastPos = fNextIndex
            case 26 =>
                n = fNodeStack[Int64(fNodeStackPtr)]
                let v = UCharacter.digit(Int32(UInt32(Char(fC.fChar))), 10)
                let update = Int64(n.fVal) * 10 + Int64(v)
                if (update > Int64(Int32.Max)) {
                    error(RBBIRuleBuilder.U_BRK_RULE_SYNTAX)
                }
                n.fVal = Int32(update)
                break
            case 28 =>
                n = fNodeStack[Int64(fNodeStackPtr)]
                n.fLastPos = fNextIndex
                n.fText = fRB.fRules[Int64(n.fFirstPos)..Int64(n.fLastPos)]
            case 27 =>
                error(RBBIRuleBuilder.U_BRK_MALFORMED_RULE_TAG)
                returnVal = false
            case 16 => fOptionStart = fScanIndex
            case 15 =>
                let opt: String = fRB.fRules[Int64(fOptionStart)..Int64(fScanIndex)]
                if (opt == "chain") {
                    fRB.fChainRules = true
                } else if (opt == "forward") {
                    fRB.fDefaultTree = RBBIRuleBuilder.fForwardTree
                } else if (opt == "reverse") {
                    fRB.fDefaultTree = RBBIRuleBuilder.fReverseTree
                } else if (opt == "safe_forward") {
                    fRB.fDefaultTree = RBBIRuleBuilder.fSafeFwdTree
                } else if (opt == "safe_reverse") {
                    fRB.fDefaultTree = RBBIRuleBuilder.fSafeRevTree
                } else if (opt == "lookAheadHardBreak") {
                    fRB.fLookAheadHardBreak = true
                } else if (opt == "quoted_literals_only") {
                    fRuleSets[Int64(Int32(RBBIRuleParseTable.kRuleSet_rule_char) - 128)].clear()
                } else if (opt == "unquoted_literals") {
                    fRuleSets[Int64(Int32(RBBIRuleParseTable.kRuleSet_rule_char) - 128)].applyPattern(gRuleSet_rule_char_pattern)
                } else {
                    error(RBBIRuleBuilder.U_BRK_UNRECOGNIZED_OPTION)
                }
                break
            case 17 => fReverseRule = true
            case 25 =>
                n = pushNewNode(RBBINode.varRef)
                n.fFirstPos = fScanIndex
            case 5 =>
                n = fNodeStack[Int64(fNodeStackPtr)]
                if (n.isNone() || n.fType != RBBINode.varRef) {
                    error(RBBIRuleBuilder.U_BRK_INTERNAL_ERROR)
                    break
                }
                n.fLastPos = fScanIndex
                n.fText = fRB.fRules[Int64(n.fFirstPos + 1)..Int64(n.fLastPos)]
                n.fLeftChild = fSymbolTable.lookupNode(n.fText)
            case 1 =>
                n = fNodeStack[Int64(fNodeStackPtr)]
                if (n.fLeftChild.isNone()) {
                    error(RBBIRuleBuilder.U_BRK_UNDEFINED_VARIABLE)
                    returnVal = false
                }
            case 8 => ()
            case 20 =>
                error(RBBIRuleBuilder.U_BRK_ASSIGN_ERROR)
                returnVal = false
            case 6 => returnVal = false
            case 21 => scanSet()
            case _ =>
                error(RBBIRuleBuilder.U_BRK_INTERNAL_ERROR)
                returnVal = false
        }
        return returnVal
    }

    public func error(e: Int32): Unit {
        let s: String = "Error " + e.toString() + " at line " + fLineNum.toString() + " column " + fCharNum.toString()
        let ex = IllegalArgumentException(s)
        throw ex
    }

    public func fixOpStack(p: Int32): Unit {
        var n: RBBINode
        while (true) {
            n = fNodeStack[Int64(fNodeStackPtr - 1)]
            if (n.fPrecedence == 0) {
                print("RBBIRuleScanner.fixOpStack, bad operator node")
                error(RBBIRuleBuilder.U_BRK_INTERNAL_ERROR)
                return
            }
            if (n.fPrecedence < p || n.fPrecedence <= RBBINode.precLParen) {
                break
            }
            n.fRightChild = fNodeStack[Int64(fNodeStackPtr)]
            fNodeStack[Int64(fNodeStackPtr)].fParent = n
            fNodeStackPtr--
        }
        if (p <= RBBINode.precLParen) {
            if (n.fPrecedence != p) {
                error(RBBIRuleBuilder.U_BRK_MISMATCHED_PAREN)
            }
            fNodeStack[Int64(fNodeStackPtr - 1)] = fNodeStack[Int64(fNodeStackPtr)]
            fNodeStackPtr--
        }
    }

    public func findSetFor(s: String, node: RBBINode, setToAdopt: UnicodeSet): Unit {
        var tempsetToAdopt = setToAdopt
        var el: RBBIRuleScanner_RBBISetTableEl
        el = fSetTable.get(s)
        if (el.isSome()) {
            node.fLeftChild = el.val
            Assert.assrt(node.fLeftChild.fType == RBBINode.uset)
            return
        }
        if (tempsetToAdopt.isNone()) {
            if (s.equals(kAny)) {
                tempsetToAdopt = UnicodeSet(0, 1114111)
            } else {
                let c: Int32
                c = UTF16.toRuneArray()[s, 0]
                tempsetToAdopt = UnicodeSet(c, c)
            }
        }
        let usetNode = RBBINode(RBBINode.uset)
        usetNode.fInputSet = tempsetToAdopt
        usetNode.fParent = node
        node.fLeftChild = usetNode
        usetNode.fText = s
        fRB.fUSetNodes.append(usetNode)
        el = RBBIRuleScanner_RBBISetTableEl()
        el.key = s
        el.val = usetNode
        fSetTable.put(el.key, el)
        return
    }

    static let chNEL = 133

    static let chLS = 8232

    static func stripRules(rules: String): String {
        let strippedRules = StringBuilder()
        let rulesLength = Int32(rules.size)
        var idx = 0
        while (idx < rulesLength) {
            let cp = rules.codePointAt(idx)
            let whiteSpace = UCharacter.hasBinaryProperty(cp, UProperty.PATTERN_WHITE_SPACE)
            if (whiteSpace) {
                continue
            }
            strippedRules.appendCodePoint(cp)
            idx = rules.offsetByCodePoints(idx, 1)
        }
        return strippedRules.toString()
    }

    public func nextCharLL(): Int32 {
        let ch: Int32
        if (fNextIndex >= Int32(fRB.fRules.size)) {
            return -1
        }
        ch = UTF16.toRuneArray()[fRB.fRules, fNextIndex]
        if (Character.isBmpCodePoint(ch) && Character.isSurrogate(Char(ch))) {
            error(RBBIRuleBuilder.U_ILLEGAL_CHAR_FOUND)
        }
        fNextIndex = UTF16.moveCodePointOffset(fRB.fRules, fNextIndex, 1)
        if (ch == Int32(UInt32('\r')) || ch == chNEL || ch == chLS || ch == Int32(UInt32('\n')) && fLastChar != Int32(UInt32('\r'))) {
            fLineNum++
            fCharNum = 0
            if (fQuoteMode) {
                error(RBBIRuleBuilder.U_BRK_NEW_LINE_IN_QUOTED_STRING)
                fQuoteMode = false
            }
        } else {
            if (ch != Int32(UInt32('\n'))) {
                fCharNum++
            }
        }
        fLastChar = ch
        return ch
    }

    public func nextChar(c: RBBIRuleScanner_RBBIRuleChar): Unit {
        fScanIndex = fNextIndex
        c.fChar = nextCharLL()
        c.fEscaped = false
        if (c.fChar == Int32(UInt32('''))) {
            if (fNextIndex < Int32(fRB.fRules.size) && UTF16.toRuneArray()[fRB.fRules, fNextIndex] == Int32(UInt32('''))) {
                c.fChar = nextCharLL()
                c.fEscaped = true
            } else {
                fQuoteMode = !fQuoteMode
                if (fQuoteMode == true) {
                    c.fChar = Int32(UInt32('('))
                } else {
                    c.fChar = Int32(UInt32(')'))
                }
                c.fEscaped = false
                return
            }
        }
        if (c.fChar == -1) {
            return
        }
        if (fQuoteMode) {
            c.fEscaped = true
        } else {
            if (c.fChar == Int32(UInt32('#'))) {
                let commentStart = fScanIndex
                while (true) {
                    c.fChar = nextCharLL()
                    if (c.fChar == -1 || c.fChar == Int32(UInt32('\r')) || c.fChar == Int32(UInt32('\n')) || c.fChar == chNEL || c.fChar == chLS) {
                        break
                    }
                }
                var i = commentStart
                while (i < fNextIndex - 1) {
                    fRB.fStrippedRules.insert(Int64(i), ' ')
                    i++
                }
            }
            if (c.fChar == -1) {
                return
            }
            if (c.fChar == Int32(UInt32('\'))) {
                c.fEscaped = true
                let cpAndLength = Utility.unescapeAndLengthAt(fRB.fRules, fNextIndex)
                if (cpAndLength < 0) {
                    error(RBBIRuleBuilder.U_BRK_HEX_DIGITS_EXPECTED)
                }
                c.fChar = Utility.cpFromCodePointAndLength(cpAndLength)
                let length = Utility.lengthFromCodePointAndLength(cpAndLength)
                fCharNum += length
                fNextIndex += length
            }
        }
    }

    public func parse(): Unit {
        var state: Int32 = 0
        var tableEl: RBBIRuleParseTable_RBBIRuleTableElement
        state = 1
        nextChar(fC)
        while (true) {
            if (state == 0) {
                break
            }
            tableEl = RBBIRuleParseTable.gRuleParseStateTable[Int64(state)]
            if (fRB.fDebugEnv.isSome() && indexOfWrap(fRB.fDebugEnv.indexOf("scan")) >= 0) {
                println("char, line, col = ('" + Char(fC.fChar).toString() + "', " + fLineNum.toString() + ", " + fCharNum.toString() + "    state = " + (tableEl.fStateName))
            }
            var tableRow = state
            while (true) {
                tableEl = RBBIRuleParseTable.gRuleParseStateTable[Int64(tableRow)]
                if (fRB.fDebugEnv.isSome() && indexOfWrap(fRB.fDebugEnv.indexOf("scan")) >= 0) {
                    print(".")
                }
                if (Int32(tableEl.fCharClass) < 127 && fC.fEscaped == false && Int32(tableEl.fCharClass) == fC.fChar) {
                    break
                }
                if (Int32(tableEl.fCharClass) == 255) {
                    break
                }
                if (Int32(tableEl.fCharClass) == 254 && fC.fEscaped) {
                    break
                }
                if (Int32(tableEl.fCharClass) == 253 && fC.fEscaped && (fC.fChar == 80 || fC.fChar == 112)) {
                    break
                }
                if (Int32(tableEl.fCharClass) == 252 && fC.fChar == -1) {
                    break
                }
                if (Int32(tableEl.fCharClass) >= 128 && Int32(tableEl.fCharClass) < 240 && fC.fEscaped == false && fC.fChar != -1) {
                    let uniset = fRuleSets[Int64(Int32(tableEl.fCharClass) - 128)]
                    if (uniset.contains(fC.fChar)) {
                        break
                    }
                }
                tableRow++
            }
            if (fRB.fDebugEnv.isSome() && indexOfWrap(fRB.fDebugEnv.indexOf("scan")) >= 0) {
                println("")
            }
            if (doParseActions(Int32(tableEl.fAction)) == false) {
                break
            }
            if (Int32(tableEl.fPushState) != 0) {
                fStackPtr++
                if (fStackPtr >= kStackSize) {
                    println("RBBIRuleScanner.parse() - state stack overflow.")
                    error(RBBIRuleBuilder.U_BRK_INTERNAL_ERROR)
                }
                fStack[Int64(fStackPtr)] = tableEl.fPushState
            }
            if (tableEl.fNextChar) {
                nextChar(fC)
            }
            if (Int32(tableEl.fNextState) != 255) {
                state = Int32(tableEl.fNextState)
            } else {
                state = Int32(fStack[Int64(fStackPtr)])
                fStackPtr--
                if (fStackPtr < 0) {
                    println("RBBIRuleScanner.parse() - state stack underflow.")
                    error(RBBIRuleBuilder.U_BRK_INTERNAL_ERROR)
                }
            }
        }
        if (fRB.fTreeRoots[Int64(RBBIRuleBuilder.fForwardTree)].isNone()) {
            error(RBBIRuleBuilder.U_BRK_RULE_SYNTAX)
        }
        if (fRB.fDebugEnv.isSome() && indexOfWrap(fRB.fDebugEnv.indexOf("symbols")) >= 0) {
            fSymbolTable.rbbiSymtablePrint()
        }
        if (fRB.fDebugEnv.isSome() && indexOfWrap(fRB.fDebugEnv.indexOf("ptree")) >= 0) {
            println("Completed Forward Rules Parse Tree...")
            fRB.fTreeRoots[Int64(RBBIRuleBuilder.fForwardTree)].printTree(true)
            println("\nCompleted Reverse Rules Parse Tree...")
            fRB.fTreeRoots[Int64(RBBIRuleBuilder.fReverseTree)].printTree(true)
            println("\nCompleted Safe Point Forward Rules Parse Tree...")
            if (fRB.fTreeRoots[Int64(RBBIRuleBuilder.fSafeFwdTree)].isNone()) {
                println("  -- null -- ")
            } else {
                fRB.fTreeRoots[Int64(RBBIRuleBuilder.fSafeFwdTree)].printTree(true)
            }
            println("\nCompleted Safe Point Reverse Rules Parse Tree...")
            if (fRB.fTreeRoots[Int64(RBBIRuleBuilder.fSafeRevTree)].isNone()) {
                println("  -- null -- ")
            } else {
                fRB.fTreeRoots[Int64(RBBIRuleBuilder.fSafeRevTree)].printTree(true)
            }
        }
    }

    public func printNodeStack(title: String): Unit {
        var i: Int32 = 0
        println((title) + ".  Dumping node stack...\n")
        i = fNodeStackPtr
        while (i > 0) {
            fNodeStack[Int64(i)].printTree(true)
            i--
        }
    }

    public func pushNewNode(nodeType: Int32): RBBINode {
        fNodeStackPtr++
        if (fNodeStackPtr >= kStackSize) {
            println("RBBIRuleScanner.pushNewNode - stack overflow.")
            error(RBBIRuleBuilder.U_BRK_INTERNAL_ERROR)
        }
        fNodeStack[Int64(fNodeStackPtr)] = RBBINode(nodeType)
        return fNodeStack[Int64(fNodeStackPtr)]
    }

    public func scanSet(): Unit {
        var uset: UnicodeSet
        let startPos: Int32
        let pos = ParsePosition(fScanIndex)
        let i: Int32
        startPos = fScanIndex
        try {
            uset = UnicodeSet(fRB.fRules, pos, fSymbolTable, UnicodeSet.IGNORE_SPACE)
        } catch (e: Exception) {
            error(RBBIRuleBuilder.U_BRK_MALFORMED_SET)
        }
        let tempSet = UnicodeSet(uset)
        tempSet.removeAllStrings()
        if (tempSet.isEmpty()) {
            error(RBBIRuleBuilder.U_BRK_RULE_EMPTY_SET)
        }
        i = pos.getIndex()
        while (true) {
            if (fNextIndex >= i) {
                break
            }
            nextCharLL()
        }
        let n: RBBINode
        n = pushNewNode(RBBINode.setRef)
        n.fFirstPos = startPos
        n.fLastPos = fNextIndex
        n.fText = fRB.fRules[Int64(n.fFirstPos)..Int64(n.fLastPos)]
        findSetFor(n.fText, n, uset)
    }

    public func numRules(): Int32 {
        return fRuleNum
    }
}


class RBBIRuleScanner_RBBIRuleChar {

    var fChar: Int32 = 0

    var fEscaped: Bool = false
}


class RBBIRuleScanner_RBBISetTableEl {

    var key: String

    var val: RBBINode
}
