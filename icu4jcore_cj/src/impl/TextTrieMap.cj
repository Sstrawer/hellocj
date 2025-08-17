package icu4cj.impl


public class TextTrieMap<V> <: Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    private var _root: TextTrieMap_Node = TextTrieMap_Node(this)

    var _ignoreCase: Bool = false

    public init(ignoreCase: Bool) {
        _ignoreCase = ignoreCase
    }

    public func put(text: String, val: V): TextTrieMap<V> {
        let chitr = TextTrieMap_CharIterator(text, 0, _ignoreCase)
        _root.add(chitr, val)
        return this
    }

    public func get(text: String): Iterator<V> {
        return get(text, 0)
    }

    public func get(text: String, start: Int32): Iterator<V> {
        return get(text, start, None)
    }

    public func get(text: String, start: Int32, output: TextTrieMap_Output): Iterator<V> {
        let handler = TextTrieMap_LongestMatchHandler<V>()
        find(text, start, handler, output)
        if (output.isSome()) {
            output.matchLength = handler.getMatchLength()
        }
        return handler.getMatches()
    }

    public func find(text: String, handler: TextTrieMap_ResultHandler<V>): Unit {
        find(text, 0, handler, None)
    }

    public func find(text: String, offset: Int32, handler: TextTrieMap_ResultHandler<V>): Unit {
        find(text, offset, handler, None)
    }

    private func find(text: String, offset: Int32, handler: TextTrieMap_ResultHandler<V>, output: TextTrieMap_Output): Unit {
        let chitr = TextTrieMap_CharIterator(text, offset, _ignoreCase)
        find(_root, chitr, handler, output)
    }

    private func find(node: TextTrieMap_Node, chitr: TextTrieMap_CharIterator, handler: TextTrieMap_ResultHandler<V>, output: TextTrieMap_Output): Unit {
        synchronized (GeneratedLockObject) {
            let values = node.values()
            if (values.isSome()) {
                if (!handler.handlePrefixMatch(chitr.processedLength(), values)) {
                    return
                }
            }
            let nextMatch = node.findMatch(chitr, output)
            if (nextMatch.isSome()) {
                find(nextMatch, chitr, handler, output)
            }
        }
    }

    public func putLeadCodePoints(output: UnicodeSet): Unit {
        _root.putLeadCodePoints(output)
    }

    static func toCharArray(text: String): Array<Char> {
        let array = Array<Char>(Int64(text.size)) { _ => '\u{0000}' }
        var i = 0
        while (i < Int32(array.size)) {
            array[Int64(i)] = text[i]
            i++
        }
        return array
    }

    static func subArray(array: Array<Char>, start: Int32): Array<Char> {
        if (start == 0) {
            return array
        }
        let sub = Array<Char>(Int64(Int32(array.size) - start)) { _ => '\u{0000}' }
        arraycopy(array, Int64(start), sub, 0, sub.size)
        return sub
    }

    static func subArray(array: Array<Char>, start: Int32, limit: Int32): Array<Char> {
        if (start == 0 && limit == Int32(array.size)) {
            return array
        }
        let sub = Array<Char>(Int64(limit - start)) { _ => '\u{0000}' }
        arraycopy(array, Int64(start), sub, 0, Int64(limit - start))
        return sub
    }
}

public class TextTrieMap_Output {
    public init() { }

    public var matchLength: Int32 = 0

    public var partialMatch: Bool = false
}


public class TextTrieMap_CharIterator <: Iterator<Character> {
    private var _ignoreCase: Bool = false

    private var _text: String

    private var _nextIdx: Int32 = 0

    private var _startIdx: Int32 = 0

    private var _remainingChar: Character = None

    init(text: String, offset: Int32, ignoreCase: Bool) {
        _text = text
        _nextIdx = match (0) { case _ => _startIdx = offset; _startIdx }
        _ignoreCase = ignoreCase
    }

    public override func hasNext(): Bool {
        if (_nextIdx == _text.size && _remainingChar.isNone()) {
            return false
        }
        return true
    }

    public override func next(): Character {
        if (_nextIdx == _text.size && _remainingChar.isNone()) {
            return None
        }
        let next: Character
        if (_remainingChar.isSome()) {
            next = _remainingChar
            _remainingChar = None
        } else {
            if (_ignoreCase) {
                let cp = UCharacter.foldCase(Character.codePointAt(_text, _nextIdx), true)
                _nextIdx = _nextIdx + Character.charCount(cp)
                let chars = Character.toChars(cp)
                next = Character.valueOf(chars[0])
                if (Int32(chars.size) == 2) {
                    _remainingChar = Character.valueOf(chars[1])
                }
            } else {
                next = Character.valueOf(_text[_nextIdx])
                _nextIdx++
            }
        }
        return next
    }

    public override func remove(): Unit {
        throw UnsupportedOperationException("remove() not supported")
    }

    public func nextIndex(): Int32 {
        return _nextIdx
    }

    public func processedLength(): Int32 {
        if (_remainingChar.isSome()) {
            throw Exception("In the middle of surrogate pair")
        }
        return _nextIdx - _startIdx
    }
}


public interface TextTrieMap_ResultHandler<V> {
    public func handlePrefixMatch(matchLength: Int32, values: Iterator<V>): Bool
}

class TextTrieMap_LongestMatchHandler<V> <: TextTrieMap_ResultHandler<V> {
    init() { }

    private var matches: Iterator<V>

    private var length = 0

    public override func handlePrefixMatch(matchLength: Int32, values: Iterator<V>): Bool {
        if (matchLength > length) {
            length = matchLength
            matches = values
        }
        return true
    }

    public func getMatches(): Iterator<V> {
        return matches
    }

    public func getMatchLength(): Int32 {
        return length
    }
}

class TextTrieMap_Node {
    let this_0: TextTrieMap<Any>

    private var _text: Array<Char>

    private var _values: ArrayList<V>

    private var _children: ArrayList<TextTrieMap_Node>

    init(this_0: TextTrieMap<Any>) {
        this.this_0 = this_0
    }

    private init(this_0: TextTrieMap<Any>, text: Array<Char>, values: ArrayList<V>, children: ArrayList<TextTrieMap_Node>) {
        this.this_0 = this_0
        _text = text
        _values = values
        _children = children
    }

    public func charCount(): Int32 {
        return if (_text.isNone()) { 0 } else { Int32(_text.size) }
    }

    public func values(): Iterator<V> {
        if (_values.isNone()) {
            return None
        }
        return _values.iterator()
    }

    public func add(chitr: TextTrieMap_CharIterator, value: V): Unit {
        let buf = StringBuilder()
        while (chitr.hasNext()) {
            buf.append(chitr.next())
        }
        add(TextTrieMap.toCharArray(buf.toString()), 0, value)
    }

    public func findMatch(chitr: TextTrieMap_CharIterator, output: TextTrieMap_Output): TextTrieMap_Node {
        if (_children.isNone()) {
            return None
        }
        if (!chitr.hasNext()) {
            if (output.isSome()) {
                output.partialMatch = true
            }
            return None
        }
        var match: TextTrieMap_Node
        let ch = chitr.next()
        for (child in _children) {
            if (ch.charValue() < child._text[0]) {
                break
            }
            if (ch.charValue() == child._text[0]) {
                if (child.matchFollowing(chitr, output)) {
                    match = child
                }
                break
            }
        }
        return match
    }

    public func putLeadCodePoints(output: UnicodeSet): Unit {
        if (_children.isNone()) {
            return
        }
        for (child in _children) {
            let c0 = child._text[0]
            if (!UCharacter.isHighSurrogate(Int32(UInt32(c0)))) {
                output.add(Int32(UInt32(c0)))
            } else if (child.charCount() >= 2) {
                output.add(Character.codePointAt(child._text, 0))
            } else if (child._children.isSome()) {
                for (grandchild in child._children) {
                    let c1 = grandchild._text[0]
                    let cp = Character.toCodePoint(c0, c1)
                    output.add(cp)
                }
            }
        }
    }

    private func add(text: Array<Char>, offset: Int32, value: V): Unit {
        if (Int32(text.size) == offset) {
            _values = addValue(_values, value)
            return
        }
        if (_children.isNone()) {
            _children = LinkedList<TextTrieMap_Node>() as ArrayList<TextTrieMap_Node>
            let child = TextTrieMap_Node(this_0, TextTrieMap.subArray(text, offset), addValue(None, value), None)
            _children.append(child)
            return
        }
        let litr = _children.listIterator()
        while (litr.hasNext()) {
            let next = litr.next()
            if (text[Int64(offset)] < next._text[0]) {
                litr.previous()
                break
            }
            if (text[Int64(offset)] == next._text[0]) {
                let matchLen = next.lenMatches(text, offset)
                if (matchLen == Int32(next._text.size)) {
                    next.add(text, offset + matchLen, value)
                } else {
                    next.split(matchLen)
                    next.add(text, offset + matchLen, value)
                }
                return
            }
        }
        litr.add(TextTrieMap_Node(this_0, TextTrieMap.subArray(text, offset), addValue(None, value), None))
    }

    private func matchFollowing(chitr: TextTrieMap_CharIterator, output: TextTrieMap_Output): Bool {
        var matched = true
        var idx = 1
        while (idx < Int32(_text.size)) {
            if (!chitr.hasNext()) {
                if (output.isSome()) {
                    output.partialMatch = true
                }
                matched = false
                break
            }
            let ch = chitr.next()
            if (ch.charValue() != _text[Int64(idx)]) {
                matched = false
                break
            }
            idx++
        }
        return matched
    }

    private func lenMatches(text: Array<Char>, offset: Int32): Int32 {
        let textLen = Int32(text.size) - offset
        let limit = if (Int32(_text.size) < textLen) { Int32(_text.size) } else { textLen }
        var len = 0
        while (len < limit) {
            if (_text[Int64(len)] != text[Int64(offset + len)]) {
                break
            }
            len++
        }
        return len
    }

    private func split(offset: Int32): Unit {
        let childText = TextTrieMap.subArray(_text, offset)
        _text = TextTrieMap.subArray(_text, 0, offset)
        let child = TextTrieMap_Node(this_0, childText, _values, _children)
        _values = None
        _children = LinkedList<TextTrieMap_Node>() as ArrayList<TextTrieMap_Node>
        _children.append(child)
    }

    private func addValue(list: ArrayList<V>, value: V): ArrayList<V> {
        var templist = list
        if (templist.isNone()) {
            templist = LinkedList<V>() as ArrayList<V>
        }
        templist.append(value)
        return templist
    }
}
