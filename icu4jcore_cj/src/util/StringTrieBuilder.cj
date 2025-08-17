package icu4cj.util

public abstract class StringTrieBuilder {
    

    
    protected func addImpl(s: String, value: Int32): Unit {
        if (!refEq(state, StringTrieBuilder_State.ADDING)) {
            throw Exception("Cannot add (string, value) pairs after build().")
        }
        if (s.size > 65535) {
            throw IndexOutOfBoundsException("The maximum string length is 0xffff.")
        }
        if (root.isNone()) {
            root = createSuffixNode(s, 0, value)
        } else {
            root = root.add(this, s, 0, value)
        }
    }

    
    protected func buildImpl(buildOption: StringTrieBuilder_Option): Unit {
        match (state) {
            case StringTrieBuilder_State.ADDING =>
                if (root.isNone()) {
                    throw IndexOutOfBoundsException("No (string, value) pairs were added.")
                }
                if (refEq(buildOption, StringTrieBuilder_Option.FAST)) {
                    state = StringTrieBuilder_State.BUILDING_FAST
                } else {
                    state = StringTrieBuilder_State.BUILDING_SMALL
                }
            case StringTrieBuilder_State.BUILDING_FAST | StringTrieBuilder_State.BUILDING_SMALL => throw Exception("Builder failed and must be clear()ed.")
            case StringTrieBuilder_State.BUILT => return
            case _ => ()
        }
        root = root.register(this)
        root.markRightEdgesFirst(-1)
        root.write(this)
        state = StringTrieBuilder_State.BUILT
    }

    
    protected func clearImpl(): Unit {
        strings.setLength(0)
        nodes.clear()
        root = None
        state = StringTrieBuilder_State.ADDING
    }

    func registerNode(newNode: StringTrieBuilder_Node): StringTrieBuilder_Node {
        if (refEq(state, StringTrieBuilder_State.BUILDING_FAST)) {
            return newNode
        }
        var oldNode = nodes.get(newNode)
        if (oldNode.isSome()) {
            return oldNode
        }
        oldNode = nodes.put(newNode, newNode)
        if (!(oldNode.isNone())) {
            throw AssertionError()
        }
        return newNode
    }

    private func registerFinalValue(value: Int32): StringTrieBuilder_ValueNode {
        lookupFinalValueNode.setFinalValue(value)
        var oldNode = nodes.get(lookupFinalValueNode)
        if (oldNode.isSome()) {
            return oldNode
        }
        let newNode = StringTrieBuilder_ValueNode(value)
        oldNode = nodes.put(newNode, newNode)
        if (!(oldNode.isNone())) {
            throw AssertionError()
        }
        return newNode
    }

    public func createSuffixNode(s: String, start: Int32, sValue: Int32): StringTrieBuilder_ValueNode {
        var node = registerFinalValue(sValue)
        if (start < s.size) {
            let offset = Int32(strings.size)
            strings.append(s, start, s.size)
            node = StringTrieBuilder_LinearMatchNode(strings.asString(), offset, s.size - start, node)
        }
        return node
    }

    
    protected func matchNodesCanHaveValues(): Bool

    
    protected func getMaxBranchLinearSubNodeLength(): Int32

    
    protected func getMinLinearMatch(): Int32

    
    protected func getMaxLinearMatchLength(): Int32

    
    protected func write(unit: Int32): Int32

    
    protected func write(offset: Int32, length: Int32): Int32

    
    protected func writeValueAndFinal(i: Int32, isFinal: Bool): Int32

    
    protected func writeValueAndType(hasValue: Bool, value: Int32, node: Int32): Int32

    
    protected func writeDeltaTo(jumpTarget: Int32): Int32

    private var state: StringTrieBuilder_State = StringTrieBuilder_State.ADDING

    
    protected var strings: StringBuilder = StringBuilder()

    private var root: StringTrieBuilder_Node

    private var nodes: HashMap<StringTrieBuilder_Node, StringTrieBuilder_Node> = HashMap<StringTrieBuilder_Node, StringTrieBuilder_Node>()

    private var lookupFinalValueNode: StringTrieBuilder_ValueNode = StringTrieBuilder_ValueNode()
}


public class StringTrieBuilder_Option <: Enum<StringTrieBuilder_Option> {
    public static let FAST = StringTrieBuilder_Option("FAST", 0)

    public static let SMALL = StringTrieBuilder_Option("SMALL", 1)

    private static func _values(): Array<StringTrieBuilder_Option> {
        return [StringTrieBuilder_Option.FAST, StringTrieBuilder_Option.SMALL]
    }

    private static let _VALUES = StringTrieBuilder_Option._values()

    public static func values(): Array<StringTrieBuilder_Option> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): StringTrieBuilder_Option {
        return (TypeInfo.of<StringTrieBuilder_Option>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as StringTrieBuilder_Option
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


abstract class StringTrieBuilder_Node {
    public init() {
        offset = 0
    }

    public override func hashCode(): Int64

    public override func equals(other: Object): Bool {
        return refEq(this, other) || refEq(TypeInfo.of(this), TypeInfo.of(other))
    }

    public func add(builder: StringTrieBuilder, s: String, start: Int32, sValue: Int32): StringTrieBuilder_Node {
        return this
    }

    public func register(builder: StringTrieBuilder): StringTrieBuilder_Node {
        return this
    }

    public func markRightEdgesFirst(edgeNumber: Int32): Int32 {
        if (offset == 0) {
            offset = edgeNumber
        }
        return edgeNumber
    }

    public func write(builder: StringTrieBuilder): Unit

    public func writeUnlessInsideRightEdge(firstRight: Int32, lastRight: Int32, builder: StringTrieBuilder): Unit {
        if (offset < 0 && (offset < lastRight || firstRight < offset)) {
            write(builder)
        }
    }

    public func getOffset(): Int32 {
        return offset
    }

    protected var offset: Int32 = 0
}


class StringTrieBuilder_ValueNode <: StringTrieBuilder_Node {
    public init() {
        super()
    }

    public init(v: Int32) {
        super()
        hasValue = true
        value = v
    }

    public func setValue(v: Int32): Unit {
        if (!(!hasValue)) {
            throw AssertionError()
        }
        hasValue = true
        value = v
    }

    public func setFinalValue(v: Int32): Unit {
        hasValue = true
        value = v
    }

    public override func hashCode(): Int64 {
        var hash = 1118481
        if (hasValue) {
            hash = hash * 37 + value
        }
        return Int64(hash)
    }

    public override func equals(other: Object): Bool {
        if (refEq(this, other)) {
            return true
        }
        if (!super.equals(other)) {
            return false
        }
        let o = other
        return hasValue == o.hasValue && (!hasValue || value == o.value)
    }

    public override func add(builder: StringTrieBuilder, s: String, start: Int32, sValue: Int32): StringTrieBuilder_Node {
        if (start == s.size) {
            throw IllegalArgumentException("Duplicate string.")
        }
        let node = builder.createSuffixNode(s, start, sValue)
        node.setValue(value)
        return node
    }

    public override func write(builder: StringTrieBuilder): Unit {
        offset = builder.writeValueAndFinal(value, true)
    }

    protected var hasValue: Bool = false

    protected var value: Int32 = 0
}


class StringTrieBuilder_IntermediateValueNode <: StringTrieBuilder_ValueNode {
    public init(v: Int32, nextNode: StringTrieBuilder_Node) {
        super()
        next = nextNode
        setValue(v)
    }

    public override func hashCode(): Int64 {
        return Int64((2236962 * 37 + value) * 37 + Int32(next.hashCode()))
    }

    public override func equals(other: Object): Bool {
        if (refEq(this, other)) {
            return true
        }
        if (!super.equals(other)) {
            return false
        }
        let o = other
        return refEq(next, o.next)
    }

    public override func markRightEdgesFirst(edgeNumber: Int32): Int32 {
        var tempedgeNumber = edgeNumber
        if (offset == 0) {
            offset = match (0) { case _ => tempedgeNumber = next.markRightEdgesFirst(tempedgeNumber); tempedgeNumber }
        }
        return tempedgeNumber
    }

    public override func write(builder: StringTrieBuilder): Unit {
        next.write(builder)
        offset = builder.writeValueAndFinal(value, false)
    }

    private var next: StringTrieBuilder_Node
}


class StringTrieBuilder_LinearMatchNode <: StringTrieBuilder_ValueNode {
    public init(builderStrings: String, sOffset: Int32, len: Int32, nextNode: StringTrieBuilder_Node) {
        super()
        strings = builderStrings
        stringOffset = sOffset
        length = len
        next = nextNode
    }

    public override func hashCode(): Int64 {
        return Int64(hash)
    }

    public override func equals(other: Object): Bool {
        if (refEq(this, other)) {
            return true
        }
        if (!super.equals(other)) {
            return false
        }
        let o = other
        if (length != o.length || !refEq(next, o.next)) {
            return false
        }
        var i = stringOffset
        var j = o.stringOffset
        let limit = stringOffset + length
        while (i < limit) {
            if (strings[i] != strings[j]) {
                return false
            }
            i++
            j++
        }
        return true
    }

    public override func add(builder: StringTrieBuilder, s: String, start: Int32, sValue: Int32): StringTrieBuilder_Node {
        var tempstart = start
        if (tempstart == s.size) {
            if (hasValue) {
                throw IllegalArgumentException("Duplicate string.")
            } else {
                setValue(sValue)
                return this
            }
        }
        let limit = stringOffset + length
        var i = stringOffset
        while (i < limit) {
            if (tempstart == s.size) {
                let prefixLength = i - stringOffset
                let suffixNode = StringTrieBuilder_LinearMatchNode(strings, i, length - prefixLength, next)
                suffixNode.setValue(sValue)
                length = prefixLength
                next = suffixNode
                return this
            }
            let thisChar = strings[i]
            let newChar = s[tempstart]
            if (thisChar != newChar) {
                let branchNode = StringTrieBuilder_DynamicBranchNode()
                let result: StringTrieBuilder_Node
                let thisSuffixNode: StringTrieBuilder_Node
                if (i == stringOffset) {
                    if (hasValue) {
                        branchNode.setValue(value)
                        value = 0
                        hasValue = false
                    }
                    stringOffset++
                    length--
                    thisSuffixNode = if (length > 0) { this } else { next }
                    result = branchNode
                } else if (i == limit - 1) {
                    length--
                    thisSuffixNode = next
                    next = branchNode
                    result = this
                } else {
                    let prefixLength = i - stringOffset
                    i++
                    thisSuffixNode = StringTrieBuilder_LinearMatchNode(strings, i, length - (prefixLength + 1), next)
                    length = prefixLength
                    next = branchNode
                    result = this
                }
                let newSuffixNode = builder.createSuffixNode(s, tempstart + 1, sValue)
                branchNode.add(thisChar, thisSuffixNode)
                branchNode.add(newChar, newSuffixNode)
                return result
            }
            i++
            tempstart++
        }
        next = next.add(builder, s, tempstart, sValue)
        return this
    }

    public override func register(builder: StringTrieBuilder): StringTrieBuilder_Node {
        next = next.register(builder)
        let maxLinearMatchLength = builder.getMaxLinearMatchLength()
        while (length > maxLinearMatchLength) {
            let nextOffset = stringOffset + length - maxLinearMatchLength
            length -= maxLinearMatchLength
            let suffixNode = StringTrieBuilder_LinearMatchNode(strings, nextOffset, maxLinearMatchLength, next)
            suffixNode.setHashCode()
            next = builder.registerNode(suffixNode)
        }
        let result: StringTrieBuilder_Node
        if (hasValue && !builder.matchNodesCanHaveValues()) {
            let intermediateValue = value
            value = 0
            hasValue = false
            setHashCode()
            result = StringTrieBuilder_IntermediateValueNode(intermediateValue, builder.registerNode(this))
        } else {
            setHashCode()
            result = this
        }
        return builder.registerNode(result)
    }

    public override func markRightEdgesFirst(edgeNumber: Int32): Int32 {
        var tempedgeNumber = edgeNumber
        if (offset == 0) {
            offset = match (0) { case _ => tempedgeNumber = next.markRightEdgesFirst(tempedgeNumber); tempedgeNumber }
        }
        return tempedgeNumber
    }

    public override func write(builder: StringTrieBuilder): Unit {
        next.write(builder)
        builder.write(stringOffset, length)
        offset = builder.writeValueAndType(hasValue, value, builder.getMinLinearMatch() + length - 1)
    }

    private func setHashCode(): Unit {
        hash = (3355443 * 37 + length) * 37 + Int32(next.hashCode())
        if (hasValue) {
            hash = hash * 37 + value
        }
        var i = stringOffset
        let limit = stringOffset + length
        while (i < limit) {
            hash = hash * 37 + Int32(UInt32(strings[i]))
            i++
        }
    }

    private var strings: String

    private var stringOffset: Int32 = 0

    private var length: Int32 = 0

    private var next: StringTrieBuilder_Node

    private var hash: Int32 = 0
}


class StringTrieBuilder_DynamicBranchNode <: StringTrieBuilder_ValueNode {
    public init() {
        super()
    }

    public func add(c: Char, node: StringTrieBuilder_Node): Unit {
        let i = find(c)
        chars.insert(Int64(i), c)
        equal.insert(Int64(i), node)
    }

    public override func add(builder: StringTrieBuilder, s: String, start: Int32, sValue: Int32): StringTrieBuilder_Node {
        var tempstart = start
        if (tempstart == s.size) {
            if (hasValue) {
                throw IllegalArgumentException("Duplicate string.")
            } else {
                setValue(sValue)
                return this
            }
        }
        let c = s[match (0] { case _ => tempstart++; tempstart - 1 })
        let i = find(c)
        if (i < Int32(chars.size) && c == chars.get(Int64(i))) {
            equal.set(Int64(i), equal[Int64(i)].add(builder, s, tempstart, sValue))
        } else {
            chars.insert(Int64(i), c)
            equal.insert(Int64(i), builder.createSuffixNode(s, tempstart, sValue))
        }
        return this
    }

    public override func register(builder: StringTrieBuilder): StringTrieBuilder_Node {
        let subNode = register(builder, 0, Int32(chars.size))
        let head = StringTrieBuilder_BranchHeadNode(Int32(chars.size), subNode)
        var result: StringTrieBuilder_Node = head
        if (hasValue) {
            if (builder.matchNodesCanHaveValues()) {
                head.setValue(value)
            } else {
                result = StringTrieBuilder_IntermediateValueNode(value, builder.registerNode(head))
            }
        }
        return builder.registerNode(result)
    }

    private func register(builder: StringTrieBuilder, start: Int32, limit: Int32): StringTrieBuilder_Node {
        var tempstart = start
        let length = limit - tempstart
        if (length > builder.getMaxBranchLinearSubNodeLength()) {
            let middle = tempstart + length / 2
            return builder.registerNode(StringTrieBuilder_SplitBranchNode(chars.get(Int64(middle)), register(builder, tempstart, middle), register(builder, middle, limit)))
        }
        let listNode = StringTrieBuilder_ListBranchNode(length)
                listNode.add(Int32(UInt32(c)), node.register(builder))
            }
        } while (match (0) { case _ => tempstart++; tempstart } < limit)
        return builder.registerNode(listNode)
    }

    private func find(c: Char): Int32 {
        var start = 0
        var limit = Int32(chars.size)
        while (start < limit) {
            let i = (start + limit) / 2
            let middleChar = chars.get(Int64(i))
            if (c < middleChar) {
                limit = i
            } else if (c == middleChar) {
                return i
            } else {
                start = i + 1
            }
        }
        return start
    }

    private var chars: StringBuilder = StringBuilder()

    private var equal: ArrayList<StringTrieBuilder_Node> = ArrayList<StringTrieBuilder_Node>()
}


abstract class StringTrieBuilder_BranchNode <: StringTrieBuilder_Node {
    public init() {
        super()
    }

    public override func hashCode(): Int64 {
        return Int64(hash)
    }

    protected var hash: Int32 = 0

    protected var firstEdgeNumber: Int32 = 0
}


class StringTrieBuilder_ListBranchNode <: StringTrieBuilder_BranchNode {
    public init(capacity: Int32) {
        super()
        hash = 4473924 * 37 + capacity
        equal = Array<StringTrieBuilder_Node>(Int64(capacity))
        values = Array<Int32>(Int64(capacity)) { _ => 0 }
        units = Array<Char>(Int64(capacity)) { _ => '\u{0000}' }
    }

    public override func equals(other: Object): Bool {
        if (refEq(this, other)) {
            return true
        }
        if (!super.equals(other)) {
            return false
        }
        let o = other
        var i = 0
        while (i < length) {
            if (units[Int64(i)] != o.units[Int64(i)] || values[Int64(i)] != o.values[Int64(i)] || !refEq(equal[Int64(i)], o.equal[Int64(i)])) {
                return false
            }
            i++
        }
        return true
    }

    public override func hashCode(): Int64 {
        return super.hashCode()
    }

    public override func markRightEdgesFirst(edgeNumber: Int32): Int32 {
        var tempedgeNumber = edgeNumber
        if (offset == 0) {
            firstEdgeNumber = tempedgeNumber
            var step = 0
            var i = length
                step = 1
            } while (i > 0)
            offset = tempedgeNumber
        }
        return tempedgeNumber
    }

    public override func write(builder: StringTrieBuilder): Unit {
        var unitNumber = length - 1
        let rightEdge = equal[Int64(unitNumber)]
        let rightEdgeNumber = if (rightEdge.isNone()) { firstEdgeNumber } else { rightEdge.getOffset() }
        } while (unitNumber > 0)
        unitNumber = length - 1
        if (rightEdge.isNone()) {
            builder.writeValueAndFinal(values[Int64(unitNumber)], true)
        } else {
            rightEdge.write(builder)
        }
        offset = builder.write(Int32(UInt32(units[Int64(unitNumber)])))
        while (match (0) { case _ => unitNumber--; unitNumber } >= 0) {
            let value: Int32
            let isFinal: Bool
            if (equal[Int64(unitNumber)].isNone()) {
                value = values[Int64(unitNumber)]
                isFinal = true
            } else {
                if (!(equal[Int64(unitNumber)].getOffset() > 0)) {
                    throw AssertionError()
                }
                value = offset - equal[Int64(unitNumber)].getOffset()
                isFinal = false
            }
            builder.writeValueAndFinal(value, isFinal)
            offset = builder.write(Int32(UInt32(units[Int64(unitNumber)])))
        }
    }

    public func add(c: Int32, value: Int32): Unit {
        units[Int64(length)] = Char(c)
        equal[Int64(length)] = None
        values[Int64(length)] = value
        length++
        hash = (hash * 37 + c) * 37 + value
    }

    public func add(c: Int32, node: StringTrieBuilder_Node): Unit {
        units[Int64(length)] = Char(c)
        equal[Int64(length)] = node
        values[Int64(length)] = 0
        length++
        hash = (hash * 37 + c) * 37 + Int32(node.hashCode())
    }

    private var equal: Array<StringTrieBuilder_Node>

    private var length: Int32 = 0

    private var values: Array<Int32>

    private var units: Array<Char>
}


class StringTrieBuilder_SplitBranchNode <: StringTrieBuilder_BranchNode {
    public init(middleUnit: Char, lessThanNode: StringTrieBuilder_Node, greaterOrEqualNode: StringTrieBuilder_Node) {
        super()
        hash = ((5592405 * 37 + Int32(UInt32(middleUnit))) * 37 + Int32(lessThanNode.hashCode())) * 37 + Int32(greaterOrEqualNode.hashCode())
        unit = middleUnit
        lessThan = lessThanNode
        greaterOrEqual = greaterOrEqualNode
    }

    public override func equals(other: Object): Bool {
        if (refEq(this, other)) {
            return true
        }
        if (!super.equals(other)) {
            return false
        }
        let o = other
        return unit == o.unit && refEq(lessThan, o.lessThan) && refEq(greaterOrEqual, o.greaterOrEqual)
    }

    public override func hashCode(): Int64 {
        return super.hashCode()
    }

    public override func markRightEdgesFirst(edgeNumber: Int32): Int32 {
        var tempedgeNumber = edgeNumber
        if (offset == 0) {
            firstEdgeNumber = tempedgeNumber
            tempedgeNumber = greaterOrEqual.markRightEdgesFirst(tempedgeNumber)
            offset = match (0) { case _ => tempedgeNumber = lessThan.markRightEdgesFirst(tempedgeNumber - 1); tempedgeNumber }
        }
        return tempedgeNumber
    }

    public override func write(builder: StringTrieBuilder): Unit {
        lessThan.writeUnlessInsideRightEdge(firstEdgeNumber, greaterOrEqual.getOffset(), builder)
        greaterOrEqual.write(builder)
        if (!(lessThan.getOffset() > 0)) {
            throw AssertionError()
        }
        builder.writeDeltaTo(lessThan.getOffset())
        offset = builder.write(Int32(UInt32(unit)))
    }

    private var unit: Char = '\u{0000}'

    private var lessThan: StringTrieBuilder_Node

    private var greaterOrEqual: StringTrieBuilder_Node
}


class StringTrieBuilder_BranchHeadNode <: StringTrieBuilder_ValueNode {
    public init(len: Int32, subNode: StringTrieBuilder_Node) {
        super()
        length = len
        next = subNode
    }

    public override func hashCode(): Int64 {
        return Int64((6710886 * 37 + length) * 37 + Int32(next.hashCode()))
    }

    public override func equals(other: Object): Bool {
        if (refEq(this, other)) {
            return true
        }
        if (!super.equals(other)) {
            return false
        }
        let o = other
        return length == o.length && refEq(next, o.next)
    }

    public override func markRightEdgesFirst(edgeNumber: Int32): Int32 {
        var tempedgeNumber = edgeNumber
        if (offset == 0) {
            offset = match (0) { case _ => tempedgeNumber = next.markRightEdgesFirst(tempedgeNumber); tempedgeNumber }
        }
        return tempedgeNumber
    }

    public override func write(builder: StringTrieBuilder): Unit {
        next.write(builder)
        if (length <= builder.getMinLinearMatch()) {
            offset = builder.writeValueAndType(hasValue, value, length - 1)
        } else {
            builder.write(length - 1)
            offset = builder.writeValueAndType(hasValue, value, 0)
        }
    }

    private var length: Int32 = 0

    private var next: StringTrieBuilder_Node
}


class StringTrieBuilder_State <: Enum<StringTrieBuilder_State> {
    public static let ADDING = StringTrieBuilder_State("ADDING", 0)

    public static let BUILDING_FAST = StringTrieBuilder_State("BUILDING_FAST", 1)

    public static let BUILDING_SMALL = StringTrieBuilder_State("BUILDING_SMALL", 2)

    public static let BUILT = StringTrieBuilder_State("BUILT", 3)

    private static func _values(): Array<StringTrieBuilder_State> {
        return [StringTrieBuilder_State.ADDING, StringTrieBuilder_State.BUILDING_FAST, StringTrieBuilder_State.BUILDING_SMALL, StringTrieBuilder_State.BUILT]
    }

    private static let _VALUES = StringTrieBuilder_State._values()

    public static func values(): Array<StringTrieBuilder_State> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): StringTrieBuilder_State {
        return (TypeInfo.of<StringTrieBuilder_State>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as StringTrieBuilder_State
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}
