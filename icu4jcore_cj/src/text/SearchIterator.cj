package icu4cj.text

public abstract class SearchIterator {
    protected var breakIterator: BreakIterator

    protected var targetText: CharacterIterator = None

    protected var matchLength: Int32 = 0

    var search_: SearchIterator_Search = SearchIterator_Search(this)

    public static let DONE = -1

    public func setIndex(position: Int32): Unit {
        if (position < search_.beginIndex() || position > search_.endIndex()) {
            throw IndexOutOfBoundsException("setIndex(int) expected position to be between " + search_.beginIndex().toString() + " and " + search_.endIndex().toString())
        }
        search_.reset_ = false
        search_.setMatchedLength(0)
        search_.matchedIndex_ = DONE
    }

    public func setOverlapping(allowOverlap: Bool): Unit {
        search_.isOverlap_ = allowOverlap
    }

    public func setBreakIterator(breakiter: BreakIterator): Unit {
        search_.setBreakIter(breakiter)
        if (search_.breakIter().isSome()) {
            if (search_.text().isSome()) {
                search_.breakIter().setText(search_.text().clone())
            }
        }
    }

    public func setTarget(text: CharacterIterator): Unit {
        if (text.isNone() || text.getEndIndex() == text.getIndex()) {
            throw IllegalArgumentException("Illegal null or empty text")
        }
        text.setIndex(text.getBeginIndex())
        search_.setTarget(text)
        search_.matchedIndex_ = DONE
        search_.setMatchedLength(0)
        search_.reset_ = true
        search_.isForwardSearching_ = true
        if (search_.breakIter().isSome()) {
            search_.breakIter().setText(text.clone())
        }
        if (search_.internalBreakIter_.isSome()) {
            search_.internalBreakIter_.setText(text.clone())
        }
    }

    public func getMatchStart(): Int32 {
        return search_.matchedIndex_
    }

    public func getIndex(): Int32

    public func getMatchLength(): Int32 {
        return search_.matchedLength()
    }

    public func getBreakIterator(): BreakIterator {
        return search_.breakIter()
    }

    public func getTarget(): CharacterIterator {
        return search_.text()
    }

    public func getMatchedText(): String {
        if (search_.matchedLength() > 0) {
            let limit = search_.matchedIndex_ + search_.matchedLength()
            let result = StringBuilder()
            let it = search_.text()
            it.setIndex(search_.matchedIndex_)
            while (it.getIndex() < limit) {
                result.append(it.current())
                it.next()
            }
            it.setIndex(search_.matchedIndex_)
            return result.toString()
        }
        return None
    }

    public func next(): Int32 {
        var index = getIndex()
        let matchindex = search_.matchedIndex_
        let matchlength = search_.matchedLength()
        search_.reset_ = false
        if (search_.isForwardSearching_) {
            let endIdx = search_.endIndex()
            if (index == endIdx || matchindex == endIdx || (matchindex != DONE && matchindex + matchlength >= endIdx)) {
                setMatchNotFound()
                return DONE
            }
        } else {
            search_.isForwardSearching_ = true
            if (search_.matchedIndex_ != DONE) {
                return matchindex
            }
        }
        if (matchlength > 0) {
            if (search_.isOverlap_) {
                index++
            } else {
                index += matchlength
            }
        }
        return handleNext(index)
    }

    public func previous(): Int32 {
        let index: Int32
        if (search_.reset_) {
            index = search_.endIndex()
            search_.isForwardSearching_ = false
            search_.reset_ = false
            setIndex(index)
        } else {
            index = getIndex()
        }
        var matchindex = search_.matchedIndex_
        if (search_.isForwardSearching_) {
            search_.isForwardSearching_ = false
            if (matchindex != DONE) {
                return matchindex
            }
        } else {
            let startIdx = search_.beginIndex()
            if (index == startIdx || matchindex == startIdx) {
                setMatchNotFound()
                return DONE
            }
        }
        if (matchindex != DONE) {
            if (search_.isOverlap_) {
                matchindex += search_.matchedLength() - 2
            }
            return handlePrevious(matchindex)
        }
        return handlePrevious(index)
    }

    public func isOverlapping(): Bool {
        return search_.isOverlap_
    }

    public func reset(): Unit {
        setMatchNotFound()
        setIndex(search_.beginIndex())
        search_.isOverlap_ = false
        search_.isCanonicalMatch_ = false
        search_.elementComparisonType_ = SearchIterator_ElementComparisonType.STANDARD_ELEMENT_COMPARISON
        search_.isForwardSearching_ = true
        search_.reset_ = true
    }

    public func first(): Int32 {
        let startIdx = search_.beginIndex()
        setIndex(startIdx)
        return handleNext(startIdx)
    }

    public func following(position: Int32): Int32 {
        setIndex(position)
        return handleNext(position)
    }

    public func last(): Int32 {
        let endIdx = search_.endIndex()
        setIndex(endIdx)
        return handlePrevious(endIdx)
    }

    public func preceding(position: Int32): Int32 {
        setIndex(position)
        return handlePrevious(position)
    }

    protected init(target: CharacterIterator, breaker: BreakIterator) {
        if (target.isNone() || (target.getEndIndex() - target.getBeginIndex()) == 0) {
            throw IllegalArgumentException("Illegal argument target.  Argument can not be null or of length 0")
        }
        search_.setTarget(target)
        search_.setBreakIter(breaker)
        if (search_.breakIter().isSome()) {
            search_.breakIter().setText(target.clone())
        }
        search_.isOverlap_ = false
        search_.isCanonicalMatch_ = false
        search_.elementComparisonType_ = SearchIterator_ElementComparisonType.STANDARD_ELEMENT_COMPARISON
        search_.isForwardSearching_ = true
        search_.reset_ = true
        search_.matchedIndex_ = DONE
        search_.setMatchedLength(0)
    }

    protected func setMatchLength(length: Int32): Unit {
        search_.setMatchedLength(length)
    }

    protected func handleNext(start: Int32): Int32

    protected func handlePrevious(startAt: Int32): Int32

    
    protected func setMatchNotFound(): Unit {
        search_.matchedIndex_ = DONE
        search_.setMatchedLength(0)
    }

    public func setElementComparisonType(Type: SearchIterator_ElementComparisonType): Unit {
        search_.elementComparisonType_ = Type
    }

    public func getElementComparisonType(): SearchIterator_ElementComparisonType {
        return search_.elementComparisonType_
    }
}


class SearchIterator_Search {
    let this_0: SearchIterator

    init(this_0: SearchIterator) {
        this.this_0 = this_0
    }

    public func text(): CharacterIterator {
        return this_0.targetText
    }

    public func setTarget(text: CharacterIterator): Unit {
        this_0.targetText = text
    }

    var isOverlap_: Bool = false

    var isCanonicalMatch_: Bool = false

    var elementComparisonType_: SearchIterator_ElementComparisonType

    var internalBreakIter_: BreakIterator

    public func breakIter(): BreakIterator {
        return this_0.breakIterator
    }

    public func setBreakIter(breakIter: BreakIterator): Unit {
        this_0.breakIterator = breakIter
    }

    var matchedIndex_: Int32 = 0

    public func matchedLength(): Int32 {
        return this_0.matchLength
    }

    public func setMatchedLength(matchedLength: Int32): Unit {
        this_0.matchLength = matchedLength
    }

    var isForwardSearching_: Bool = false

    var reset_: Bool = false

    public func beginIndex(): Int32 {
        if (this_0.targetText.isNone()) {
            return 0
        }
        return this_0.targetText.getBeginIndex()
    }

    public func endIndex(): Int32 {
        if (this_0.targetText.isNone()) {
            return 0
        }
        return this_0.targetText.getEndIndex()
    }
}


public class SearchIterator_ElementComparisonType <: Enum<SearchIterator_ElementComparisonType> {
    public static let STANDARD_ELEMENT_COMPARISON = SearchIterator_ElementComparisonType("STANDARD_ELEMENT_COMPARISON", 0)

    public static let PATTERN_BASE_WEIGHT_IS_WILDCARD = SearchIterator_ElementComparisonType("PATTERN_BASE_WEIGHT_IS_WILDCARD", 1)

    public static let ANY_BASE_WEIGHT_IS_WILDCARD = SearchIterator_ElementComparisonType("ANY_BASE_WEIGHT_IS_WILDCARD", 2)

    private static func _values(): Array<SearchIterator_ElementComparisonType> {
        return [SearchIterator_ElementComparisonType.STANDARD_ELEMENT_COMPARISON, SearchIterator_ElementComparisonType.PATTERN_BASE_WEIGHT_IS_WILDCARD, SearchIterator_ElementComparisonType.ANY_BASE_WEIGHT_IS_WILDCARD]
    }

    private static let _VALUES = SearchIterator_ElementComparisonType._values()

    public static func values(): Array<SearchIterator_ElementComparisonType> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): SearchIterator_ElementComparisonType {
        return (TypeInfo.of<SearchIterator_ElementComparisonType>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as SearchIterator_ElementComparisonType
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}
