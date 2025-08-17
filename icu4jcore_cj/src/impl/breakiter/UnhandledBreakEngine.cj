package icu4cj.impl.breakiter


public class UnhandledBreakEngine <: LanguageBreakEngine {
     var fHandled: UnicodeSet = UnicodeSet()


    public override func handles(c: Int32): Bool {
        return fHandled.contains(c)
    }

    public override func findBreaks(text: CharacterIterator, startPos: Int32, endPos: Int32, foundBreaks: DictionaryBreakEngine_DequeI, isPhraseBreaking: Bool): Int32 {
        let uniset = fHandled
        var c = CharacterIteration.current32(text)
        while (text.getIndex() < endPos && uniset.contains(c)) {
            CharacterIteration.next32(text)
            c = CharacterIteration.current32(text)
        }
        return 0
    }

    public func handleChar(c: Int32): Unit {
        let originalSet = fHandled
        if (!originalSet.contains(c)) {
            let script = UCharacter.getIntPropertyValue(c, UProperty.SCRIPT)
            let newSet = UnicodeSet()
            newSet.applyIntPropertyValue(UProperty.SCRIPT, script)
            newSet.addAll(originalSet)
            fHandled = newSet
        }
    }
}
