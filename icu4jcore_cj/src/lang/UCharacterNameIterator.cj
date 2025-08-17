package icu4cj.lang

class UCharacterNameIterator <: ValueIterator {
    public override func next(element: ValueIterator_Element): Bool {
        if (m_current_ >= m_limit_) {
            return false
        }
        if (m_choice_ == UCharacterNameChoice.UNICODE_CHAR_NAME || m_choice_ == UCharacterNameChoice.EXTENDED_CHAR_NAME) {
            let length = m_name_.getAlgorithmLength()
            if (m_algorithmIndex_ < length) {
                while (m_algorithmIndex_ < length) {
                    if (m_algorithmIndex_ < 0 || m_name_.getAlgorithmEnd(m_algorithmIndex_) < m_current_) {
                        m_algorithmIndex_++
                    } else {
                        break
                    }
                }
                if (m_algorithmIndex_ < length) {
                    let start = m_name_.getAlgorithmStart(m_algorithmIndex_)
                    if (m_current_ < start) {
                        var end = start
                        if (m_limit_ <= start) {
                            end = m_limit_
                        }
                        if (!iterateGroup(element, end)) {
                            m_current_++
                            return true
                        }
                    }
                    if (m_current_ >= m_limit_) {
                        return false
                    }
                    element.integer = m_current_
                    element.value = m_name_.getAlgorithmName(m_algorithmIndex_, m_current_)
                    m_groupIndex_ = -1
                    m_current_++
                    return true
                }
            }
        }
        if (!iterateGroup(element, m_limit_)) {
            m_current_++
            return true
        } else if (m_choice_ == UCharacterNameChoice.EXTENDED_CHAR_NAME) {
            if (!iterateExtended(element, m_limit_)) {
                m_current_++
                return true
            }
        }
        return false
    }

    public override func reset(): Unit {
        m_current_ = m_start_
        m_groupIndex_ = -1
        m_algorithmIndex_ = -1
    }

    public override func setRange(start: Int32, limit: Int32): Unit {
        if (start >= limit) {
            throw IllegalArgumentException("start or limit has to be valid Unicode codepoints and start < limit")
        }
        if (start < UCharacter.MIN_VALUE) {
            m_start_ = UCharacter.MIN_VALUE
        } else {
            m_start_ = start
        }
        if (limit > UCharacter.MAX_VALUE + 1) {
            m_limit_ = UCharacter.MAX_VALUE + 1
        } else {
            m_limit_ = limit
        }
        m_current_ = m_start_
    }

    protected init(name: UCharacterName, choice: Int32) {
        if (name.isNone()) {
            throw IllegalArgumentException("UCharacterName name argument cannot be null. Missing unames.icu")
        }
        m_name_ = name
        m_choice_ = choice
        m_start_ = UCharacter.MIN_VALUE
        m_limit_ = UCharacter.MAX_VALUE + 1
        m_current_ = m_start_
    }

    private var m_name_: UCharacterName

    private var m_choice_: Int32 = 0

    private var m_start_: Int32 = 0

    private var m_limit_: Int32 = 0

    private var m_current_: Int32 = 0

    private var m_groupIndex_ = -1

    private var m_algorithmIndex_ = -1

    private static var GROUP_OFFSETS_: Array<Char> = Array<Char>(Int64(UCharacterName.LINES_PER_GROUP_ + 1)) { _ => '\u{0000}' }

    private static var GROUP_LENGTHS_: Array<Char> = Array<Char>(Int64(UCharacterName.LINES_PER_GROUP_ + 1)) { _ => '\u{0000}' }

    private func iterateSingleGroup(result: ValueIterator_Element, limit: Int32): Bool {
        synchronized (getMonitorByObject(GROUP_OFFSETS_)) {
            synchronized (getMonitorByObject(GROUP_LENGTHS_)) {
                let index = m_name_.getGroupLengths(m_groupIndex_, GROUP_OFFSETS_, GROUP_LENGTHS_)
                while (m_current_ < limit) {
                    let offset = UCharacterName.getGroupOffset(m_current_)
                    var name = m_name_.getGroupName(index + Int32(UInt32(GROUP_OFFSETS_[Int64(offset)])), Int32(UInt32(GROUP_LENGTHS_[Int64(offset)])), m_choice_)
                    if ((name.isNone() || Int32(name.size) == 0) && m_choice_ == UCharacterNameChoice.EXTENDED_CHAR_NAME) {
                        name = m_name_.getExtendedName(m_current_)
                    }
                    if (name.isSome() && Int32(name.size) > 0) {
                        result.integer = m_current_
                        result.value = name
                        return false
                    }
                    m_current_++
                }
            }
        }
        return true
    }

    private func iterateGroup(result: ValueIterator_Element, limit: Int32): Bool {
        if (m_groupIndex_ < 0) {
            m_groupIndex_ = m_name_.getGroup(m_current_)
        }
        while (m_groupIndex_ < m_name_.m_groupcount_ && m_current_ < limit) {
            let startMSB = UCharacterName.getCodepointMSB(m_current_)
            let gMSB = m_name_.getGroupMSB(m_groupIndex_)
            if (startMSB == gMSB) {
                if (startMSB == UCharacterName.getCodepointMSB(limit - 1)) {
                    return iterateSingleGroup(result, limit)
                }
                if (!iterateSingleGroup(result, UCharacterName.getGroupLimit(gMSB))) {
                    return false
                }
                m_groupIndex_++
            } else if (startMSB > gMSB) {
                m_groupIndex_++
            } else {
                var gMIN = UCharacterName.getGroupMin(gMSB)
                if (gMIN > limit) {
                    gMIN = limit
                }
                if (m_choice_ == UCharacterNameChoice.EXTENDED_CHAR_NAME) {
                    if (!iterateExtended(result, gMIN)) {
                        return false
                    }
                }
                m_current_ = gMIN
            }
        }
        return true
    }

    private func iterateExtended(result: ValueIterator_Element, limit: Int32): Bool {
        while (m_current_ < limit) {
            let name = m_name_.getExtendedOr10Name(m_current_)
            if (name.isSome() && Int32(name.size) > 0) {
                result.integer = m_current_
                result.value = name
                return false
            }
            m_current_++
        }
        return true
    }
}
