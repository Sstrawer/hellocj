package icu4cj.impl


public class UCharacterName <: Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    public static let INSTANCE: UCharacterName


    public static let LINES_PER_GROUP_ = shl(1, 5)

    public var m_groupcount_ = 0

    public func getName(ch: Int32, choice: Int32): String {
        if (ch < UCharacter.MIN_VALUE || ch > UCharacter.MAX_VALUE || choice > UCharacterNameChoice.CHAR_NAME_CHOICE_COUNT) {
            return None
        }
        var result: String
        result = getAlgName(ch, choice)
        if (result.isNone() || Int32(result.size) == 0) {
            if (choice == UCharacterNameChoice.EXTENDED_CHAR_NAME) {
                result = getExtendedName(ch)
            } else {
                result = getGroupName(ch, choice)
            }
        }
        return result
    }

    public func getCharFromName(choice: Int32, name: String): Int32 {
        if (choice >= UCharacterNameChoice.CHAR_NAME_CHOICE_COUNT || name.isNone() || Int32(name.size) == 0) {
            return -1
        }
        var result = getExtendedChar(name.toLowerCase(Locale.ENGLISH), choice)
        if (result >= -1) {
            return result
        }
        let upperCaseName = name.toUpperCase(Locale.ENGLISH)
        if (choice == UCharacterNameChoice.UNICODE_CHAR_NAME || choice == UCharacterNameChoice.EXTENDED_CHAR_NAME) {
            var count = 0
            if (m_algorithm_.isSome()) {
                count = Int32(m_algorithm_.size)
            }
            count--
            while (count >= 0) {
                result = m_algorithm_[Int64(count)].getChar(upperCaseName)
                if (result >= 0) {
                    return result
                }
                count--
            }
        }
        if (choice == UCharacterNameChoice.EXTENDED_CHAR_NAME) {
            result = getGroupChar(upperCaseName, UCharacterNameChoice.UNICODE_CHAR_NAME)
            if (result == -1) {
                result = getGroupChar(upperCaseName, UCharacterNameChoice.CHAR_NAME_ALIAS)
            }
        } else {
            result = getGroupChar(upperCaseName, choice)
        }
        return result
    }

    public func getGroupLengths(index: Int32, offsets: Array<Char>, lengths: Array<Char>): Int32 {
        var tempindex = index
        var length = Char(65535)
        var b = 0u8
        var n = 0u8
        var shift: Int32 = 0
        tempindex = tempindex * m_groupsize_
        var stringoffset = UCharacterUtility.toInt(m_groupinfo_[Int64(tempindex + OFFSET_HIGH_OFFSET_)], m_groupinfo_[Int64(tempindex + OFFSET_LOW_OFFSET_)])
        offsets[0] = Char(0)
        var i = 0
        while (i < LINES_PER_GROUP_) {
            b = m_groupstring_[Int64(stringoffset)]
            shift = 4
            while (shift >= 0) {
                n = UInt8((shr(Int32(b), shift)) & 15)
                if (Int32(UInt32(length)) == 65535 && Int32(n) > SINGLE_NIBBLE_MAX_) {
                    length = Char(shl((Int32(n) - 12), 4))
                } else {
                    if (Int32(UInt32(length)) != 65535) {
                        lengths[Int64(i)] = Char((Int32(UInt32(length)) | Int32(n)) + 12)
                    } else {
                        lengths[Int64(i)] = Char(n)
                    }
                    if (i < LINES_PER_GROUP_) {
                        offsets[Int64(i + 1)] = 
                    }
                    length = Char(65535)
                    i++
                }
                shift -= 4
            }
            stringoffset++
        }
        return stringoffset
    }

    public func getGroupName(index: Int32, length: Int32, choice: Int32): String {
        var tempindex = index
        var templength = length
        if (choice != UCharacterNameChoice.UNICODE_CHAR_NAME && choice != UCharacterNameChoice.EXTENDED_CHAR_NAME) {
            if (Int32(UInt32(';')) >= Int32(m_tokentable_.size) || Int32(UInt32(m_tokentable_[Int64(UInt32(';'))])) == 65535) {
                var fieldIndex = if (choice == UCharacterNameChoice.ISO_COMMENT_) { 2 } else { choice }
            } else {
                templength = 0
            }
        }
        synchronized (getMonitorByObject(m_utilStringBuffer_)) {
            m_utilStringBuffer_.setLength(0)
            var b: UInt8 = 0
            var token: Char = '\u{0000}'
            var i = 0
            while (i < templength) {
                b = m_groupstring_[Int64(tempindex + i)]
                i++
                if (Int32(b) >= Int32(m_tokentable_.size)) {
                    if (Int32(b) == Int32(UInt32(';'))) {
                        break
                    }
                    m_utilStringBuffer_.append(Int32(b))
                } else {
                    token = m_tokentable_[Int64(Int32(b) & 255)]
                    if (Int32(UInt32(token)) == 65534) {
                        token = m_tokentable_[Int64(shl(Int32(b), 8) | (Int32(m_groupstring_[Int64(tempindex + i)]) & 255))]
                        i++
                    }
                    if (Int32(UInt32(token)) == 65535) {
                        if (Int32(b) == Int32(UInt32(';'))) {
                            if (Int32(m_utilStringBuffer_.size) == 0 && choice == UCharacterNameChoice.EXTENDED_CHAR_NAME) {
                                continue
                            }
                            break
                        }
                        m_utilStringBuffer_.append(Char(Int32(b) & 255))
                    } else {
                        UCharacterUtility.getNullTermByteSubString(m_utilStringBuffer_, m_tokenstring_, Int32(UInt32(token)))
                    }
                }
            }
            if (Int32(m_utilStringBuffer_.size) > 0) {
                return toString(m_utilStringBuffer_)
            }
        }
        return None
    }

    public func getExtendedName(ch: Int32): String {
        var result = getName(ch, UCharacterNameChoice.UNICODE_CHAR_NAME)
        if (result.isNone()) {
            result = getExtendedOr10Name(ch)
        }
        return result
    }

    public func getGroup(codepoint: Int32): Int32 {
        var endGroup = m_groupcount_
        let msb = getCodepointMSB(codepoint)
        var result = 0
        while (result < endGroup - 1) {
            let gindex = shr((result + endGroup), 1)
            if (msb < getGroupMSB(gindex)) {
                endGroup = gindex
            } else {
                result = gindex
            }
        }
        return result
    }

    public func getExtendedOr10Name(ch: Int32): String {
        var result: String
        if (result.isNone()) {
            let Type = getType(ch)
            if (Type >= Int32(TYPE_NAMES_.size)) {
                result = UNKNOWN_TYPE_NAME_
            } else {
                result = TYPE_NAMES_[Int64(Type)]
            }
            synchronized (getMonitorByObject(m_utilStringBuffer_)) {
                m_utilStringBuffer_.setLength(0)
                m_utilStringBuffer_.append('<')
                m_utilStringBuffer_.append(result)
                m_utilStringBuffer_.append('-')
                let chStr = ch.format("x").toUpperCase(Locale.ENGLISH)
                var zeros = 4 - Int32(chStr.size)
                while (zeros > 0) {
                    m_utilStringBuffer_.append('0')
                    zeros--
                }
                m_utilStringBuffer_.append(chStr)
                m_utilStringBuffer_.append('>')
                result = toString(m_utilStringBuffer_)
            }
        }
        return result
    }

    public func getGroupMSB(gindex: Int32): Int32 {
        if (gindex >= m_groupcount_) {
            return -1
        }
        return Int32(UInt32(m_groupinfo_[Int64(gindex * m_groupsize_)]))
    }

    public static func getCodepointMSB(codepoint: Int32): Int32 {
        return shr(codepoint, GROUP_SHIFT_)
    }

    public static func getGroupLimit(msb: Int32): Int32 {
        return (shl(msb, GROUP_SHIFT_)) + LINES_PER_GROUP_
    }

    public static func getGroupMin(msb: Int32): Int32 {
        return shl(msb, GROUP_SHIFT_)
    }

    public static func getGroupOffset(codepoint: Int32): Int32 {
        return codepoint & GROUP_MASK_
    }

    public static func getGroupMinFromCodepoint(codepoint: Int32): Int32 {
        return codepoint & 
    }

    public func getAlgorithmLength(): Int32 {
        return Int32(m_algorithm_.size)
    }

    public func getAlgorithmStart(index: Int32): Int32 {
        return m_algorithm_[Int64(index)].m_rangestart_
    }

    public func getAlgorithmEnd(index: Int32): Int32 {
        return m_algorithm_[Int64(index)].m_rangeend_
    }

    public func getAlgorithmName(index: Int32, codepoint: Int32): String {
        var result: String
        synchronized (getMonitorByObject(m_utilStringBuffer_)) {
            m_utilStringBuffer_.setLength(0)
            m_algorithm_[Int64(index)].appendName(codepoint, m_utilStringBuffer_)
            result = toString(m_utilStringBuffer_)
        }
        return result
    }

    public func getGroupName(ch: Int32, choice: Int32): String {
        synchronized (GeneratedLockObject) {
            let msb = getCodepointMSB(ch)
            let group = getGroup(ch)
            if (msb == Int32(UInt32(m_groupinfo_[Int64(group * m_groupsize_)]))) {
                let index = getGroupLengths(group, m_groupoffsets_, m_grouplengths_)
                let offset = ch & GROUP_MASK_
                return getGroupName(index + Int32(UInt32(m_groupoffsets_[Int64(offset)])), Int32(UInt32(m_grouplengths_[Int64(offset)])), choice)
            }
            return None
        }
    }

    public func getMaxCharNameLength(): Int32 {
        if (initNameSetsLengths()) {
            return m_maxNameLength_
        } else {
            return 0
        }
    }

    public func getMaxISOCommentLength(): Int32 {
        if (initNameSetsLengths()) {
            return m_maxISOCommentLength_
        } else {
            return 0
        }
    }

    public func getCharNameCharacters(set: UnicodeSet): Unit {
        convert(m_nameSet_, set)
    }

    public func getISOCommentCharacters(set: UnicodeSet): Unit {
        convert(m_ISOCommentSet_, set)
    }

    var m_groupsize_ = 0

    public func setToken(token: Array<Char>, tokenstring: Array<UInt8>): Bool {
        if (token.isSome() && tokenstring.isSome() && Int32(token.size) > 0 && Int32(tokenstring.size) > 0) {
            m_tokentable_ = token
            m_tokenstring_ = tokenstring
            return true
        }
        return false
    }

    public func setAlgorithm(alg: Array<UCharacterName_AlgorithmName>): Bool {
        if (alg.isSome() && Int32(alg.size) != 0) {
            m_algorithm_ = alg
            return true
        }
        return false
    }

    public func setGroupCountSize(count: Int32, size: Int32): Bool {
        if (count <= 0 || size <= 0) {
            return false
        }
        m_groupcount_ = count
        m_groupsize_ = size
        return true
    }

    public func setGroup(group: Array<Char>, groupstring: Array<UInt8>): Bool {
        if (group.isSome() && groupstring.isSome() && Int32(group.size) > 0 && Int32(groupstring.size) > 0) {
            m_groupinfo_ = group
            m_groupstring_ = groupstring
            return true
        }
        return false
    }

    private var m_tokentable_: Array<Char>

    private var m_tokenstring_: Array<UInt8>

    private var m_groupinfo_: Array<Char>

    private var m_groupstring_: Array<UInt8>

    private var m_algorithm_: Array<UCharacterName_AlgorithmName>

    private var m_groupoffsets_: Array<Char> = Array<Char>(Int64(LINES_PER_GROUP_ + 1)) { _ => '\u{0000}' }

    private var m_grouplengths_: Array<Char> = Array<Char>(Int64(LINES_PER_GROUP_ + 1)) { _ => '\u{0000}' }

    private static let FILE_NAME_ = "unames.icu"

    private static let GROUP_SHIFT_ = 5

    private static let GROUP_MASK_ = LINES_PER_GROUP_ - 1

    private static let OFFSET_HIGH_OFFSET_ = 1

    private static let OFFSET_LOW_OFFSET_ = 2

    private static let SINGLE_NIBBLE_MAX_ = 11

    private var m_nameSet_: Array<Int32> = Array<Int32>(8) { _ => 0 }

    private var m_ISOCommentSet_: Array<Int32> = Array<Int32>(8) { _ => 0 }

    private var m_utilStringBuffer_: StringBuffer = StringBuffer()

    private var m_utilIntBuffer_: Array<Int32> = Array<Int32>(2) { _ => 0 }

    private var m_maxISOCommentLength_: Int32 = 0

    private var m_maxNameLength_: Int32 = 0

    private static let TYPE_NAMES_: Array<String> = ["unassigned", "uppercase letter", "lowercase letter", "titlecase letter", "modifier letter", "other letter", "non spacing mark", "enclosing mark", "combining spacing mark", "decimal digit number", "letter number", "other number", "space separator", "line separator", "paragraph separator", "control", "format", "private use area", "surrogate", "dash punctuation", "start punctuation", "end punctuation", "connector punctuation", "other punctuation", "math symbol", "currency symbol", "modifier symbol", "other symbol", "initial punctuation", "final punctuation", "noncharacter", "lead surrogate", "trail surrogate"]

    private static let UNKNOWN_TYPE_NAME_ = "unknown"

    private static let NON_CHARACTER_ = Int32(UCharacterCategory.CHAR_CATEGORY_COUNT)

    private static let LEAD_SURROGATE_ = Int32(UCharacterCategory.CHAR_CATEGORY_COUNT) + 1

    private static let TRAIL_SURROGATE_ = Int32(UCharacterCategory.CHAR_CATEGORY_COUNT) + 2

    static let EXTENDED_CATEGORY_ = Int32(UCharacterCategory.CHAR_CATEGORY_COUNT) + 3

    private init() {
        let b = ICUBinary.getRequiredData(FILE_NAME_)
        let reader = UCharacterNameReader(b)
        reader.read(this)
    }

    private func getAlgName(ch: Int32, choice: Int32): String {
        if (choice == UCharacterNameChoice.UNICODE_CHAR_NAME || choice == UCharacterNameChoice.EXTENDED_CHAR_NAME) {
            synchronized (getMonitorByObject(m_utilStringBuffer_)) {
                m_utilStringBuffer_.setLength(0)
                var index = Int32(m_algorithm_.size) - 1
                while (index >= 0) {
                    if (m_algorithm_[Int64(index)].contains(ch)) {
                        m_algorithm_[Int64(index)].appendName(ch, m_utilStringBuffer_)
                        return toString(m_utilStringBuffer_)
                    }
                    index--
                }
            }
        }
        return None
    }

    private func getGroupChar(name: String, choice: Int32): Int32 {
        synchronized (GeneratedLockObject) {
            var i = 0
            while (i < m_groupcount_) {
                let startgpstrindex = getGroupLengths(i, m_groupoffsets_, m_grouplengths_)
                let result = getGroupChar(startgpstrindex, m_grouplengths_, name, choice)
                if (result != -1) {
                    return (shl(Int32(UInt32(m_groupinfo_[Int64(i * m_groupsize_)])), GROUP_SHIFT_)) | result
                }
                i++
            }
            return -1
        }
    }

    private func getGroupChar(index: Int32, length: Array<Char>, name: String, choice: Int32): Int32 {
        var tempindex = index
        var b = 0u8
        var token: Char = '\u{0000}'
        var len: Int32 = 0
        let namelen = Int32(name.size)
        var nindex: Int32 = 0
        var count: Int32 = 0
        var result = 0
        while (result <= LINES_PER_GROUP_) {
            nindex = 0
            len = Int32(UInt32(length[Int64(result)]))
            if (choice != UCharacterNameChoice.UNICODE_CHAR_NAME && choice != UCharacterNameChoice.EXTENDED_CHAR_NAME) {
                var fieldIndex = if (choice == UCharacterNameChoice.ISO_COMMENT_) { 2 } else { choice }
            }
            count = 0
            while (count < len && nindex != -1 && nindex < namelen) {
                b = m_groupstring_[Int64(tempindex + count)]
                count++
                if (Int32(b) >= Int32(m_tokentable_.size)) {
                    if (Int32(UInt32(Char(name[Int64(match (0) { case _ => nindex++; nindex - 1 })]))) != (Int32(b) & 255)) {
                        nindex = -1
                    }
                } else {
                    token = m_tokentable_[Int64(Int32(b) & 255)]
                    if (Int32(UInt32(token)) == 65534) {
                        token = m_tokentable_[Int64(shl(Int32(b), 8) | (Int32(m_groupstring_[Int64(tempindex + count)]) & 255))]
                        count++
                    }
                    if (Int32(UInt32(token)) == 65535) {
                        if (Int32(UInt32(Char(name[Int64(match (0) { case _ => nindex++; nindex - 1 })]))) != (Int32(b) & 255)) {
                            nindex = -1
                        }
                    } else {
                        nindex = UCharacterUtility.compareNullTermByteSubString(name, m_tokenstring_, nindex, Int32(UInt32(token)))
                    }
                }
            }
            if (namelen == nindex && (count == len || Int32(m_groupstring_[Int64(tempindex + count)]) == Int32(UInt32(';')))) {
                return result
            }
            tempindex += len
            result++
        }
        return -1
    }

    private static func getType(ch: Int32): Int32 {
        if (UCharacterUtility.isNonCharacter(ch)) {
            return NON_CHARACTER_
        }
        var result = UCharacter.getType(ch)
        if (result == Int32(UCharacterCategory.SURROGATE)) {
            if (ch <= UTF16.LEAD_SURROGATE_MAX_VALUE) {
                result = LEAD_SURROGATE_
            } else {
                result = TRAIL_SURROGATE_
            }
        }
        return result
    }

    private static func getExtendedChar(name: String, choice: Int32): Int32 {
        if (Char(name[0]) == '<') {
            if (choice == UCharacterNameChoice.EXTENDED_CHAR_NAME) {
                let endIndex = Int32(name.size) - 1
                if (Char(name[Int64(endIndex)]) == '>') {
                    var startIndex = indexOfWrap(name.lastIndexOf(UInt8(UInt32('-'))))
                    if (startIndex >= 0) {
                        startIndex++
                        let hexLength = endIndex - startIndex
                        if (hexLength < 1 || 8 < hexLength) {
                            return -1
                        }
                        var result = -1
                        try {
                            result = parse<Int32>(name[Int64(startIndex)..Int64(endIndex)], 16)
                        } catch (e: TimeParseException) {
                            return -1
                        }
                        if (result < 0 || 1114111 < result) {
                            return -1
                        }
                        let charType = getType(result)
                        let Type: String = name[1..Int64(startIndex - 1)]
                        let length = Int32(TYPE_NAMES_.size)
                        var i = 0
                        while (i < length) {
                            if (Type.compare(TYPE_NAMES_[Int64(i)]).value() == 0) {
                                if (charType == i) {
                                    return result
                                }
                                break
                            }
                            i++
                        }
                    }
                }
            }
            return -1
        }
        return -2
    }

    private static func add(set: Array<Int32>, ch: Char): Unit {
        set[Int64(ushr(Int32(UInt32(ch)), 5))] |= shl(1, (Int32(UInt32(ch)) & 31))
    }

    private static func contains(set: Array<Int32>, ch: Char): Bool {
        return (set[Int64(ushr(Int32(UInt32(ch)), 5))] & (shl(1, (Int32(UInt32(ch)) & 31)))) != 0
    }

    static func add(set: Array<Int32>, str: String): Int32 {
        let result = Int32(str.size)
        var i = result - 1
        while (i >= 0) {
            add(set, Char(str[Int64(i)]))
            i--
        }
        return result
    }

    static func add(set: Array<Int32>, str: StringBuffer): Int32 {
        let result = Int32(str.size)
        var i = result - 1
        while (i >= 0) {
            add(set, str.get(Int64(i)))
            i--
        }
        return result
    }

    private func addAlgorithmName(maxlength: Int32): Int32 {
        var tempmaxlength = maxlength
        var result = 0
        var i = Int32(m_algorithm_.size) - 1
        while (i >= 0) {
            result = m_algorithm_[Int64(i)].add(m_nameSet_, tempmaxlength)
            if (result > tempmaxlength) {
                tempmaxlength = result
            }
            i--
        }
        return tempmaxlength
    }

    private func addExtendedName(maxlength: Int32): Int32 {
        var tempmaxlength = maxlength
        var i = Int32(TYPE_NAMES_.size) - 1
        while (i >= 0) {
            let length = 9 + add(m_nameSet_, TYPE_NAMES_[Int64(i)])
            if (length > tempmaxlength) {
                tempmaxlength = length
            }
            i--
        }
        return tempmaxlength
    }

    private func addGroupName(offset: Int32, length: Int32, tokenlength: Array<UInt8>, set: Array<Int32>): Array<Int32> {
        var resultnlength = 0
        var resultplength = 0
        while (resultplength < length) {
            var b = Char(Int32(m_groupstring_[Int64(offset + resultplength)]) & 255)
            resultplength++
            if (b == ';') {
                break
            }
            if (Int32(UInt32(b)) >= Int32(m_tokentable_.size)) {
                add(set, b)
                resultnlength++
            } else {
                var token = m_tokentable_[Int64(Int32(UInt32(b)) & 255)]
                if (Int32(UInt32(token)) == 65534) {
                    b = Char(shl(Int32(UInt32(b)), 8) | (Int32(m_groupstring_[Int64(offset + resultplength)]) & 255))
                    token = m_tokentable_[Int64(UInt32(b))]
                    resultplength++
                }
                if (Int32(UInt32(token)) == 65535) {
                    add(set, b)
                    resultnlength++
                } else {
                    var tlength = tokenlength[Int64(UInt32(b))]
                    if (Int32(tlength) == 0) {
                        synchronized (getMonitorByObject(m_utilStringBuffer_)) {
                            m_utilStringBuffer_.setLength(0)
                            UCharacterUtility.getNullTermByteSubString(m_utilStringBuffer_, m_tokenstring_, Int32(UInt32(token)))
                            tlength = UInt8(add(set, m_utilStringBuffer_))
                        }
                        tokenlength[Int64(UInt32(b))] = tlength
                    }
                    resultnlength += Int32(tlength)
                }
            }
        }
        m_utilIntBuffer_[0] = resultnlength
        m_utilIntBuffer_[1] = resultplength
        return m_utilIntBuffer_
    }

    private func addGroupName(maxlength: Int32): Unit {
        var tempmaxlength = maxlength
        var maxisolength = 0
        let offsets = Array<Char>(Int64(LINES_PER_GROUP_ + 2)) { _ => '\u{0000}' }
        let lengths = Array<Char>(Int64(LINES_PER_GROUP_ + 2)) { _ => '\u{0000}' }
        let tokenlengths = Array<UInt8>(m_tokentable_.size) { _ => 0 }
        var i = 0
        while (i < m_groupcount_) {
            let offset = getGroupLengths(i, offsets, lengths)
            var linenumber = 0
            while (linenumber < LINES_PER_GROUP_) {
                var lineoffset = offset + Int32(UInt32(offsets[Int64(linenumber)]))
                var length = Int32(UInt32(lengths[Int64(linenumber)]))
                if (length == 0) {
                    continue
                }
                var parsed = addGroupName(lineoffset, length, tokenlengths, m_nameSet_)
                if (parsed[0] > tempmaxlength) {
                    tempmaxlength = parsed[0]
                }
                lineoffset += parsed[1]
                if (parsed[1] >= length) {
                    continue
                }
                length -= parsed[1]
                parsed = addGroupName(lineoffset, length, tokenlengths, m_nameSet_)
                if (parsed[0] > tempmaxlength) {
                    tempmaxlength = parsed[0]
                }
                lineoffset += parsed[1]
                if (parsed[1] >= length) {
                    continue
                }
                length -= parsed[1]
                parsed = addGroupName(lineoffset, length, tokenlengths, m_ISOCommentSet_)
                if (parsed[1] > maxisolength) {
                    maxisolength = length
                }
                linenumber++
            }
            i++
        }
        m_maxISOCommentLength_ = maxisolength
        m_maxNameLength_ = tempmaxlength
    }

    private func initNameSetsLengths(): Bool {
        if (m_maxNameLength_ > 0) {
            return true
        }
        let extra = "0123456789ABCDEF<>-"
        var i = Int32(extra.size) - 1
        while (i >= 0) {
            add(m_nameSet_, Char(extra[Int64(i)]))
            i--
        }
        m_maxNameLength_ = addAlgorithmName(0)
        m_maxNameLength_ = addExtendedName(m_maxNameLength_)
        addGroupName(m_maxNameLength_)
        return true
    }

    private func convert(set: Array<Int32>, uset: UnicodeSet): Unit {
        uset.clear()
        if (!initNameSetsLengths()) {
            return
        }
        var c = Char(255)
        while (Int32(UInt32(c)) > 0) {
            if (contains(set, c)) {
                uset.add(Int32(UInt32(c)))
            }
            c--
        }
    }
}


class UCharacterName_AlgorithmName {
    static let TYPE_0_ = 0

    static let TYPE_1_ = 1


    public func setInfo(rangestart: Int32, rangeend: Int32, Type: UInt8, variant: UInt8): Bool {
        if (rangestart >= UCharacter.MIN_VALUE && rangestart <= rangeend && rangeend <= UCharacter.MAX_VALUE && (Int32(Type) == TYPE_0_ || Int32(Type) == TYPE_1_)) {
            m_rangestart_ = rangestart
            m_rangeend_ = rangeend
            m_type_ = Type
            m_variant_ = variant
            return true
        }
        return false
    }

    public func setFactor(factor: Array<Char>): Bool {
        if (Int32(factor.size) == Int32(m_variant_)) {
            m_factor_ = factor
            return true
        }
        return false
    }

    public func setPrefix(prefix: String): Bool {
        if (prefix.isSome() && Int32(prefix.size) > 0) {
            m_prefix_ = prefix
            return true
        }
        return false
    }

    public func setFactorString(string: Array<UInt8>): Bool {
        m_factorstring_ = string
        return true
    }

    public func contains(ch: Int32): Bool {
        return m_rangestart_ <= ch && ch <= m_rangeend_
    }

    public func appendName(ch: Int32, str: StringBuffer): Unit {
        str.append(m_prefix_)
        match (m_type_) {
            case 0u8 => str.append(Utility.hex(Int64(ch), Int32(m_variant_)))
            case 1u8 =>
                var offset = ch - m_rangestart_
                let indexes = m_utilIntBuffer_
                var factor: Int32 = 0
                synchronized (getMonitorByObject(m_utilIntBuffer_)) {
                    var i = Int32(m_variant_) - 1
                    while (i > 0) {
                        factor = Int32(UInt32(m_factor_[Int64(i)])) & 255
                        indexes[Int64(i)] = offset % factor
                        offset /= factor
                        i--
                    }
                    indexes[0] = offset
                    str.append(getFactorString(indexes, Int32(m_variant_)))
                }
            case _ => ()
        }
    }

    public func getChar(name: String): Int32 {
        let prefixlen = Int32(m_prefix_.size)
        if (Int32(name.size) < prefixlen || !m_prefix_.equals(name[0..Int64(prefixlen)])) {
            return -1
        }
        match (m_type_) {
            case 0u8 => try {
                let result = parse<Int32>(name[Int64(prefixlen)..], 16)
                if (m_rangestart_ <= result && result <= m_rangeend_) {
                    return result
                }
            } catch (e: TimeParseException) {
                return -1
            }
            case 1u8 =>
                var ch = m_rangestart_
                while (ch <= m_rangeend_) {
                    var offset = ch - m_rangestart_
                    let indexes = m_utilIntBuffer_
                    var factor: Int32 = 0
                    synchronized (getMonitorByObject(m_utilIntBuffer_)) {
                        var i = Int32(m_variant_) - 1
                        while (i > 0) {
                            factor = Int32(UInt32(m_factor_[Int64(i)])) & 255
                            indexes[Int64(i)] = offset % factor
                            offset /= factor
                            i--
                        }
                        indexes[0] = offset
                        if (compareFactorString(indexes, Int32(m_variant_), name, prefixlen)) {
                            return ch
                        }
                    }
                    ch++
                }
            case _ => ()
        }
        return -1
    }

    public func add(set: Array<Int32>, maxlength: Int32): Int32 {
        var length = UCharacterName.add(set, m_prefix_)
        match (m_type_) {
            case 0u8 =>
                length += Int32(m_variant_)
                break
            case 1u8 =>
                var i = Int32(m_variant_) - 1
                while (i > 0) {
                    var maxfactorlength = 0
                    var count = 0
                    var factor = Int32(UInt32(m_factor_[Int64(i)]))
                    while (factor > 0) {
                        synchronized (getMonitorByObject(m_utilStringBuffer_)) {
                            m_utilStringBuffer_.setLength(0)
                            count = UCharacterUtility.getNullTermByteSubString(m_utilStringBuffer_, m_factorstring_, count)
                            UCharacterName.add(set, m_utilStringBuffer_)
                            if (Int32(m_utilStringBuffer_.size) > maxfactorlength) {
                                maxfactorlength = Int32(m_utilStringBuffer_.size)
                            }
                        }
                        factor--
                    }
                    length += maxfactorlength
                    i--
                }
            case _ => ()
        }
        if (length > maxlength) {
            return length
        }
        return maxlength
    }

    var m_rangestart_: Int32 = 0

    var m_rangeend_: Int32 = 0

    private var m_type_: UInt8 = 0

    private var m_variant_: UInt8 = 0

    private var m_factor_: Array<Char>

    private var m_prefix_: String

    private var m_factorstring_: Array<UInt8>

    private var m_utilStringBuffer_: StringBuffer = StringBuffer()

    private var m_utilIntBuffer_: Array<Int32> = Array<Int32>(256) { _ => 0 }

    private func getFactorString(index: Array<Int32>, length: Int32): String {
        var size = Int32(m_factor_.size)
        if (index.isNone() || length != size) {
            return None
        }
        synchronized (getMonitorByObject(m_utilStringBuffer_)) {
            m_utilStringBuffer_.setLength(0)
            var count = 0
            var factor: Int32 = 0
            size--
            var i = 0
            while (i <= size) {
                factor = Int32(UInt32(m_factor_[Int64(i)]))
                count = UCharacterUtility.skipNullTermByteSubString(m_factorstring_, count, index[Int64(i)])
                count = UCharacterUtility.getNullTermByteSubString(m_utilStringBuffer_, m_factorstring_, count)
                if (i != size) {
                    count = UCharacterUtility.skipNullTermByteSubString(m_factorstring_, count, factor - index[Int64(i)] - 1)
                }
                i++
            }
            return toString(m_utilStringBuffer_)
        }
    }

    private func compareFactorString(index: Array<Int32>, length: Int32, str: String, offset: Int32): Bool {
        var size = Int32(m_factor_.size)
        if (index.isNone() || length != size) {
            return false
        }
        var count = 0
        var strcount = offset
        var factor: Int32 = 0
        size--
        var i = 0
        while (i <= size) {
            factor = Int32(UInt32(m_factor_[Int64(i)]))
            count = UCharacterUtility.skipNullTermByteSubString(m_factorstring_, count, index[Int64(i)])
            strcount = UCharacterUtility.compareNullTermByteSubString(str, m_factorstring_, strcount, count)
            if (strcount < 0) {
                return false
            }
            if (i != size) {
                count = UCharacterUtility.skipNullTermByteSubString(m_factorstring_, count, factor - index[Int64(i)])
            }
            i++
        }
        if (strcount != Int32(str.size)) {
            return false
        }
        return true
    }
}
