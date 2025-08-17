package icu4cj.text


public interface RbnfLenientScanner {
    
    func allIgnorable(s: String): Bool

    
    func prefixLength(str: String, prefix: String): Int32

    
    func findText(str: String, key: String, startingAt: Int32): Array<Int32>
}