package icu4cj.text

public class BidiRun {
    var start: Int32 = 0

    var limit: Int32 = 0

    var insertRemove: Int32 = 0

    var level: UInt8 = 0

    init() {
        this(0, 0, 0)
    }

    init(start: Int32, limit: Int32, embeddingLevel: UInt8) {
        this.start = start
        this.limit = limit
        this.level = embeddingLevel
    }

    public func copyFrom(run: BidiRun): Unit {
        this.start = run.start
        this.limit = run.limit
        this.level = run.level
        this.insertRemove = run.insertRemove
    }

    public func getStart(): Int32 {
        return start
    }

    public func getLimit(): Int32 {
        return limit
    }

    public func getLength(): Int32 {
        return limit - start
    }

    public func getEmbeddingLevel(): UInt8 {
        return level
    }

    public func isOddRun(): Bool {
        return (Int32(level) & 1) == 1
    }

    public func isEvenRun(): Bool {
        return (Int32(level) & 1) == 0
    }

    public func getDirection(): UInt8 {
        return UInt8(Int32(level) & 1)
    }

    public override func toString(): String {
        return "BidiRun " + start.toString() + " - " + limit.toString() + " @ " + level.toString()
    }
}
