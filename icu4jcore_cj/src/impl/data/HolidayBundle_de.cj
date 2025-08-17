package icu4cj.impl.data

public class HolidayBundle_de <: ListResourceBundle & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    public init() {
        ListResourceBundle()
    }

    private static let fContents: Array<Array<Object>> = [["All Saints' Day", "Allerheiligen"], ["All Souls' Day", "Allerseelen"], ["Armistice Day", "Waffenstillstandstag"], ["Ascension", "Christi Himmelfahrt"], ["Ash Wednesday", "Aschermittwoch"], ["Assumption", "Mari\u{00e4} Himmelfahrt"], ["Boxing Day", "2. Weihnachtstag"], ["Carnival", "Karneval"], ["Christmas", "Weihnachtstag"], ["Civic Holiday", "B\u{00fc}rgerfeiertag"], ["Constitution Day", "Verfassungstag"], ["Corpus Christi", "Fronleichnam"], ["Day of Prayer and Repentance", "Bu\u{00df}- und Bettag"], ["Easter Monday", "Ostermonntag"], ["Easter Sunday", "Ostersonntag"], ["Epiphany", "Heilige 3 K\u{00f6}nige"], ["Father's Day", "Vatertag"], ["Flag Day", "Jahrestag der Nationalflagge"], ["German Unity Day", "Tag der deutschen Einheit"], ["Good Friday", "Karfreitag"], ["Halloween", "Abend vor Allerheiligen"], ["Immaculate Conception", "Mari\u{00e4} Empf\u{00e4}ngnis"], ["Independence Day", "Unabh\u{00e4}ngigkeitstag"], ["Labor Day", "Tag der Arbeit"], ["Liberation Day", "Befreiungstag"], ["Mardi Gras", "Faschingsdienstag"], ["Maundy Thursday", "Gr\u{00fc}ndonnerstag"], ["May Day", "Maifeiertag"], ["Memorial Day", "Tag des Gedenkens"], ["Mother's Day", "Muttertag"], ["National Holiday", "Nationalfeiertag"], ["New Year's Day", "Neujahr"], ["New Year's Eve", "Silvesterabend"], ["Palm Sunday", "Palmsonntag"], ["Pentecost", "Pfingsten"], ["Presidents' Day", "Pr\u{00e4}sidentstag"], ["Remembrance Day", "Volkstrauertag"], ["Revolution Day", "Jahrestag der Revolution"], ["Rose Monday", "Rosenmontag"], ["St. Stephen's Day", "Stephanitag"], ["Shrove Tuesday", "Faschingsdienstag"], ["Spring Holiday", "Tag des Fr\u{00fc}hlings"], ["Summer Bank Holiday", "Bankfeiertag"], ["Thanksgiving", "Dankfest"], ["Unity Day", "Einheitstag"], ["Veterans' Day", "Veteranstag"], ["Victory Day", "Tag der Befreiung"], ["Washington's Birthday", "Washingtons Geburtstag"], ["Whit Monday", "Pfingstmontag"], ["Whit Sunday", "Pfingstsonntag"]]

    public override func getContents(): Array<Array<Object>> {
        synchronized (GeneratedLockObject) {
            return fContents
        }
    }
}
