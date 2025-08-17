package icu4cj.util

public class StringTokenizer <: Enumeration<Object> {
    public init(str: String, delim: UnicodeSet, returndelims: Bool) {
        this(str, delim, returndelims, false)
    }

    
    public init(str: String, delim: UnicodeSet, returndelims: Bool, coalescedelims: Bool) {
        m_source_ = str
        m_length_ = Int32(str.size)
        if (delim.isNone()) {
            m_delimiters_ = EMPTY_DELIMITER_
        } else {
            m_delimiters_ = delim
        }
        m_returnDelimiters_ = returndelims
        m_coalesceDelimiters_ = coalescedelims
        m_tokenOffset_ = -1
        m_tokenSize_ = -1
        if (m_length_ == 0) {
            m_nextOffset_ = -1
        } else {
            m_nextOffset_ = 0
            if (!returndelims) {
                m_nextOffset_ = getNextNonDelimiter(0)
            }
        }
    }

    public init(str: String, delim: UnicodeSet) {
        this(str, delim, false, false)
    }

    public init(str: String, delim: String, returndelims: Bool) {
        this(str, delim, returndelims, false)
    }

    
    public init(str: String, delim: String, returndelims: Bool, coalescedelims: Bool) {
        m_delimiters_ = EMPTY_DELIMITER_
        if (delim.isSome() && Int32(delim.size) > 0) {
            m_delimiters_ = UnicodeSet()
            m_delimiters_.addAll(delim)
            checkDelimiters()
        }
        m_coalesceDelimiters_ = coalescedelims
        m_source_ = str
        m_length_ = Int32(str.size)
        m_returnDelimiters_ = returndelims
        m_tokenOffset_ = -1
        m_tokenSize_ = -1
        if (m_length_ == 0) {
            m_nextOffset_ = -1
        } else {
            m_nextOffset_ = 0
            if (!returndelims) {
                m_nextOffset_ = getNextNonDelimiter(0)
            }
        }
    }

    public init(str: String, delim: String) {
        this(str, delim, false, false)
    }

    public init(str: String) {
        this(str, DEFAULT_DELIMITERS_, false, false)
    }

    public func hasMoreTokens(): Bool {
        return m_nextOffset_ >= 0
    }

    public func nextToken(): String {
        if (m_tokenOffset_ < 0) {
            if (m_nextOffset_ < 0) {
                throw NoSuchElementException("No more tokens in String")
            }
            if (m_returnDelimiters_) {
                var tokenlimit = 0
                let c = UTF16.toRuneArray()[m_source_, m_nextOffset_]
                let contains = if (delims.isNone()) { m_delimiters_.contains(c) } else { c < Int32(delims.size) && delims[Int64(c)] }
                if (contains) {
                    if (m_coalesceDelimiters_) {
                        tokenlimit = getNextNonDelimiter(m_nextOffset_)
                    } else {
                        tokenlimit = m_nextOffset_ + UTF16.getCharCount(c)
                        if (tokenlimit == m_length_) {
                            tokenlimit = -1
                        }
                    }
                } else {
                    tokenlimit = getNextDelimiter(m_nextOffset_)
                }
                let result: String
                if (tokenlimit < 0) {
                    result = m_source_[Int64(m_nextOffset_)..]
                } else {
                    result = m_source_[Int64(m_nextOffset_)..Int64(tokenlimit)]
                }
                m_nextOffset_ = tokenlimit
                return result
            } else {
                let tokenlimit = getNextDelimiter(m_nextOffset_)
                let result: String
                if (tokenlimit < 0) {
                    result = m_source_[Int64(m_nextOffset_)..]
                    m_nextOffset_ = tokenlimit
                } else {
                    result = m_source_[Int64(m_nextOffset_)..Int64(tokenlimit)]
                    m_nextOffset_ = getNextNonDelimiter(tokenlimit)
                }
                return result
            }
        }
        if (m_tokenOffset_ >= m_tokenSize_) {
            throw NoSuchElementException("No more tokens in String")
        }
        let result: String
        if (m_tokenLimit_[Int64(m_tokenOffset_)] >= 0) {
            result = m_source_[Int64(m_tokenStart_[Int64(m_tokenOffset_)])..Int64(m_tokenLimit_[Int64(m_tokenOffset_)])]
        } else {
            result = m_source_[Int64(m_tokenStart_[Int64(m_tokenOffset_)])..]
        }
        m_tokenOffset_++
        m_nextOffset_ = -1
        if (m_tokenOffset_ < m_tokenSize_) {
            m_nextOffset_ = m_tokenStart_[Int64(m_tokenOffset_)]
        }
        return result
    }

    public func nextToken(delim: String): String {
        m_delimiters_ = EMPTY_DELIMITER_
        if (delim.isSome() && Int32(delim.size) > 0) {
            m_delimiters_ = UnicodeSet()
            m_delimiters_.addAll(delim)
        }
        return nextToken(m_delimiters_)
    }

    public func nextToken(delim: UnicodeSet): String {
        m_delimiters_ = delim
        checkDelimiters()
        m_tokenOffset_ = -1
        m_tokenSize_ = -1
        if (!m_returnDelimiters_) {
            m_nextOffset_ = getNextNonDelimiter(m_nextOffset_)
        }
        return nextToken()
    }

    public override func hasMoreElements(): Bool {
        return hasMoreTokens()
    }

    public override func nextElement(): Object {
        return nextToken()
    }

    public func countTokens(): Int32 {
        var result = 0
        if (hasMoreTokens()) {
            if (m_tokenOffset_ >= 0) {
                return m_tokenSize_ - m_tokenOffset_
            }
            if (m_tokenStart_.isNone()) {
                m_tokenStart_ = Array<Int32>(Int64(TOKEN_SIZE_)) { _ => 0 }
                m_tokenLimit_ = Array<Int32>(Int64(TOKEN_SIZE_)) { _ => 0 }
            }
                m_tokenStart_[Int64(result)] = m_nextOffset_
                if (m_returnDelimiters_) {
                    let c = UTF16.toRuneArray()[m_source_, m_nextOffset_]
                    let contains = if (delims.isNone()) { m_delimiters_.contains(c) } else { c < Int32(delims.size) && delims[Int64(c)] }
                    if (contains) {
                        if (m_coalesceDelimiters_) {
                            m_tokenLimit_[Int64(result)] = getNextNonDelimiter(m_nextOffset_)
                        } else {
                            var p = m_nextOffset_ + 1
                            if (p == m_length_) {
                                p = -1
                            }
                            m_tokenLimit_[Int64(result)] = p
                        }
                    } else {
                        m_tokenLimit_[Int64(result)] = getNextDelimiter(m_nextOffset_)
                    }
                    m_nextOffset_ = m_tokenLimit_[Int64(result)]
                } else {
                    m_tokenLimit_[Int64(result)] = getNextDelimiter(m_nextOffset_)
                    m_nextOffset_ = getNextNonDelimiter(m_tokenLimit_[Int64(result)])
                }
                result++
            } while (m_nextOffset_ >= 0)
            m_tokenOffset_ = 0
            m_tokenSize_ = result
            m_nextOffset_ = m_tokenStart_[0]
        }
        return result
    }

    private var m_tokenOffset_: Int32 = 0

    private var m_tokenSize_: Int32 = 0

    private var m_tokenStart_: Array<Int32>

    private var m_tokenLimit_: Array<Int32>

    private var m_delimiters_: UnicodeSet

    private var m_source_: String

    private var m_length_: Int32 = 0

    private var m_nextOffset_: Int32 = 0

    private var m_returnDelimiters_: Bool = false

    private var m_coalesceDelimiters_: Bool = false

    private static let DEFAULT_DELIMITERS_ = UnicodeSet([9, 10, 12, 13, 32, 32])

    private static let TOKEN_SIZE_ = 100

    private static let EMPTY_DELIMITER_ = UnicodeSet.EMPTY

    private func getNextDelimiter(offset: Int32): Int32 {
        if (offset >= 0) {
            var result = offset
            var c = 0
            if (delims.isNone()) {
                    result++
                } while (result < m_length_)
            } else {
                    result++
                } while (result < m_length_)
            }
            if (result < m_length_) {
                return result
            }
        }
        return -1 - m_length_
    }

    private func getNextNonDelimiter(offset: Int32): Int32 {
        if (offset >= 0) {
            var result = offset
            var c = 0
            if (delims.isNone()) {
                    result++
                } while (result < m_length_)
            } else {
                    result++
                } while (result < m_length_)
            }
            if (result < m_length_) {
                return result
            }
        }
        return -1 - m_length_
    }

    public func checkDelimiters(): Unit {
        if (m_delimiters_.isNone() || m_delimiters_.size() == 0) {
            delims = Array<Bool>(0) { _ => false }
        } else {
            let maxChar = m_delimiters_.getRangeEnd(m_delimiters_.getRangeCount() - 1)
            if (maxChar < 127) {
                delims = Array<Bool>(Int64(maxChar + 1)) { _ => false }
                var i = 0
                var ch: Int32 = 0
                while (-1 != (match (0) { case _ => ch = m_delimiters_.toRuneArray()[i]; ch })) {
                    delims[Int64(ch)] = true
                    i++
                }
            } else {
                delims = None
            }
        }
    }

    private var delims: Array<Bool>
}
