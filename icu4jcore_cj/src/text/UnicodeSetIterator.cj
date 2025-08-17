package icu4cj.text

public class UnicodeSetIterator {
    public static let IS_STRING = -1

    public var codepoint: Int32 = 0

    public var codepointEnd: Int32 = 0

    public var string: String

    public init(set: UnicodeSet) {
        reset(set)
    }

    public init() {
        reset(UnicodeSet())
    }

    public func skipToStrings(): UnicodeSetIterator {
        range = endRange
        endElement = -1
        nextElement = 0
        return this
    }

    public func next(): Bool {
        if (nextElement <= endElement) {
            codepoint = match (0) { case _ => codepointEnd = match (0) { case _ => nextElement++; nextElement - 1 }; codepointEnd }
            return true
        }
        if (range < endRange) {
            loadRange(match (0) { case _ => range++; range })
            codepoint = match (0) { case _ => codepointEnd = match (0) { case _ => nextElement++; nextElement - 1 }; codepointEnd }
            return true
        }
        if (stringIterator.isNone()) {
            return false
        }
        codepoint = IS_STRING
        string = stringIterator.next()
        if (!stringIterator.hasNext()) {
            stringIterator = None
        }
        return true
    }

    public func nextRange(): Bool {
        if (nextElement <= endElement) {
            codepointEnd = endElement
            codepoint = nextElement
            nextElement = endElement + 1
            return true
        }
        if (range < endRange) {
            loadRange(match (0) { case _ => range++; range })
            codepointEnd = endElement
            codepoint = nextElement
            nextElement = endElement + 1
            return true
        }
        if (stringIterator.isNone()) {
            return false
        }
        codepoint = IS_STRING
        string = stringIterator.next()
        if (!stringIterator.hasNext()) {
            stringIterator = None
        }
        return true
    }

    public func reset(uset: UnicodeSet): Unit {
        set = uset
        reset()
    }

    public func reset(): Unit {
        endRange = set.getRangeCount() - 1
        range = 0
        endElement = -1
        nextElement = 0
        if (endRange >= 0) {
            loadRange(range)
        }
        if (set.hasStrings()) {
            stringIterator = set.strings.iterator()
        } else {
            stringIterator = None
        }
    }

    public func getString(): String {
        if (codepoint != IS_STRING) {
            return UTF16.valueOf(codepoint)
        }
        return string
    }

    private var set: UnicodeSet

    private var endRange = 0

    private var range = 0

    private var endElement: Int32 = 0

    private var nextElement: Int32 = 0

    private var stringIterator: Iterator<String>

    private func loadRange(aRange: Int32): Unit {
        nextElement = set.getRangeStart(aRange)
        endElement = set.getRangeEnd(aRange)
    }
}
