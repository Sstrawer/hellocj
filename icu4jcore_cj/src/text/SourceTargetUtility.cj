package icu4cj.text

class SourceTargetUtility {
    let transform: Transform<String, String>

    let sourceCache: UnicodeSet

    let sourceStrings: Set<String>

    static let NON_STARTERS = UnicodeSet("[:^ccc=0:]").freeze()

    static var NFC = Normalizer2.getNFCInstance()

    public init(transform: Transform<String, String>) {
        this(transform, None)
    }

    public init(transform: Transform<String, String>, normalizer: Normalizer2) {
        this.transform = transform
        if (normalizer.isSome()) {
            sourceCache = UnicodeSet("[:^ccc=0:]")
        } else {
            sourceCache = UnicodeSet()
        }
        sourceStrings = HashSet<String>()
        var i = 0
        while (i <= 1114111) {
            var s = transform.transform(UTF16.valueOf(i))
            var added = false
            if (!CharSequences.equals(i, s)) {
                sourceCache.add(i)
                added = true
            }
            if (normalizer.isNone()) {
                continue
            }
            let d = NFC.getDecomposition(i)
            if (d.isNone()) {
                continue
            }
            s = transform.transform(d)
            if (!d.equals(s)) {
                sourceStrings.put(d)
            }
            if (added) {
                continue
            }
            if (!normalizer.isInert(i)) {
                sourceCache.add(i)
                continue
            }
            i++
        }
        sourceCache.freeze()
    }

    public func addSourceTargetSet(transliterator: Transliterator, inputFilter: UnicodeSet, sourceSet: UnicodeSet, targetSet: UnicodeSet): Unit {
        let myFilter = transliterator.getFilterAsUnicodeSet(inputFilter)
        let affectedCharacters = UnicodeSet(sourceCache).retainAll(myFilter)
        sourceSet.addAll(affectedCharacters)
        for (s in affectedCharacters) {
            targetSet.addAll(transform.transform(s))
        }
        for (s in sourceStrings) {
            if (myFilter.containsAll(s)) {
                let t = transform.transform(s)
                if (!s.equals(t)) {
                    targetSet.addAll(t)
                    sourceSet.addAll(s)
                }
            }
        }
    }
}
