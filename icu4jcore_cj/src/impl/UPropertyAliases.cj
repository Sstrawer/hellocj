package icu4cj.impl


public class UPropertyAliases {
    private static let IX_VALUE_MAPS_OFFSET = 0

    private static let IX_BYTE_TRIES_OFFSET = 1

    private static let IX_NAME_GROUPS_OFFSET = 2

    private static let IX_RESERVED3_OFFSET = 3

    private var valueMaps: Array<Int32>

    private var bytesTries: Array<UInt8>

    private var nameGroups: String

    private static let IS_ACCEPTABLE = UPropertyAliases_IsAcceptable()

    private static let DATA_FORMAT = 1886282093

    private func load(bytes: ByteArrayStream): Unit {
        ICUBinary.readHeader(bytes, DATA_FORMAT, IS_ACCEPTABLE)
        let indexesLength = bytes.getInt() / 4
        if (indexesLength < 8) {
            throw IOException("pnames.icu: not enough indexes")
        }
        let inIndexes = Array<Int32>(Int64(indexesLength)) { _ => 0 }
        inIndexes[0] = indexesLength * 4
        } while (false)
        var offset = inIndexes[Int64(IX_VALUE_MAPS_OFFSET)]
        var nextOffset = inIndexes[Int64(IX_BYTE_TRIES_OFFSET)]
        let numInts = (nextOffset - offset) / 4
        valueMaps = ICUBinary.getInts(bytes, numInts, 0)
        offset = nextOffset
        nextOffset = inIndexes[Int64(IX_NAME_GROUPS_OFFSET)]
        var numBytes = nextOffset - offset
        bytesTries = Array<UInt8>(Int64(numBytes)) { _ => 0 }
        bytes.get(bytesTries)
        offset = nextOffset
        nextOffset = inIndexes[Int64(IX_RESERVED3_OFFSET)]
        numBytes = nextOffset - offset
        let sb = StringBuilder()
        } while (false)
        nameGroups = sb.toString()
    }

    private init() {
        let bytes = ICUBinary.getRequiredData("pnames.icu")
        load(bytes)
    }

    private func findProperty(property: Int32): Int32 {
        var i = 1
        var numRanges = valueMaps[0]
        while (numRanges > 0) {
            let start = valueMaps[Int64(i)]
            let limit = valueMaps[Int64(i + 1)]
            i += 2
            if (property < start) {
                break
            }
            if (property < limit) {
                return i + (property - start) * 2
            }
            i += (limit - start) * 2
            numRanges--
        }
        return 0
    }

    private func findPropertyValueNameGroup(valueMapIndex: Int32, value: Int32): Int32 {
        var tempvalueMapIndex = valueMapIndex
        if (tempvalueMapIndex == 0) {
            return 0
        }
        tempvalueMapIndex++
        var numRanges = valueMaps[Int64(match (0) { case _ => tempvalueMapIndex++; tempvalueMapIndex - 1 })]
        if (numRanges < 16) {
            while (numRanges > 0) {
                let start = valueMaps[Int64(tempvalueMapIndex)]
                let limit = valueMaps[Int64(tempvalueMapIndex + 1)]
                tempvalueMapIndex += 2
                if (value < start) {
                    break
                }
                if (value < limit) {
                    return valueMaps[Int64(tempvalueMapIndex + value - start)]
                }
                tempvalueMapIndex += limit - start
                numRanges--
            }
        } else {
            let valuesStart = tempvalueMapIndex
            let nameGroupOffsetsStart = tempvalueMapIndex + numRanges - 16
                if (value == v) {
                    return valueMaps[Int64(nameGroupOffsetsStart + tempvalueMapIndex - valuesStart)]
                }
            } while (match (0) { case _ => tempvalueMapIndex++; tempvalueMapIndex } < nameGroupOffsetsStart)
        }
        return 0
    }

    private func getName(nameGroupsIndex: Int32, nameIndex: Int32): String {
        var tempnameGroupsIndex = nameGroupsIndex
        var tempnameIndex = nameIndex
        let numNames = Int32(UInt32(Char(nameGroups[Int64(match (0) { case _ => tempnameGroupsIndex++; tempnameGroupsIndex - 1 })])))
        if (tempnameIndex < 0 || numNames <= tempnameIndex) {
            throw IllegalIcuArgumentException("Invalid property (value) name choice")
        }
        while (tempnameIndex > 0) {
            while (0 != Int32(UInt32(Char(nameGroups[Int64(match (0) { case _ => tempnameGroupsIndex++; tempnameGroupsIndex - 1 })])))) { }
            tempnameIndex--
        }
        let nameStart = tempnameGroupsIndex
        while (0 != Int32(UInt32(Char(nameGroups[Int64(tempnameGroupsIndex)])))) {
            tempnameGroupsIndex++
        }
        if (nameStart == tempnameGroupsIndex) {
            return None
        }
        return nameGroups[Int64(nameStart)..Int64(tempnameGroupsIndex)]
    }

    private static func asciiToLowercase(c: Int32): Int32 {
        return if (Int32(UInt32('A')) <= c && c <= Int32(UInt32('Z'))) { c + 32 } else { c }
    }

    private func containsName(trie: BytesTrie, name: String): Bool {
        var result: BytesTrie_Result = BytesTrie_Result.NO_VALUE
        var i = 0
        while (i < name.size) {
            var c = Int32(UInt32(name[i]))
            if (c == Int32(UInt32('-')) || c == Int32(UInt32('_')) || c == Int32(UInt32(' ')) || (9 <= c && c <= 13)) {
                continue
            }
            if (!result.hasNext()) {
                return false
            }
            c = asciiToLowercase(c)
            result = trie.next(c)
            i++
        }
        return result.hasValue()
    }

    public static let INSTANCE: UPropertyAliases


    public func getPropertyName(property: Int32, nameChoice: Int32): String {
        let valueMapIndex = findProperty(property)
        if (valueMapIndex == 0) {
            throw IllegalArgumentException("Invalid property enum " + property.toString() + " (0x" + property.format("x") + ")")
        }
        return getName(valueMaps[Int64(valueMapIndex)], nameChoice)
    }

    public func getPropertyValueName(property: Int32, value: Int32, nameChoice: Int32): String {
        let valueMapIndex = findProperty(property)
        if (valueMapIndex == 0) {
            throw IllegalArgumentException("Invalid property enum " + property.toString() + " (0x" + property.format("x") + ")")
        }
        let nameGroupOffset = findPropertyValueNameGroup(valueMaps[Int64(valueMapIndex + 1)], value)
        if (nameGroupOffset == 0) {
            throw IllegalArgumentException("Property " + property.toString() + " (0x" + property.format("x") + ") does not have named values")
        }
        return getName(nameGroupOffset, nameChoice)
    }

    private func getPropertyOrValueEnum(bytesTrieOffset: Int32, alias: String): Int32 {
        let trie = BytesTrie(bytesTries, bytesTrieOffset)
        if (containsName(trie, alias)) {
            return trie.getValue()
        } else {
            return UProperty.UNDEFINED
        }
    }

    public func getPropertyEnum(alias: String): Int32 {
        return getPropertyOrValueEnum(0, alias)
    }

    public func getPropertyValueEnum(property: Int32, alias: String): Int32 {
        var valueMapIndex = findProperty(property)
        if (valueMapIndex == 0) {
            throw IllegalArgumentException("Invalid property enum " + property.toString() + " (0x" + property.format("x") + ")")
        }
        valueMapIndex = valueMaps[Int64(valueMapIndex + 1)]
        if (valueMapIndex == 0) {
            throw IllegalArgumentException("Property " + property.toString() + " (0x" + property.format("x") + ") does not have named values")
        }
        return getPropertyOrValueEnum(valueMaps[Int64(valueMapIndex)], alias)
    }

    public func getPropertyValueEnumNoThrow(property: Int32, alias: String): Int32 {
        var valueMapIndex = findProperty(property)
        if (valueMapIndex == 0) {
            return UProperty.UNDEFINED
        }
        valueMapIndex = valueMaps[Int64(valueMapIndex + 1)]
        if (valueMapIndex == 0) {
            return UProperty.UNDEFINED
        }
        return getPropertyOrValueEnum(valueMaps[Int64(valueMapIndex)], alias)
    }

    public static func compare(stra: String, strb: String): Int32 {
        var istra = 0
        var istrb = 0
        var rc: Int32 = 0
        var cstra = 0
        var cstrb = 0
        while (true) {
            while (istra < Int32(stra.size)) {
                cstra = Int32(UInt32(Char(stra[Int64(istra)])))
                <-- Internal error: switch (cstra) {
                case '-':

                case '_':

                case ' ':

                case '\t':

                case '\n':

                case 11:

                case '\f':

                case '\r':
                    ++istra;
                    continue;

                } -->
                break
            }
            while (istrb < Int32(strb.size)) {
                cstrb = Int32(UInt32(Char(strb[Int64(istrb)])))
                <-- Internal error: switch (cstrb) {
                case '-':

                case '_':

                case ' ':

                case '\t':

                case '\n':

                case 11:

                case '\f':

                case '\r':
                    ++istrb;
                    continue;

                } -->
                break
            }
            let endstra = istra == Int32(stra.size)
            let endstrb = istrb == Int32(strb.size)
            if (endstra) {
                if (endstrb) {
                    return 0
                }
                cstra = 0
            } else if (endstrb) {
                cstrb = 0
            }
            rc = asciiToLowercase(cstra) - asciiToLowercase(cstrb)
            if (rc != 0) {
                return rc
            }
            istra++
            istrb++
        }
    }
}


class UPropertyAliases_IsAcceptable <: ICUBinary_Authenticate {

    public override func isDataVersionAcceptable(version: Array<UInt8>): Bool {
        return Int32(version[0]) == 2
    }
}
