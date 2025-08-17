package icu4cj.impl.data

public class HolidayBundle_es <: ListResourceBundle & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    public init() {
        ListResourceBundle()
    }

    private static let fContents: Array<Array<Object>> = [["All Saints' Day", "Todos los Santos"], ["Armistice Day", "D\u{00ed}a del Armisticio"], ["Ascension", "Ascensi\u{00f3}n"], ["Benito Ju\u{00e1}rez Day", "D\u{00ed}a de la Benito Ju\u{00e1}rez"], ["Boxing Day", "D\u{00ed}a en que se dan Aguinaldos Navide\u{00f1}os"], ["Canada Day", "D\u{00ed}a del Canad\u{00e1}"], ["Christmas Eve", "V\u{00ed}spera de Navidad"], ["Christmas", "Navidad"], ["Constitution Day", "D\u{00ed}a de la Constituci\u{00f3}n"], ["Day of the Dead", "D\u{00ed}a de los Muertos"], ["Easter Sunday", "Pascua"], ["Easter Monday", "Pascua Lunes"], ["Epiphany", "Epifan\u{00ed}a"], ["Father's Day", "D\u{00ed}a del Padre"], ["Flag Day", "D\u{00ed}a de la Bandera"], ["Good Friday", "Viernes Santo"], ["Halloween", "v\u{00ed}spera de Todos los Santos"], ["Independence Day", "D\u{00ed}a de la Independencia"], ["Labor Day", "D\u{00ed}a de Trabajadores"], ["Maundy Thursday", "Jueves Santo"], ["May Day", "Primero de Mayo"], ["Memorial Day", "D\u{00ed}a de la Rememoraci\u{00f3}n"], ["Mother's Day", "D\u{00ed}a de la Madre"], ["New Year's Day", "A\u{00f1}o Nuevo"], ["Palm Sunday", "Domingo de Ramos"], ["Pentecost", "Pentecost\u{00e9}s"], ["Presidents' Day", "D\u{00ed}a de Presidentes"], ["Revolution Day", "D\u{00ed}a de la Revoluci\u{00f3}n"], ["Shrove Tuesday", "Martes de Carnaval"], ["Thanksgiving", "D\u{00ed}a de Acci\u{00f3}n de Gracias"], ["Veterans' Day", "D\u{00ed}a de Veteranos"], ["Victoria Day", "D\u{00ed}a de Victoria"], ["Whit Sunday", "Pentecost\u{00e9}s"]]

    public override func getContents(): Array<Array<Object>> {
        synchronized (GeneratedLockObject) {
            return fContents
        }
    }
}
