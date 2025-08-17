package icu4cj.text

public class BidiClassifier {
    protected var context: Object

    public init(context: Object) {
        this.context = context
    }

    public func setContext(context: Object): Unit {
        this.context = context
    }

    public func getContext(): Object {
        return this.context
    }

    public func classify(c: Int32): Int32 {
        return Bidi.CLASS_DEFAULT
    }
}
