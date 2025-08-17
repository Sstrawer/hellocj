package icu4cj.message2


public interface Formatter {
    
    func formatToString(toFormat: Object, variableOptions: Map<String, Object>): String

    
    func format(toFormat: Object, variableOptions: Map<String, Object>): FormattedPlaceholder
}