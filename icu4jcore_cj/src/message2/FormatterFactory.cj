package icu4cj.message2



public interface FormatterFactory {
    
    func createFormatter(locale: Locale, fixedOptions: Map<String, Object>): Formatter
}