package icu4cj.text

class FunctionReplacer <: UnicodeReplacer {
    private var translit: Transliterator

    private var replacer: UnicodeReplacer

    public init(theTranslit: Transliterator, theReplacer: UnicodeReplacer) {
        translit = theTranslit
        replacer = theReplacer
    }

    public override func replace(text: Replaceable, start: Int32, limit: Int32, cursor: Array<Int32>): Int32 {
        var templimit = limit
        let len = replacer.replace(text, start, templimit, cursor)
        templimit = start + len
        templimit = translit.transliterate(text, start, templimit)
        return templimit - start
    }

    public override func toReplacerPattern(escapeUnprintable: Bool): String {
        let rule = StringBuilder("&")
        rule.append(translit.getID())
        rule.append("( ")
        rule.append(replacer.toReplacerPattern(escapeUnprintable))
        rule.append(" )")
        return rule.toString()
    }

    public override func addReplacementSetTo(toUnionTo: UnicodeSet): Unit {
        toUnionTo.addAll(translit.getTargetSet())
    }
}
