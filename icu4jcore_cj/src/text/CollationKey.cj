package icu4cj.text


public class CollationKey <: Comparable<CollationKey> {
    public init(source: String, key: Array<UInt8>) {
        this(source, key, -1)
    }

    private init(source: String, key: Array<UInt8>, length: Int32) {
        m_source_ = source
        m_key_ = key
        m_hashCode_ = 0
        m_length_ = length
    }

    public init(source: String, key: RawCollationKey) {
        m_source_ = source
        m_length_ = key.size - 1
        m_key_ = key.releaseBytes()
        if (!(Int32(m_key_[Int64(m_length_)]) == 0)) {
            throw AssertionError()
        }
        m_hashCode_ = 0
    }

    public func getSourceString(): String {
        return m_source_
    }

    public func toByteArray(): Array<UInt8> {
        let length = getLength() + 1
        let result = Array<UInt8>(Int64(length)) { _ => 0 }
        arraycopy(m_key_, 0, result, 0, Int64(length))
        return result
    }

    public override func compareTo(target: CollationKey): Int32 {
        var i = 0
        while (true) {
            let l = Int32(m_key_[Int64(i)]) & 255
            let r = Int32(target.m_key_[Int64(i)]) & 255
            if (l < r) {
                return -1
            } else if (l > r) {
                return 1
            } else if (l == 0) {
                return 0
            }
            i++
        }
    }

    public override func equals(target: Object): Bool {
        if (!(checkOptionalIs<CollationKey, Object>(target))) {
            return false
        }
        return equals(target)
    }

    public func equals(target: CollationKey): Bool {
        if (refEq(this, target)) {
            return true
        }
        if (target.isNone()) {
            return false
        }
        let other = target
        var i = 0
        while (true) {
            if (m_key_[Int64(i)] != other.m_key_[Int64(i)]) {
                return false
            }
            if (Int32(m_key_[Int64(i)]) == 0) {
                break
            }
            i++
        }
        return true
    }

    public override func hashCode(): Int64 {
        if (m_hashCode_ == 0) {
            if (m_key_.isNone()) {
                m_hashCode_ = 1
            } else {
                let size = shr(Int32(m_key_.size), 1)
                let key = StringBuilder()
                var i = 0
                while (Int32(m_key_[Int64(i)]) != 0 && Int32(m_key_[Int64(i + 1)]) != 0) {
                    key.append(Char((shl(Int32(m_key_[Int64(i)]), 8)) | (255 & Int32(m_key_[Int64(i + 1)]))))
                    i += 2
                }
                if (Int32(m_key_[Int64(i)]) != 0) {
                    key.append(Char(shl(Int32(m_key_[Int64(i)]), 8)))
                }
                m_hashCode_ = Int32(key.toString().hashCode())
            }
        }
        return Int64(m_hashCode_)
    }

    public func getBound(boundType: Int32, noOfLevels: Int32): CollationKey {
        var tempnoOfLevels = noOfLevels
        var offset = 0
        var keystrength = Collator.PRIMARY
        if (tempnoOfLevels > Collator.PRIMARY) {
            while (offset < Int32(m_key_.size) && Int32(m_key_[Int64(offset)]) != 0) {
                if (Int32(m_key_[Int64(match (0) { case _ => offset++; offset - 1 })]) == Collation.LEVEL_SEPARATOR_BYTE) {
                    keystrength++
                    tempnoOfLevels--
                    if (tempnoOfLevels == Collator.PRIMARY || offset == Int32(m_key_.size) || Int32(m_key_[Int64(offset)]) == 0) {
                        offset--
                        break
                    }
                }
            }
        }
        if (tempnoOfLevels > 0) {
            throw IllegalArgumentException("Source collation key has only " + keystrength.toString() + " strength level. Call getBound() again  with noOfLevels < " + keystrength.toString())
        }
        let resultkey = Array<UInt8>(Int64(offset + boundType + 1)) { _ => 0 }
        arraycopy(m_key_, 0, resultkey, 0, Int64(offset))
        match (boundType) {
            case 0 => ()
            case 1 => resultkey[Int64(match (0) { case _ => offset++; offset - 1 })] = 2
            case 2 =>
                resultkey[Int64(match (0) { case _ => offset++; offset - 1 })] = 255
                resultkey[Int64(match (0) { case _ => offset++; offset - 1 })] = 255
            case _ => throw IllegalArgumentException("Illegal boundType argument")
        }
        resultkey[Int64(offset)] = 0
        return CollationKey(None, resultkey, offset)
    }

    public func merge(source: CollationKey): CollationKey {
        if (source.isNone() || source.getLength() == 0) {
            throw IllegalArgumentException("CollationKey argument can not be null or of 0 length")
        }
        let result = Array<UInt8>(Int64(getLength() + source.getLength() + 2)) { _ => 0 }
        var rindex = 0
        var index = 0
        var sourceindex = 0
        while (true) {
            while (Int32(m_key_[Int64(index)]) < 0 || Int32(m_key_[Int64(index)]) >= MERGE_SEPERATOR_) {
                result[Int64(match (0) { case _ => rindex++; rindex - 1 })] = m_key_[Int64(match (0) { case _ => index++; index - 1 })]
            }
            result[Int64(match (0) { case _ => rindex++; rindex - 1 })] = UInt8(MERGE_SEPERATOR_)
            while (Int32(source.m_key_[Int64(sourceindex)]) < 0 || Int32(source.m_key_[Int64(sourceindex)]) >= MERGE_SEPERATOR_) {
                result[Int64(match (0) { case _ => rindex++; rindex - 1 })] = source.m_key_[Int64(match (0) { case _ => sourceindex++; sourceindex - 1 })]
            }
            if (Int32(m_key_[Int64(index)]) == Collation.LEVEL_SEPARATOR_BYTE && Int32(source.m_key_[Int64(sourceindex)]) == Collation.LEVEL_SEPARATOR_BYTE) {
                index++
                sourceindex++
                result[Int64(match (0) { case _ => rindex++; rindex - 1 })] = UInt8(Collation.LEVEL_SEPARATOR_BYTE)
            } else {
                break
            }
        }
        var remainingLength: Int32 = 0
        if ((match (0) { case _ => remainingLength = m_length_ - index; remainingLength }) > 0) {
            arraycopy(m_key_, Int64(index), result, Int64(rindex), Int64(remainingLength))
            rindex += remainingLength
        } else if ((match (0) { case _ => remainingLength = source.m_length_ - sourceindex; remainingLength }) > 0) {
            arraycopy(source.m_key_, Int64(sourceindex), result, Int64(rindex), Int64(remainingLength))
            rindex += remainingLength
        }
        result[Int64(rindex)] = 0
        if (!(rindex == Int32(result.size) - 1)) {
            throw AssertionError()
        }
        return CollationKey(None, result, rindex)
    }

    private var m_key_: Array<UInt8>

    private var m_source_: String

    private var m_hashCode_: Int32 = 0

    private var m_length_: Int32 = 0

    private static let MERGE_SEPERATOR_ = 2

    private func getLength(): Int32 {
        if (m_length_ >= 0) {
            return m_length_
        }
        var length = Int32(m_key_.size)
        var index = 0
        while (index < length) {
            if (Int32(m_key_[Int64(index)]) == 0) {
                length = index
                break
            }
            index++
        }
        m_length_ = length
        return m_length_
    }
}


public class CollationKey_BoundMode {
    public static let LOWER = 0

    public static let UPPER = 1

    public static let UPPER_LONG = 2

    
    public static let COUNT = 3

}
