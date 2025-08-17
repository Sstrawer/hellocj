package icu4cj.impl


public class UBiDiProps {
    private init() {
        let bytes = ICUBinary.getData(DATA_FILE_NAME)
        readData(bytes)
    }

    private func readData(bytes: ByteArrayStream): Unit {
        ICUBinary.readHeader(bytes, FMT, UBiDiProps_IsAcceptable())
        var i: Int32 = 0
        var count: Int32 = 0
        count = bytes.getInt()
        if (count < IX_TOP) {
            throw IOException("indexes[0] too small in " + (DATA_FILE_NAME))
        }
        indexes = Array<Int32>(Int64(count)) { _ => 0 }
        indexes[0] = count
        i = 1
        while (i < count) {
            indexes[Int64(i)] = bytes.getInt()
            i++
        }
        trie = Trie2_16.createFromSerialized(bytes)
        let expectedTrieLength = indexes[Int64(IX_TRIE_SIZE)]
        let trieLength = trie.getSerializedLength()
        if (trieLength > expectedTrieLength) {
            throw IOException((DATA_FILE_NAME) + ": not enough bytes for the trie")
        }
        ICUBinary.skipBytes(bytes, expectedTrieLength - trieLength)
        count = indexes[Int64(IX_MIRROR_LENGTH)]
        if (count > 0) {
            mirrors = ICUBinary.getInts(bytes, count, 0)
        }
        count = indexes[Int64(IX_JG_LIMIT)] - indexes[Int64(IX_JG_START)]
        jgArray = Array<UInt8>(Int64(count)) { _ => 0 }
        bytes.get(jgArray)
        count = indexes[Int64(IX_JG_LIMIT2)] - indexes[Int64(IX_JG_START2)]
        jgArray2 = Array<UInt8>(Int64(count)) { _ => 0 }
        bytes.get(jgArray2)
    }

    public func addPropertyStarts(set: UnicodeSet): Unit {
        var i: Int32 = 0
        var length: Int32 = 0
        var c: Int32 = 0
        var start: Int32 = 0
        var limit: Int32 = 0
        var prev: UInt8 = 0
        var jg: UInt8 = 0
        let trieIterator = trie.iterator()
        var range: Trie2_Range
        while (trieIterator.hasNext() && !(match (0) { case _ => range = trieIterator.next(); range }).leadSurrogate) {
            set.add(range.startCodePoint)
        }
        length = indexes[Int64(IX_MIRROR_LENGTH)]
        i = 0
        while (i < length) {
            c = getMirrorCodePoint(mirrors[Int64(i)])
            set.add(c, c + 1)
            i++
        }
        start = indexes[Int64(IX_JG_START)]
        limit = indexes[Int64(IX_JG_LIMIT)]
        var jga = jgArray
        while (true) {
            length = limit - start
            prev = 0
            i = 0
            while (i < length) {
                jg = jga[Int64(i)]
                if (jg != prev) {
                    set.add(start)
                    prev = jg
                }
                start++
                i++
            }
            if (Int32(prev) != 0) {
                set.add(limit)
            }
            if (limit == indexes[Int64(IX_JG_LIMIT)]) {
                start = indexes[Int64(IX_JG_START2)]
                limit = indexes[Int64(IX_JG_LIMIT2)]
                jga = jgArray2
            } else {
                break
            }
        }
    }

    public func getMaxValue(which: Int32): Int32 {
        let max: Int32
        max = indexes[Int64(IX_MAX_VALUES)]
        match (which) {
            case 4096 => return (max & CLASS_MASK)
            case 4102 => return shr((max & MAX_JG_MASK), MAX_JG_SHIFT)
            case 4103 => return shr((max & JT_MASK), JT_SHIFT)
            case 4117 => return shr((max & BPT_MASK), BPT_SHIFT)
            case _ => return -1
        }
    }

    public func getClass(c: Int32): Int32 {
        return getClassFromProps(trie.get(c))
    }

    public func isMirrored(c: Int32): Bool {
        return getFlagFromProps(trie.get(c), IS_MIRRORED_SHIFT)
    }

    private func getMirror(c: Int32, props: Int32): Int32 {
        let delta = getMirrorDeltaFromProps(props)
        if (delta != ESC_MIRROR_DELTA) {
            return c + delta
        } else {
            var m: Int32 = 0
            var i: Int32 = 0
            let length: Int32
            var c2: Int32 = 0
            length = indexes[Int64(IX_MIRROR_LENGTH)]
            i = 0
            while (i < length) {
                m = mirrors[Int64(i)]
                c2 = getMirrorCodePoint(m)
                if (c == c2) {
                    return getMirrorCodePoint(mirrors[Int64(getMirrorIndex(m))])
                } else if (c < c2) {
                    break
                }
                i++
            }
            return c
        }
    }

    public func getMirror(c: Int32): Int32 {
        let props = trie.get(c)
        return getMirror(c, props)
    }

    public func isBidiControl(c: Int32): Bool {
        return getFlagFromProps(trie.get(c), BIDI_CONTROL_SHIFT)
    }

    public func isJoinControl(c: Int32): Bool {
        return getFlagFromProps(trie.get(c), JOIN_CONTROL_SHIFT)
    }

    public func getJoiningType(c: Int32): Int32 {
        return shr((trie.get(c) & JT_MASK), JT_SHIFT)
    }

    public func getJoiningGroup(c: Int32): Int32 {
        var start: Int32 = 0
        var limit: Int32 = 0
        start = indexes[Int64(IX_JG_START)]
        limit = indexes[Int64(IX_JG_LIMIT)]
        if (start <= c && c < limit) {
            return Int32(jgArray[Int64(c - start)]) & 255
        }
        start = indexes[Int64(IX_JG_START2)]
        limit = indexes[Int64(IX_JG_LIMIT2)]
        if (start <= c && c < limit) {
            return Int32(jgArray2[Int64(c - start)]) & 255
        }
        return UCharacter_JoiningGroup.NO_JOINING_GROUP
    }

    public func getPairedBracketType(c: Int32): Int32 {
        return shr((trie.get(c) & BPT_MASK), BPT_SHIFT)
    }

    public func getPairedBracket(c: Int32): Int32 {
        let props = trie.get(c)
        if ((props & BPT_MASK) == 0) {
            return c
        } else {
            return getMirror(c, props)
        }
    }

    private var indexes: Array<Int32>

    private var mirrors: Array<Int32>

    private var jgArray: Array<UInt8>

    private var jgArray2: Array<UInt8>

    private var trie: Trie2_16

    private static let DATA_NAME = "ubidi"

    private static let DATA_TYPE = "icu"

    private static let DATA_FILE_NAME: String = DATA_NAME + "." + DATA_TYPE

    private static let FMT = 1114195049

    private static let IX_TRIE_SIZE = 2

    private static let IX_MIRROR_LENGTH = 3

    private static let IX_JG_START = 4

    private static let IX_JG_LIMIT = 5

    private static let IX_JG_START2 = 6

    private static let IX_JG_LIMIT2 = 7

    private static let IX_MAX_VALUES = 15

    private static let IX_TOP = 16

    private static let JT_SHIFT = 5

    private static let BPT_SHIFT = 8

    private static let JOIN_CONTROL_SHIFT = 10

    private static let BIDI_CONTROL_SHIFT = 11

    private static let IS_MIRRORED_SHIFT = 12

    private static let MIRROR_DELTA_SHIFT = 13

    private static let MAX_JG_SHIFT = 16

    private static let CLASS_MASK = 31

    private static let JT_MASK = 224

    private static let BPT_MASK = 768

    private static let MAX_JG_MASK = 16711680

    private static func getClassFromProps(props: Int32): Int32 {
        return props & CLASS_MASK
    }

    private static func getFlagFromProps(props: Int32, shift: Int32): Bool {
        return ((shr(props, shift)) & 1) != 0
    }

    private static func getMirrorDeltaFromProps(props: Int32): Int32 {
        return shr(Int32(Int16(props)), MIRROR_DELTA_SHIFT)
    }

    private static let ESC_MIRROR_DELTA = -4

    private static let MIRROR_INDEX_SHIFT = 21

    private static func getMirrorCodePoint(m: Int32): Int32 {
        return m & 2097151
    }

    private static func getMirrorIndex(m: Int32): Int32 {
        return ushr(m, MIRROR_INDEX_SHIFT)
    }

    public static let INSTANCE: UBiDiProps

}


class UBiDiProps_IsAcceptable <: ICUBinary_Authenticate {

    public override func isDataVersionAcceptable(version: Array<UInt8>): Bool {
        return Int32(version[0]) == 2
    }
}
