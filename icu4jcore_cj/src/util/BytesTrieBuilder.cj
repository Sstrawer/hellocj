package icu4cj.util

public class BytesTrieBuilder <: StringTrieBuilder {
    public init() {
        super()
    }

    public func add(sequence: Array<UInt8>, length: Int32, value: Int32): BytesTrieBuilder {
        addImpl(BytesTrieBuilder_BytesAsCharSequence(sequence, length), value)
        return this
    }

    public func build(buildOption: StringTrieBuilder_Option): BytesTrie {
        buildBytes(buildOption)
        return BytesTrie(bytes, Int32(bytes.size) - bytesLength)
    }

    public func buildByteArrayStream(buildOption: StringTrieBuilder_Option): ByteArrayStream {
        buildBytes(buildOption)
        return ByteArrayStream.wrap(bytes, Int32(bytes.size) - bytesLength, bytesLength)
    }

    private func buildBytes(buildOption: StringTrieBuilder_Option): Unit {
        if (bytes.isNone()) {
            bytes = Array<UInt8>(1024) { _ => 0 }
        }
        buildImpl(buildOption)
    }

    public func clear(): BytesTrieBuilder {
        clearImpl()
        bytes = None
        bytesLength = 0
        return this
    }

    
    override protected func matchNodesCanHaveValues(): Bool {
        return false
    }

    
    override protected func getMaxBranchLinearSubNodeLength(): Int32 {
        return BytesTrie.kMaxBranchLinearSubNodeLength
    }

    
    override protected func getMinLinearMatch(): Int32 {
        return BytesTrie.kMinLinearMatch
    }

    
    override protected func getMaxLinearMatchLength(): Int32 {
        return BytesTrie.kMaxLinearMatchLength
    }

    private func ensureCapacity(length: Int32): Unit {
        if (length > Int32(bytes.size)) {
            var newCapacity = Int32(bytes.size)
            let newBytes = Array<UInt8>(Int64(newCapacity)) { _ => 0 }
            arraycopy(bytes, Int64(Int32(bytes.size) - bytesLength), newBytes, Int64(Int32(newBytes.size) - bytesLength), Int64(bytesLength))
            bytes = newBytes
        }
    }

    
    override protected func write(b: Int32): Int32 {
        let newLength = bytesLength + 1
        ensureCapacity(newLength)
        bytesLength = newLength
        bytes[Int64(Int32(bytes.size) - bytesLength)] = UInt8(b)
        return bytesLength
    }

    
    override protected func write(offset: Int32, length: Int32): Int32 {
        var tempoffset = offset
        var templength = length
        let newLength = bytesLength + templength
        ensureCapacity(newLength)
        bytesLength = newLength
        var bytesOffset = Int32(bytes.size) - bytesLength
        while (templength > 0) {
            bytes[Int64(match (0) { case _ => bytesOffset++; bytesOffset - 1 })] = UInt8(UInt32(strings.get(Int64(match (0) { case _ => tempoffset++; tempoffset - 1 }))))
            templength--
        }
        return bytesLength
    }

    private func write(b: Array<UInt8>, length: Int32): Int32 {
        let newLength = bytesLength + length
        ensureCapacity(newLength)
        bytesLength = newLength
        arraycopy(b, 0, bytes, Int64(Int32(bytes.size) - bytesLength), Int64(length))
        return bytesLength
    }

    private let intBytes = Array<UInt8>(5) { _ => 0 }

    
    override protected func writeValueAndFinal(i: Int32, isFinal: Bool): Int32 {
        if (0 <= i && i <= BytesTrie.kMaxOneByteValue) {
            return write((shl((BytesTrie.kMinOneByteValueLead + i), 1)) | (if (isFinal) { 1 } else { 0 }))
        }
        var length = 1
        if (i < 0 || i > 16777215) {
            intBytes[0] = UInt8(BytesTrie.kFiveByteValueLead)
            intBytes[1] = UInt8(shr(i, 24))
            intBytes[2] = UInt8(shr(i, 16))
            intBytes[3] = UInt8(shr(i, 8))
            intBytes[4] = UInt8(i)
            length = 5
        } else {
            if (i <= BytesTrie.kMaxTwoByteValue) {
                intBytes[0] = UInt8(BytesTrie.kMinTwoByteValueLead + (shr(i, 8)))
            } else {
                if (i <= BytesTrie.kMaxThreeByteValue) {
                    intBytes[0] = UInt8(BytesTrie.kMinThreeByteValueLead + (shr(i, 16)))
                } else {
                    intBytes[0] = UInt8(BytesTrie.kFourByteValueLead)
                    intBytes[1] = UInt8(shr(i, 16))
                    length = 2
                }
                intBytes[Int64(match (0) { case _ => length++; length - 1 })] = UInt8(shr(i, 8))
            }
            intBytes[Int64(match (0) { case _ => length++; length - 1 })] = UInt8(i)
        }
        intBytes[0] = UInt8((shl(Int32(intBytes[0]), 1)) | (if (isFinal) { 1 } else { 0 }))
        return write(intBytes, length)
    }

    
    override protected func writeValueAndType(hasValue: Bool, value: Int32, node: Int32): Int32 {
        var offset = write(node)
        if (hasValue) {
            offset = writeValueAndFinal(value, false)
        }
        return offset
    }

    
    override protected func writeDeltaTo(jumpTarget: Int32): Int32 {
        let i = bytesLength - jumpTarget
        if (!(i >= 0)) {
            throw AssertionError()
        }
        if (i <= BytesTrie.kMaxOneByteDelta) {
            return write(i)
        } else {
            return write(intBytes, internalEncodeDelta(i, intBytes))
        }
    }

    
    public static func internalEncodeDelta(i: Int32, intBytes: Array<UInt8>): Int32 {
        if (!(i >= 0)) {
            throw AssertionError()
        }
        if (i <= BytesTrie.kMaxOneByteDelta) {
            intBytes[0] = UInt8(i)
            return 1
        }
        var length = 1
        if (i <= BytesTrie.kMaxTwoByteDelta) {
            intBytes[0] = UInt8(BytesTrie.kMinTwoByteDeltaLead + (shr(i, 8)))
        } else {
            if (i <= BytesTrie.kMaxThreeByteDelta) {
                intBytes[0] = UInt8(BytesTrie.kMinThreeByteDeltaLead + (shr(i, 16)))
            } else {
                if (i <= 16777215) {
                    intBytes[0] = UInt8(BytesTrie.kFourByteDeltaLead)
                } else {
                    intBytes[0] = UInt8(BytesTrie.kFiveByteDeltaLead)
                    intBytes[1] = UInt8(shr(i, 24))
                    length = 2
                }
                intBytes[Int64(match (0) { case _ => length++; length - 1 })] = UInt8(shr(i, 16))
            }
            intBytes[Int64(match (0) { case _ => length++; length - 1 })] = UInt8(shr(i, 8))
        }
        intBytes[Int64(match (0) { case _ => length++; length - 1 })] = UInt8(i)
        return length
    }

    private var bytes: Array<UInt8>

    private var bytesLength: Int32 = 0
}


class BytesTrieBuilder_BytesAsCharSequence <: String {
    public init(sequence: Array<UInt8>, length: Int32) {
        s = sequence
        len = length
    }

    public override func charAt(i: Int32): Char {
        return Char(Int32(s[Int64(i)]) & 255)
    }

    public override func length(): Int32 {
        return len
    }

    public override func subSequence(start: Int32, end: Int32): String {
        return None
    }

    private var s: Array<UInt8>

    private var len: Int32 = 0
}
