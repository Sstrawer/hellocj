package icu4cj.text


class RBBIRuleBuilder {
    var fDebugEnv: String

    var fRules: String

    var fStrippedRules: StringBuilder

    var fScanner: RBBIRuleScanner

    var fTreeRoots: Array<RBBINode> = Array<RBBINode>(4)

    static let fForwardTree = 0

    static let fReverseTree = 1

    static let fSafeFwdTree = 2

    static let fSafeRevTree = 3

    var fDefaultTree = fForwardTree

    var fChainRules: Bool = false

    var fLookAheadHardBreak: Bool = false

    var fSetBuilder: RBBISetBuilder

    var fUSetNodes: ArrayList<RBBINode>

    var fForwardTable: RBBITableBuilder

    var fStatusSets: Map<Set<Int32>, Int32> = HashMap<Set<Int32>, Int32>() as Map<Set<Int32>, Int32>

    var fRuleStatusVals: ArrayList<Int32>

    static let U_ILLEGAL_CHAR_FOUND = 12

    static let U_BRK_ERROR_START = 66048

    static let U_BRK_INTERNAL_ERROR = 66049

    static let U_BRK_HEX_DIGITS_EXPECTED = 66050

    static let U_BRK_SEMICOLON_EXPECTED = 66051

    static let U_BRK_RULE_SYNTAX = 66052

    static let U_BRK_UNCLOSED_SET = 66053

    static let U_BRK_ASSIGN_ERROR = 66054

    static let U_BRK_VARIABLE_REDFINITION = 66055

    static let U_BRK_MISMATCHED_PAREN = 66056

    static let U_BRK_NEW_LINE_IN_QUOTED_STRING = 66057

    static let U_BRK_UNDEFINED_VARIABLE = 66058

    static let U_BRK_INIT_ERROR = 66059

    static let U_BRK_RULE_EMPTY_SET = 66060

    static let U_BRK_UNRECOGNIZED_OPTION = 66061

    static let U_BRK_MALFORMED_RULE_TAG = 66062

    static let U_BRK_MALFORMED_SET = 66063

    static let U_BRK_ERROR_LIMIT = 66064

    init(rules: String) {
        fDebugEnv = if (ICUDebug.enabled("rbbi")) { ICUDebug.value("rbbi") } else { None }
        fRules = rules
        fStrippedRules = StringBuilder(rules)
        fUSetNodes = ArrayList<RBBINode>()
        fRuleStatusVals = ArrayList<Int32>()
        fScanner = RBBIRuleScanner(this)
        fSetBuilder = RBBISetBuilder(this)
    }

    static func align8(i: Int32): Int32 {
        return (i + 7) & -8
    }

    public func flattenData(os: OutputStream): Unit {
        let dos = DataOutputStream(os)
        var i: Int32 = 0
        let strippedRules = RBBIRuleScanner.stripRules(fStrippedRules.toString())
        let headerSize = RBBIDataWrapper.DH_SIZE * 4
        let forwardTableSize = align8(fForwardTable.getTableSize())
        let reverseTableSize = align8(fForwardTable.getSafeTableSize())
        let trieSize = align8(fSetBuilder.getTrieSize())
        let statusTableSize = align8(Int32(fRuleStatusVals.size) * 4)
        let strippedRulesUTF8 = strippedRules.toArray()
        let rulesSize = align8(Int32(strippedRulesUTF8.size) + 1)
        let totalSize = headerSize + forwardTableSize + reverseTableSize + statusTableSize + trieSize + rulesSize
        var outputPos = 0
        ICUBinary.writeHeader(RBBIDataWrapper.DATA_FORMAT, RBBIDataWrapper.FORMAT_VERSION, 0, dos)
        let header = Array<Int32>(Int64(RBBIDataWrapper.DH_SIZE)) { _ => 0 }
        header[Int64(RBBIDataWrapper.DH_MAGIC)] = 45472
        header[Int64(RBBIDataWrapper.DH_FORMATVERSION)] = RBBIDataWrapper.FORMAT_VERSION
        header[Int64(RBBIDataWrapper.DH_LENGTH)] = totalSize
        header[Int64(RBBIDataWrapper.DH_CATCOUNT)] = fSetBuilder.getNumCharCategories()
        header[Int64(RBBIDataWrapper.DH_FTABLE)] = headerSize
        header[Int64(RBBIDataWrapper.DH_FTABLELEN)] = forwardTableSize
        header[Int64(RBBIDataWrapper.DH_RTABLE)] = header[Int64(RBBIDataWrapper.DH_FTABLE)] + forwardTableSize
        header[Int64(RBBIDataWrapper.DH_RTABLELEN)] = reverseTableSize
        header[Int64(RBBIDataWrapper.DH_TRIE)] = header[Int64(RBBIDataWrapper.DH_RTABLE)] + header[Int64(RBBIDataWrapper.DH_RTABLELEN)]
        header[Int64(RBBIDataWrapper.DH_TRIELEN)] = fSetBuilder.getTrieSize()
        header[Int64(RBBIDataWrapper.DH_STATUSTABLE)] = header[Int64(RBBIDataWrapper.DH_TRIE)] + trieSize
        header[Int64(RBBIDataWrapper.DH_STATUSTABLELEN)] = statusTableSize
        header[Int64(RBBIDataWrapper.DH_RULESOURCE)] = header[Int64(RBBIDataWrapper.DH_STATUSTABLE)] + statusTableSize
        header[Int64(RBBIDataWrapper.DH_RULESOURCELEN)] = Int32(strippedRulesUTF8.size)
        i = 0
        while (i < Int32(header.size)) {
            dos.writeInt(header[Int64(i)])
            outputPos += 4
            i++
        }
        var table = fForwardTable.exportTable()
        if (!(outputPos == header[Int64(RBBIDataWrapper.DH_FTABLE)])) {
            throw AssertionError()
        }
        outputPos += table.put(dos)
        table = fForwardTable.exportSafeTable()
        Assert.assrt(outputPos == header[Int64(RBBIDataWrapper.DH_RTABLE)])
        outputPos += table.put(dos)
        Assert.assrt(outputPos == header[Int64(RBBIDataWrapper.DH_TRIE)])
        fSetBuilder.serializeTrie(os)
        outputPos += header[Int64(RBBIDataWrapper.DH_TRIELEN)]
        while (outputPos % 8 != 0) {
            dos.write(0)
            outputPos += 1
        }
        Assert.assrt(outputPos == header[Int64(RBBIDataWrapper.DH_STATUSTABLE)])
        for (val in fRuleStatusVals) {
            dos.writeInt(val)
            outputPos += 4
        }
        while (outputPos % 8 != 0) {
            dos.write(0)
            outputPos += 1
        }
        Assert.assrt(outputPos == header[Int64(RBBIDataWrapper.DH_RULESOURCE)])
        dos.write(strippedRulesUTF8, 0, Int32(strippedRulesUTF8.size))
        dos.write(0)
        outputPos += Int32(strippedRulesUTF8.size) + 1
        while (outputPos % 8 != 0) {
            dos.write(0)
            outputPos += 1
        }
    }

    static func compileRules(rules: String, os: OutputStream): Unit {
        let builder = RBBIRuleBuilder(rules)
        builder.build(os)
    }

    public func build(os: OutputStream): Unit {
        fScanner.parse()
        fSetBuilder.buildRanges()
        fForwardTable = RBBITableBuilder(this, fForwardTree)
        fForwardTable.buildForwardTable()
        optimizeTables()
        fForwardTable.buildSafeReverseTable()
        if (fDebugEnv.isSome() && indexOfWrap(fDebugEnv.indexOf("states")) >= 0) {
            fForwardTable.printStates()
            fForwardTable.printRuleStatusTable()
            fForwardTable.printReverseTable()
        }
        fSetBuilder.buildTrie()
        flattenData(os)
    }

    public func optimizeTables(): Unit {
        var didSomething: Bool = false
            while (fForwardTable.removeDuplicateStates() > 0) {
                didSomething = true
            }
        } while (didSomething)
    }
}


class RBBIRuleBuilder_IntPair {
    var first = 0

    var second = 0


    init(f: Int32, s: Int32) {
        first = f
        second = s
    }
}
