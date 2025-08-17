package icu4cj.impl


public class EmojiProps {
    private static let IS_ACCEPTABLE = EmojiProps_IsAcceptable()

    private static let DATA_FORMAT = 1164799850

    private static let IX_CPTRIE_OFFSET = 0

    private static let IX_BASIC_EMOJI_TRIE_OFFSET = 4

    private static let IX_RGI_EMOJI_ZWJ_SEQUENCE_TRIE_OFFSET = 9

    private static let BIT_EMOJI = 0

    private static let BIT_EMOJI_PRESENTATION = 1

    private static let BIT_EMOJI_MODIFIER = 2

    private static let BIT_EMOJI_MODIFIER_BASE = 3

    private static let BIT_EMOJI_COMPONENT = 4

    private static let BIT_EXTENDED_PICTOGRAPHIC = 5

    private static let BIT_BASIC_EMOJI = 6

    public static let INSTANCE = EmojiProps()

    private var cpTrie: CodePointTrie_Fast8

    private var stringTries: Array<String> = Array<String>(6)

    private static func getStringTrieIndex(i: Int32): Int32 {
        return i - IX_BASIC_EMOJI_TRIE_OFFSET
    }

    private init() {
        let bytes = ICUBinary.getRequiredData("uemoji.icu")
        try {
            ICUBinary.readHeaderAndDataVersion(bytes, DATA_FORMAT, IS_ACCEPTABLE)
            let startPos = bytes.position()
            let cpTrieOffset = bytes.getInt()
            let indexesLength = cpTrieOffset / 4
            if (indexesLength <= IX_RGI_EMOJI_ZWJ_SEQUENCE_TRIE_OFFSET) {
                throw ICUUncheckedIOException("Emoji properties data: not enough indexes")
            }
            let inIndexes = Array<Int32>(Int64(indexesLength)) { _ => 0 }
            inIndexes[0] = cpTrieOffset
            } while (false)
            var i = IX_CPTRIE_OFFSET
            var offset = inIndexes[Int64(match (0) { case _ => i++; i - 1 })]
            var nextOffset = inIndexes[Int64(i)]
            cpTrie = CodePointTrie_Fast8.fromBinary(bytes)
            let pos = bytes.position() - startPos
            if (!(nextOffset >= pos)) {
                throw AssertionError()
            }
            ICUBinary.skipBytes(bytes, nextOffset - pos)
            offset = nextOffset
            nextOffset = inIndexes[Int64(IX_BASIC_EMOJI_TRIE_OFFSET)]
            ICUBinary.skipBytes(bytes, nextOffset - offset)
            i = IX_BASIC_EMOJI_TRIE_OFFSET
            while (i <= IX_RGI_EMOJI_ZWJ_SEQUENCE_TRIE_OFFSET) {
                offset = inIndexes[Int64(i)]
                nextOffset = inIndexes[Int64(i + 1)]
                if (nextOffset > offset) {
                    stringTries[Int64(getStringTrieIndex(i))] = ICUBinary.getString(bytes, (nextOffset - offset) / 2, 0)
                }
                i++
            }
        } catch (e: IOException) {
            throw ICUUncheckedIOException(e)
        }
    }

    public func addPropertyStarts(set: UnicodeSet): UnicodeSet {
        let range = CodePointMap_Range()
        var start = 0
        while (cpTrie.getRange(start, None, range)) {
            set.add(start)
            start = range.getEnd() + 1
        }
        return set
    }

    private static let bitFlags: Array<UInt8> = [UInt8(BIT_EMOJI), UInt8(BIT_EMOJI_PRESENTATION), UInt8(BIT_EMOJI_MODIFIER), UInt8(BIT_EMOJI_MODIFIER_BASE), UInt8(BIT_EMOJI_COMPONENT), 255, 255, UInt8(BIT_EXTENDED_PICTOGRAPHIC), UInt8(BIT_BASIC_EMOJI), 255, 255, 255, 255, 255, UInt8(BIT_BASIC_EMOJI)]

    public func hasBinaryProperty(c: Int32, which: Int32): Bool {
        if (which < UProperty.EMOJI || UProperty.RGI_EMOJI < which) {
            return false
        }
        let bit = Int32(bitFlags[Int64(which - UProperty.EMOJI)])
        if (bit < 0) {
            return false
        }
        let bits = cpTrie.get(c)
        return ((shr(bits, bit)) & 1) != 0
    }

    public func hasBinaryProperty(s: String, which: Int32): Bool {
        let length = s.size
        if (length == 0) {
            return false
        }
        if (which < UProperty.BASIC_EMOJI || UProperty.RGI_EMOJI < which) {
            return false
        }
        var firstProp = which
        var lastProp = which
        if (which == UProperty.RGI_EMOJI) {
            firstProp = UProperty.BASIC_EMOJI
            lastProp = UProperty.RGI_EMOJI_ZWJ_SEQUENCE
        }
        var property = firstProp
        while (property <= lastProp) {
            let trieUChars = stringTries[Int64(property - UProperty.BASIC_EMOJI)]
            if (trieUChars.isSome()) {
                let trie = CharsTrie(trieUChars, 0)
                let result = trie.next(s, 0, length)
                if (result.hasValue()) {
                    return true
                }
            }
            property++
        }
        return false
    }

    public func addStrings(which: Int32, set: UnicodeSet): Unit {
        if (which < UProperty.BASIC_EMOJI || UProperty.RGI_EMOJI < which) {
            return
        }
        var firstProp = which
        var lastProp = which
        if (which == UProperty.RGI_EMOJI) {
            firstProp = UProperty.BASIC_EMOJI
            lastProp = UProperty.RGI_EMOJI_ZWJ_SEQUENCE
        }
        var property = firstProp
        while (property <= lastProp) {
            let trieUChars = stringTries[Int64(property - UProperty.BASIC_EMOJI)]
            if (trieUChars.isSome()) {
                let trie = CharsTrie(trieUChars, 0)
                for (entry in trie) {
                    set.add(entry.chars)
                }
            }
            property++
        }
    }
}


class EmojiProps_IsAcceptable <: ICUBinary_Authenticate {

    public override func isDataVersionAcceptable(version: Array<UInt8>): Bool {
        return Int32(version[0]) == 1
    }
}
