package icu4cj.text

class RBBINode {
    static let setRef = 0

    static let uset = 1

    static let varRef = 2

    static let leafChar = 3

    static let lookAhead = 4

    static let tag = 5

    static let endMark = 6

    static let opStart = 7

    static let opCat = 8

    static let opOr = 9

    static let opStar = 10

    static let opPlus = 11

    static let opQuestion = 12

    static let opBreak = 13

    static let opReverse = 14

    static let opLParen = 15

    static let nodeTypeLimit = 16

    static let nodeTypeNames: Array<String> = ["setRef", "uset", "varRef", "leafChar", "lookAhead", "tag", "endMark", "opStart", "opCat", "opOr", "opStar", "opPlus", "opQuestion", "opBreak", "opReverse", "opLParen"]

    static let precZero = 0

    static let precStart = 1

    static let precLParen = 2

    static let precOpOr = 3

    static let precOpCat = 4

    var fType: Int32 = 0

    var fParent: RBBINode

    var fLeftChild: RBBINode

    var fRightChild: RBBINode

    var fInputSet: UnicodeSet

    var fPrecedence = precZero

    var fText: String

    var fFirstPos: Int32 = 0

    var fLastPos: Int32 = 0

    var fNullable: Bool = false

    var fVal: Int32 = 0

    var fLookAheadEnd: Bool = false

    var fRuleRoot: Bool = false

    var fChainIn: Bool = false

    var fFirstPosSet: Set<RBBINode>

    var fLastPosSet: Set<RBBINode>

    var fFollowPos: Set<RBBINode>

    var fSerialNum: Int32 = 0

    static var gLastSerial: Int32 = 0

    init(t: Int32) {
        Assert.assrt(t < nodeTypeLimit)
        fSerialNum = match (0) { case _ => gLastSerial++; gLastSerial }
        fType = t
        fFirstPosSet = HashSet<RBBINode>()
        fLastPosSet = HashSet<RBBINode>()
        fFollowPos = HashSet<RBBINode>()
        if (t == opCat) {
            fPrecedence = precOpCat
        } else if (t == opOr) {
            fPrecedence = precOpOr
        } else if (t == opStart) {
            fPrecedence = precStart
        } else if (t == opLParen) {
            fPrecedence = precLParen
        } else {
            fPrecedence = precZero
        }
    }

    init(other: RBBINode) {
        fSerialNum = match (0) { case _ => gLastSerial++; gLastSerial }
        fType = other.fType
        fInputSet = other.fInputSet
        fPrecedence = other.fPrecedence
        fText = other.fText
        fFirstPos = other.fFirstPos
        fLastPos = other.fLastPos
        fNullable = other.fNullable
        fVal = other.fVal
        fRuleRoot = false
        fChainIn = other.fChainIn
        fFirstPosSet = HashSet<RBBINode>(other.fFirstPosSet)
        fLastPosSet = HashSet<RBBINode>(other.fLastPosSet)
        fFollowPos = HashSet<RBBINode>(other.fFollowPos)
    }

    public func cloneTree(): RBBINode {
        let n: RBBINode
        if (fType == RBBINode.varRef) {
            n = fLeftChild.cloneTree()
        } else if (fType == RBBINode.uset) {
            n = this
        } else {
            n = RBBINode(this)
            if (fLeftChild.isSome()) {
                n.fLeftChild = fLeftChild.cloneTree()
                n.fLeftChild.fParent = n
            }
            if (fRightChild.isSome()) {
                n.fRightChild = fRightChild.cloneTree()
                n.fRightChild.fParent = n
            }
        }
        return n
    }

    private static let kRecursiveDepthLimit = 3500

    public func flattenVariables(depth: Int32): RBBINode {
        if (depth > kRecursiveDepthLimit) {
            throw IllegalArgumentException("The input is too long")
        }
        if (fType == varRef) {
            let retNode = fLeftChild.cloneTree()
            retNode.fRuleRoot = this.fRuleRoot
            retNode.fChainIn = this.fChainIn
            return retNode
        }
        if (fLeftChild.isSome()) {
            fLeftChild = fLeftChild.flattenVariables(depth + 1)
            fLeftChild.fParent = this
        }
        if (fRightChild.isSome()) {
            fRightChild = fRightChild.flattenVariables(depth + 1)
            fRightChild.fParent = this
        }
        return this
    }

    public func flattenSets(): Unit {
        Assert.assrt(fType != setRef)
        if (fLeftChild.isSome()) {
            if (fLeftChild.fType == setRef) {
                let setRefNode = fLeftChild
                let usetNode = setRefNode.fLeftChild
                let replTree = usetNode.fLeftChild
                fLeftChild = replTree.cloneTree()
                fLeftChild.fParent = this
            } else {
                fLeftChild.flattenSets()
            }
        }
        if (fRightChild.isSome()) {
            if (fRightChild.fType == setRef) {
                let setRefNode = fRightChild
                let usetNode = setRefNode.fLeftChild
                let replTree = usetNode.fLeftChild
                fRightChild = replTree.cloneTree()
                fRightChild.fParent = this
            } else {
                fRightChild.flattenSets()
            }
        }
    }

    public func findNodes(dest: ArrayList<RBBINode>, kind: Int32): Unit {
        if (fType == kind) {
            dest.append(this)
        }
        if (fLeftChild.isSome()) {
            fLeftChild.findNodes(dest, kind)
        }
        if (fRightChild.isSome()) {
            fRightChild.findNodes(dest, kind)
        }
    }

    static func printNode(n: RBBINode): Unit {
        if (n.isNone()) {
            print(" -- null --\n")
        } else {
            RBBINode.printInt(n.fSerialNum, 10)
            RBBINode.printString(nodeTypeNames[Int64(n.fType)], 11)
            RBBINode.printInt(if (n.fParent.isNone()) { 0 } else { n.fParent.fSerialNum }, 11)
            RBBINode.printInt(if (n.fLeftChild.isNone()) { 0 } else { n.fLeftChild.fSerialNum }, 11)
            RBBINode.printInt(if (n.fRightChild.isNone()) { 0 } else { n.fRightChild.fSerialNum }, 12)
            RBBINode.printInt(n.fFirstPos, 12)
            RBBINode.printInt(n.fVal, 7)
            if (n.fType == varRef) {
                print(" " + (n.fText))
            }
        }
        println("")
    }

    static func printString(s: String, minWidth: Int32): Unit {
        } while (false)
        } while (false)
        print(s)
    }

    static func printInt(i: Int32, minWidth: Int32): Unit {
        let s: String = i.toString()
        printString(s, max(minWidth, Int32(s.size) + 1))
    }

    static func printHex(i: Int32, minWidth: Int32): Unit {
        var s = Int32.toString(i, 16)
        let leadingZeroes: String = "00000"[0..Int64(max(0, 5 - Int32(s.size)))]
        s = (leadingZeroes) + (s)
        printString(s, minWidth)
    }

    public func printTree(printHeading: Bool): Unit {
        if (printHeading) {
            println("-------------------------------------------------------------------")
            println("    Serial       type     Parent  LeftChild  RightChild    position  value")
        }
        printNode(this)
        if (fType != varRef) {
            if (fLeftChild.isSome()) {
                fLeftChild.printTree(false)
            }
            if (fRightChild.isSome()) {
                fRightChild.printTree(false)
            }
        }
    }
}
