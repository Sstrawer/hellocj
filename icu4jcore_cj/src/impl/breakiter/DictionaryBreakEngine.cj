package icu4cj.impl.breakiter


public abstract class DictionaryBreakEngine <: LanguageBreakEngine {
    var fSet: UnicodeSet = UnicodeSet()


    public override func handles(c: Int32): Bool {
        return fSet.contains(c)
    }

    public override func findBreaks(text: CharacterIterator, startPos: Int32, endPos: Int32, foundBreaks: DictionaryBreakEngine_DequeI, isPhraseBreaking: Bool): Int32 {
        var result = 0
        let start = text.getIndex()
        var current: Int32 = 0
        let rangeStart: Int32
        let rangeEnd: Int32
        var c = CharacterIteration.current32(text)
        while ((match (0) { case _ => current = text.getIndex(); current }) < endPos && fSet.contains(c)) {
            CharacterIteration.next32(text)
            c = CharacterIteration.current32(text)
        }
        rangeStart = start
        rangeEnd = current
        result = divideUpDictionaryRange(text, rangeStart, rangeEnd, foundBreaks, isPhraseBreaking)
        text.setIndex(current)
        return result
    }

    public func setCharacters(set: UnicodeSet): Unit {
        fSet = UnicodeSet(set)
        fSet.compact()
    }

    public func divideUpDictionaryRange(text: CharacterIterator, rangeStart: Int32, rangeEnd: Int32, foundBreaks: DictionaryBreakEngine_DequeI, isPhraseBreaking: Bool): Int32
}


class DictionaryBreakEngine_PossibleWord {
    private static let POSSIBLE_WORD_LIST_MAX = 20

    private var lengths: Array<Int32>

    private var count: Array<Int32>

    private var prefix: Int32 = 0

    private var offset: Int32 = 0

    private var mark: Int32 = 0

    private var current: Int32 = 0

    public init() {
        lengths = Array<Int32>(Int64(POSSIBLE_WORD_LIST_MAX)) { _ => 0 }
        count = Array<Int32>(1) { _ => 0 }
        offset = -1
    }

    public func candidates(fIter: CharacterIterator, dict: DictionaryMatcher, rangeEnd: Int32): Int32 {
        let start = fIter.getIndex()
        if (start != offset) {
            offset = start
            prefix = dict.matches(fIter, rangeEnd - start, lengths, count, Int32(lengths.size))
            if (count[0] <= 0) {
                fIter.setIndex(start)
            }
        }
        if (count[0] > 0) {
            fIter.setIndex(start + lengths[Int64(count[0] - 1)])
        }
        current = count[0] - 1
        mark = current
        return count[0]
    }

    public func acceptMarked(fIter: CharacterIterator): Int32 {
        fIter.setIndex(offset + lengths[Int64(mark)])
        return lengths[Int64(mark)]
    }

    public func backUp(fIter: CharacterIterator): Bool {
        if (current > 0) {
            fIter.setIndex(offset + lengths[Int64(match (0) { case _ => current--; current })])
            return true
        }
        return false
    }

    public func longestPrefix(): Int32 {
        return prefix
    }

    public func markCurrent(): Unit {
        mark = current
    }
}


public class DictionaryBreakEngine_DequeI <: Cloneable {

    private var data: Array<Int32> = Array<Int32>(50) { _ => 0 }

    private var lastIdx = 4

    private var firstIdx = 4

    public override func clone(): Object {
        let result = super.toString()
        result.data = data.clone()
        return result
    }

    public func size(): Int32 {
        return firstIdx - lastIdx
    }

    public func isEmpty(): Bool {
        return size() == 0
    }

    private func grow(): Unit {
        let newData = Array<Int32>(Int64(Int32(data.size) * 2)) { _ => 0 }
        arraycopy(data, 0, newData, 0, data.size)
        data = newData
    }

    public func offer(v: Int32): Unit {
        if (!(lastIdx > 0)) {
            throw AssertionError()
        }
        data[Int64(match (0) { case _ => lastIdx--; lastIdx })] = v
    }

    public func push(v: Int32): Unit {
        if (firstIdx >= Int32(data.size)) {
            grow()
        }
        data[Int64(match (0) { case _ => firstIdx++; firstIdx - 1 })] = v
    }

    public func pop(): Int32 {
        if (!(size() > 0)) {
            throw AssertionError()
        }
        return data[Int64(match (0) { case _ => firstIdx--; firstIdx })]
    }

    public func peek(): Int32 {
        if (!(size() > 0)) {
            throw AssertionError()
        }
        return data[Int64(firstIdx - 1)]
    }

    public func peekLast(): Int32 {
        if (!(size() > 0)) {
            throw AssertionError()
        }
        return data[Int64(lastIdx)]
    }

    public func pollLast(): Int32 {
        if (!(size() > 0)) {
            throw AssertionError()
        }
        return data[Int64(match (0) { case _ => lastIdx++; lastIdx - 1 })]
    }

    public func contains(v: Int32): Bool {
        var i = lastIdx
        while (i < firstIdx) {
            if (data[Int64(i)] == v) {
                return true
            }
            i++
        }
        return false
    }

    public func elementAt(i: Int32): Int32 {
        if (!(i < size())) {
            throw AssertionError()
        }
        return data[Int64(lastIdx + i)]
    }

    public func removeAllElements(): Unit {
        lastIdx = match (0) { case _ => firstIdx = 4; firstIdx }
    }
}
