package icu4cj.impl


public class RBBIDataWrapper {
    public static func equals(left: RBBIDataWrapper_RBBIStateTable, right: RBBIDataWrapper_RBBIStateTable): Bool {
        if (refEq(left, right)) {
            return true
        }
        if (left.isNone() || right.isNone()) {
            return false
        }
        return left.equals(right)
    }

    public var fHeader: RBBIDataWrapper_RBBIDataHeader

    public var fFTable: RBBIDataWrapper_RBBIStateTable

    public var fRTable: RBBIDataWrapper_RBBIStateTable

    public var fTrie: CodePointTrie

    public var fRuleSource: String

    public var fStatusTable: Array<Int32>

    public static let DATA_FORMAT = 1114794784

    public static let FORMAT_VERSION = 100663296

    private static let IS_ACCEPTABLE = RBBIDataWrapper_IsAcceptable()

    public static let DH_SIZE = 20

    public static let DH_MAGIC = 0

    public static let DH_FORMATVERSION = 1

    public static let DH_LENGTH = 2

    public static let DH_CATCOUNT = 3

    public static let DH_FTABLE = 4

    public static let DH_FTABLELEN = 5

    public static let DH_RTABLE = 6

    public static let DH_RTABLELEN = 7

    public static let DH_TRIE = 8

    public static let DH_TRIELEN = 9

    public static let DH_RULESOURCE = 10

    public static let DH_RULESOURCELEN = 11

    public static let DH_STATUSTABLE = 12

    public static let DH_STATUSTABLELEN = 13

    public static let ACCEPTING = 0

    public static let LOOKAHEAD = 1

    public static let TAGSIDX = 2

    public static let NEXTSTATES = 3

    public static let ACCEPTING_UNCONDITIONAL = 1

    public static let RBBI_LOOKAHEAD_HARD_BREAK = 1

    public static let RBBI_BOF_REQUIRED = 2

    public static let RBBI_8BITS_ROWS = 4

    public func getRowIndex(state: Int32): Int32 {
        return state * (fHeader.fCatCount + NEXTSTATES)
    }


    public static func get(bytes: ByteArrayStream): RBBIDataWrapper {
        let `This` = RBBIDataWrapper()
        ICUBinary.readHeader(bytes, DATA_FORMAT, IS_ACCEPTABLE)
        `This`.fHeader = RBBIDataWrapper_RBBIDataHeader()
        `This`.fHeader.fMagic = bytes.getInt()
        `This`.fHeader.fFormatVersion[0] = bytes.get()
        `This`.fHeader.fFormatVersion[1] = bytes.get()
        `This`.fHeader.fFormatVersion[2] = bytes.get()
        `This`.fHeader.fFormatVersion[3] = bytes.get()
        `This`.fHeader.fLength = bytes.getInt()
        `This`.fHeader.fCatCount = bytes.getInt()
        `This`.fHeader.fFTable = bytes.getInt()
        `This`.fHeader.fFTableLen = bytes.getInt()
        `This`.fHeader.fRTable = bytes.getInt()
        `This`.fHeader.fRTableLen = bytes.getInt()
        `This`.fHeader.fTrie = bytes.getInt()
        `This`.fHeader.fTrieLen = bytes.getInt()
        `This`.fHeader.fRuleSource = bytes.getInt()
        `This`.fHeader.fRuleSourceLen = bytes.getInt()
        `This`.fHeader.fStatusTable = bytes.getInt()
        `This`.fHeader.fStatusTableLen = bytes.getInt()
        ICUBinary.skipBytes(bytes, 6 * 4)
        if (`This`.fHeader.fMagic != 45472 || !IS_ACCEPTABLE.isDataVersionAcceptable(`This`.fHeader.fFormatVersion)) {
            throw IOException("Break Iterator Rule Data Magic Number Incorrect, or unsupported data version.")
        }
        var pos = DH_SIZE * 4
        if (`This`.fHeader.fFTable < pos || `This`.fHeader.fFTable > `This`.fHeader.fLength) {
            throw IOException("Break iterator Rule data corrupt")
        }
        ICUBinary.skipBytes(bytes, `This`.fHeader.fFTable - pos)
        pos = `This`.fHeader.fFTable
        `This`.fFTable = RBBIDataWrapper_RBBIStateTable.get(bytes, `This`.fHeader.fFTableLen)
        pos += `This`.fHeader.fFTableLen
        ICUBinary.skipBytes(bytes, `This`.fHeader.fRTable - pos)
        pos = `This`.fHeader.fRTable
        `This`.fRTable = RBBIDataWrapper_RBBIStateTable.get(bytes, `This`.fHeader.fRTableLen)
        pos += `This`.fHeader.fRTableLen
        ICUBinary.skipBytes(bytes, `This`.fHeader.fTrie - pos)
        pos = `This`.fHeader.fTrie
        bytes.mark()
        `This`.fTrie = CodePointTrie.fromBinary(CodePointTrie_Type.FAST, None, bytes)
        bytes.reset()
        if (pos > `This`.fHeader.fStatusTable) {
            throw IOException("Break iterator Rule data corrupt")
        }
        ICUBinary.skipBytes(bytes, `This`.fHeader.fStatusTable - pos)
        pos = `This`.fHeader.fStatusTable
        `This`.fStatusTable = ICUBinary.getInts(bytes, `This`.fHeader.fStatusTableLen / 4, `This`.fHeader.fStatusTableLen & 3)
        pos += `This`.fHeader.fStatusTableLen
        if (pos > `This`.fHeader.fRuleSource) {
            throw IOException("Break iterator Rule data corrupt")
        }
        ICUBinary.skipBytes(bytes, `This`.fHeader.fRuleSource - pos)
        pos = `This`.fHeader.fRuleSource
        `This`.fRuleSource = String.fromUtf8(ICUBinary.toArray() // bytes, `This`.fHeader.fRuleSourceLen, 0))
        if (RuleBasedBreakIterator.fDebugEnv.isSome() && indexOfWrap(RuleBasedBreakIterator.fDebugEnv.indexOf("data")) >= 0) {
            `This`.dump(Console.stdOut as PrintStream)
        }
        return `This`
    }

    public func dump(out: PrintStream): Unit {
        if (fFTable.isNone()) {
            throw NoneValueException()
        }
        out.println("RBBI Data Wrapper dump ...")
        out.println()
        out.println("Forward State Table")
        dumpTable(out, fFTable)
        out.println("Reverse State Table")
        dumpTable(out, fRTable)
        dumpCharCategories(out)
        out.println("Source Rules: " + (fRuleSource))
    }

    public static func intToString(n: Int32, width: Int32): String {
        let dest = StringBuilder()
        dest.append(n)
        while (Int32(dest.size) < width) {
            dest.insert(0, ' ')
        }
        return dest.toString()
    }

    public static func charToString(n: Char, width: Int32): String {
        let dest = StringBuilder()
        dest.append(n)
        while (Int32(dest.size) < width) {
            dest.insert(0, ' ')
        }
        return dest.toString()
    }

    public static func intToHexString(n: Int32, width: Int32): String {
        let dest = StringBuilder()
        dest.append(n.format("x"))
        while (Int32(dest.size) < width) {
            dest.insert(0, ' ')
        }
        return dest.toString()
    }

    private func dumpTable(out: PrintStream, table: RBBIDataWrapper_RBBIStateTable): Unit {
        if (table.isNone() || (Int32(table.fTable.size) == 0)) {
            out.println("  -- null -- ")
        } else {
            var n: Char = '\u{0000}'
            var state: Char = '\u{0000}'
            let header = StringBuilder(" Row  Acc Look  Tag")
            n = Char(0)
            while (Int32(UInt32(n)) < fHeader.fCatCount) {
                header.append(intToString(Int32(UInt32(n)), 5))
                n++
            }
            out.println(header.toString())
            n = Char(0)
            while (Int32(UInt32(n)) < Int32(header.size)) {
                out.print("-")
                n++
            }
            out.println()
            state = Char(0)
            while (Int32(UInt32(state)) < table.fNumStates) {
                dumpRow(out, table, state)
                state++
            }
            out.println()
        }
    }

    private func dumpRow(out: PrintStream, table: RBBIDataWrapper_RBBIStateTable, state: Char): Unit {
        let dest = StringBuilder()
        dest.append(intToString(Int32(UInt32(state)), 4))
        let row = getRowIndex(Int32(UInt32(state)))
        if (Int32(UInt32(table.fTable[Int64(row + ACCEPTING)])) != 0) {
            dest.append(intToString(Int32(UInt32(table.fTable[Int64(row + ACCEPTING)])), 5))
        } else {
            dest.append("     ")
        }
        if (Int32(UInt32(table.fTable[Int64(row + LOOKAHEAD)])) != 0) {
            dest.append(intToString(Int32(UInt32(table.fTable[Int64(row + LOOKAHEAD)])), 5))
        } else {
            dest.append("     ")
        }
        dest.append(intToString(Int32(UInt32(table.fTable[Int64(row + TAGSIDX)])), 5))
        var col = 0
        while (col < fHeader.fCatCount) {
            dest.append(intToString(Int32(UInt32(table.fTable[Int64(row + NEXTSTATES + col)])), 5))
            col++
        }
        out.println(dest)
    }

    private func dumpCharCategories(out: PrintStream): Unit {
        let n = fHeader.fCatCount
        let catStrings = Array<String>(Int64(n + 1))
        var rangeStart = 0
        var rangeEnd = 0
        var lastCat = -1
        var char32: Int32 = 0
        var category: Int32 = 0
        let lastNewline = Array<Int32>(Int64(n + 1)) { _ => 0 }
        category = 0
        while (category <= fHeader.fCatCount) {
            catStrings[Int64(category)] = ""
            category++
        }
        out.println("\nCharacter Categories")
        out.println("--------------------")
        char32 = 0
        while (char32 <= 1114111) {
            category = fTrie.get(char32)
            if (category < 0 || category > fHeader.fCatCount) {
                out.println("Error, bad category " + category.format("x") + " for char " + char32.format("x"))
                break
            }
            if (category == lastCat) {
                rangeEnd = char32
            } else {
                if (lastCat >= 0) {
                    if (Int32(catStrings[Int64(lastCat)].size) > lastNewline[Int64(lastCat)] + 70) {
                        lastNewline[Int64(lastCat)] = Int32(catStrings[Int64(lastCat)].size) + 10
                        catStrings[Int64(lastCat)] += "\n       "
                    }
                    catStrings[Int64(lastCat)] += " " + rangeStart.format("x")
                    if (rangeEnd != rangeStart) {
                        catStrings[Int64(lastCat)] += "-" + rangeEnd.format("x")
                    }
                }
                lastCat = category
                rangeStart = match (0) { case _ => rangeEnd = char32; rangeEnd }
            }
            char32++
        }
        catStrings[Int64(lastCat)] += " " + rangeStart.format("x")
        if (rangeEnd != rangeStart) {
            catStrings[Int64(lastCat)] += "-" + rangeEnd.format("x")
        }
        category = 0
        while (category <= fHeader.fCatCount) {
            out.println((intToString(category, 5)) + "  " + (catStrings[Int64(category)]))
            category++
        }
        out.println()
    }
}


public class RBBIDataWrapper_RBBIStateTable {
    public var fNumStates: Int32 = 0

    public var fRowLen: Int32 = 0

    public var fDictCategoriesStart: Int32 = 0

    public var fLookAheadResultsSize: Int32 = 0

    public var fFlags: Int32 = 0

    public static var fHeaderSize = 20

    public var fTable: Array<Char>


    static func get(bytes: ByteArrayStream, length: Int32): RBBIDataWrapper_RBBIStateTable {
        if (length == 0) {
            return None
        }
        if (length < fHeaderSize) {
            throw IOException("Invalid RBBI state table length.")
        }
        let `This` = RBBIDataWrapper_RBBIStateTable()
        `This`.fNumStates = bytes.getInt()
        `This`.fRowLen = bytes.getInt()
        `This`.fDictCategoriesStart = bytes.getInt()
        `This`.fLookAheadResultsSize = bytes.getInt()
        `This`.fFlags = bytes.getInt()
        let lengthOfTable = length - fHeaderSize
        let use8Bits = (`This`.fFlags & RBBIDataWrapper.RBBI_8BITS_ROWS) == RBBIDataWrapper.RBBI_8BITS_ROWS
        if (use8Bits) {
            `This`.fTable = Array<Char>(Int64(lengthOfTable)) { _ => '\u{0000}' }
            var i = 0
            while (i < lengthOfTable) {
                let b = bytes.get()
                `This`.fTable[Int64(i)] = Char(255 & Int32(b))
                i++
            }
            ICUBinary.skipBytes(bytes, lengthOfTable & 1)
        } else {
            `This`.fTable = ICUBinary.getChars(bytes, lengthOfTable / 2, lengthOfTable & 1)
        }
        return `This`
    }

    public func put(bytes: DataOutputStream): Int32 {
        bytes.writeInt(fNumStates)
        bytes.writeInt(fRowLen)
        bytes.writeInt(fDictCategoriesStart)
        bytes.writeInt(fLookAheadResultsSize)
        bytes.writeInt(fFlags)
        if ((fFlags & RBBIDataWrapper.RBBI_8BITS_ROWS) == RBBIDataWrapper.RBBI_8BITS_ROWS) {
            let tableLen = fRowLen * fNumStates
            } while (false)
        } else {
            let tableLen = fRowLen * fNumStates / 2
            } while (false)
        }
        var bytesWritten = fHeaderSize + fRowLen * fNumStates
        while (bytesWritten % 8 != 0) {
            bytes.writeByte(0)
            bytesWritten++
        }
        return bytesWritten
    }

    public override func equals(other: Object): Bool {
        if (refEq(other, this)) {
            return true
        }
        if (!(checkOptionalIs<RBBIDataWrapper_RBBIStateTable, Object>(other))) {
            return false
        }
        let otherST = other
        if (fNumStates != otherST.fNumStates) {
            return false
        }
        if (fRowLen != otherST.fRowLen) {
            return false
        }
        if (fDictCategoriesStart != otherST.fDictCategoriesStart) {
            return false
        }
        if (fLookAheadResultsSize != otherST.fLookAheadResultsSize) {
            return false
        }
        if (fFlags != otherST.fFlags) {
            return false
        }
        return fTable == otherST.fTable
    }
}


class RBBIDataWrapper_IsAcceptable <: ICUBinary_Authenticate {

    public override func isDataVersionAcceptable(version: Array<UInt8>): Bool {
        let intVersion = (shl(Int32(version[0]), 24)) + (shl(Int32(version[1]), 16)) + (shl(Int32(version[2]), 8)) + Int32(version[3])
        return intVersion == RBBIDataWrapper.FORMAT_VERSION
    }
}


public class RBBIDataWrapper_RBBIDataHeader {
    var fMagic: Int32 = 0

    var fFormatVersion: Array<UInt8>

    var fLength: Int32 = 0

    public var fCatCount: Int32 = 0

    var fFTable: Int32 = 0

    var fFTableLen: Int32 = 0

    var fRTable: Int32 = 0

    var fRTableLen: Int32 = 0

    var fTrie: Int32 = 0

    var fTrieLen: Int32 = 0

    var fRuleSource: Int32 = 0

    var fRuleSourceLen: Int32 = 0

    var fStatusTable: Int32 = 0

    var fStatusTableLen: Int32 = 0

    public init() {
        fMagic = 0
        fFormatVersion = Array<UInt8>(4) { _ => 0 }
    }
}
