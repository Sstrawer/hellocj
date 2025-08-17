package icu4cj.message2


public interface SelectorFactory {
    
    func createSelector(locale: Locale, fixedOptions: Map<String, Object>): Selector
}