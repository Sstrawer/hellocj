package icu4cj.impl.data

public class HolidayBundle_fr <: ListResourceBundle & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    public init() {
        ListResourceBundle()
    }

    private static let fContents: Array<Array<Object>> = [["All Saints' Day", "Toussaint"], ["Armistice Day", "Jour de l'Armistice"], ["Ascension", "Ascension"], ["Bastille Day", "F\u{00ea}te de la Bastille"], ["Benito Ju\u{00e1}rez Day", "F\u{00ea}te de Benito Ju\u{00e1}rez"], ["Boxing Day", "Lendemain de No\u{00eb}l"], ["Christmas Eve", "Veille de No\u{00eb}l"], ["Christmas", "No\u{00eb}l"], ["Easter Monday", "P\u{00e2}ques lundi"], ["Easter Sunday", "P\u{00e2}ques"], ["Epiphany", "l'\u{00c9}piphanie"], ["Flag Day", "F\u{00ea}te du Drapeau"], ["Good Friday", "Vendredi Saint"], ["Halloween", "Veille de la Toussaint"], ["All Saints' Day", "Toussaint"], ["Independence Day", "F\u{00ea}te Ind\u{00e9}pendance"], ["Maundy Thursday", "Jeudi Saint"], ["Mother's Day", "F\u{00ea}te des m\u{00e8}res"], ["National Day", "F\u{00ea}te Nationale"], ["New Year's Day", "Jour de l'an"], ["Palm Sunday", "les Rameaux"], ["Pentecost", "Pentec\u{00f4}te"], ["Shrove Tuesday", "Mardi Gras"], ["St. Stephen's Day", "Saint-\u{00c9}tienne"], ["Victoria Day", "F\u{00ea}te de la Victoria"], ["Victory Day", "F\u{00ea}te de la Victoire"]]

    public override func getContents(): Array<Array<Object>> {
        synchronized (GeneratedLockObject) {
            return fContents
        }
    }
}
