package icu4cj.text

class RBBISymbolTable <: SymbolTable {
    var fHashTable: HashMap<String, RBBISymbolTable_RBBISymbolTableEntry> = None

    var fRuleScanner: RBBIRuleScanner

    var ffffString: String

    var fCachedSetLookup: UnicodeSet

    init(rs: RBBIRuleScanner) {
        fRuleScanner = rs
        fHashTable = HashMap<String, RBBISymbolTable_RBBISymbolTableEntry>()
        ffffString = "\u{ffff}"
    }

    public override func lookup(s: String): Array<Char> {
        let el: RBBISymbolTable_RBBISymbolTableEntry
        var varRefNode: RBBINode
        let exprNode: RBBINode
        let usetNode: RBBINode
        let retString: String
        el = fHashTable.get(s)
        if (el.isNone()) {
            return None
        }
        varRefNode = el.val
        while (varRefNode.fLeftChild.fType == RBBINode.varRef) {
            varRefNode = varRefNode.fLeftChild
        }
        exprNode = varRefNode.fLeftChild
        if (exprNode.fType == RBBINode.setRef) {
            usetNode = exprNode.fLeftChild
            fCachedSetLookup = usetNode.fInputSet
            retString = ffffString
        } else {
            fRuleScanner.error(RBBIRuleBuilder.U_BRK_MALFORMED_SET)
            retString = exprNode.fText
            fCachedSetLookup = None
        }
        return retString.toRuneArray()
    }

    public override func lookupMatcher(ch: Int32): UnicodeMatcher {
        var retVal: UnicodeSet
        if (ch == 65535) {
            retVal = fCachedSetLookup
            fCachedSetLookup = None
        }
        return retVal
    }

    public override func parseReference(text: String, pos: ParsePosition, limit: Int32): String {
        let start = pos.getIndex()
        var i = start
        var result: String = ""
        while (i < limit) {
            let c = UTF16.toRuneArray()[text, i]
            if ((i == start && !UCharacter.isUnicodeIdentifierStart(c)) || !UCharacter.isUnicodeIdentifierPart(c)) {
                break
            }
            i += UTF16.getCharCount(c)
        }
        if (i == start) {
            return result
        }
        pos.setIndex(i)
        result = text[Int64(start)..Int64(i)]
        return result
    }

    public func lookupNode(key: String): RBBINode {
        var retNode: RBBINode
        let el: RBBISymbolTable_RBBISymbolTableEntry
        el = fHashTable.get(key)
        if (el.isSome()) {
            retNode = el.val
        }
        return retNode
    }

    public func addEntry(key: String, val: RBBINode): Unit {
        var e: RBBISymbolTable_RBBISymbolTableEntry
        e = fHashTable.get(key)
        if (e.isSome()) {
            fRuleScanner.error(RBBIRuleBuilder.U_BRK_VARIABLE_REDFINITION)
            return
        }
        e = RBBISymbolTable_RBBISymbolTableEntry()
        e.key = key
        e.val = val
        fHashTable.put(e.key, e)
    }

    public func rbbiSymtablePrint(): Unit {
        print("Variable Definitions\nName               Node Val     String Val\n----------------------------------------------------------------------\n")
        let syms = fHashTable.values().toArray(Array<RBBISymbolTable_RBBISymbolTableEntry>(0))
        } while (false)
        println("\nParsed Variable Definitions\n")
        } while (false)
    }
}


class RBBISymbolTable_RBBISymbolTableEntry {

    var key: String

    var val: RBBINode
}
