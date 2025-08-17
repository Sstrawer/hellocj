package icu4cj.message2

class IdentityFormatterFactory <: FormatterFactory {

    public override func createFormatter(locale: Locale, fixedOptions: Map<String, Object>): Formatter {
        return IdentityFormatterFactory_IdentityFormatterImpl()
    }
}


class IdentityFormatterFactory_IdentityFormatterImpl <: Formatter {

    public override func format(toFormat: Object, variableOptions: Map<String, Object>): FormattedPlaceholder {
        return FormattedPlaceholder(toFormat, PlainStringFormattedValue(Objects.toString(toFormat)))
    }

    public override func formatToString(toFormat: Object, variableOptions: Map<String, Object>): String {
        return format(toFormat, variableOptions).toString()
    }
}
