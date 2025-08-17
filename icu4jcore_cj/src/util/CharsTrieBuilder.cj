package icu4cj.util


public class CharsTrieBuilder <: StringTrieBuilder {
    public init() {
        super()
    }

    public func add(s: String, value: Int32): CharsTrieBuilder {
        addImpl(s, value)
        return this
    }

    public func build(buildOption: StringTrieBuilder_Option): CharsTrie {
        return CharsTrie(buildCharSequence(buildOption), 0)
    }

    public func buildCharSequence(buildOption: StringTrieBuilder_Option): String {
        buildChars(buildOption)
        return CharBuffer.wrap(chars, Int32(chars.size) - charsLength, charsLength)
    }

    private func buildChars(buildOption: StringTrieBuilder_Option): Unit {
        if (chars.isNone()) {
            chars = Array<Char>(1024) { _ => '\u{0000}' }
        }
        buildImpl(buildOption)
    }

    public func clear(): CharsTrieBuilder {
        clearImpl()
        chars = None
        charsLength = 0
        return this
    }

    
    override protected func matchNodesCanHaveValues(): Bool {
        return true
    }

    
    override protected func getMaxBranchLinearSubNodeLength(): Int32 {
        return CharsTrie.kMaxBranchLinearSubNodeLength
    }

    
    override protected func getMinLinearMatch(): Int32 {
        return CharsTrie.kMinLinearMatch
    }

    
    override protected func getMaxLinearMatchLength(): Int32 {
        return CharsTrie.kMaxLinearMatchLength
    }

    private func ensureCapacity(length: Int32): Unit {
        if (length > Int32(chars.size)) {
            var newCapacity = Int32(chars.size)
            let newChars = Array<Char>(Int64(newCapacity)) { _ => '\u{0000}' }
            arraycopy(chars, Int64(Int32(chars.size) - charsLength), newChars, Int64(Int32(newChars.size) - charsLength), Int64(charsLength))
            chars = newChars
        }
    }

    
    override protected func write(unit: Int32): Int32 {
        let newLength = charsLength + 1
        ensureCapacity(newLength)
        charsLength = newLength
        chars[Int64(Int32(chars.size) - charsLength)] = Char(unit)
        return charsLength
    }

    
    override protected func write(offset: Int32, length: Int32): Int32 {
        var tempoffset = offset
        var templength = length
        let newLength = charsLength + templength
        ensureCapacity(newLength)
        charsLength = newLength
        var charsOffset = Int32(chars.size) - charsLength
        while (templength > 0) {
            chars[Int64(match (0) { case _ => charsOffset++; charsOffset - 1 })] = strings.get(Int64(match (0) { case _ => tempoffset++; tempoffset - 1 }))
            templength--
        }
        return charsLength
    }

    private func write(s: Array<Char>, length: Int32): Int32 {
        let newLength = charsLength + length
        ensureCapacity(newLength)
        charsLength = newLength
        arraycopy(s, 0, chars, Int64(Int32(chars.size) - charsLength), Int64(length))
        return charsLength
    }

    private let intUnits = Array<Char>(3) { _ => '\u{0000}' }

    
    override protected func writeValueAndFinal(i: Int32, isFinal: Bool): Int32 {
        if (0 <= i && i <= CharsTrie.kMaxOneUnitValue) {
            return write(i | (if (isFinal) { CharsTrie.kValueIsFinal } else { 0 }))
        }
        let length: Int32
        if (i < 0 || i > CharsTrie.kMaxTwoUnitValue) {
            intUnits[0] = Char(CharsTrie.kThreeUnitValueLead)
            intUnits[1] = Char(shr(i, 16))
            intUnits[2] = Char(i)
            length = 3
        } else {
            intUnits[0] = Char(CharsTrie.kMinTwoUnitValueLead + (shr(i, 16)))
            intUnits[1] = Char(i)
            length = 2
        }
        intUnits[0] = Char(Int32(UInt32(intUnits[0])) | (if (isFinal) { CharsTrie.kValueIsFinal } else { 0 }))
        return write(intUnits, length)
    }

    
    override protected func writeValueAndType(hasValue: Bool, value: Int32, node: Int32): Int32 {
        if (!hasValue) {
            return write(node)
        }
        let length: Int32
        if (value < 0 || value > CharsTrie.kMaxTwoUnitNodeValue) {
            intUnits[0] = Char(CharsTrie.kThreeUnitNodeValueLead)
            intUnits[1] = Char(shr(value, 16))
            intUnits[2] = Char(value)
            length = 3
        } else if (value <= CharsTrie.kMaxOneUnitNodeValue) {
            intUnits[0] = Char(shl((value + 1), 6))
            length = 1
        } else {
            intUnits[0] = Char(CharsTrie.kMinTwoUnitNodeValueLead + ((shr(value, 10)) & 32704))
            intUnits[1] = Char(value)
            length = 2
        }
        intUnits[0] |= Char(node)
        return write(intUnits, length)
    }

    
    override protected func writeDeltaTo(jumpTarget: Int32): Int32 {
        let i = charsLength - jumpTarget
        if (!(i >= 0)) {
            throw AssertionError()
        }
        if (i <= CharsTrie.kMaxOneUnitDelta) {
            return write(i)
        }
        var length: Int32 = 0
        if (i <= CharsTrie.kMaxTwoUnitDelta) {
            intUnits[0] = Char(CharsTrie.kMinTwoUnitDeltaLead + (shr(i, 16)))
            length = 1
        } else {
            intUnits[0] = Char(CharsTrie.kThreeUnitDeltaLead)
            intUnits[1] = Char(shr(i, 16))
            length = 2
        }
        intUnits[Int64(match (0) { case _ => length++; length - 1 })] = Char(i)
        return write(intUnits, length)
    }

    private var chars: Array<Char>

    private var charsLength: Int32 = 0
}
