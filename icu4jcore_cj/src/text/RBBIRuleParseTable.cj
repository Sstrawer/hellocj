package icu4cj.text

class RBBIRuleParseTable {

    static let doCheckVarDef = 1i16

    static let doDotAny = 2i16

    static let doEndAssign = 3i16

    static let doEndOfRule = 4i16

    static let doEndVariableName = 5i16

    static let doExit = 6i16

    static let doExprCatOperator = 7i16

    static let doExprFinished = 8i16

    static let doExprOrOperator = 9i16

    static let doExprRParen = 10i16

    static let doExprStart = 11i16

    static let doLParen = 12i16

    static let doNOP = 13i16

    static let doNoChain = 14i16

    static let doOptionEnd = 15i16

    static let doOptionStart = 16i16

    static let doReverseDir = 17i16

    static let doRuleChar = 18i16

    static let doRuleError = 19i16

    static let doRuleErrorAssignExpr = 20i16

    static let doScanUnicodeSet = 21i16

    static let doSlash = 22i16

    static let doStartAssign = 23i16

    static let doStartTagValue = 24i16

    static let doStartVariableName = 25i16

    static let doTagDigit = 26i16

    static let doTagExpectedError = 27i16

    static let doTagValue = 28i16

    static let doUnaryOpPlus = 29i16

    static let doUnaryOpQuestion = 30i16

    static let doUnaryOpStar = 31i16

    static let doVariableNameExpectedErr = 32i16

    static let kRuleSet_default = 255i16

    static let kRuleSet_digit_char = 128i16

    static let kRuleSet_eof = 252i16

    static let kRuleSet_escaped = 254i16

    static let kRuleSet_name_char = 129i16

    static let kRuleSet_name_start_char = 130i16

    static let kRuleSet_rule_char = 131i16

    static let kRuleSet_white_space = 132i16

    static var gRuleParseStateTable: Array<RBBIRuleParseTable_RBBIRuleTableElement> = [RBBIRuleParseTable_RBBIRuleTableElement(doNOP, 0, 0, 0, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprStart, 254, 29, 9, false, "start"), RBBIRuleParseTable_RBBIRuleTableElement(doNOP, 132, 1, 0, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doNoChain, Int32(UInt32('^')), 12, 9, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprStart, Int32(UInt32('$')), 88, 98, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doNOP, Int32(UInt32('!')), 19, 0, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doNOP, Int32(UInt32(';')), 1, 0, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doNOP, 252, 0, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprStart, 255, 29, 9, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doEndOfRule, Int32(UInt32(';')), 1, 0, true, "break-rule-end"), RBBIRuleParseTable_RBBIRuleTableElement(doNOP, 132, 9, 0, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doRuleError, 255, 103, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprStart, 254, 29, 0, false, "start-after-caret"), RBBIRuleParseTable_RBBIRuleTableElement(doNOP, 132, 12, 0, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doRuleError, Int32(UInt32('^')), 103, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprStart, Int32(UInt32('$')), 88, 37, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doRuleError, Int32(UInt32(';')), 103, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doRuleError, 252, 103, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprStart, 255, 29, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doNOP, Int32(UInt32('!')), 21, 0, true, "rev-option"), RBBIRuleParseTable_RBBIRuleTableElement(doReverseDir, 255, 28, 9, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doOptionStart, 130, 23, 0, true, "option-scan1"), RBBIRuleParseTable_RBBIRuleTableElement(doRuleError, 255, 103, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doNOP, 129, 23, 0, true, "option-scan2"), RBBIRuleParseTable_RBBIRuleTableElement(doOptionEnd, 255, 25, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doNOP, Int32(UInt32(';')), 1, 0, true, "option-scan3"), RBBIRuleParseTable_RBBIRuleTableElement(doNOP, 132, 25, 0, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doRuleError, 255, 103, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprStart, 255, 29, 9, false, "reverse-rule"), RBBIRuleParseTable_RBBIRuleTableElement(doRuleChar, 254, 38, 0, true, "term"), RBBIRuleParseTable_RBBIRuleTableElement(doNOP, 132, 29, 0, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doRuleChar, 131, 38, 0, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doNOP, Int32(UInt32('[')), 94, 38, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doLParen, Int32(UInt32('(')), 29, 38, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doNOP, Int32(UInt32('$')), 88, 37, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doDotAny, Int32(UInt32('.')), 38, 0, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doRuleError, 255, 103, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doCheckVarDef, 255, 38, 0, false, "term-var-ref"), RBBIRuleParseTable_RBBIRuleTableElement(doNOP, 132, 38, 0, true, "expr-mod"), RBBIRuleParseTable_RBBIRuleTableElement(doUnaryOpStar, Int32(UInt32('*')), 43, 0, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doUnaryOpPlus, Int32(UInt32('+')), 43, 0, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doUnaryOpQuestion, Int32(UInt32('?')), 43, 0, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doNOP, 255, 43, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprCatOperator, 254, 29, 0, false, "expr-cont"), RBBIRuleParseTable_RBBIRuleTableElement(doNOP, 132, 43, 0, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprCatOperator, 131, 29, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprCatOperator, Int32(UInt32('[')), 29, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprCatOperator, Int32(UInt32('(')), 29, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprCatOperator, Int32(UInt32('$')), 29, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprCatOperator, Int32(UInt32('.')), 29, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprCatOperator, Int32(UInt32('/')), 55, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprCatOperator, Int32(UInt32('{')), 67, 0, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprOrOperator, Int32(UInt32('|')), 29, 0, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprRParen, Int32(UInt32(')')), 255, 0, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprFinished, 255, 255, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doSlash, Int32(UInt32('/')), 57, 0, true, "look-ahead"), RBBIRuleParseTable_RBBIRuleTableElement(doNOP, 255, 103, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprCatOperator, 254, 29, 0, false, "expr-cont-no-slash"), RBBIRuleParseTable_RBBIRuleTableElement(doNOP, 132, 43, 0, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprCatOperator, 131, 29, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprCatOperator, Int32(UInt32('[')), 29, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprCatOperator, Int32(UInt32('(')), 29, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprCatOperator, Int32(UInt32('$')), 29, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprCatOperator, Int32(UInt32('.')), 29, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprOrOperator, Int32(UInt32('|')), 29, 0, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprRParen, Int32(UInt32(')')), 255, 0, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprFinished, 255, 255, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doNOP, 132, 67, 0, true, "tag-open"), RBBIRuleParseTable_RBBIRuleTableElement(doStartTagValue, 128, 70, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doTagExpectedError, 255, 103, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doNOP, 132, 74, 0, true, "tag-value"), RBBIRuleParseTable_RBBIRuleTableElement(doNOP, Int32(UInt32('}')), 74, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doTagDigit, 128, 70, 0, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doTagExpectedError, 255, 103, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doNOP, 132, 74, 0, true, "tag-close"), RBBIRuleParseTable_RBBIRuleTableElement(doTagValue, Int32(UInt32('}')), 77, 0, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doTagExpectedError, 255, 103, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprCatOperator, 254, 29, 0, false, "expr-cont-no-tag"), RBBIRuleParseTable_RBBIRuleTableElement(doNOP, 132, 77, 0, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprCatOperator, 131, 29, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprCatOperator, Int32(UInt32('[')), 29, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprCatOperator, Int32(UInt32('(')), 29, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprCatOperator, Int32(UInt32('$')), 29, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprCatOperator, Int32(UInt32('.')), 29, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprCatOperator, Int32(UInt32('/')), 55, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprOrOperator, Int32(UInt32('|')), 29, 0, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprRParen, Int32(UInt32(')')), 255, 0, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doExprFinished, 255, 255, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doStartVariableName, Int32(UInt32('$')), 90, 0, true, "scan-var-name"), RBBIRuleParseTable_RBBIRuleTableElement(doNOP, 255, 103, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doNOP, 130, 92, 0, true, "scan-var-start"), RBBIRuleParseTable_RBBIRuleTableElement(doVariableNameExpectedErr, 255, 103, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doNOP, 129, 92, 0, true, "scan-var-body"), RBBIRuleParseTable_RBBIRuleTableElement(doEndVariableName, 255, 255, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doScanUnicodeSet, Int32(UInt32('[')), 255, 0, true, "scan-unicode-set"), RBBIRuleParseTable_RBBIRuleTableElement(doScanUnicodeSet, Int32(UInt32('p')), 255, 0, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doScanUnicodeSet, Int32(UInt32('P')), 255, 0, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doNOP, 255, 103, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doNOP, 132, 98, 0, true, "assign-or-rule"), RBBIRuleParseTable_RBBIRuleTableElement(doStartAssign, Int32(UInt32('=')), 29, 101, true, None), RBBIRuleParseTable_RBBIRuleTableElement(doNOP, 255, 37, 9, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doEndAssign, Int32(UInt32(';')), 1, 0, true, "assign-end"), RBBIRuleParseTable_RBBIRuleTableElement(doRuleErrorAssignExpr, 255, 103, 0, false, None), RBBIRuleParseTable_RBBIRuleTableElement(doExit, 255, 103, 0, true, "errorDeath")]
}


class RBBIRuleParseTable_RBBIRuleTableElement {
    var fAction: Int16 = 0

    var fCharClass: Int16 = 0

    var fNextState: Int16 = 0

    var fPushState: Int16 = 0

    var fNextChar: Bool = false

    var fStateName: String

    init(a: Int16, cc: Int32, ns: Int32, ps: Int32, nc: Bool, sn: String) {
        fAction = a
        fCharClass = Int16(cc)
        fNextState = Int16(ns)
        fPushState = Int16(ps)
        fNextChar = nc
        fStateName = sn
    }
}
