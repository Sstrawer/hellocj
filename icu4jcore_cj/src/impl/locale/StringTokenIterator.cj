package icu4cj.impl.locale

public class StringTokenIterator {
    private var _text: String

    private var _dlms: String

    private var _token: String

    private var _start: Int32 = 0

    private var _end: Int32 = 0

    private var _done: Bool = false

    public init(text: String, dlms: String) {
        _text = text
        _dlms = dlms
        setStart(0)
    }

    public func first(): String {
        setStart(0)
        return _token
    }

    public func current(): String {
        return _token
    }

    public func currentStart(): Int32 {
        return _start
    }

    public func currentEnd(): Int32 {
        return _end
    }

    public func isDone(): Bool {
        return _done
    }

    public func next(): String {
        if (hasNext()) {
            _start = _end + 1
            _end = nextDelimiter(_start)
            _token = _text[Int64(_start)..Int64(_end)]
        } else {
            _start = _end
            _token = None
            _done = true
        }
        return _token
    }

    public func hasNext(): Bool {
        return (_end < Int32(_text.size))
    }

    public func setStart(offset: Int32): StringTokenIterator {
        if (offset > Int32(_text.size)) {
            throw IndexOutOfBoundsException()
        }
        _start = offset
        _end = nextDelimiter(_start)
        _token = _text[Int64(_start)..Int64(_end)]
        _done = false
        return this
    }

    public func setText(text: String): StringTokenIterator {
        _text = text
        setStart(0)
        return this
    }

    private func nextDelimiter(start: Int32): Int32 {
        var idx = start
