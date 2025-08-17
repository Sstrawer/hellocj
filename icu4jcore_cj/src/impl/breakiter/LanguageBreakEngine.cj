package icu4cj.impl.breakiter

public interface LanguageBreakEngine {
    func handles(c: Int32): Bool

    func findBreaks(text: CharacterIterator, startPos: Int32, endPos: Int32, foundBreaks: DictionaryBreakEngine_DequeI, isPhraseBreaking: Bool): Int32
}