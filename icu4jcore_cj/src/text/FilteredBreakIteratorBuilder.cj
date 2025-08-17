package icu4cj.text


public abstract class FilteredBreakIteratorBuilder {
    public static func getInstance(`where`: Locale): FilteredBreakIteratorBuilder {
        return SimpleFilteredSentenceBreakIterator_Builder(`where`)
    }

    public static func getInstance(`where`: ULocale): FilteredBreakIteratorBuilder {
        return SimpleFilteredSentenceBreakIterator_Builder(`where`)
    }

    public static func getEmptyInstance(): FilteredBreakIteratorBuilder {
        return SimpleFilteredSentenceBreakIterator_Builder()
    }

    public func suppressBreakAfter(str: String): Bool

    public func unsuppressBreakAfter(str: String): Bool

    public func wrapIteratorWithFilter(wrappedBreakIterator: BreakIterator): BreakIterator

    
}
