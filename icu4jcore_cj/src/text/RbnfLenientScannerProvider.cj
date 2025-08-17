package icu4cj.text


public interface RbnfLenientScannerProvider {
    
    func get(locale: ULocale, extras: String): RbnfLenientScanner
}