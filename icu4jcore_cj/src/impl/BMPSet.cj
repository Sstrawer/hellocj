package icu4cj.impl


public class BMPSet {
    public static var U16_SURROGATE_OFFSET = ((shl(55296, 10)) + 56320 - 65536)

    private var latin1Contains: Array<Bool>

    private var table7FF: Array<Int32>

    private var bmpBlockBits: Array<Int32>

    private var list4kStarts: Array<Int32>

    private let list: Array<Int32>

    private let listLength: Int32

    public init(parentList: Array<Int32>, parentListLength: Int32) {
        list = parentList
        listLength = parentListLength
        latin1Contains = Array<Bool>(256) { _ => false }
        table7FF = Array<Int32>(64) { _ => 0 }
        bmpBlockBits = Array<Int32>(64) { _ => 0 }
        list4kStarts = Array<Int32>(18) { _ => 0 }
        list4kStarts[0] = findCodePoint(2048, 0, listLength - 1)
        var i: Int32 = 0
        i = 1
        while (i <= 16) {
            list4kStarts[Int64(i)] = findCodePoint(shl(i, 12), list4kStarts[Int64(i - 1)], listLength - 1)
            i++
        }
        list4kStarts[17] = listLength - 1
        initBits()
    }

    public init(otherBMPSet: BMPSet, newParentList: Array<Int32>, newParentListLength: Int32) {
        list = newParentList
        listLength = newParentListLength
        latin1Contains = otherBMPSet.latin1Contains.clone()
        table7FF = otherBMPSet.table7FF.clone()
        bmpBlockBits = otherBMPSet.bmpBlockBits.clone()
        list4kStarts = otherBMPSet.list4kStarts.clone()
    }

    public func contains(c: Int32): Bool {
        if (c <= 255) {
            return (latin1Contains[Int64(c)])
        } else if (c <= 2047) {
            return ((table7FF[Int64(c & 63)] & (shl(1, (shr(c, 6))))) != 0)
        } else if (c < 55296 || (c >= 57344 && c <= 65535)) {
            let lead = shr(c, 12)
            let twoBits = (shr(bmpBlockBits[Int64((shr(c, 6)) & 63)], lead)) & 65537
            if (twoBits <= 1) {
                return (0 != twoBits)
            } else {
                return containsSlow(c, list4kStarts[Int64(lead)], list4kStarts[Int64(lead + 1)])
            }
        } else if (c <= 1114111) {
            return containsSlow(c, list4kStarts[13], list4kStarts[17])
        } else {
            return false
        }
    }

    public func span(s: String, start: Int32, spanCondition: UnicodeSet_SpanCondition, outCount: OutputInt): Int32 {
        var c: Char = '\u{0000}'
        var c2: Char = '\u{0000}'
        var i = start
        let limit = s.size
        var numSupplementary = 0
        if (!refEq(UnicodeSet_SpanCondition.NOT_CONTAINED, spanCondition)) {
            while (i < limit) {
                c = s[i]
                if (Int32(UInt32(c)) <= 255) {
                    if (!latin1Contains[Int64(UInt32(c))]) {
                        break
                    }
                } else if (Int32(UInt32(c)) <= 2047) {
                    if ((table7FF[Int64(Int32(UInt32(c)) & 63)] & (shl(1, (shr(Int32(UInt32(c)), 6))))) == 0) {
                        break
                    }
                } else if (Int32(UInt32(c)) < 55296 || Int32(UInt32(c)) >= 56320 || (i + 1) == limit || (Int32(UInt32(match (0) { case _ => c2 = s[i + 1]; c2 }))) < 56320 || Int32(UInt32(c2)) >= 57344) {
                    let lead = shr(Int32(UInt32(c)), 12)
                    let twoBits = (shr(bmpBlockBits[Int64((shr(Int32(UInt32(c)), 6)) & 63)], lead)) & 65537
                    if (twoBits <= 1) {
                        if (twoBits == 0) {
                            break
                        }
                    } else {
                        if (!containsSlow(Int32(UInt32(c)), list4kStarts[Int64(lead)], list4kStarts[Int64(lead + 1)])) {
                            break
                        }
                    }
                } else {
                    let supplementary = Character.toCodePoint(c, c2)
                    if (!containsSlow(supplementary, list4kStarts[16], list4kStarts[17])) {
                        break
                    }
                    numSupplementary++
                    i++
                }
                i++
            }
        } else {
            while (i < limit) {
                c = s[i]
                if (Int32(UInt32(c)) <= 255) {
                    if (latin1Contains[Int64(UInt32(c))]) {
                        break
                    }
                } else if (Int32(UInt32(c)) <= 2047) {
                    if ((table7FF[Int64(Int32(UInt32(c)) & 63)] & (shl(1, (shr(Int32(UInt32(c)), 6))))) != 0) {
                        break
                    }
                } else if (Int32(UInt32(c)) < 55296 || Int32(UInt32(c)) >= 56320 || (i + 1) == limit || (Int32(UInt32(match (0) { case _ => c2 = s[i + 1]; c2 }))) < 56320 || Int32(UInt32(c2)) >= 57344) {
                    let lead = shr(Int32(UInt32(c)), 12)
                    let twoBits = (shr(bmpBlockBits[Int64((shr(Int32(UInt32(c)), 6)) & 63)], lead)) & 65537
                    if (twoBits <= 1) {
                        if (twoBits != 0) {
                            break
                        }
                    } else {
                        if (containsSlow(Int32(UInt32(c)), list4kStarts[Int64(lead)], list4kStarts[Int64(lead + 1)])) {
                            break
                        }
                    }
                } else {
                    let supplementary = Character.toCodePoint(c, c2)
                    if (containsSlow(supplementary, list4kStarts[16], list4kStarts[17])) {
                        break
                    }
                    numSupplementary++
                    i++
                }
                i++
            }
        }
        if (outCount.isSome()) {
            let spanLength = i - start
            outCount.value = spanLength - numSupplementary
        }
        return i
    }

    public func spanBack(s: String, limit: Int32, spanCondition: UnicodeSet_SpanCondition): Int32 {
        var templimit = limit
        var c: Char = '\u{0000}'
        var c2: Char = '\u{0000}'
        if (!refEq(UnicodeSet_SpanCondition.NOT_CONTAINED, spanCondition)) {
            while (true) {
                c = s[match (0] { case _ => templimit--; templimit })
                if (Int32(UInt32(c)) <= 255) {
                    if (!latin1Contains[Int64(UInt32(c))]) {
                        break
                    }
                } else if (Int32(UInt32(c)) <= 2047) {
                    if ((table7FF[Int64(Int32(UInt32(c)) & 63)] & (shl(1, (shr(Int32(UInt32(c)), 6))))) == 0) {
                        break
                    }
                } else if (Int32(UInt32(c)) < 55296 || Int32(UInt32(c)) < 56320 || 0 == templimit || (Int32(UInt32(match (0) { case _ => c2 = s[templimit - 1]; c2 }))) < 55296 || Int32(UInt32(c2)) >= 56320) {
                    let lead = shr(Int32(UInt32(c)), 12)
                    let twoBits = (shr(bmpBlockBits[Int64((shr(Int32(UInt32(c)), 6)) & 63)], lead)) & 65537
                    if (twoBits <= 1) {
                        if (twoBits == 0) {
                            break
                        }
                    } else {
                        if (!containsSlow(Int32(UInt32(c)), list4kStarts[Int64(lead)], list4kStarts[Int64(lead + 1)])) {
                            break
                        }
                    }
                } else {
                    let supplementary = Character.toCodePoint(c2, c)
                    if (!containsSlow(supplementary, list4kStarts[16], list4kStarts[17])) {
                        break
                    }
                    templimit--
                }
                if (0 == templimit) {
                    return 0
                }
            }
        } else {
            while (true) {
                c = s[match (0] { case _ => templimit--; templimit })
                if (Int32(UInt32(c)) <= 255) {
                    if (latin1Contains[Int64(UInt32(c))]) {
                        break
                    }
                } else if (Int32(UInt32(c)) <= 2047) {
                    if ((table7FF[Int64(Int32(UInt32(c)) & 63)] & (shl(1, (shr(Int32(UInt32(c)), 6))))) != 0) {
                        break
                    }
                } else if (Int32(UInt32(c)) < 55296 || Int32(UInt32(c)) < 56320 || 0 == templimit || (Int32(UInt32(match (0) { case _ => c2 = s[templimit - 1]; c2 }))) < 55296 || Int32(UInt32(c2)) >= 56320) {
                    let lead = shr(Int32(UInt32(c)), 12)
                    let twoBits = (shr(bmpBlockBits[Int64((shr(Int32(UInt32(c)), 6)) & 63)], lead)) & 65537
                    if (twoBits <= 1) {
                        if (twoBits != 0) {
                            break
                        }
                    } else {
                        if (containsSlow(Int32(UInt32(c)), list4kStarts[Int64(lead)], list4kStarts[Int64(lead + 1)])) {
                            break
                        }
                    }
                } else {
                    let supplementary = Character.toCodePoint(c2, c)
                    if (containsSlow(supplementary, list4kStarts[16], list4kStarts[17])) {
                        break
                    }
                    templimit--
                }
                if (0 == templimit) {
                    return 0
                }
            }
        }
        return templimit + 1
    }

    private static func set32x64Bits(table: Array<Int32>, start: Int32, limit: Int32): Unit {
        if (!(64 == Int32(table.size))) {
            throw AssertionError()
        }
        var lead = shr(start, 6)
        var trail = start & 63
        var bits = shl(1, lead)
        if ((start + 1) == limit) {
            table[Int64(trail)] |= bits
            return
        }
        let limitLead = shr(limit, 6)
        let limitTrail = limit & 63
        if (lead == limitLead) {
            while (trail < limitTrail) {
                table[Int64(match (0) { case _ => trail++; trail - 1 })] |= bits
            }
        } else {
            if (trail > 0) {
                lead++
            }
            if (lead < limitLead) {
                bits = 
                if (limitLead < 32) {
                    bits &= (shl(1, limitLead)) - 1
                }
                trail = 0
                while (trail < 64) {
                    table[Int64(trail)] |= bits
                    trail++
                }
            }
            bits = shl(1, limitLead)
            trail = 0
            while (trail < limitTrail) {
                table[Int64(trail)] |= bits
                trail++
            }
        }
    }

    private func initBits(): Unit {
        var start: Int32 = 0
        var limit: Int32 = 0
        var listIndex = 0
                limit = 1114112
            }
            if (start >= 256) {
                break
            }
        } while (limit <= 256)
        while (start < 2048) {
            set32x64Bits(table7FF, start, if (limit <= 2048) { limit } else { 2048 })
            if (limit > 2048) {
                start = 2048
                break
            }
            start = list[Int64(match (0) { case _ => listIndex++; listIndex - 1 })]
            if (listIndex < listLength) {
                limit = list[Int64(match (0) { case _ => listIndex++; listIndex - 1 })]
            } else {
                limit = 1114112
            }
        }
        var minStart = 2048
        while (start < 65536) {
            if (limit > 65536) {
                limit = 65536
            }
            if (start < minStart) {
                start = minStart
            }
            if (start < limit) {
                if (0 != (start & 63)) {
                    start >>= 6
                    bmpBlockBits[Int64(start & 63)] |= shl(65537, (shr(start, 6)))
                    start = shl((start + 1), 6)
                    minStart = start
                }
                if (start < limit) {
                    if (start < (limit & )) {
                        set32x64Bits(bmpBlockBits, shr(start, 6), shr(limit, 6))
                    }
                    if (0 != (limit & 63)) {
                        limit >>= 6
                        bmpBlockBits[Int64(limit & 63)] |= shl(65537, (shr(limit, 6)))
                        limit = shl((limit + 1), 6)
                        minStart = limit
                    }
                }
            }
            if (limit == 65536) {
                break
            }
            start = list[Int64(match (0) { case _ => listIndex++; listIndex - 1 })]
            if (listIndex < listLength) {
                limit = list[Int64(match (0) { case _ => listIndex++; listIndex - 1 })]
            } else {
                limit = 1114112
            }
        }
    }

    private func findCodePoint(c: Int32, lo: Int32, hi: Int32): Int32 {
        var temphi = hi
        var templo = lo
        if (c < list[Int64(templo)]) {
            return templo
        }
        if (templo >= temphi || c >= list[Int64(temphi - 1)]) {
            return temphi
        }
        while (true) {
            let i = ushr((templo + temphi), 1)
            if (i == templo) {
                break
            } else if (c < list[Int64(i)]) {
                temphi = i
            } else {
                templo = i
            }
        }
        return temphi
    }

    private func containsSlow(c: Int32, lo: Int32, hi: Int32): Bool {
        return (0 != (findCodePoint(c, lo, hi) & 1))
    }
}
