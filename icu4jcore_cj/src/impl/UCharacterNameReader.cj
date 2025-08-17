package icu4cj.impl

class UCharacterNameReader <: ICUBinary_Authenticate {
    public override func isDataVersionAcceptable(version: Array<UInt8>): Bool {
        return Int32(version[0]) == 1
    }

    protected init(bytes: ByteArrayStream) {
        ICUBinary.readHeader(bytes, DATA_FORMAT_ID_, this)
        m_byteBuffer_ = bytes
    }

    protected func read(data: UCharacterName): Unit {
        m_tokenstringindex_ = m_byteBuffer_.getInt()
        m_groupindex_ = m_byteBuffer_.getInt()
        m_groupstringindex_ = m_byteBuffer_.getInt()
        m_algnamesindex_ = m_byteBuffer_.getInt()
        var count = Int32(UInt32(m_byteBuffer_.getChar()))
        let token = ICUBinary.getChars(m_byteBuffer_, count, 0)
        var size = m_groupindex_ - m_tokenstringindex_
        let tokenstr = Array<UInt8>(Int64(size)) { _ => 0 }
        m_byteBuffer_.get(tokenstr)
        data.setToken(token, tokenstr)
        count = Int32(UInt32(m_byteBuffer_.getChar()))
        data.setGroupCountSize(count, GROUP_INFO_SIZE_)
        count *= GROUP_INFO_SIZE_
        let group = ICUBinary.getChars(m_byteBuffer_, count, 0)
        size = m_algnamesindex_ - m_groupstringindex_
        let groupstring = Array<UInt8>(Int64(size)) { _ => 0 }
        m_byteBuffer_.get(groupstring)
        data.setGroup(group, groupstring)
        count = m_byteBuffer_.getInt()
        let alg = Array<UCharacterName_AlgorithmName>(Int64(count))
        var i = 0
        while (i < count) {
            let an = readAlg()
            if (an.isNone()) {
                throw IOException("unames.icu read error: Algorithmic names creation error")
            }
            alg[Int64(i)] = an
            i++
        }
        data.setAlgorithm(alg)
    }

    protected func authenticate(dataformatid: Array<UInt8>, dataformatversion: Array<UInt8>): Bool {
        return ICUBinary.getVersionByteArrayFromCompactInt(DATA_FORMAT_ID_) == dataformatid && isDataVersionAcceptable(dataformatversion)
    }

    private var m_byteBuffer_: ByteArrayStream = None

    private static let GROUP_INFO_SIZE_ = 3

    private var m_tokenstringindex_: Int32 = 0

    private var m_groupindex_: Int32 = 0

    private var m_groupstringindex_: Int32 = 0

    private var m_algnamesindex_: Int32 = 0

    private static let ALG_INFO_SIZE_ = 12

    private static let DATA_FORMAT_ID_ = 1970168173

    private func readAlg(): UCharacterName_AlgorithmName {
        let result = UCharacterName_AlgorithmName()
        let rangestart = m_byteBuffer_.getInt()
        let rangeend = m_byteBuffer_.getInt()
        let Type = m_byteBuffer_.get()
        let variant = m_byteBuffer_.get()
        if (!result.setInfo(rangestart, rangeend, Type, variant)) {
            return None
        }
        var size = Int32(UInt32(m_byteBuffer_.getChar()))
        if (Int32(Type) == UCharacterName_AlgorithmName.TYPE_1_) {
            let factor = ICUBinary.getChars(m_byteBuffer_, Int32(variant), 0)
            result.setFactor(factor)
            size -= (shl(Int32(variant), 1))
        }
        let prefix = StringBuilder()
        var c = Char(Int32(m_byteBuffer_.get()) & 255)
        while (Int32(UInt32(c)) != 0) {
            prefix.append(c)
            c = Char(Int32(m_byteBuffer_.get()) & 255)
        }
        result.setPrefix(prefix.toString())
        size -= (ALG_INFO_SIZE_ + Int32(prefix.size) + 1)
        if (size > 0) {
            let string = Array<UInt8>(Int64(size)) { _ => 0 }
            m_byteBuffer_.get(string)
            result.setFactorString(string)
        }
        return result
    }
}
