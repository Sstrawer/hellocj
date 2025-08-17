package icu4cj.text

class CompoundTransliterator <: Transliterator {
    private var trans: Array<Transliterator>

    private var numAnonymousRBTs = 0

    init(list: ArrayList<Transliterator>) {
        this(list, 0)
    }

    init(list: ArrayList<Transliterator>, numAnonymousRBTs: Int32) {
        super("", None)
        trans = None
        initself(list, FORWARD, false)
        this.numAnonymousRBTs = numAnonymousRBTs
    }

    init(id: String, filter2: UnicodeFilter, trans2: Array<Transliterator>, numAnonymousRBTs2: Int32) {
        super(id, filter2)
        trans = trans2
        numAnonymousRBTs = numAnonymousRBTs2
    }

    private func initself(list: ArrayList<Transliterator>, direction: Int32, fixReverseID: Bool): Unit {
        let count = Int32(list.size)
        trans = Array<Transliterator>(Int64(count))
        var i: Int32 = 0
        i = 0
        while (i < count) {
            let j = if (direction == FORWARD) { i } else { count - 1 - i }
            trans[Int64(i)] = list[Int64(j)]
            i++
        }
        if (direction == REVERSE && fixReverseID) {
            let newID = StringBuilder()
            i = 0
            while (i < count) {
                if (i > 0) {
                    newID.append(ID_DELIM)
                }
                newID.append(trans[Int64(i)].getID())
                i++
            }
            setID(newID.toString())
        }
        computeMaximumContextLength()
    }

    public func getCount(): Int32 {
        return Int32(trans.size)
    }

    public func getTransliterator(index: Int32): Transliterator {
        return trans[Int64(index)]
    }

    private static func _smartAppend(buf: StringBuilder, c: Char): Unit {
        if (Int32(buf.size) != 0 && buf.get(Int64(Int32(buf.size) - 1)) != c) {
            buf.append(c)
        }
    }

    public override func toRules(escapeUnprintable: Bool): String {
        let rulesSource = StringBuilder()
        if (numAnonymousRBTs >= 1 && getFilter().isSome()) {
            rulesSource.append("::").append(getFilter().toPattern(escapeUnprintable)).append(ID_DELIM)
        }
        var i = 0
        while (i < Int32(trans.size)) {
            var rule: String
            if (trans[Int64(i)].getID().startsWith("%Pass")) {
                rule = trans[Int64(i)].toRules(escapeUnprintable)
                if (numAnonymousRBTs > 1 && i > 0 && trans[Int64(i - 1)].getID().startsWith("%Pass")) {
                    rule = "::Null;" + (rule)
                }
            } else if (indexOfWrap(trans[Int64(i)].getID().indexOf(UInt8(UInt32(';')))) >= 0) {
                rule = trans[Int64(i)].toRules(escapeUnprintable)
            } else {
                rule = trans[Int64(i)].baseToRules(escapeUnprintable)
            }
            _smartAppend(rulesSource, '\n')
            rulesSource.append(rule)
            _smartAppend(rulesSource, ID_DELIM)
            i++
        }
        return rulesSource.toString()
    }

    public override func addSourceTargetSet(filter: UnicodeSet, sourceSet: UnicodeSet, targetSet: UnicodeSet): Unit {
        let myFilter = UnicodeSet(getFilterAsUnicodeSet(filter))
        let tempTargetSet = UnicodeSet()
        var i = 0
        while (i < Int32(trans.size)) {
            tempTargetSet.clear()
            trans[Int64(i)].addSourceTargetSet(myFilter, sourceSet, tempTargetSet)
            targetSet.addAll(tempTargetSet)
            myFilter.addAll(tempTargetSet)
            i++
        }
    }

    override protected func handleTransliterate(text: Replaceable, index: Transliterator_Position, incremental: Bool): Unit {
        if (Int32(trans.size) < 1) {
            index.start = index.limit
            return
        }
        var compoundLimit = index.limit
        let compoundStart = index.start
        var delta = 0
        let log: StringBuffer = None
        if (DEBUG) {
            log = StringBuffer("CompoundTransliterator{" + (getID()) + (if (incremental) { "}i: IN=" } else { "}: IN=" }))
            UtilityExtensions.formatInput(log, text, index)
            println(Utility.escape(toString(log)))
        }
        var i = 0
        while (i < Int32(trans.size)) {
            index.start = compoundStart
            let limit = index.limit
            if (index.start == index.limit) {
                if (DEBUG) {
                    println("CompoundTransliterator[" + i.toString() + ".." + ((Int32(trans.size) - 1).toString()) + (if (incremental) { "]i: " } else { "]: " }) + (UtilityExtensions.formatInput(text, index)) + " (NOTHING TO DO)")
                }
                break
            }
            if (DEBUG) {
                log.setLength(0)
                log.append("CompoundTransliterator[" + i.toString() + "=" + (trans[Int64(i)].getID()) + (if (incremental) { "]i: " } else { "]: " }))
                UtilityExtensions.formatInput(log, text, index)
            }
            trans[Int64(i)].filteredTransliterate(text, index, incremental)
            if (!incremental && index.start != index.limit) {
                throw Exception("ERROR: Incomplete non-incremental transliteration by " + (trans[Int64(i)].getID()))
            }
            if (DEBUG) {
                log.append(" => ")
                UtilityExtensions.formatInput(log, text, index)
                println(Utility.escape(toString(log)))
            }
            delta += index.limit - limit
            if (incremental) {
                index.limit = index.start
            }
            i++
        }
        compoundLimit += delta
        index.limit = compoundLimit
        if (DEBUG) {
            log.setLength(0)
            log.append("CompoundTransliterator{" + (getID()) + (if (incremental) { "}i: OUT=" } else { "}: OUT=" }))
            UtilityExtensions.formatInput(log, text, index)
            println(Utility.escape(toString(log)))
        }
    }

    private func computeMaximumContextLength(): Unit {
        var max = 0
        var i = 0
        while (i < Int32(trans.size)) {
            let len = trans[Int64(i)].getMaximumContextLength()
            if (len > max) {
                max = len
            }
            i++
        }
        setMaximumContextLength(max)
    }

    public func safeClone(): Transliterator {
        var filter = getFilter()
        if (filter.isSome() && checkOptionalIs<UnicodeSet, UnicodeFilter>(filter)) {
            filter = UnicodeSet(filter)
        }
        return CompoundTransliterator(getID(), filter, trans, numAnonymousRBTs)
    }
}
