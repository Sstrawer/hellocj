package icu4cj.text


class RBBISetBuilder {
    var fRB: RBBIRuleBuilder

    var fRangeList: RBBISetBuilder_RangeDescriptor

    var fTrie: MutableCodePointTrie

    var fFrozenTrie: CodePointTrie

    var fGroupCount: Int32 = 0

    var fDictCategoriesStart: Int32 = 0

    var fSawBOF: Bool = false

    init(rb: RBBIRuleBuilder) {
        fRB = rb
    }

    public func buildRanges(): Unit {
        var rlRange: RBBISetBuilder_RangeDescriptor
        if (fRB.fDebugEnv.isSome() && indexOfWrap(fRB.fDebugEnv.indexOf("usets")) >= 0) {
            printSets()
        }
        fRangeList = RBBISetBuilder_RangeDescriptor()
        fRangeList.fStartChar = 0
        fRangeList.fEndChar = 1114111
        for (usetNode in fRB.fUSetNodes) {
            let inputSet = usetNode.fInputSet
            let inputSetRangeCount = inputSet.getRangeCount()
            var inputSetRangeIndex = 0
            rlRange = fRangeList
            while (true) {
                if (inputSetRangeIndex >= inputSetRangeCount) {
                    break
                }
                let inputSetRangeBegin = inputSet.getRangeStart(inputSetRangeIndex)
                let inputSetRangeEnd = inputSet.getRangeEnd(inputSetRangeIndex)
                while (rlRange.fEndChar < inputSetRangeBegin) {
                    rlRange = rlRange.fNext
                }
                if (rlRange.fStartChar < inputSetRangeBegin) {
                    rlRange.split(inputSetRangeBegin)
                    continue
                }
                if (rlRange.fEndChar > inputSetRangeEnd) {
                    rlRange.split(inputSetRangeEnd + 1)
                }
                if (rlRange.fIncludesSets.indexOf(usetNode) == -1) {
                    rlRange.fIncludesSets.append(usetNode)
                }
                if (inputSetRangeEnd == rlRange.fEndChar) {
                    inputSetRangeIndex++
                }
                rlRange = rlRange.fNext
            }
        }
        if (fRB.fDebugEnv.isSome() && indexOfWrap(fRB.fDebugEnv.indexOf("range")) >= 0) {
            printRanges()
        }
        var rlSearchRange: RBBISetBuilder_RangeDescriptor
        var dictGroupCount = 0
        rlRange = fRangeList
        while (rlRange.isSome()) {
            rlSearchRange = fRangeList
            while (!refEq(rlSearchRange, rlRange)) {
                if (refEq(rlRange.fIncludesSets, rlSearchRange.fIncludesSets)) {
                    rlRange.fNum = rlSearchRange.fNum
                    rlRange.fIncludesDict = rlSearchRange.fIncludesDict
                    break
                }
                rlSearchRange = rlSearchRange.fNext
            }
            if (rlRange.fNum == 0) {
                rlRange.fFirstInGroup = true
                if (rlRange.isDictionaryRange()) {
                    rlRange.fNum = match (0) { case _ => dictGroupCount++; dictGroupCount }
                    rlRange.fIncludesDict = true
                } else {
                    fGroupCount++
                    rlRange.fNum = fGroupCount + 2
                    addValToSets(rlRange.fIncludesSets, fGroupCount + 2)
                }
            }
            rlRange = rlRange.fNext
        }
        fDictCategoriesStart = fGroupCount + 3
        rlRange = fRangeList
        while (rlRange.isSome()) {
            if (rlRange.fIncludesDict) {
                rlRange.fNum += fDictCategoriesStart - 1
                if (rlRange.fFirstInGroup) {
                    addValToSets(rlRange.fIncludesSets, rlRange.fNum)
                }
            }
            rlRange = rlRange.fNext
        }
        fGroupCount += dictGroupCount
        let eofString = "eof"
        let bofString = "bof"
        for (usetNode in fRB.fUSetNodes) {
            let inputSet = usetNode.fInputSet
            if (inputSet.contains(eofString)) {
                addValToSet(usetNode, 1)
            }
            if (inputSet.contains(bofString)) {
                addValToSet(usetNode, 2)
                fSawBOF = true
            }
        }
        if (fRB.fDebugEnv.isSome() && indexOfWrap(fRB.fDebugEnv.indexOf("rgroup")) >= 0) {
            printRangeGroups()
        }
        if (fRB.fDebugEnv.isSome() && indexOfWrap(fRB.fDebugEnv.indexOf("esets")) >= 0) {
            printSets()
        }
    }

    private static let MAX_CHAR_CATEGORIES_FOR_8BITS_TRIE = 255

    public func buildTrie(): Unit {
        fTrie = MutableCodePointTrie(0, 0)
        var rlRange = fRangeList
        while (rlRange.isSome()) {
            fTrie.setRange(rlRange.fStartChar, rlRange.fEndChar, rlRange.fNum)
            rlRange = rlRange.fNext
        }
    }

    public func mergeCategories(categories: RBBIRuleBuilder_IntPair): Unit {
        if (!(categories.first >= 1)) {
            throw AssertionError()
        }
        if (!(categories.second > categories.first)) {
            throw AssertionError()
        }
        if (!((categories.first < fDictCategoriesStart && categories.second < fDictCategoriesStart) || (categories.first >= fDictCategoriesStart && categories.second >= fDictCategoriesStart))) {
            throw AssertionError()
        }
        var rd = fRangeList
        while (rd.isSome()) {
            let rangeNum = rd.fNum
            if (rangeNum == categories.second) {
                rd.fNum = categories.first
            } else if (rangeNum > categories.second) {
                rd.fNum--
            }
            rd = rd.fNext
        }
        fGroupCount--
        if (categories.second <= fDictCategoriesStart) {
            fDictCategoriesStart--
        }
    }

    public func freezeTrieIfNotYet(): Unit {
        if (fFrozenTrie.isNone()) {
            let use8Bits = getNumCharCategories() <= MAX_CHAR_CATEGORIES_FOR_8BITS_TRIE
            fFrozenTrie = fTrie.buildImmutable(CodePointTrie_Type.FAST, if (use8Bits) { CodePointTrie_ValueWidth.BITS_8 } else { CodePointTrie_ValueWidth.BITS_16 })
            fTrie = None
        }
    }

    public func getTrieSize(): Int32 {
        freezeTrieIfNotYet()
        return fFrozenTrie.toBinary(ByteArrayStream())
    }

    public func serializeTrie(os: OutputStream): Unit {
        freezeTrieIfNotYet()
        fFrozenTrie.toBinary(os)
    }

    public func addValToSets(sets: ArrayList<RBBINode>, val: Int32): Unit {
        for (usetNode in sets) {
            addValToSet(usetNode, val)
        }
    }

    public func addValToSet(usetNode: RBBINode, val: Int32): Unit {
        let leafNode = RBBINode(RBBINode.leafChar)
        leafNode.fVal = val
        if (usetNode.fLeftChild.isNone()) {
            usetNode.fLeftChild = leafNode
            leafNode.fParent = usetNode
        } else {
            let orNode = RBBINode(RBBINode.opOr)
            orNode.fLeftChild = usetNode.fLeftChild
            orNode.fRightChild = leafNode
            orNode.fLeftChild.fParent = orNode
            orNode.fRightChild.fParent = orNode
            usetNode.fLeftChild = orNode
            orNode.fParent = usetNode
        }
    }

    public func getNumCharCategories(): Int32 {
        return fGroupCount + 3
    }

    public func getDictCategoriesStart(): Int32 {
        return fDictCategoriesStart
    }

    public func sawBOF(): Bool {
        return fSawBOF
    }

    public func getFirstChar(category: Int32): Int32 {
        var rlRange: RBBISetBuilder_RangeDescriptor
        var retVal = -1
        rlRange = fRangeList
        while (rlRange.isSome()) {
            if (rlRange.fNum == category) {
                retVal = rlRange.fStartChar
                break
            }
            rlRange = rlRange.fNext
        }
        return retVal
    }

    public func printRanges(): Unit {
        var rlRange: RBBISetBuilder_RangeDescriptor
        var i: Int32 = 0
        print("\n\n Nonoverlapping Ranges ...\n")
        rlRange = fRangeList
        while (rlRange.isSome()) {
            Console.stdOut.printf("%04x-%04x ", [rlRange.fStartChar, rlRange.fEndChar])
            i = 0
            while (i < Int32(rlRange.fIncludesSets.size)) {
                let usetNode = rlRange.fIncludesSets[Int64(i)]
                var setName: String = "anon"
                let setRef = usetNode.fParent
                if (setRef.isSome()) {
                    let varRef = setRef.fParent
                    if (varRef.isSome() && varRef.fType == RBBINode.varRef) {
                        setName = varRef.fText
                    }
                }
                print(setName)
                print("  ")
                i++
            }
            println("")
            rlRange = rlRange.fNext
        }
    }

    public func printRangeGroups(): Unit {
        var i: Int32 = 0
        print("\nRanges grouped by Unicode Set Membership...\n")
        var rlRange = fRangeList
        while (rlRange.isSome()) {
            if (rlRange.fFirstInGroup) {
                let groupNum = rlRange.fNum
                if (groupNum < 10) {
                    print(" ")
                }
                print(groupNum.toString() + " ")
                if (groupNum >= fDictCategoriesStart) {
                    print(" <DICT> ")
                }
                i = 0
                while (i < Int32(rlRange.fIncludesSets.size)) {
                    let usetNode = rlRange.fIncludesSets[Int64(i)]
                    var setName: String = "anon"
                    let setRef = usetNode.fParent
                    if (setRef.isSome()) {
                        let varRef = setRef.fParent
                        if (varRef.isSome() && varRef.fType == RBBINode.varRef) {
                            setName = varRef.fText
                        }
                    }
                    print(setName)
                    print(" ")
                    i++
                }
                i = 0
                var tRange = rlRange
                while (tRange.isSome()) {
                    if (tRange.fNum == rlRange.fNum) {
                        if (match (0) { case _ => i++; i - 1 } % 5 == 0) {
                            print("\n    ")
                        }
                        RBBINode.printHex(tRange.fStartChar, -1)
                        print("-")
                        RBBINode.printHex(tRange.fEndChar, 0)
                    }
                    tRange = tRange.fNext
                }
                print("\n")
            }
            rlRange = rlRange.fNext
        }
        print("\n")
    }

    public func printSets(): Unit {
        var i: Int32 = 0
        print("\n\nUnicode Sets List\n------------------\n")
        i = 0
        while (i < Int32(fRB.fUSetNodes.size)) {
            let usetNode: RBBINode
            let setRef: RBBINode
            let varRef: RBBINode
            var setName: String
            usetNode = fRB.fUSetNodes[Int64(i)]
            RBBINode.printInt(2, i)
            setName = "anonymous"
            setRef = usetNode.fParent
            if (setRef.isSome()) {
                varRef = setRef.fParent
                if (varRef.isSome() && varRef.fType == RBBINode.varRef) {
                    setName = varRef.fText
                }
            }
            print("  " + (setName))
            print("   ")
            print(usetNode.fText)
            print("\n")
            if (usetNode.fLeftChild.isSome()) {
                usetNode.fLeftChild.printTree(true)
            }
            i++
        }
        print("\n")
    }
}


class RBBISetBuilder_RangeDescriptor {
    var fStartChar = 0

    var fEndChar = 0

    var fNum = 0

    var fIncludesDict = false

    var fFirstInGroup = false

    var fIncludesSets: ArrayList<RBBINode>

    var fNext: RBBISetBuilder_RangeDescriptor

    init() {
        fIncludesSets = ArrayList<RBBINode>()
    }

    init(other: RBBISetBuilder_RangeDescriptor) {
        fStartChar = other.fStartChar
        fEndChar = other.fEndChar
        fNum = other.fNum
        fIncludesDict = other.fIncludesDict
        fFirstInGroup = other.fFirstInGroup
        fIncludesSets = ArrayList<RBBINode>(other.fIncludesSets)
    }

    public func split(`where`: Int32): Unit {
        Assert.assrt(`where` > fStartChar && `where` <= fEndChar)
        let nr = RBBISetBuilder_RangeDescriptor(this)
        nr.fStartChar = `where`
        this.fEndChar = `where` - 1
        nr.fNext = this.fNext
        this.fNext = nr
    }

    public func isDictionaryRange(): Bool {
        var i = 0
        while (i < Int32(this.fIncludesSets.size)) {
            let usetNode = fIncludesSets[Int64(i)]
            var setName: String = ""
            let setRef = usetNode.fParent
            if (setRef.isSome()) {
                let varRef = setRef.fParent
                if (varRef.isSome() && varRef.fType == RBBINode.varRef) {
                    setName = varRef.fText
                }
            }
            if (setName == "dictionary") {
                return true
            }
            i++
        }
        return false
    }
}
