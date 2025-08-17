package icu4cj.text


class RBBITableBuilder {
    private var fRB: RBBIRuleBuilder

    private var fRootIx: Int32 = 0

    private var fDStates: ArrayList<RBBITableBuilder_RBBIStateDescriptor>

    private var fSafeTable: ArrayList<Array<Int16>>

    private static let MAX_STATE_FOR_8BITS_TABLE = 255

    var fLookAheadRuleMap: Array<Int32>

    var fLASlotsInUse = RBBIDataWrapper.ACCEPTING_UNCONDITIONAL

    init(rb: RBBIRuleBuilder, rootNodeIx: Int32) {
        fRootIx = rootNodeIx
        fRB = rb
        fDStates = ArrayList<RBBITableBuilder_RBBIStateDescriptor>()
    }

    public func buildForwardTable(): Unit {
        if (fRB.fTreeRoots[Int64(fRootIx)].isNone()) {
            return
        }
        fRB.fTreeRoots[Int64(fRootIx)] = fRB.fTreeRoots[Int64(fRootIx)].flattenVariables(0)
        if (fRB.fDebugEnv.isSome() && indexOfWrap(fRB.fDebugEnv.indexOf("ftree")) >= 0) {
            println("Parse tree after flattening variable references.")
            fRB.fTreeRoots[Int64(fRootIx)].printTree(true)
        }
        if (fRB.fSetBuilder.sawBOF()) {
            let bofTop = RBBINode(RBBINode.opCat)
            let bofLeaf = RBBINode(RBBINode.leafChar)
            bofTop.fLeftChild = bofLeaf
            bofTop.fRightChild = fRB.fTreeRoots[Int64(fRootIx)]
            bofLeaf.fParent = bofTop
            bofLeaf.fVal = 2
            fRB.fTreeRoots[Int64(fRootIx)] = bofTop
        }
        let cn = RBBINode(RBBINode.opCat)
        cn.fLeftChild = fRB.fTreeRoots[Int64(fRootIx)]
        fRB.fTreeRoots[Int64(fRootIx)].fParent = cn
        let endMarkerNode = match (0) { case _ => cn.fRightChild = RBBINode(RBBINode.endMark); cn.fRightChild }
        cn.fRightChild.fParent = cn
        fRB.fTreeRoots[Int64(fRootIx)] = cn
        fRB.fTreeRoots[Int64(fRootIx)].flattenSets()
        if (fRB.fDebugEnv.isSome() && indexOfWrap(fRB.fDebugEnv.indexOf("stree")) >= 0) {
            println("Parse tree after flattening Unicode Set references.")
            fRB.fTreeRoots[Int64(fRootIx)].printTree(true)
        }
        calcNullable(fRB.fTreeRoots[Int64(fRootIx)])
        calcFirstPos(fRB.fTreeRoots[Int64(fRootIx)])
        calcLastPos(fRB.fTreeRoots[Int64(fRootIx)])
        calcFollowPos(fRB.fTreeRoots[Int64(fRootIx)])
        if (fRB.fDebugEnv.isSome() && indexOfWrap(fRB.fDebugEnv.indexOf("pos")) >= 0) {
            print("\n")
            printPosSets(fRB.fTreeRoots[Int64(fRootIx)])
        }
        if (fRB.fChainRules) {
            calcChainedFollowPos(fRB.fTreeRoots[Int64(fRootIx)], endMarkerNode)
        }
        if (fRB.fSetBuilder.sawBOF()) {
            bofFixup()
        }
        buildStateTable()
        mapLookAheadRules()
        flagAcceptingStates()
        flagLookAheadStates()
        flagTaggedStates()
        mergeRuleStatusVals()
    }

    public func calcNullable(n: RBBINode): Unit {
        if (n.isNone()) {
            return
        }
        if (n.fType == RBBINode.setRef || n.fType == RBBINode.endMark) {
            n.fNullable = false
            return
        }
        if (n.fType == RBBINode.lookAhead || n.fType == RBBINode.tag) {
            n.fNullable = true
            return
        }
        calcNullable(n.fLeftChild)
        calcNullable(n.fRightChild)
        if (n.fType == RBBINode.opOr) {
            n.fNullable = n.fLeftChild.fNullable || n.fRightChild.fNullable
        } else if (n.fType == RBBINode.opCat) {
            n.fNullable = n.fLeftChild.fNullable && n.fRightChild.fNullable
        } else if (n.fType == RBBINode.opStar || n.fType == RBBINode.opQuestion) {
            n.fNullable = true
        } else {
            n.fNullable = false
        }
    }

    public func calcFirstPos(n: RBBINode): Unit {
        if (n.isNone()) {
            return
        }
        if (n.fType == RBBINode.leafChar || n.fType == RBBINode.endMark || n.fType == RBBINode.lookAhead || n.fType == RBBINode.tag) {
            n.fFirstPosSet.put(n)
            return
        }
        calcFirstPos(n.fLeftChild)
        calcFirstPos(n.fRightChild)
        if (n.fType == RBBINode.opOr) {
            n.fFirstPosSet.putAll(n.fLeftChild.fFirstPosSet)
            n.fFirstPosSet.putAll(n.fRightChild.fFirstPosSet)
        } else if (n.fType == RBBINode.opCat) {
            n.fFirstPosSet.putAll(n.fLeftChild.fFirstPosSet)
            if (n.fLeftChild.fNullable) {
                n.fFirstPosSet.putAll(n.fRightChild.fFirstPosSet)
            }
        } else if (n.fType == RBBINode.opStar || n.fType == RBBINode.opQuestion || n.fType == RBBINode.opPlus) {
            n.fFirstPosSet.putAll(n.fLeftChild.fFirstPosSet)
        }
    }

    public func calcLastPos(n: RBBINode): Unit {
        if (n.isNone()) {
            return
        }
        if (n.fType == RBBINode.leafChar || n.fType == RBBINode.endMark || n.fType == RBBINode.lookAhead || n.fType == RBBINode.tag) {
            n.fLastPosSet.put(n)
            return
        }
        calcLastPos(n.fLeftChild)
        calcLastPos(n.fRightChild)
        if (n.fType == RBBINode.opOr) {
            n.fLastPosSet.putAll(n.fLeftChild.fLastPosSet)
            n.fLastPosSet.putAll(n.fRightChild.fLastPosSet)
        } else if (n.fType == RBBINode.opCat) {
            n.fLastPosSet.putAll(n.fRightChild.fLastPosSet)
            if (n.fRightChild.fNullable) {
                n.fLastPosSet.putAll(n.fLeftChild.fLastPosSet)
            }
        } else if (n.fType == RBBINode.opStar || n.fType == RBBINode.opQuestion || n.fType == RBBINode.opPlus) {
            n.fLastPosSet.putAll(n.fLeftChild.fLastPosSet)
        }
    }

    public func calcFollowPos(n: RBBINode): Unit {
        if (n.isNone() || n.fType == RBBINode.leafChar || n.fType == RBBINode.endMark) {
            return
        }
        calcFollowPos(n.fLeftChild)
        calcFollowPos(n.fRightChild)
        if (n.fType == RBBINode.opCat) {
            for (i in n.fLeftChild.fLastPosSet) {
                i.fFollowPos.putAll(n.fRightChild.fFirstPosSet)
            }
        }
        if (n.fType == RBBINode.opStar || n.fType == RBBINode.opPlus) {
            for (i in n.fLastPosSet) {
                i.fFollowPos.putAll(n.fFirstPosSet)
            }
        }
    }

    public func addRuleRootNodes(dest: ArrayList<RBBINode>, node: RBBINode): Unit {
        if (node.isNone()) {
            return
        }
        if (node.fRuleRoot) {
            dest.append(node)
            return
        }
        addRuleRootNodes(dest, node.fLeftChild)
        addRuleRootNodes(dest, node.fRightChild)
    }

    public func calcChainedFollowPos(tree: RBBINode, endMarkNode: RBBINode): Unit {
        let leafNodes = ArrayList<RBBINode>()
        tree.findNodes(leafNodes, RBBINode.leafChar)
        let ruleRootNodes = ArrayList<RBBINode>()
        addRuleRootNodes(ruleRootNodes, tree)
        let matchStartNodes: Set<RBBINode> = HashSet<RBBINode>()
        for (node in ruleRootNodes) {
            if (node.fChainIn) {
                matchStartNodes.putAll(node.fFirstPosSet)
            }
        }
        for (endNode in leafNodes) {
            if (!endNode.fFollowPos.contains(endMarkNode)) {
                continue
            }
            for (startNode in matchStartNodes) {
                if (startNode.fType != RBBINode.leafChar) {
                    continue
                }
                if (endNode.fVal == startNode.fVal) {
                    endNode.fFollowPos.putAll(startNode.fFollowPos)
                }
            }
        }
    }

    public func bofFixup(): Unit {
        let bofNode = fRB.fTreeRoots[Int64(fRootIx)].fLeftChild.fLeftChild
        Assert.assrt(bofNode.fType == RBBINode.leafChar)
        Assert.assrt(bofNode.fVal == 2)
        let matchStartNodes = fRB.fTreeRoots[Int64(fRootIx)].fLeftChild.fRightChild.fFirstPosSet
        for (startNode in matchStartNodes) {
            if (startNode.fType != RBBINode.leafChar) {
                continue
            }
            if (startNode.fVal == bofNode.fVal) {
                bofNode.fFollowPos.putAll(startNode.fFollowPos)
            }
        }
    }

    public func buildStateTable(): Unit {
        let lastInputSymbol = fRB.fSetBuilder.getNumCharCategories() - 1
        let failState = RBBITableBuilder_RBBIStateDescriptor(lastInputSymbol)
        fDStates.append(failState)
        let initialState = RBBITableBuilder_RBBIStateDescriptor(lastInputSymbol)
        initialState.fPositions.putAll(fRB.fTreeRoots[Int64(fRootIx)].fFirstPosSet)
        fDStates.append(initialState)
        while (true) {
            var T: RBBITableBuilder_RBBIStateDescriptor
            var tx: Int32 = 0
            tx = 1
            while (tx < Int32(fDStates.size)) {
                let temp = fDStates[Int64(tx)]
                if (temp.fMarked == false) {
                    T = temp
                    break
                }
                tx++
            }
            if (T.isNone()) {
                break
            }
            T.fMarked = true
            var a: Int32 = 0
            a = 1
            while (a <= lastInputSymbol) {
                var U: Set<RBBINode>
                for (p in T.fPositions) {
                    if ((p.fType == RBBINode.leafChar) && (p.fVal == a)) {
                        if (U.isNone()) {
                            U = HashSet<RBBINode>()
                        }
                        U.putAll(p.fFollowPos)
                    }
                }
                var ux = 0
                var UinDstates = false
                if (U.isSome()) {
                    Assert.assrt(Int32(U.size) > 0)
                    var ix: Int32 = 0
                    ix = 0
                    while (ix < Int32(fDStates.size)) {
                        let temp2: RBBITableBuilder_RBBIStateDescriptor
                        temp2 = fDStates[Int64(ix)]
                        if (// Мapping is present but failed: refEq(U, temp2.fPositions)) {
                            U = temp2.fPositions
                            ux = ix
                            UinDstates = true
                            break
                        }
                        ix++
                    }
                    if (!UinDstates) {
                        let newState = RBBITableBuilder_RBBIStateDescriptor(lastInputSymbol)
                        newState.fPositions = U
                        fDStates.append(newState)
                        ux = Int32(fDStates.size) - 1
                    }
                    T.fDtran[Int64(a)] = ux
                }
                a++
            }
        }
    }

    public func mapLookAheadRules(): Unit {
        fLookAheadRuleMap = Array<Int32>(Int64(fRB.fScanner.numRules() + 1)) { _ => 0 }
        for (sd in fDStates) {
            var laSlotForState = 0
            var sawLookAheadNode = false
            for (node in sd.fPositions) {
                if (node.fType != RBBINode.lookAhead) {
                    continue
                }
                sawLookAheadNode = true
                let ruleNum = node.fVal
                if (!(ruleNum < Int32(fLookAheadRuleMap.size))) {
                    throw AssertionError()
                }
                if (!(ruleNum > 0)) {
                    throw AssertionError()
                }
                let laSlot = fLookAheadRuleMap[Int64(ruleNum)]
                if (laSlot != 0) {
                    if (laSlotForState == 0) {
                        laSlotForState = laSlot
                    } else {
                        if (!(laSlot == laSlotForState)) {
                            throw AssertionError()
                        }
                    }
                }
            }
            if (!sawLookAheadNode) {
                continue
            }
            if (laSlotForState == 0) {
                laSlotForState = match (0) { case _ => fLASlotsInUse++; fLASlotsInUse }
            }
            for (node in sd.fPositions) {
                if (node.fType != RBBINode.lookAhead) {
                    continue
                }
                let ruleNum = node.fVal
                let existingVal = fLookAheadRuleMap[Int64(ruleNum)]
                if (!(existingVal == 0 || existingVal == laSlotForState)) {
                    throw AssertionError()
                }
                fLookAheadRuleMap[Int64(ruleNum)] = laSlotForState
            }
        }
    }

    public func flagAcceptingStates(): Unit {
        let endMarkerNodes = ArrayList<RBBINode>()
        var endMarker: RBBINode
        var i: Int32 = 0
        var n: Int32 = 0
        fRB.fTreeRoots[Int64(fRootIx)].findNodes(endMarkerNodes, RBBINode.endMark)
        i = 0
        while (i < Int32(endMarkerNodes.size)) {
            endMarker = endMarkerNodes[Int64(i)]
            n = 0
            while (n < Int32(fDStates.size)) {
                let sd = fDStates[Int64(n)]
                if (sd.fPositions.contains(endMarker)) {
                    if (sd.fAccepting == 0) {
                        sd.fAccepting = fLookAheadRuleMap[Int64(endMarker.fVal)]
                        if (sd.fAccepting == 0) {
                            sd.fAccepting = RBBIDataWrapper.ACCEPTING_UNCONDITIONAL
                        }
                    }
                    if (sd.fAccepting == RBBIDataWrapper.ACCEPTING_UNCONDITIONAL && endMarker.fVal != 0) {
                        sd.fAccepting = fLookAheadRuleMap[Int64(endMarker.fVal)]
                    }
                }
                n++
            }
            i++
        }
    }

    public func flagLookAheadStates(): Unit {
        let lookAheadNodes = ArrayList<RBBINode>()
        var lookAheadNode: RBBINode
        var i: Int32 = 0
        var n: Int32 = 0
        fRB.fTreeRoots[Int64(fRootIx)].findNodes(lookAheadNodes, RBBINode.lookAhead)
        i = 0
        while (i < Int32(lookAheadNodes.size)) {
            lookAheadNode = lookAheadNodes[Int64(i)]
            n = 0
            while (n < Int32(fDStates.size)) {
                let sd = fDStates[Int64(n)]
                if (sd.fPositions.contains(lookAheadNode)) {
                    let lookaheadSlot = fLookAheadRuleMap[Int64(lookAheadNode.fVal)]
                    if (!(sd.fLookAhead == 0 || sd.fLookAhead == lookaheadSlot)) {
                        throw AssertionError()
                    }
                    sd.fLookAhead = lookaheadSlot
                }
                n++
            }
            i++
        }
    }

    public func flagTaggedStates(): Unit {
        let tagNodes = ArrayList<RBBINode>()
        var tagNode: RBBINode
        var i: Int32 = 0
        var n: Int32 = 0
        fRB.fTreeRoots[Int64(fRootIx)].findNodes(tagNodes, RBBINode.tag)
        i = 0
        while (i < Int32(tagNodes.size)) {
            tagNode = tagNodes[Int64(i)]
            n = 0
            while (n < Int32(fDStates.size)) {
                let sd = fDStates[Int64(n)]
                if (sd.fPositions.contains(tagNode)) {
                    sd.fTagVals.put(tagNode.fVal)
                }
                n++
            }
            i++
        }
    }

    public func mergeRuleStatusVals(): Unit {
        var n: Int32 = 0
        if (Int32(fRB.fRuleStatusVals.size) == 0) {
            fRB.fRuleStatusVals.append(1)
            fRB.fRuleStatusVals.append(0)
            let s0: SortedSet = TreeSet()
            fRB.fStatusSets.put(s0 as Set<Int32>, 0)
            let s1: SortedSet = TreeSet()
            s1.put(0)
            fRB.fStatusSets.put(s1 as Set<Int32>, 0)
        }
        n = 0
        while (n < Int32(fDStates.size)) {
            let sd = fDStates[Int64(n)]
            let statusVals = sd.fTagVals
            var arrayIndexI = fRB.fStatusSets.get(statusVals)
            if (arrayIndexI.isNone()) {
                arrayIndexI = Int32(fRB.fRuleStatusVals.size)
                fRB.fStatusSets.put(statusVals, arrayIndexI)
                fRB.fRuleStatusVals.append(Int32(statusVals.size))
                fRB.fRuleStatusVals.appendAll(statusVals)
            }
            sd.fTagsIdx = arrayIndexI
            n++
        }
    }

    public func printPosSets(n: RBBINode): Unit {
        if (n.isNone()) {
            return
        }
        RBBINode.printNode(n)
        print("         Nullable:  " + n.fNullable.toString())
        print("         firstpos:  ")
        printSet(n.fFirstPosSet)
        print("         lastpos:   ")
        printSet(n.fLastPosSet)
        print("         followpos: ")
        printSet(n.fFollowPos)
        printPosSets(n.fLeftChild)
        printPosSets(n.fRightChild)
    }

    public func findDuplCharClassFrom(categories: RBBIRuleBuilder_IntPair): Bool {
        let numStates = Int32(fDStates.size)
        let numCols = fRB.fSetBuilder.getNumCharCategories()
        var table_base = 0
        var table_dupl = 0
        while (categories.first < numCols - 1) {
            let limitSecond = if (categories.first < fRB.fSetBuilder.getDictCategoriesStart()) { fRB.fSetBuilder.getDictCategoriesStart() } else { numCols }
            categories.second = categories.first + 1
            while (categories.second < limitSecond) {
                var state = 0
                while (state < numStates) {
                    let sd = fDStates[Int64(state)]
                    table_base = sd.fDtran[Int64(categories.first)]
                    table_dupl = sd.fDtran[Int64(categories.second)]
                    if (table_base != table_dupl) {
                        break
                    }
                    state++
                }
                if (table_base == table_dupl) {
                    return true
                }
                categories.second++
            }
            categories.first++
        }
        return false
    }

    public func removeColumn(column: Int32): Unit {
        let numStates = Int32(fDStates.size)
        var state = 0
        while (state < numStates) {
            let sd = fDStates[Int64(state)]
            if (!(column < Int32(sd.fDtran.size))) {
                throw AssertionError()
            }
            let newArray = sd.fDtran.clone(0.. Int32(sd.fDtran.size) - 1)
            arraycopy(sd.fDtran, Int64(column + 1), newArray, Int64(column), Int64(Int32(newArray.size) - column))
            sd.fDtran = newArray
            state++
        }
    }

    public func findDuplicateState(states: RBBIRuleBuilder_IntPair): Bool {
        let numStates = Int32(fDStates.size)
        let numCols = fRB.fSetBuilder.getNumCharCategories()
        while (states.first < numStates - 1) {
            let firstSD = fDStates[Int64(states.first)]
            states.second = states.first + 1
            while (states.second < numStates) {
                let duplSD = fDStates[Int64(states.second)]
                if (firstSD.fAccepting != duplSD.fAccepting || firstSD.fLookAhead != duplSD.fLookAhead || firstSD.fTagsIdx != duplSD.fTagsIdx) {
                    continue
                }
                var rowsMatch = true
                var col = 0
                while (col < numCols) {
                    let firstVal = firstSD.fDtran[Int64(col)]
                    let duplVal = duplSD.fDtran[Int64(col)]
                    if (!((firstVal == duplVal) || ((firstVal == states.first || firstVal == states.second) && (duplVal == states.first || duplVal == states.second)))) {
                        rowsMatch = false
                        break
                    }
                    col++
                }
                if (rowsMatch) {
                    return true
                }
                states.second++
            }
            states.first++
        }
        return false
    }

    public func findDuplicateSafeState(states: RBBIRuleBuilder_IntPair): Bool {
        let numStates = Int32(fSafeTable.size)
        while (states.first < numStates - 1) {
            let firstRow = fSafeTable[Int64(states.first)]
            states.second = states.first + 1
            while (states.second < numStates) {
                let duplRow = fSafeTable[Int64(states.second)]
                var rowsMatch = true
                let numCols = Int32(firstRow.size)
                var col = 0
                while (col < numCols) {
                    let firstVal = Int32(firstRow[Int64(col)])
                    let duplVal = Int32(duplRow[Int64(col)])
                    if (!((firstVal == duplVal) || ((firstVal == states.first || firstVal == states.second) && (duplVal == states.first || duplVal == states.second)))) {
                        rowsMatch = false
                        break
                    }
                    col++
                }
                if (rowsMatch) {
                    return true
                }
                states.second++
            }
            states.first++
        }
        return false
    }

    public func removeState(duplStates: RBBIRuleBuilder_IntPair): Unit {
        let keepState = duplStates.first
        let duplState = duplStates.second
        if (!(keepState < duplState)) {
            throw AssertionError()
        }
        if (!(duplState < Int32(fDStates.size))) {
            throw AssertionError()
        }
        fDStates.remove(Int64(duplState))
        let numStates = Int32(fDStates.size)
        let numCols = fRB.fSetBuilder.getNumCharCategories()
        var state = 0
        while (state < numStates) {
            let sd = fDStates[Int64(state)]
            var col = 0
            while (col < numCols) {
                let existingVal = sd.fDtran[Int64(col)]
                var newVal = existingVal
                if (existingVal == duplState) {
                    newVal = keepState
                } else if (existingVal > duplState) {
                    newVal = existingVal - 1
                }
                sd.fDtran[Int64(col)] = newVal
                col++
            }
            state++
        }
    }

    public func removeSafeState(duplStates: RBBIRuleBuilder_IntPair): Unit {
        let keepState = duplStates.first
        let duplState = duplStates.second
        if (!(keepState < duplState)) {
            throw AssertionError()
        }
        if (!(duplState < Int32(fSafeTable.size))) {
            throw AssertionError()
        }
        fSafeTable.remove(Int64(duplState))
        let numStates = Int32(fSafeTable.size)
        var state = 0
        while (state < numStates) {
            let row = fSafeTable[Int64(state)]
            var col = 0
            while (col < Int32(row.size)) {
                let existingVal = Int32(row[Int64(col)])
                var newVal = existingVal
                if (existingVal == duplState) {
                    newVal = keepState
                } else if (existingVal > duplState) {
                    newVal = existingVal - 1
                }
                row[Int64(col)] = Int16(newVal)
                col++
            }
            state++
        }
    }

    public func removeDuplicateStates(): Int32 {
        let dupls = RBBIRuleBuilder_IntPair(3, 0)
        var numStatesRemoved = 0
        while (findDuplicateState(dupls)) {
            removeState(dupls)
            numStatesRemoved++
        }
        return numStatesRemoved
    }

    public func getTableSize(): Int32 {
        if (fRB.fTreeRoots[Int64(fRootIx)].isNone()) {
            return 0
        }
        var size = RBBIDataWrapper_RBBIStateTable.fHeaderSize
        let numRows = Int32(fDStates.size)
        let numCols = fRB.fSetBuilder.getNumCharCategories()
        let use8Bits = numRows <= MAX_STATE_FOR_8BITS_TABLE
        let rowSize = (if (use8Bits) { 1 } else { 2 }) * (RBBIDataWrapper.NEXTSTATES + numCols)
        size += numRows * rowSize
        size = (size + 7) & 
        return size
    }

    public func exportTable(): RBBIDataWrapper_RBBIStateTable {
        var state: Int32 = 0
        var col: Int32 = 0
        let table = RBBIDataWrapper_RBBIStateTable()
        if (fRB.fTreeRoots[Int64(fRootIx)].isNone()) {
            return table
        }
        Assert.assrt(fRB.fSetBuilder.getNumCharCategories() < 32767 && Int32(fDStates.size) < 32767)
        table.fNumStates = Int32(fDStates.size)
        table.fDictCategoriesStart = fRB.fSetBuilder.getDictCategoriesStart()
        table.fLookAheadResultsSize = if (fLASlotsInUse == RBBIDataWrapper.ACCEPTING_UNCONDITIONAL) { 0 } else { fLASlotsInUse + 1 }
        let use8Bits = table.fNumStates <= MAX_STATE_FOR_8BITS_TABLE
        let rowLen = RBBIDataWrapper.NEXTSTATES + fRB.fSetBuilder.getNumCharCategories()
        let tableSize: Int32
        if (use8Bits) {
            tableSize = (getTableSize() - RBBIDataWrapper_RBBIStateTable.fHeaderSize)
            table.fTable = Array<Char>(Int64(tableSize)) { _ => '\u{0000}' }
            table.fRowLen = rowLen
        } else {
            tableSize = (getTableSize() - RBBIDataWrapper_RBBIStateTable.fHeaderSize) / 2
            table.fTable = Array<Char>(Int64(tableSize)) { _ => '\u{0000}' }
            table.fRowLen = rowLen * 2
        }
        if (fRB.fLookAheadHardBreak) {
            table.fFlags |= RBBIDataWrapper.RBBI_LOOKAHEAD_HARD_BREAK
        }
        if (fRB.fSetBuilder.sawBOF()) {
            table.fFlags |= RBBIDataWrapper.RBBI_BOF_REQUIRED
        }
        if (use8Bits) {
            table.fFlags |= RBBIDataWrapper.RBBI_8BITS_ROWS
        }
        let numCharCategories = fRB.fSetBuilder.getNumCharCategories()
        state = 0
        while (state < table.fNumStates) {
            let sd = fDStates[Int64(state)]
            let row = state * rowLen
            if (use8Bits) {
                Assert.assrt(0 <= sd.fAccepting && sd.fAccepting <= 255)
                Assert.assrt(0 <= sd.fLookAhead && sd.fLookAhead <= 255)
            } else {
                Assert.assrt(0 <= sd.fAccepting && sd.fAccepting <= 65535)
                Assert.assrt(0 <= sd.fLookAhead && sd.fLookAhead <= 65535)
            }
            table.fTable[Int64(row + RBBIDataWrapper.ACCEPTING)] = Char(sd.fAccepting)
            table.fTable[Int64(row + RBBIDataWrapper.LOOKAHEAD)] = Char(sd.fLookAhead)
            table.fTable[Int64(row + RBBIDataWrapper.TAGSIDX)] = Char(sd.fTagsIdx)
            col = 0
            while (col < numCharCategories) {
                if (use8Bits) {
                    Assert.assrt(0 <= sd.fDtran[Int64(col)] && sd.fDtran[Int64(col)] <= MAX_STATE_FOR_8BITS_TABLE)
                }
                table.fTable[Int64(row + RBBIDataWrapper.NEXTSTATES + col)] = Char(sd.fDtran[Int64(col)])
                col++
            }
            state++
        }
        return table
    }

    public func buildSafeReverseTable(): Unit {
        let safePairs = StringBuilder()
        let numCharClasses = fRB.fSetBuilder.getNumCharCategories()
        let numStates = Int32(fDStates.size)
                                    if (wantedEndState != endState) {
                                        break
                                    }
                                }
                                startState++
                            }
                        } while (false)
                        if (wantedEndState == endState) {
                            safePairs.append(Char(c1))
                            safePairs.append(Char(c2))
                        }
                        c2++
                    }
                } while (false)
                c1++
            }
        } while (false)
        if (!(fSafeTable.isNone())) {
            throw AssertionError()
        }
        fSafeTable = ArrayList<Array<Int16>>()
        } while (false)
        let startState = fSafeTable[1]
        var charClass = 0
        while (charClass < numCharClasses) {
            startState[Int64(charClass)] = Int16(charClass + 2)
            charClass++
        }
        } while (false)
        var pairIdx = 0
        while (pairIdx < Int32(safePairs.size)) {
            let c1 = Int32(UInt32(safePairs.get(Int64(pairIdx))))
            let c2 = Int32(UInt32(safePairs.get(Int64(pairIdx + 1))))
            let rowState = fSafeTable[Int64(c2 + 2)]
            rowState[Int64(c1)] = 0i16
            pairIdx += 2
        }
        let states = RBBIRuleBuilder_IntPair(1, 0)
        while (findDuplicateSafeState(states)) {
            removeSafeState(states)
        }
    }

    public func getSafeTableSize(): Int32 {
        if (fSafeTable.isNone()) {
            return 0
        }
        var size = RBBIDataWrapper_RBBIStateTable.fHeaderSize
        let numRows = Int32(fSafeTable.size)
        let numCols = Int32(fSafeTable[0].size)
        let use8Bits = numRows <= MAX_STATE_FOR_8BITS_TABLE
        let rowSize = (if (use8Bits) { 1 } else { 2 }) * (RBBIDataWrapper.NEXTSTATES + numCols)
        size += numRows * rowSize
        size = (size + 7) & 
        return size
    }

    public func exportSafeTable(): RBBIDataWrapper_RBBIStateTable {
        let table = RBBIDataWrapper_RBBIStateTable()
        table.fNumStates = Int32(fSafeTable.size)
        let use8Bits = table.fNumStates <= MAX_STATE_FOR_8BITS_TABLE
        let numCharCategories = Int32(fSafeTable[0].size)
        let rowLen = RBBIDataWrapper.NEXTSTATES + numCharCategories
        var tableSize = (getSafeTableSize() - RBBIDataWrapper_RBBIStateTable.fHeaderSize)
        if (use8Bits) {
            table.fFlags |= RBBIDataWrapper.RBBI_8BITS_ROWS
            table.fTable = Array<Char>(Int64(tableSize)) { _ => '\u{0000}' }
            table.fRowLen = rowLen
        } else {
            tableSize /= 2
            table.fTable = Array<Char>(Int64(tableSize)) { _ => '\u{0000}' }
            table.fRowLen = rowLen * 2
        }
        var state = 0
        while (state < table.fNumStates) {
            let rowArray = fSafeTable[Int64(state)]
            let row = state * rowLen
            var col = 0
            while (col < numCharCategories) {
                if (use8Bits) {
                    Assert.assrt(Int32(rowArray[Int64(col)]) <= MAX_STATE_FOR_8BITS_TABLE)
                }
                table.fTable[Int64(row + RBBIDataWrapper.NEXTSTATES + col)] = Char(rowArray[Int64(col)])
                col++
            }
            state++
        }
        return table
    }

    public func printSet(s: Collection<RBBINode>): Unit {
        for (n in s) {
            RBBINode.printInt(n.fSerialNum, 8)
        }
        println()
    }

    public func printStates(): Unit {
        var c: Int32 = 0
        var n: Int32 = 0
        print("state |           i n p u t     s y m b o l s \n")
        print("      | Acc  LA    Tag")
        c = 0
        while (c < fRB.fSetBuilder.getNumCharCategories()) {
            RBBINode.printInt(c, 4)
            c++
        }
        print("\n")
        print("      |---------------")
        c = 0
        while (c < fRB.fSetBuilder.getNumCharCategories()) {
            print("----")
            c++
        }
        print("\n")
        n = 0
        while (n < Int32(fDStates.size)) {
            let sd = fDStates[Int64(n)]
            RBBINode.printInt(n, 5)
            print(" | ")
            RBBINode.printInt(sd.fAccepting, 3)
            RBBINode.printInt(sd.fLookAhead, 4)
            RBBINode.printInt(sd.fTagsIdx, 6)
            print(" ")
            c = 0
            while (c < fRB.fSetBuilder.getNumCharCategories()) {
                RBBINode.printInt(sd.fDtran[Int64(c)], 4)
                c++
            }
            print("\n")
            n++
        }
        print("\n\n")
    }

    public func printReverseTable(): Unit {
        var c: Int32 = 0
        Console.stdOut.printf("    Safe Reverse Table \n", [0])
        if (fSafeTable.isNone()) {
            Console.stdOut.printf("   --- nullptr ---\n", [0])
            return
        }
        let numCharCategories = Int32(fSafeTable[0].size)
        Console.stdOut.printf("state |           i n p u t     s y m b o l s \n", [0])
        Console.stdOut.printf("      | Acc  LA    Tag", [0])
        c = 0
        while (c < numCharCategories) {
            Console.stdOut.printf(" %2d", [c])
            c++
        }
        Console.stdOut.printf("\n", [0])
        Console.stdOut.printf("      |---------------", [0])
        c = 0
        while (c < numCharCategories) {
            Console.stdOut.printf("---", [0])
            c++
        }
        Console.stdOut.printf("\n", [0])
        var n = 0
        while (n < Int32(fSafeTable.size)) {
            let rowArray = fSafeTable[Int64(n)]
            Console.stdOut.printf("  %3d | ", [n])
            Console.stdOut.printf("%3d %3d %5d ", [0, 0, 0])
            c = 0
            while (c < numCharCategories) {
                Console.stdOut.printf(" %2d", [rowArray[Int64(c)]])
                c++
            }
            Console.stdOut.printf("\n", [0])
            n++
        }
        Console.stdOut.printf("\n\n", [0])
    }

    public func printRuleStatusTable(): Unit {
        var thisRecord = 0
        var nextRecord = 0
        var i: Int32 = 0
        let tbl = fRB.fRuleStatusVals
        print("index |  tags \n")
        print("-------------------\n")
        while (nextRecord < Int32(tbl.size)) {
            thisRecord = nextRecord
            nextRecord = thisRecord + tbl[Int64(thisRecord)] + 1
            RBBINode.printInt(thisRecord, 7)
            i = thisRecord + 1
            while (i < nextRecord) {
                let val = tbl[Int64(i)]
                RBBINode.printInt(val, 7)
                i++
            }
            print("\n")
        }
        print("\n\n")
    }
}


class RBBITableBuilder_RBBIStateDescriptor {
    var fMarked: Bool = false

    var fAccepting: Int32 = 0

    var fLookAhead: Int32 = 0

    var fTagVals: SortedSet = None

    var fTagsIdx: Int32 = 0

    var fPositions: Set<RBBINode>

    var fDtran: Array<Int32>

    init(maxInputSymbol: Int32) {
        fTagVals = TreeSet()
        fPositions = HashSet<RBBINode>()
        fDtran = Array<Int32>(Int64(maxInputSymbol + 1)) { _ => 0 }
    }
}
