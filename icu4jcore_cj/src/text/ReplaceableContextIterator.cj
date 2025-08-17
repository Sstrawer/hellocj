package icu4cj.text

class ReplaceableContextIterator <: UCaseProps_ContextIterator {
    init() {
        this.rep = None
        limit = match (0) { case _ => cpStart = match (0) { case _ => cpLimit = match (0) { case _ => index = match (0) { case _ => contextStart = match (0) { case _ => contextLimit = 0; contextLimit }; contextStart }; index }; cpLimit }; cpStart }
        dir = 0
        reachedLimit = false
    }

    public func setText(rep: Replaceable): Unit {
        this.rep = rep
        limit = match (0) { case _ => contextLimit = rep.size; contextLimit }
        cpStart = match (0) { case _ => cpLimit = match (0) { case _ => index = match (0) { case _ => contextStart = 0; contextStart }; index }; cpLimit }
        dir = 0
        reachedLimit = false
    }

    public func setIndex(index: Int32): Unit {
        cpStart = match (0) { case _ => cpLimit = index; cpLimit }
        this.index = 0
        dir = 0
        reachedLimit = false
    }

    public func getCaseMapCPStart(): Int32 {
        return cpStart
    }

    public func setLimit(lim: Int32): Unit {
        if (0 <= lim && lim <= rep.size) {
            limit = lim
        } else {
            limit = rep.size
        }
        reachedLimit = false
    }

    public func setContextLimits(contextStart: Int32, contextLimit: Int32): Unit {
        if (contextStart < 0) {
            this.contextStart = 0
        } else if (contextStart <= rep.size) {
            this.contextStart = contextStart
        } else {
            this.contextStart = rep.size
        }
        if (contextLimit < this.contextStart) {
            this.contextLimit = this.contextStart
        } else if (contextLimit <= rep.size) {
            this.contextLimit = contextLimit
        } else {
            this.contextLimit = rep.size
        }
        reachedLimit = false
    }

    public func nextCaseMapCP(): Int32 {
        let c: Int32
        if (cpLimit < limit) {
            cpStart = cpLimit
            c = rep.char32At(cpLimit)
            cpLimit += UTF16.getCharCount(c)
            return c
        } else {
            return -1
        }
    }

    public func replace(text: String): Int32 {
        let delta = Int32(text.size) - (cpLimit - cpStart)
        rep.replace(cpStart, cpLimit, text)
        cpLimit += delta
        limit += delta
        contextLimit += delta
        return delta
    }

    public func didReachLimit(): Bool {
        return reachedLimit
    }

    public override func reset(direction: Int32): Unit {
        if (direction > 0) {
            this.dir = 1
            index = cpLimit
        } else if (direction < 0) {
            this.dir = -1
            index = cpStart
        } else {
            this.dir = 0
            index = 0
        }
        reachedLimit = false
    }

    public override func next(): Int32 {
        let c: Int32
        if (dir > 0) {
            if (index < contextLimit) {
                c = rep.char32At(index)
                index += UTF16.getCharCount(c)
                return c
            } else {
                reachedLimit = true
            }
        } else if (dir < 0 && index > contextStart) {
            c = rep.char32At(index - 1)
            index -= UTF16.getCharCount(c)
            return c
        }
        return -1
    }

    protected var rep: Replaceable

    protected var index: Int32 = 0

    protected var limit: Int32 = 0

    protected var cpStart: Int32 = 0

    protected var cpLimit: Int32 = 0

    protected var contextStart: Int32 = 0

    protected var contextLimit: Int32 = 0

    protected var dir: Int32 = 0

    protected var reachedLimit: Bool = false
}
