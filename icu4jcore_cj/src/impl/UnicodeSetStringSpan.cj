package icu4cj.impl


public class UnicodeSetStringSpan <: Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    public static let WITH_COUNT = 64

    public static let FWD = 32

    public static let BACK = 16

    public static let CONTAINED = 2

    public static let NOT_CONTAINED = 1

    public static let ALL = 127

    public static let FWD_UTF16_CONTAINED = FWD | CONTAINED

    public static let FWD_UTF16_NOT_CONTAINED = FWD | NOT_CONTAINED

    public static let BACK_UTF16_CONTAINED = BACK | CONTAINED

    public static let BACK_UTF16_NOT_CONTAINED = BACK | NOT_CONTAINED

    static let ALL_CP_CONTAINED = 255i16

    static let LONG_SPAN = Int16(Int32(ALL_CP_CONTAINED) - 1)

    private var spanSet: UnicodeSet

    private var spanNotSet: UnicodeSet

    private var strings: ArrayList<String>

    private var spanLengths: Array<Int16>

    private let maxLength16: Int32

    private var someRelevant: Bool = false

    private var all: Bool = false

    private var offsets: UnicodeSetStringSpan_OffsetList

    public init(set: UnicodeSet, setStrings: ArrayList<String>, which: Int32) {
        spanSet = UnicodeSet(0, 1114111)
        strings = setStrings
        all = (which == ALL)
        spanSet.retainAll(set)
        if (0 != (which & NOT_CONTAINED)) {
            spanNotSet = spanSet
        }
        offsets = UnicodeSetStringSpan_OffsetList()
        var stringsLength = Int32(strings.size)
        var i: Int32 = 0
        var spanLength: Int32 = 0
        var maxLength16 = 0
        someRelevant = false
        i = 0
        while (i < stringsLength) {
            let string = strings[Int64(i)]
            let length16 = Int32(string.size)
            if (length16 == 0) {
                strings.remove(Int64(i))
                stringsLength--
                continue
            }
            spanLength = spanSet.span(string, UnicodeSet_SpanCondition.CONTAINED)
            if (spanLength < length16) {
                someRelevant = true
            }
            if (length16 > maxLength16) {
                maxLength16 = length16
            }
            i++
        }
        this.maxLength16 = maxLength16
        if (!someRelevant && (which & WITH_COUNT) == 0) {
            return
        }
        if (all) {
            spanSet.freeze()
        }
        let spanBackLengthsOffset: Int32
        let allocSize: Int32
        if (all) {
            allocSize = stringsLength * (2)
        } else {
            allocSize = stringsLength
        }
        spanLengths = Array<Int16>(Int64(allocSize)) { _ => 0 }
        if (all) {
            spanBackLengthsOffset = stringsLength
        } else {
            spanBackLengthsOffset = 0
        }
        i = 0
        while (i < stringsLength) {
            let string = strings[Int64(i)]
            let length16 = Int32(string.size)
            spanLength = spanSet.span(string, UnicodeSet_SpanCondition.CONTAINED)
            if (spanLength < length16) {
                if (true) {
                    if (0 != (which & CONTAINED)) {
                        if (0 != (which & FWD)) {
                            spanLengths[Int64(i)] = makeSpanLengthByte(spanLength)
                        }
                        if (0 != (which & BACK)) {
                            spanLength = length16 - spanSet.spanBack(string, length16, UnicodeSet_SpanCondition.CONTAINED)
                            spanLengths[Int64(spanBackLengthsOffset + i)] = makeSpanLengthByte(spanLength)
                        }
                    } else {
                        spanLengths[Int64(i)] = match (0) { case _ => spanLengths[Int64(spanBackLengthsOffset + i)] = 0i16; spanLengths[Int64(spanBackLengthsOffset + i)] }
                    }
                }
                if (0 != (which & NOT_CONTAINED)) {
                    var c: Int32 = 0
                    if (0 != (which & FWD)) {
                        c = string.codePointAt(0)
                        addToSpanNotSet(c)
                    }
                    if (0 != (which & BACK)) {
                        c = string.codePointBefore(length16)
                        addToSpanNotSet(c)
                    }
                }
            } else {
                if (all) {
                    spanLengths[Int64(i)] = match (0) { case _ => spanLengths[Int64(spanBackLengthsOffset + i)] = ALL_CP_CONTAINED; spanLengths[Int64(spanBackLengthsOffset + i)] }
                } else {
                    spanLengths[Int64(i)] = ALL_CP_CONTAINED
                }
            }
            i++
        }
        if (all) {
            spanNotSet.freeze()
        }
    }

    public init(otherStringSpan: UnicodeSetStringSpan, newParentSetStrings: ArrayList<String>) {
        spanSet = otherStringSpan.spanSet
        strings = newParentSetStrings
        maxLength16 = otherStringSpan.maxLength16
        someRelevant = otherStringSpan.someRelevant
        all = true
        if (Utility.sameObjects(otherStringSpan.spanNotSet, otherStringSpan.spanSet)) {
            spanNotSet = spanSet
        } else {
            spanNotSet = otherStringSpan.spanNotSet.clone()
        }
        offsets = UnicodeSetStringSpan_OffsetList()
        spanLengths = otherStringSpan.spanLengths.clone()
    }

    public func needsStringSpanUTF16(): Bool {
        return someRelevant
    }

    public func contains(c: Int32): Bool {
        return spanSet.contains(c)
    }

    private func addToSpanNotSet(c: Int32): Unit {
        if (Utility.sameObjects(spanNotSet, None) || Utility.sameObjects(spanNotSet, spanSet)) {
            if (spanSet.contains(c)) {
                return
            }
            spanNotSet = spanSet.cloneAsThawed()
        }
        spanNotSet.add(c)
    }

    public func span(s: String, start: Int32, spanCondition: UnicodeSet_SpanCondition): Int32 {
        if (refEq(spanCondition, UnicodeSet_SpanCondition.NOT_CONTAINED)) {
            return spanNot(s, start, None)
        }
        let spanLimit = spanSet.span(s, start, UnicodeSet_SpanCondition.CONTAINED)
        if (spanLimit == s.size) {
            return spanLimit
        }
        return spanWithStrings(s, start, spanLimit, spanCondition)
    }

    private func spanWithStrings(s: String, start: Int32, spanLimit: Int32, spanCondition: UnicodeSet_SpanCondition): Int32 {
        synchronized (GeneratedLockObject) {
            var tempspanLimit = spanLimit
            var initSize = 0
            if (refEq(spanCondition, UnicodeSet_SpanCondition.CONTAINED)) {
                initSize = maxLength16
            }
            offsets.setMaxLength(initSize)
            let length = s.size
            var pos = tempspanLimit
            var rest = length - tempspanLimit
            var spanLength = tempspanLimit - start
            var i: Int32 = 0
            let stringsLength = Int32(strings.size)
            while (true) {
                if (refEq(spanCondition, UnicodeSet_SpanCondition.CONTAINED)) {
                    i = 0
                    while (i < stringsLength) {
                        var overlap = Int32(spanLengths[Int64(i)])
                        if (overlap == Int32(ALL_CP_CONTAINED)) {
                            continue
                        }
                        let string = strings[Int64(i)]
                        let length16 = Int32(string.size)
                        if (overlap >= Int32(LONG_SPAN)) {
                            overlap = length16
                            overlap = string.offsetByCodePoints(overlap, -1)
                        }
                        if (overlap > spanLength) {
                            overlap = spanLength
                        }
                        var inc = length16 - overlap
                        while (true) {
                            if (inc > rest) {
                                break
                            }
                            if (!offsets.containsOffset(inc) && matches16CPB(s, pos - overlap, length, string, length16)) {
                                if (inc == rest) {
                                    return length
                                }
                                offsets.addOffset(inc)
                            }
                            if (overlap == 0) {
                                break
                            }
                            overlap--
                            inc++
                        }
                        i++
                    }
                } else {
                    var maxInc = 0
                    var maxOverlap = 0
                    i = 0
                    while (i < stringsLength) {
                        var overlap = Int32(spanLengths[Int64(i)])
                        let string = strings[Int64(i)]
                        let length16 = Int32(string.size)
                        if (overlap >= Int32(LONG_SPAN)) {
                            overlap = length16
                        }
                        if (overlap > spanLength) {
                            overlap = spanLength
                        }
                        var inc = length16 - overlap
                        while (true) {
                            if (inc > rest || overlap < maxOverlap) {
                                break
                            }
                            if ((overlap > maxOverlap || inc > maxInc) && matches16CPB(s, pos - overlap, length, string, length16)) {
                                maxInc = inc
                                maxOverlap = overlap
                                break
                            }
                            overlap--
                            inc++
                        }
                        i++
                    }
                    if (maxInc != 0 || maxOverlap != 0) {
                        pos += maxInc
                        rest -= maxInc
                        if (rest == 0) {
                            return length
                        }
                        spanLength = 0
                        continue
                    }
                }
                if (spanLength != 0 || pos == 0) {
                    if (offsets.isEmpty()) {
                        return pos
                    }
                } else {
                    if (offsets.isEmpty()) {
                        tempspanLimit = spanSet.span(s, pos, UnicodeSet_SpanCondition.CONTAINED)
                        spanLength = tempspanLimit - pos
                        if (spanLength == rest || spanLength == 0) {
                            return tempspanLimit
                        }
                        pos += spanLength
                        rest -= spanLength
                        continue
                    } else {
                        spanLength = spanOne(spanSet, s, pos, rest)
                        if (spanLength > 0) {
                            if (spanLength == rest) {
                                return length
                            }
                            pos += spanLength
                            rest -= spanLength
                            offsets.shift(spanLength)
                            spanLength = 0
                            continue
                        }
                    }
                }
                let minOffset = offsets.popMinimum(None)
                pos += minOffset
                rest -= minOffset
                spanLength = 0
            }
        }
    }

    public func spanAndCount(s: String, start: Int32, spanCondition: UnicodeSet_SpanCondition, outCount: OutputInt): Int32 {
        if (refEq(spanCondition, UnicodeSet_SpanCondition.NOT_CONTAINED)) {
            return spanNot(s, start, outCount)
        }
        if (refEq(spanCondition, UnicodeSet_SpanCondition.CONTAINED)) {
            return spanContainedAndCount(s, start, outCount)
        }
        let stringsLength = Int32(strings.size)
        let length = s.size
        var pos = start
        var rest = length - start
        var count = 0
        while (rest != 0) {
            let cpLength = spanOne(spanSet, s, pos, rest)
            var maxInc = if (cpLength > 0) { cpLength } else { 0 }
            var i = 0
            while (i < stringsLength) {
                let string = strings[Int64(i)]
                let length16 = Int32(string.size)
                if (maxInc < length16 && length16 <= rest && matches16CPB(s, pos, length, string, length16)) {
                    maxInc = length16
                }
                i++
            }
            if (maxInc == 0) {
                outCount.value = count
                return pos
            }
            count++
            pos += maxInc
            rest -= maxInc
        }
        outCount.value = count
        return pos
    }

    private func spanContainedAndCount(s: String, start: Int32, outCount: OutputInt): Int32 {
        synchronized (GeneratedLockObject) {
            offsets.setMaxLength(maxLength16)
            let stringsLength = Int32(strings.size)
            let length = s.size
            var pos = start
            var rest = length - start
            var count = 0
            while (rest != 0) {
                let cpLength = spanOne(spanSet, s, pos, rest)
                if (cpLength > 0) {
                    offsets.addOffsetAndCount(cpLength, count + 1)
                }
                var i = 0
                while (i < stringsLength) {
                    let string = strings[Int64(i)]
                    let length16 = Int32(string.size)
                    if (length16 <= rest && !offsets.hasCountAtOffset(length16, count + 1) && matches16CPB(s, pos, length, string, length16)) {
                        offsets.addOffsetAndCount(length16, count + 1)
                    }
                    i++
                }
                if (offsets.isEmpty()) {
                    outCount.value = count
                    return pos
                }
                let minOffset = offsets.popMinimum(outCount)
                count = outCount.value
                pos += minOffset
                rest -= minOffset
            }
            outCount.value = count
            return pos
        }
    }

    public func spanBack(s: String, length: Int32, spanCondition: UnicodeSet_SpanCondition): Int32 {
        synchronized (GeneratedLockObject) {
            if (refEq(spanCondition, UnicodeSet_SpanCondition.NOT_CONTAINED)) {
                return spanNotBack(s, length)
            }
            var pos = spanSet.spanBack(s, length, UnicodeSet_SpanCondition.CONTAINED)
            if (pos == 0) {
                return 0
            }
            var spanLength = length - pos
            var initSize = 0
            if (refEq(spanCondition, UnicodeSet_SpanCondition.CONTAINED)) {
                initSize = maxLength16
            }
            offsets.setMaxLength(initSize)
            var i: Int32 = 0
            let stringsLength = Int32(strings.size)
            var spanBackLengthsOffset = 0
            if (all) {
                spanBackLengthsOffset = stringsLength
            }
            while (true) {
                if (refEq(spanCondition, UnicodeSet_SpanCondition.CONTAINED)) {
                    i = 0
                    while (i < stringsLength) {
                        var overlap = Int32(spanLengths[Int64(spanBackLengthsOffset + i)])
                        if (overlap == Int32(ALL_CP_CONTAINED)) {
                            continue
                        }
                        let string = strings[Int64(i)]
                        let length16 = Int32(string.size)
                        if (overlap >= Int32(LONG_SPAN)) {
                            overlap = length16
                            var len1 = 0
                            len1 = string.offsetByCodePoints(0, 1)
                            overlap -= len1
                        }
                        if (overlap > spanLength) {
                            overlap = spanLength
                        }
                        var dec = length16 - overlap
                        while (true) {
                            if (dec > pos) {
                                break
                            }
                            if (!offsets.containsOffset(dec) && matches16CPB(s, pos - dec, length, string, length16)) {
                                if (dec == pos) {
                                    return 0
                                }
                                offsets.addOffset(dec)
                            }
                            if (overlap == 0) {
                                break
                            }
                            overlap--
                            dec++
                        }
                        i++
                    }
                } else {
                    var maxDec = 0
                    var maxOverlap = 0
                    i = 0
                    while (i < stringsLength) {
                        var overlap = Int32(spanLengths[Int64(spanBackLengthsOffset + i)])
                        let string = strings[Int64(i)]
                        let length16 = Int32(string.size)
                        if (overlap >= Int32(LONG_SPAN)) {
                            overlap = length16
                        }
                        if (overlap > spanLength) {
                            overlap = spanLength
                        }
                        var dec = length16 - overlap
                        while (true) {
                            if (dec > pos || overlap < maxOverlap) {
                                break
                            }
                            if ((overlap > maxOverlap || dec > maxDec) && matches16CPB(s, pos - dec, length, string, length16)) {
                                maxDec = dec
                                maxOverlap = overlap
                                break
                            }
                            overlap--
                            dec++
                        }
                        i++
                    }
                    if (maxDec != 0 || maxOverlap != 0) {
                        pos -= maxDec
                        if (pos == 0) {
                            return 0
                        }
                        spanLength = 0
                        continue
                    }
                }
                if (spanLength != 0 || pos == length) {
                    if (offsets.isEmpty()) {
                        return pos
                    }
                } else {
                    if (offsets.isEmpty()) {
                        let oldPos = pos
                        pos = spanSet.spanBack(s, oldPos, UnicodeSet_SpanCondition.CONTAINED)
                        spanLength = oldPos - pos
                        if (pos == 0 || spanLength == 0) {
                            return pos
                        }
                        continue
                    } else {
                        spanLength = spanOneBack(spanSet, s, pos)
                        if (spanLength > 0) {
                            if (spanLength == pos) {
                                return 0
                            }
                            pos -= spanLength
                            offsets.shift(spanLength)
                            spanLength = 0
                            continue
                        }
                    }
                }
                pos -= offsets.popMinimum(None)
                spanLength = 0
            }
        }
    }

    private func spanNot(s: String, start: Int32, outCount: OutputInt): Int32 {
        let length = s.size
        var pos = start
        var rest = length - start
        let stringsLength = Int32(strings.size)
        var count = 0
                spanLimit = spanNotSet.spanAndCount(s, pos, UnicodeSet_SpanCondition.NOT_CONTAINED, outCount)
                outCount.value = match (0) { case _ => count = count + outCount.value; count }
            }
            if (spanLimit == length) {
                return length
            }
            pos = spanLimit
            rest = length - spanLimit
            let cpLength = spanOne(spanSet, s, pos, rest)
            if (cpLength > 0) {
                return pos
            }
            var i = 0
            while (i < stringsLength) {
                if (spanLengths[Int64(i)] == ALL_CP_CONTAINED) {
                    continue
                }
                let string = strings[Int64(i)]
                let length16 = Int32(string.size)
                if (length16 <= rest && matches16CPB(s, pos, length, string, length16)) {
                    return pos
                }
                i++
            }
            pos -= cpLength
            rest += cpLength
            count++
        } while (rest != 0)
        if (outCount.isSome()) {
            outCount.value = count
        }
        return length
    }

    private func spanNotBack(s: String, length: Int32): Int32 {
        var pos = length
        var i: Int32 = 0
        let stringsLength = Int32(strings.size)
            let cpLength = spanOneBack(spanSet, s, pos)
            if (cpLength > 0) {
                return pos
            }
            i = 0
            while (i < stringsLength) {
                if (spanLengths[Int64(i)] == ALL_CP_CONTAINED) {
                    continue
                }
                let string = strings[Int64(i)]
                let length16 = Int32(string.size)
                if (length16 <= pos && matches16CPB(s, pos - length16, length, string, length16)) {
                    return pos
                }
                i++
            }
            pos += cpLength
        } while (pos != 0)
        return 0
    }

    static func makeSpanLengthByte(spanLength: Int32): Int16 {
        return if (spanLength < Int32(LONG_SPAN)) { Int16(spanLength) } else { LONG_SPAN }
    }

    private static func matches16(s: String, start: Int32, t: String, length: Int32): Bool {
        var templength = length
        var end = start + templength
        while (match (0) { case _ => templength--; templength + 1 } > 0) {
            if (s[match (0] { case _ => end--; end }) != Char(t[Int64(templength)])) {
                return false
            }
        }
        return true
    }

    static func matches16CPB(s: String, start: Int32, limit: Int32, t: String, tlength: Int32): Bool {
        return matches16(s, start, t, tlength) && !(0 < start && Character.isHighSurrogate(s[start - 1]) && Character.isLowSurrogate(s[start])) && !((start + tlength) < limit && Character.isHighSurrogate(s[start + tlength - 1]) && Character.isLowSurrogate(s[start + tlength]))
    }

    static func spanOne(set: UnicodeSet, s: String, start: Int32, length: Int32): Int32 {
        let c = s[start]
        if (Int32(UInt32(c)) >= 55296 && Int32(UInt32(c)) <= 56319 && length >= 2) {
            let c2 = s[start + 1]
            if (UTF16.isTrailSurrogate(Int32(UInt32(c2)))) {
                let supplementary = Character.toCodePoint(c, c2)
                return if (set.contains(supplementary)) { 2 } else { -2 }
            }
        }
        return if (set.contains(Int32(UInt32(c)))) { 1 } else { -1 }
    }

    static func spanOneBack(set: UnicodeSet, s: String, length: Int32): Int32 {
        let c = s[length - 1]
        if (Int32(UInt32(c)) >= 56320 && Int32(UInt32(c)) <= 57343 && length >= 2) {
            let c2 = s[length - 2]
            if (UTF16.isLeadSurrogate(Int32(UInt32(c2)))) {
                let supplementary = Character.toCodePoint(c2, c)
                return if (set.contains(supplementary)) { 2 } else { -2 }
            }
        }
        return if (set.contains(Int32(UInt32(c)))) { 1 } else { -1 }
    }
}


class UnicodeSetStringSpan_OffsetList {
    private var list: Array<Int32>

    private var length: Int32 = 0

    private var start: Int32 = 0

    public init() {
        list = Array<Int32>(16) { _ => 0 }
    }

    public func setMaxLength(maxLength: Int32): Unit {
        if (maxLength > Int32(list.size)) {
            list = Array<Int32>(Int64(maxLength)) { _ => 0 }
        }
        clear()
    }

    public func clear(): Unit {
        var i = Int32(list.size)
        while (match (0) { case _ => i--; i + 1 } > 0) {
            list[Int64(i)] = 0
        }
        start = match (0) { case _ => length = 0; length }
    }

    public func isEmpty(): Bool {
        return (length == 0)
    }

    public func shift(delta: Int32): Unit {
        var i = start + delta
        if (i >= Int32(list.size)) {
            i -= Int32(list.size)
        }
        if (list[Int64(i)] != 0) {
            list[Int64(i)] = 0
            length--
        }
        start = i
    }

    public func addOffset(offset: Int32): Unit {
        var i = start + offset
        if (i >= Int32(list.size)) {
            i -= Int32(list.size)
        }
        if (!(list[Int64(i)] == 0)) {
            throw AssertionError()
        }
        list[Int64(i)] = 1
        length++
    }

    public func addOffsetAndCount(offset: Int32, count: Int32): Unit {
        if (!(count > 0)) {
            throw AssertionError()
        }
        var i = start + offset
        if (i >= Int32(list.size)) {
            i -= Int32(list.size)
        }
        if (list[Int64(i)] == 0) {
            list[Int64(i)] = count
            length++
        } else if (count < list[Int64(i)]) {
            list[Int64(i)] = count
        }
    }

    public func containsOffset(offset: Int32): Bool {
        var i = start + offset
        if (i >= Int32(list.size)) {
            i -= Int32(list.size)
        }
        return list[Int64(i)] != 0
    }

    public func hasCountAtOffset(offset: Int32, count: Int32): Bool {
        var i = start + offset
        if (i >= Int32(list.size)) {
            i -= Int32(list.size)
        }
        let oldCount = list[Int64(i)]
        return oldCount != 0 && oldCount <= count
    }

    public func popMinimum(outCount: OutputInt): Int32 {
        var i = start
        let result: Int32
        while (match (0) { case _ => i++; i } < Int32(list.size)) {
            let count = list[Int64(i)]
            if (count != 0) {
                list[Int64(i)] = 0
                length--
                result = i - start
                start = i
                if (outCount.isSome()) {
                    outCount.value = count
                }
                return result
            }
        }
        result = Int32(list.size) - start
        i = 0
        var count: Int32 = 0
        while ((match (0) { case _ => count = list[Int64(i)]; count }) == 0) {
            i++
        }
        list[Int64(i)] = 0
        length--
        start = i
        if (outCount.isSome()) {
            outCount.value = count
        }
        return result + i
    }
}
