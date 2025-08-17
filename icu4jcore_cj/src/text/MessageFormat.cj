package icu4cj.text


public class MessageFormat <: UFormat {
    static let serialVersionUID = 7136212545847378652

    public init(pattern: String) {
        super()
        this.ulocale = ULocale.getDefault(ULocale_Category.FORMAT)
        applyPattern(pattern)
    }

    public init(pattern: String, locale: Locale) {
        this(pattern, ULocale.forLocale(locale))
    }

    public init(pattern: String, locale: ULocale) {
        super()
        this.ulocale = locale
        applyPattern(pattern)
    }

    public func setLocale(locale: Locale): Unit {
        setLocale(ULocale.forLocale(locale))
    }

    public func setLocale(locale: ULocale): Unit {
        let existingPattern = toPattern()
        this.ulocale = locale
        stockDateFormatter = None
        stockNumberFormatter = None
        pluralProvider = None
        ordinalProvider = None
        applyPattern(existingPattern)
    }

    public func getLocale(): Locale {
        return ulocale.toLocale()
    }

    public func getULocale(): ULocale {
        return ulocale
    }

    public func applyPattern(pttrn: String): Unit {
        @AssertThrows[Exception]({
            if (msgPattern.isNone()) {
                msgPattern = MessagePattern(pttrn)
            } else {
                msgPattern.parse(pttrn)
            }
            cacheExplicitFormats()
        } catch (e: Exception) {
            resetPattern()
            throw e
        }
    }

    public func applyPattern(pattern: String, aposMode: MessagePattern_ApostropheMode): Unit {
        if (msgPattern.isNone()) {
            msgPattern = MessagePattern(aposMode)
        } else if (!refEq(aposMode, msgPattern.getApostropheMode())) {
            msgPattern.clearPatternAndSetApostropheMode(aposMode)
        }
        applyPattern(pattern)
    }

    public func getApostropheMode(): MessagePattern_ApostropheMode {
        if (msgPattern.isNone()) {
            msgPattern = MessagePattern()
        }
        return msgPattern.getApostropheMode()
    }

    public func toPattern(): String {
        if (customFormatArgStarts.isSome()) {
            throw Exception("toPattern() is not supported after custom Format objects have been set via setFormat() or similar APIs")
        }
        if (msgPattern.isNone()) {
            return ""
        }
        let originalPattern = msgPattern.getPatternString()
        return if (originalPattern.isNone()) { "" } else { originalPattern }
    }

    private func nextTopLevelArgStart(partIndex: Int32): Int32 {
        var temppartIndex = partIndex
        if (temppartIndex != 0) {
            temppartIndex = msgPattern.getLimitPartIndex(temppartIndex)
        }
        while (true) {
            let Type = msgPattern.getPartType(match (0) { case _ => temppartIndex++; temppartIndex })
            if (refEq(Type, MessagePattern_Part_Type.ARG_START)) {
                return temppartIndex
            }
            if (refEq(Type, MessagePattern_Part_Type.MSG_LIMIT)) {
                return -1
            }
        }
    }

    private func argNameMatches(partIndex: Int32, argName: String, argNumber: Int32): Bool {
        let part = msgPattern.getPart(partIndex)
        return if (refEq(part.getType(), MessagePattern_Part_Type.ARG_NAME)) { msgPattern.partSubstringMatches(part, argName) } else { part.getValue() == argNumber }
    }

    private func getArgName(partIndex: Int32): String {
        let part = msgPattern.getPart(partIndex)
        if (refEq(part.getType(), MessagePattern_Part_Type.ARG_NAME)) {
            return msgPattern.getSubstring(part)
        } else {
            return part.getValue().toString()
        }
    }

    public func setFormatsByArgumentIndex(newFormats: Array<Format>): Unit {
        if (msgPattern.hasNamedArguments()) {
            throw IllegalArgumentException("This method is not available in MessageFormat objects that use alphanumeric argument names.")
        }
        var partIndex = 0
        while ((match (0) { case _ => partIndex = nextTopLevelArgStart(partIndex); partIndex }) >= 0) {
            let argNumber = msgPattern.getPart(partIndex + 1).getValue()
            if (argNumber < Int32(newFormats.size)) {
                setCustomArgStartFormat(partIndex, newFormats[Int64(argNumber)])
            }
        }
    }

    public func setFormatsByArgumentName(newFormats: Map<String, Format>): Unit {
        var partIndex = 0
        while ((match (0) { case _ => partIndex = nextTopLevelArgStart(partIndex); partIndex }) >= 0) {
            let key = getArgName(partIndex + 1)
            if (newFormats.contains(key)) {
                setCustomArgStartFormat(partIndex, newFormats.get(key))
            }
        }
    }

    public func setFormats(newFormats: Array<Format>): Unit {
        var formatNumber = 0
        var partIndex = 0
        while (formatNumber < Int32(newFormats.size) && (match (0) { case _ => partIndex = nextTopLevelArgStart(partIndex); partIndex }) >= 0) {
            setCustomArgStartFormat(partIndex, newFormats[Int64(formatNumber)])
            formatNumber++
        }
    }

    public func setFormatByArgumentIndex(argumentIndex: Int32, newFormat: Format): Unit {
        if (msgPattern.hasNamedArguments()) {
            throw IllegalArgumentException("This method is not available in MessageFormat objects that use alphanumeric argument names.")
        }
        var partIndex = 0
        while ((match (0) { case _ => partIndex = nextTopLevelArgStart(partIndex); partIndex }) >= 0) {
            if (msgPattern.getPart(partIndex + 1).getValue() == argumentIndex) {
                setCustomArgStartFormat(partIndex, newFormat)
            }
        }
    }

    public func setFormatByArgumentName(argumentName: String, newFormat: Format): Unit {
        let argNumber = MessagePattern.validateArgumentName(argumentName)
        if (argNumber < MessagePattern.ARG_NAME_NOT_NUMBER) {
            return
        }
        var partIndex = 0
        while ((match (0) { case _ => partIndex = nextTopLevelArgStart(partIndex); partIndex }) >= 0) {
            if (argNameMatches(partIndex + 1, argumentName, argNumber)) {
                setCustomArgStartFormat(partIndex, newFormat)
            }
        }
    }

    public func setFormat(formatElementIndex: Int32, newFormat: Format): Unit {
        var formatNumber = 0
        var partIndex = 0
        while ((match (0) { case _ => partIndex = nextTopLevelArgStart(partIndex); partIndex }) >= 0) {
            if (formatNumber == formatElementIndex) {
                setCustomArgStartFormat(partIndex, newFormat)
                return
            }
            formatNumber++
        }
        throw IndexOutOfBoundsException(formatElementIndex)
    }

    public func getFormatsByArgumentIndex(): Array<Format> {
        if (msgPattern.hasNamedArguments()) {
            throw IllegalArgumentException("This method is not available in MessageFormat objects that use alphanumeric argument names.")
        }
        let list = ArrayList<Format>()
        var partIndex = 0
        while ((match (0) { case _ => partIndex = nextTopLevelArgStart(partIndex); partIndex }) >= 0) {
            let argNumber = msgPattern.getPart(partIndex + 1).getValue()
            while (argNumber >= Int32(list.size)) {
                list.append(None)
            }
            list.set(Int64(argNumber), if (cachedFormatters.isNone()) { None } else { cachedFormatters.get(partIndex) })
        }
        return list.toArray(Array<<-->(list.size)) : Array<??Format> => Array<Format> -->
    }

    public func getFormats(): Array<Format> {
        let list = ArrayList<Format>()
        var partIndex = 0
        while ((match (0) { case _ => partIndex = nextTopLevelArgStart(partIndex); partIndex }) >= 0) {
            list.append(if (cachedFormatters.isNone()) { None } else { cachedFormatters.get(partIndex) })
        }
        return list.toArray(Array<<-->(list.size)) : Array<??Format> => Array<Format> -->
    }

    public func getArgumentNames(): Set<String> {
        let result: Set<String> = HashSet<String>()
        var partIndex = 0
        while ((match (0) { case _ => partIndex = nextTopLevelArgStart(partIndex); partIndex }) >= 0) {
            result.put(getArgName(partIndex + 1))
        }
        return result
    }

    public func getFormatByArgumentName(argumentName: String): Format {
        if (cachedFormatters.isNone()) {
            return None
        }
        let argNumber = MessagePattern.validateArgumentName(argumentName)
        if (argNumber < MessagePattern.ARG_NAME_NOT_NUMBER) {
            return None
        }
        var partIndex = 0
        while ((match (0) { case _ => partIndex = nextTopLevelArgStart(partIndex); partIndex }) >= 0) {
            if (argNameMatches(partIndex + 1, argumentName, argNumber)) {
                return cachedFormatters.get(partIndex)
            }
        }
        return None
    }

    public func format(arguments: Array<Object>, result: StringBuffer, pos: FieldPosition): StringBuffer {
        format(arguments, None, MessageFormat_AppendableWrapper(result), pos)
        return result
    }

    public func format(arguments: Map<String, Object>, result: StringBuffer, pos: FieldPosition): StringBuffer {
        format(None, arguments, MessageFormat_AppendableWrapper(result), pos)
        return result
    }

    public static func formatStatic(pattern: String, arguments: Array<Object>): String {
        let temp = MessageFormat(pattern)
        return temp.format(arguments)
    }

    public static func formatStatic(pattern: String, arguments: Map<String, Object>): String {
        let temp = MessageFormat(pattern)
        return temp.format(arguments)
    }

    public func usesNamedArguments(): Bool {
        return msgPattern.hasNamedArguments()
    }

    public override func format(arguments: Object, result: StringBuffer, pos: FieldPosition): StringBuffer {
        format(arguments, MessageFormat_AppendableWrapper(result), pos)
        return result
    }

    public override func formatToCharacterIterator(arguments: Object): AttributedCharacterIterator {
        if (arguments.isNone()) {
            throw NoneValueException("formatToCharacterIterator must be passed non-null object")
        }
        let result = StringBuilder()
        let wrapper = MessageFormat_AppendableWrapper(result)
        wrapper.useAttributes()
        format(arguments, wrapper, None)
        let `as` = AttributedString(result.toString())
        for (a in wrapper.attributes) {
            `as`.addAttribute(a.key, a.value, a.start, a.limit)
        }
        return `as`.getIterator()
    }

    public func parse(source: String, pos: ParsePosition): Array<Object> {
        if (msgPattern.hasNamedArguments()) {
            throw IllegalArgumentException("This method is not available in MessageFormat objects that use named argument.")
        }
        var maxArgId = -1
        var partIndex = 0
        while ((match (0) { case _ => partIndex = nextTopLevelArgStart(partIndex); partIndex }) >= 0) {
            let argNumber = msgPattern.getPart(partIndex + 1).getValue()
            if (argNumber > maxArgId) {
                maxArgId = argNumber
            }
        }
        let resultArray = Array<Object>(Int64(maxArgId + 1))
        let backupStartPos = pos.getIndex()
        parse(0, source, pos, resultArray, None)
        if (pos.getIndex() == backupStartPos) {
            return None
        }
        return resultArray
    }

    public func parseToMap(source: String, pos: ParsePosition): Map<String, Object> {
        let result: Map<String, Object> = HashMap<String, Object>()
        let backupStartPos = pos.getIndex()
        parse(0, source, pos, None, result)
        if (pos.getIndex() == backupStartPos) {
            return None
        }
        return result
    }

    public func parse(source: String): Array<Object> {
        let pos = ParsePosition(0)
        let result = parse(source, pos)
        if (pos.getIndex() == 0) {
            throw ParseException("MessageFormat parse error!", pos.getErrorIndex())
        }
        return result
    }

    private func parse(msgStart: Int32, source: String, pos: ParsePosition, args: Array<Object>, argsMap: Map<String, Object>): Unit {
        if (source.isNone()) {
            return
        }
        let msgString = msgPattern.getPatternString()
        var prevIndex = msgPattern.getPart(msgStart).getLimit()
        var sourceOffset = pos.getIndex()
        let tempStatus = ParsePosition(0)
        var i = msgStart + 1
        while (true) {
            var part = msgPattern.getPart(i)
            let Type = part.getType()
            let index = part.getIndex()
            let len = index - prevIndex
            if (len == 0 || msgString.regionMatches(prevIndex, source, sourceOffset, len)) {
                sourceOffset += len
                prevIndex += len
            } else {
                pos.setErrorIndex(sourceOffset)
                return
            }
            if (refEq(Type, MessagePattern_Part_Type.MSG_LIMIT)) {
                pos.setIndex(sourceOffset)
                return
            }
            if (refEq(Type, MessagePattern_Part_Type.SKIP_SYNTAX) || refEq(Type, MessagePattern_Part_Type.INSERT_CHAR)) {
                prevIndex = part.getLimit()
                continue
            }
            if (!refEq(Type, MessagePattern_Part_Type.ARG_START)) {
                throw Exception("Unexpected Part " + part.asString() + " in parsed message.")
            }
            let argLimit = msgPattern.getLimitPartIndex(i)
            let argType = part.getArgType()
            part = msgPattern.getPart(match (0) { case _ => i++; i })
            var argId: Object
            var argNumber = 0
            var key: String
            if (args.isSome()) {
                argNumber = part.getValue()
                argId = argNumber
            } else {
                if (refEq(part.getType(), MessagePattern_Part_Type.ARG_NAME)) {
                    key = msgPattern.getSubstring(part)
                } else {
                    key = part.getValue().toString()
                }
                argId = key
            }
            i++
            var formatter: Format = None
            var haveArgResult = false
            var argResult: Object
            if (cachedFormatters.isSome() && (match (0) { case _ => formatter = cachedFormatters.get(i - 2); formatter }).isSome()) {
                tempStatus.setIndex(sourceOffset)
                argResult = formatter.parseObject(source, tempStatus)
                if (tempStatus.getIndex() == sourceOffset) {
                    pos.setErrorIndex(sourceOffset)
                    return
                }
                haveArgResult = true
                sourceOffset = tempStatus.getIndex()
            } else if (refEq(argType, MessagePattern_ArgType.NONE) || (cachedFormatters.isSome() && cachedFormatters.contains(i - 2))) {
                let stringAfterArgument = getLiteralStringUntilNextArgument(argLimit)
                let next: Int32
                if (Int32(stringAfterArgument.size) != 0) {
                    next = indexOfWrap(source.indexOf(stringAfterArgument, Int64(sourceOffset)))
                } else {
                    next = Int32(source.size)
                }
                if (next < 0) {
                    pos.setErrorIndex(sourceOffset)
                    return
                } else {
                    let strValue: String = source[Int64(sourceOffset)..Int64(next)]
                    if (!strValue.equals("{" + toString(argId) + "}")) {
                        haveArgResult = true
                        argResult = strValue
                    }
                    sourceOffset = next
                }
            } else if (refEq(argType, MessagePattern_ArgType.CHOICE)) {
                tempStatus.setIndex(sourceOffset)
                let choiceResult = parseChoiceArgument(msgPattern, i, source, tempStatus)
                if (tempStatus.getIndex() == sourceOffset) {
                    pos.setErrorIndex(sourceOffset)
                    return
                }
                argResult = choiceResult
                haveArgResult = true
                sourceOffset = tempStatus.getIndex()
            } else if (argType.hasPluralStyle() || refEq(argType, MessagePattern_ArgType.SELECT)) {
                throw UnsupportedOperationException("Parsing of plural/select/selectordinal argument is not supported.")
            } else {
                throw Exception("unexpected argType " + argType.asString())
            }
            if (haveArgResult) {
                if (args.isSome()) {
                    args[Int64(argNumber)] = argResult
                } else if (argsMap.isSome()) {
                    argsMap.put(key, argResult)
                }
            }
            prevIndex = msgPattern.getPart(argLimit).getLimit()
            i = argLimit
            i++
        }
    }

    public func parseToMap(source: String): Map<String, Object> {
        let pos = ParsePosition(0)
        let result: Map<String, Object> = HashMap<String, Object>()
        parse(0, source, pos, None, result)
        if (pos.getIndex() == 0) {
            throw ParseException("MessageFormat parse error!", pos.getErrorIndex())
        }
        return result
    }

    public override func parseObject(source: String, pos: ParsePosition): Object {
        if (!msgPattern.hasNamedArguments()) {
            return parse(source, pos)
        } else {
            return parseToMap(source, pos)
        }
    }

    public override func clone(): Object {
        let other = super.clone()
        if (customFormatArgStarts.isSome()) {
            other.customFormatArgStarts = HashSet<Int32>()
            for (key in customFormatArgStarts) {
                other.customFormatArgStarts.put(key)
            }
        } else {
            other.customFormatArgStarts = None
        }
        if (cachedFormatters.isSome()) {
            other.cachedFormatters = HashMap<Int32, Format>()
            let it = cachedFormatters.entrySet().iterator()
            while (it.hasNext()) {
                let entry = it.next()
                other.cachedFormatters.put(entry.getKey(), entry.getValue())
            }
        } else {
            other.cachedFormatters = None
        }
        other.msgPattern = if (msgPattern.isNone()) { None } else { msgPattern.clone() }
        other.stockDateFormatter = if (stockDateFormatter.isNone()) { None } else { stockDateFormatter.clone() }
        other.stockNumberFormatter = if (stockNumberFormatter.isNone()) { None } else { stockNumberFormatter.clone() }
        other.pluralProvider = None
        other.ordinalProvider = None
        return other
    }

    public override func equals(obj: Object): Bool {
        if (refEq(this, obj)) {
            return true
        }
        if (obj.isNone() || !refEq(TypeInfo.of(this), TypeInfo.of(obj))) {
            return false
        }
        let other = obj
        return Objects.equals(ulocale, other.ulocale) && Objects.equals(msgPattern, other.msgPattern) && Objects.equals(cachedFormatters, other.cachedFormatters) && Objects.equals(customFormatArgStarts, other.customFormatArgStarts)
    }

    public override func hashCode(): Int64 {
        return msgPattern.getPatternString().hashCode()
    }

     var ulocale: ULocale

     private var msgPattern: MessagePattern

     var cachedFormatters: Map<Int32, Format> = None

     private var customFormatArgStarts: Set<Int32>

     private var stockDateFormatter: DateFormat

     private var stockNumberFormatter: NumberFormat

     private var pluralProvider: MessageFormat_PluralSelectorProvider

     private var ordinalProvider: MessageFormat_PluralSelectorProvider

    private func getStockDateFormatter(): DateFormat {
        if (stockDateFormatter.isNone()) {
            stockDateFormatter = DateFormat.getDateTimeInstance(DateFormat.SHORT, DateFormat.SHORT, ulocale)
        }
        return stockDateFormatter
    }

    public func getStockNumberFormatter(): NumberFormat {
        if (stockNumberFormatter.isNone()) {
            stockNumberFormatter = NumberFormat.getInstance(ulocale)
        }
        return stockNumberFormatter
    }

    private func format(msgStart: Int32, pluralNumber: MessageFormat_PluralSelectorContext, args: Array<Object>, argsMap: Map<String, Object>, dest: MessageFormat_AppendableWrapper, fp: FieldPosition): Unit {
        var tempfp = fp
        let msgString = msgPattern.getPatternString()
        var prevIndex = msgPattern.getPart(msgStart).getLimit()
        var i = msgStart + 1
        while (true) {
            var part = msgPattern.getPart(i)
            let Type = part.getType()
            let index = part.getIndex()
            dest.append(msgString, prevIndex, index)
            if (refEq(Type, MessagePattern_Part_Type.MSG_LIMIT)) {
                return
            }
            prevIndex = part.getLimit()
            if (refEq(Type, MessagePattern_Part_Type.REPLACE_NUMBER)) {
                if (pluralNumber.forReplaceNumber) {
                    dest.formatAndAppend(pluralNumber.formatter, pluralNumber.number, pluralNumber.numberString)
                } else {
                    dest.formatAndAppend(getStockNumberFormatter(), pluralNumber.number)
                }
                continue
            }
            if (!refEq(Type, MessagePattern_Part_Type.ARG_START)) {
                continue
            }
            let argLimit = msgPattern.getLimitPartIndex(i)
            let argType = part.getArgType()
            part = msgPattern.getPart(match (0) { case _ => i++; i })
            let arg: Object
            var noArg = false
            var argId: Object
            let argName = msgPattern.getSubstring(part)
            if (args.isSome()) {
                let argNumber = part.getValue()
                if (dest.attributes.isSome()) {
                    argId = argNumber
                }
                if (0 <= argNumber && argNumber < Int32(args.size)) {
                    arg = args[Int64(argNumber)]
                } else {
                    arg = None
                    noArg = true
                }
            } else {
                argId = argName
                if (argsMap.isSome()) {
                    arg = argsMap.get(argName)
                    if (arg.isNone()) {
                        noArg = !argsMap.contains(argName)
                    }
                } else {
                    arg = None
                    noArg = true
                }
            }
            i++
            let prevDestLength = dest.length
            var formatter: Format = None
            if (noArg) {
                dest.append("{")
                dest.append(argName)
                dest.append("}")
            } else if (arg.isNone()) {
                dest.append("null")
            } else if (pluralNumber.isSome() && pluralNumber.numberArgIndex == (i - 2)) {
                if (pluralNumber.offset == 0.0) {
                    dest.formatAndAppend(pluralNumber.formatter, pluralNumber.number, pluralNumber.numberString)
                } else {
                    dest.formatAndAppend(pluralNumber.formatter, arg)
                }
            } else if (cachedFormatters.isSome() && (match (0) { case _ => formatter = cachedFormatters.get(i - 2); formatter }).isSome()) {
                if (checkOptionalIs<ChoiceFormat, Format>(formatter) || checkOptionalIs<PluralFormat, Format>(formatter) || checkOptionalIs<SelectFormat, Format>(formatter)) {
                    let subMsgString = formatter.format(arg)
                    if (indexOfWrap(subMsgString.indexOf(UInt8(UInt32('{')))) >= 0 || (indexOfWrap(subMsgString.indexOf(UInt8(UInt32(''')))) >= 0 && !msgPattern.jdkAposMode())) {
                        let subMsgFormat = MessageFormat(subMsgString, ulocale)
                        subMsgFormat.format(0, None, args, argsMap, dest, None)
                    } else if (dest.attributes.isNone()) {
                        dest.append(subMsgString)
                    } else {
                        dest.formatAndAppend(formatter, arg)
                    }
                } else {
                    dest.formatAndAppend(formatter, arg)
                }
            } else if (refEq(argType, MessagePattern_ArgType.NONE) || (cachedFormatters.isSome() && cachedFormatters.contains(i - 2))) {
                if (checkOptionalIs<Number, Object>(arg)) {
                    dest.formatAndAppend(getStockNumberFormatter(), arg)
                } else if (checkOptionalIs<Date, Object>(arg)) {
                    dest.formatAndAppend(getStockDateFormatter(), arg)
                } else {
                    dest.append(toString(arg))
                }
            } else if (refEq(argType, MessagePattern_ArgType.CHOICE)) {
                if (!(checkOptionalIs<Number, Object>(arg))) {
                    throw IllegalArgumentException("'" + toString(arg) + "' is not a Number")
                }
                let number = arg.doubleValue()
                let subMsgStart = findChoiceSubMessage(msgPattern, i, number)
                formatComplexSubMessage(subMsgStart, None, args, argsMap, dest)
            } else if (argType.hasPluralStyle()) {
                if (!(checkOptionalIs<Number, Object>(arg))) {
                    throw IllegalArgumentException("'" + toString(arg) + "' is not a Number")
                }
                let selector: MessageFormat_PluralSelectorProvider
                if (refEq(argType, MessagePattern_ArgType.PLURAL)) {
                    if (pluralProvider.isNone()) {
                        pluralProvider = MessageFormat_PluralSelectorProvider(this, PluralRules_PluralType.CARDINAL)
                    }
                    selector = pluralProvider
                } else {
                    if (ordinalProvider.isNone()) {
                        ordinalProvider = MessageFormat_PluralSelectorProvider(this, PluralRules_PluralType.ORDINAL)
                    }
                    selector = ordinalProvider
                }
                let number = arg
                let offset = msgPattern.getPluralOffset(i)
                let context = MessageFormat_PluralSelectorContext(i, argName, number, offset)
                let subMsgStart = PluralFormat.findSubMessage(msgPattern, i, selector, context, number.doubleValue())
                formatComplexSubMessage(subMsgStart, context, args, argsMap, dest)
            } else if (refEq(argType, MessagePattern_ArgType.SELECT)) {
                let subMsgStart = SelectFormat.findSubMessage(msgPattern, i, toString(arg))
                formatComplexSubMessage(subMsgStart, None, args, argsMap, dest)
            } else {
                throw Exception("unexpected argType " + argType.asString())
            }
            tempfp = updateMetaData(dest, prevDestLength, tempfp, argId)
            prevIndex = msgPattern.getPart(argLimit).getLimit()
            i = argLimit
            i++
        }
    }

    private func formatComplexSubMessage(msgStart: Int32, pluralNumber: MessageFormat_PluralSelectorContext, args: Array<Object>, argsMap: Map<String, Object>, dest: MessageFormat_AppendableWrapper): Unit {
        if (!msgPattern.jdkAposMode()) {
            format(msgStart, pluralNumber, args, argsMap, dest, None)
            return
        }
        let msgString = msgPattern.getPatternString()
        let subMsgString: String
        var sb: StringBuilder
        var prevIndex = msgPattern.getPart(msgStart).getLimit()
        var i = msgStart
        while (true) {
            let part = msgPattern.getPart(match (0) { case _ => i++; i })
            let Type = part.getType()
            var index = part.getIndex()
            if (refEq(Type, MessagePattern_Part_Type.MSG_LIMIT)) {
                if (sb.isNone()) {
                    subMsgString = msgString[Int64(prevIndex)..Int64(index)]
                } else {
                    subMsgString = sb.append(msgString, prevIndex, index).toString()
                }
                break
            } else if (refEq(Type, MessagePattern_Part_Type.REPLACE_NUMBER) || refEq(Type, MessagePattern_Part_Type.SKIP_SYNTAX)) {
                if (sb.isNone()) {
                    sb = StringBuilder()
                }
                sb.append(msgString, prevIndex, index)
                if (refEq(Type, MessagePattern_Part_Type.REPLACE_NUMBER)) {
                    if (pluralNumber.forReplaceNumber) {
                        sb.append(pluralNumber.numberString)
                    } else {
                        sb.append(getStockNumberFormatter().format(pluralNumber.number))
                    }
                }
                prevIndex = part.getLimit()
            } else if (refEq(Type, MessagePattern_Part_Type.ARG_START)) {
                if (sb.isNone()) {
                    sb = StringBuilder()
                }
                sb.append(msgString, prevIndex, index)
                prevIndex = index
                i = msgPattern.getLimitPartIndex(i)
                index = msgPattern.getPart(i).getLimit()
                MessagePattern.appendReducedApostrophes(msgString, prevIndex, index, sb)
                prevIndex = index
            }
        }
        if (indexOfWrap(subMsgString.indexOf(UInt8(UInt32('{')))) >= 0) {
            let subMsgFormat = MessageFormat("", ulocale)
            subMsgFormat.applyPattern(subMsgString, MessagePattern_ApostropheMode.DOUBLE_REQUIRED)
            subMsgFormat.format(0, None, args, argsMap, dest, None)
        } else {
            dest.append(subMsgString)
        }
    }

    private func getLiteralStringUntilNextArgument(comefrom: Int32): String {
        let b = StringBuilder()
        let msgString = msgPattern.getPatternString()
        var prevIndex = msgPattern.getPart(comefrom).getLimit()
        var i = comefrom + 1
        while (true) {
            let part = msgPattern.getPart(i)
            let Type = part.getType()
            let index = part.getIndex()
            b.append(msgString, prevIndex, index)
            if (refEq(Type, MessagePattern_Part_Type.ARG_START) || refEq(Type, MessagePattern_Part_Type.MSG_LIMIT)) {
                return b.toString()
            }
            if (!(refEq(Type, MessagePattern_Part_Type.SKIP_SYNTAX) || refEq(Type, MessagePattern_Part_Type.INSERT_CHAR))) {
                throw Exception("Unexpected Part " + part.asString() + " in parsed message.")
            }
            prevIndex = part.getLimit()
            i++
        }
    }

    private func updateMetaData(dest: MessageFormat_AppendableWrapper, prevLength: Int32, fp: FieldPosition, argId: Object): FieldPosition {
        if (dest.attributes.isSome() && prevLength < dest.length) {
            dest.attributes.append(MessageFormat_AttributeAndPosition(argId, prevLength, dest.length))
        }
        if (fp.isSome() && refEq(MessageFormat_Field.ARGUMENT, fp.getFieldAttribute())) {
            fp.setBeginIndex(prevLength)
            fp.setEndIndex(dest.length)
            return None
        }
        return fp
    }

    private static func findChoiceSubMessage(pattern: MessagePattern, partIndex: Int32, number: Float64): Int32 {
        var temppartIndex = partIndex
        let count = pattern.countParts()
        var msgStart: Int32 = 0
        temppartIndex += 2
        while (true) {
            msgStart = temppartIndex
            temppartIndex = pattern.getLimitPartIndex(temppartIndex)
            if (match (0) { case _ => temppartIndex++; temppartIndex } >= count) {
                break
            }
            let part = pattern.getPart(match (0) { case _ => temppartIndex++; temppartIndex - 1 })
            let Type = part.getType()
            if (refEq(Type, MessagePattern_Part_Type.ARG_LIMIT)) {
                break
            }
            if (!Type.hasNumericValue()) {
                throw AssertionError()
            }
            let boundary = pattern.getNumericValue(part)
            let selectorIndex = pattern.getPatternIndex(match (0) { case _ => temppartIndex++; temppartIndex - 1 })
            let boundaryChar = Char(pattern.getPatternString()[Int64(selectorIndex)])
            if (if (boundaryChar == '<') { !(number > boundary) } else { !(number >= boundary) }) {
                break
            }
        }
        return msgStart
    }

    private static func parseChoiceArgument(pattern: MessagePattern, partIndex: Int32, source: String, pos: ParsePosition): Float64 {
        var temppartIndex = partIndex
        let start = pos.getIndex()
        var furthest = start
        var bestNumber = Float64.NaN
        var tempNumber = 0.0
        while (!refEq(pattern.getPartType(temppartIndex), MessagePattern_Part_Type.ARG_LIMIT)) {
            tempNumber = pattern.getNumericValue(pattern.getPart(temppartIndex))
            temppartIndex += 2
            let msgLimit = pattern.getLimitPartIndex(temppartIndex)
            let len = matchStringUntilLimitPart(pattern, temppartIndex, msgLimit, source, start)
            if (len >= 0) {
                let newIndex = start + len
                if (newIndex > furthest) {
                    furthest = newIndex
                    bestNumber = tempNumber
                    if (furthest == Int32(source.size)) {
                        break
                    }
                }
            }
            temppartIndex = msgLimit + 1
        }
        if (furthest == start) {
            pos.setErrorIndex(start)
        } else {
            pos.setIndex(furthest)
        }
        return bestNumber
    }

    private static func matchStringUntilLimitPart(pattern: MessagePattern, partIndex: Int32, limitPartIndex: Int32, source: String, sourceOffset: Int32): Int32 {
        var temppartIndex = partIndex
        var matchingSourceLength = 0
        let msgString = pattern.getPatternString()
        var prevIndex = pattern.getPart(temppartIndex).getLimit()
        while (true) {
            let part = pattern.getPart(match (0) { case _ => temppartIndex++; temppartIndex })
            if (temppartIndex == limitPartIndex || refEq(part.getType(), MessagePattern_Part_Type.SKIP_SYNTAX)) {
                let index = part.getIndex()
                let length = index - prevIndex
                if (length != 0 && !source.regionMatches(sourceOffset, msgString, prevIndex, length)) {
                    return -1
                }
                matchingSourceLength += length
                if (temppartIndex == limitPartIndex) {
                    return matchingSourceLength
                }
                prevIndex = part.getLimit()
            }
        }
    }

    public func findOtherSubMessage(partIndex: Int32): Int32 {
        var temppartIndex = partIndex
        let count = msgPattern.countParts()
        var part = msgPattern.getPart(temppartIndex)
        if (part.getType().hasNumericValue()) {
            temppartIndex++
        }
            if (!refEq(Type, MessagePattern_Part_Type.ARG_SELECTOR)) {
                throw AssertionError()
            }
            if (msgPattern.partSubstringMatches(part, "other")) {
                return temppartIndex
            }
            if (msgPattern.getPartType(temppartIndex).hasNumericValue()) {
                temppartIndex++
            }
            temppartIndex = msgPattern.getLimitPartIndex(temppartIndex)
        } while (match (0) { case _ => temppartIndex++; temppartIndex } < count)
        return 0
    }

    public func findFirstPluralNumberArg(msgStart: Int32, argName: String): Int32 {
        var i = msgStart + 1
        while (true) {
            var part = msgPattern.getPart(i)
            let Type = part.getType()
            if (refEq(Type, MessagePattern_Part_Type.MSG_LIMIT)) {
                return 0
            }
            if (refEq(Type, MessagePattern_Part_Type.REPLACE_NUMBER)) {
                return -1
            }
            if (refEq(Type, MessagePattern_Part_Type.ARG_START)) {
                let argType = part.getArgType()
                if (Int32(argName.size) != 0 && (refEq(argType, MessagePattern_ArgType.NONE) || refEq(argType, MessagePattern_ArgType.SIMPLE))) {
                    part = msgPattern.getPart(i + 1)
                    if (msgPattern.partSubstringMatches(part, argName)) {
                        return i
                    }
                }
                i = msgPattern.getLimitPartIndex(i)
            }
            i++
        }
    }

    private func format(arguments: Object, result: MessageFormat_AppendableWrapper, fp: FieldPosition): Unit {
        if (arguments.isNone() || checkOptionalIs<Map<Any, Any>, Object>(arguments)) {
            format(None, arguments, result, fp)
        } else {
            format(arguments, None, result, fp)
        }
    }

    private func format(arguments: Array<Object>, argsMap: Map<String, Object>, dest: MessageFormat_AppendableWrapper, fp: FieldPosition): Unit {
        if (arguments.isSome() && msgPattern.hasNamedArguments()) {
            throw IllegalArgumentException("This method is not available in MessageFormat objects that use alphanumeric argument names.")
        }
        format(0, None, arguments, argsMap, dest, fp)
    }

    private func resetPattern(): Unit {
        if (msgPattern.isSome()) {
            msgPattern.clear()
        }
        if (cachedFormatters.isSome()) {
            cachedFormatters.clear()
        }
        customFormatArgStarts = None
    }

    private static let typeList: Array<String> = ["number", "date", "time", "spellout", "ordinal", "duration"]

    private static let TYPE_NUMBER = 0

    private static let TYPE_DATE = 1

    private static let TYPE_TIME = 2

    private static let TYPE_SPELLOUT = 3

    private static let TYPE_ORDINAL = 4

    private static let TYPE_DURATION = 5

    private static let modifierList: Array<String> = ["", "currency", "percent", "integer"]

    private static let MODIFIER_EMPTY = 0

    private static let MODIFIER_CURRENCY = 1

    private static let MODIFIER_PERCENT = 2

    private static let MODIFIER_INTEGER = 3

    private static let dateModifierList: Array<String> = ["", "short", "medium", "long", "full"]

    private static let DATE_MODIFIER_EMPTY = 0

    private static let DATE_MODIFIER_SHORT = 1

    private static let DATE_MODIFIER_MEDIUM = 2

    private static let DATE_MODIFIER_LONG = 3

    private static let DATE_MODIFIER_FULL = 4

    public func dateTimeFormatForPatternOrSkeleton(style: String): Format {
        let i = PatternProps.skipWhiteSpace(style, 0)
        if (style.regionMatches(i, "::", 0, 2)) {
            return DateFormat.getInstanceForSkeleton(style[Int64(i + 2)..], ulocale)
        } else {
            return SimpleDateFormat(style, ulocale)
        }
    }

    private func createAppropriateFormat(Type: String, style: String): Format {
        var newFormat: Format = None
        let subformatType = findKeyword(Type, typeList)
        match (subformatType) {
            case 0 => match (findKeyword(style, modifierList)) {
                case 0 => newFormat = NumberFormat.getInstance(ulocale)
                case 1 => newFormat = NumberFormat.getCurrencyInstance(ulocale)
                case 2 => newFormat = NumberFormat.getPercentInstance(ulocale)
                case 3 => newFormat = NumberFormat.getIntegerInstance(ulocale)
                case _ =>
                    let i = PatternProps.skipWhiteSpace(style, 0)
                    if (style.regionMatches(i, "::", 0, 2)) {
                        newFormat = NumberFormatter.forSkeleton(style[Int64(i + 2)..]).locale(ulocale).toFormat()
                    } else {
                        newFormat = DecimalFormat(style, DecimalFormatSymbols(ulocale))
                    }
            }
            case 1 => match (findKeyword(style, dateModifierList)) {
                case 0 => newFormat = DateFormat.getDateInstance(DateFormat.DEFAULT, ulocale)
                case 1 => newFormat = DateFormat.getDateInstance(DateFormat.SHORT, ulocale)
                case 2 => newFormat = DateFormat.getDateInstance(DateFormat.DEFAULT, ulocale)
                case 3 => newFormat = DateFormat.getDateInstance(DateFormat.LONG, ulocale)
                case 4 => newFormat = DateFormat.getDateInstance(DateFormat.FULL, ulocale)
                case _ => newFormat = dateTimeFormatForPatternOrSkeleton(style)
            }
            case 2 => match (findKeyword(style, dateModifierList)) {
                case 0 => newFormat = DateFormat.getTimeInstance(DateFormat.DEFAULT, ulocale)
                case 1 => newFormat = DateFormat.getTimeInstance(DateFormat.SHORT, ulocale)
                case 2 => newFormat = DateFormat.getTimeInstance(DateFormat.DEFAULT, ulocale)
                case 3 => newFormat = DateFormat.getTimeInstance(DateFormat.LONG, ulocale)
                case 4 => newFormat = DateFormat.getTimeInstance(DateFormat.FULL, ulocale)
                case _ => newFormat = dateTimeFormatForPatternOrSkeleton(style)
            }
            case 3 =>
                let rbnf = RuleBasedNumberFormat(ulocale, RuleBasedNumberFormat.SPELLOUT)
                let ruleset = style.trimAscii()
                if (Int32(ruleset.size) != 0) {
                    try {
                        rbnf.setDefaultRuleSet(ruleset)
                    })
                }
                newFormat = rbnf
            case 4 =>
                let rbnf = RuleBasedNumberFormat(ulocale, RuleBasedNumberFormat.ORDINAL)
                let ruleset = style.trimAscii()
                if (Int32(ruleset.size) != 0) {
                    @AssertThrows[Exception]({
                        rbnf.setDefaultRuleSet(ruleset)
                    })
                }
                newFormat = rbnf
            case 5 =>
                let rbnf = RuleBasedNumberFormat(ulocale, RuleBasedNumberFormat.DURATION)
                let ruleset = style.trimAscii()
                if (Int32(ruleset.size) != 0) {
                    @AssertThrows[Exception]({
                        rbnf.setDefaultRuleSet(ruleset)
                    })
                }
                newFormat = rbnf
            case _ => throw IllegalArgumentException("Unknown format type \"" + (Type) + "\"")
        }
        return newFormat
    }

    private static let rootLocale = Locale("")

    private static func findKeyword(s: String, list: Array<String>): Int32 {
        var temps = s
        temps = PatternProps.trimWhiteSpace(temps).toLowerCase(rootLocale)
        var i = 0
        while (i < Int32(list.size)) {
            if (temps.equals(list[Int64(i)])) {
                return i
            }
            i++
        }
        return -1
    }

    private func writeObject(out: ObjectOutputStream): Unit {
        out.defaultWriteObject()
        out.writeObject(ulocale.toLanguageTag())
        if (msgPattern.isNone()) {
            msgPattern = MessagePattern()
        }
        out.writeObject(msgPattern.getApostropheMode())
        out.writeObject(msgPattern.getPatternString())
        if (customFormatArgStarts.isNone() || customFormatArgStarts.isEmpty()) {
            out.writeInt(0)
        } else {
            out.writeInt(Int32(customFormatArgStarts.size))
            var formatIndex = 0
            var partIndex = 0
            while ((match (0) { case _ => partIndex = nextTopLevelArgStart(partIndex); partIndex }) >= 0) {
                if (customFormatArgStarts.contains(partIndex)) {
                    out.writeInt(formatIndex)
                    out.writeObject(cachedFormatters.get(partIndex))
                }
                formatIndex++
            }
        }
        out.writeInt(0)
    }

    private func readObject(input: ObjectInputStream): Unit {
        input.defaultReadObject()
        let languageTag = input.readObject()
        ulocale = ULocale.forLanguageTag(languageTag)
        let aposMode = input.readObject()
        if (msgPattern.isNone() || !refEq(aposMode, msgPattern.getApostropheMode())) {
            msgPattern = MessagePattern(aposMode)
        }
        let msg = input.readObject()
        if (msg.isSome()) {
            applyPattern(msg)
        }
        var numFormatters = input.readInt()
        while (numFormatters > 0) {
            let formatIndex = input.readInt()
            let formatter = input.readObject()
            setFormat(formatIndex, formatter)
            numFormatters--
        }
        var numPairs = input.readInt()
        while (numPairs > 0) {
            input.readInt()
            input.readObject()
            numPairs--
        }
    }

    private func cacheExplicitFormats(): Unit {
        if (cachedFormatters.isSome()) {
            cachedFormatters.clear()
        }
        customFormatArgStarts = None
        let limit = msgPattern.countParts() - 2
        var i = 1
        while (i < limit) {
            var part = msgPattern.getPart(i)
            if (!refEq(part.getType(), MessagePattern_Part_Type.ARG_START)) {
                continue
            }
            let argType = part.getArgType()
            if (!refEq(argType, MessagePattern_ArgType.SIMPLE)) {
                continue
            }
            let index = i
            i += 2
            let explicitType = msgPattern.getSubstring(msgPattern.getPart(match (0) { case _ => i++; i - 1 }))
            var style: String = ""
            if (refEq((match (0) { case _ => part = msgPattern.getPart(i); part }).getType(), MessagePattern_Part_Type.ARG_STYLE)) {
                style = msgPattern.getSubstring(part)
                i++
            }
            let formatter = createAppropriateFormat(explicitType, style)
            setArgStartFormat(index, formatter)
            i++
        }
    }

    private func setArgStartFormat(argStart: Int32, formatter: Format): Unit {
        if (cachedFormatters.isNone()) {
            cachedFormatters = HashMap<Int32, Format>()
        }
        cachedFormatters.put(argStart, formatter)
    }

    private func setCustomArgStartFormat(argStart: Int32, formatter: Format): Unit {
        setArgStartFormat(argStart, formatter)
        if (customFormatArgStarts.isNone()) {
            customFormatArgStarts = HashSet<Int32>()
        }
        customFormatArgStarts.put(argStart)
    }

    private static let SINGLE_QUOTE = '''

    private static let CURLY_BRACE_LEFT = '{'

    private static let CURLY_BRACE_RIGHT = '}'

    private static let STATE_INITIAL = 0

    private static let STATE_SINGLE_QUOTE = 1

    private static let STATE_IN_QUOTE = 2

    private static let STATE_MSG_ELEMENT = 3

    public static func autoQuoteApostrophe(pattern: String): String {
        let buf = StringBuilder()
        var state = STATE_INITIAL
        var braceCount = 0
        var i = 0
        let j = Int32(pattern.size)
        while (i < j) {
            let c = Char(pattern[Int64(i)])
            match (state) {
                case 0 => match (c) {
                    case ''' => state = STATE_SINGLE_QUOTE
                    case '{' =>
                        state = STATE_MSG_ELEMENT
                        braceCount++
                    case _ => ()
                }
                case 1 => match (c) {
                    case ''' => state = STATE_INITIAL
                    case '{' | '}' => state = STATE_IN_QUOTE
                    case _ =>
                        buf.append(SINGLE_QUOTE)
                        state = STATE_INITIAL
                }
                case 2 => match (c) {
                    case ''' => state = STATE_INITIAL
                    case _ => ()
                }
                case 3 => match (c) {
                    case '{' => braceCount++
                    case '}' => if (match (0) { case _ => braceCount--; braceCount } == 0) {
                        state = STATE_INITIAL
                    }
                    case _ => ()
                }
                case _ => ()
            }
            buf.append(c)
            i++
        }
        if (state == STATE_SINGLE_QUOTE || state == STATE_IN_QUOTE) {
            buf.append(SINGLE_QUOTE)
        }
        return String(buf)
    }
}


public class MessageFormat_Field <: Format_Field {
    private static let serialVersionUID = 7510380454602616157

    protected init(name: String) {
        Format_Field(name)
    }

    override protected func readResolve(): Object {
        if (!refEq(TypeInfo.of(this), TypeInfo.of<MessageFormat_Field>())) {
            throw InvalidObjectException("A subclass of MessageFormat.Field must implement readResolve.")
        }
        if (this.getName().equals(ARGUMENT.getName())) {
            return ARGUMENT
        } else {
            throw InvalidObjectException("Unknown attribute name.")
        }
    }

    public static let ARGUMENT = MessageFormat_Field("message argument field")
}


class MessageFormat_PluralSelectorContext {
    init(start: Int32, name: String, num: Number, off: Float64) {
        startIndex = start
        argName = name
        if (off == 0.0) {
            number = num
        } else {
            number = num.doubleValue() - off
        }
        offset = off
    }

    public override func toString(): String {
        throw Exception("PluralSelectorContext being formatted, rather than its number")
    }

    var startIndex: Int32 = 0

    var argName: String

    var number: Number = None

    var offset: Float64 = 0.0

    var numberArgIndex: Int32 = 0

    var formatter: Format = None

    var numberString: String

    var forReplaceNumber: Bool = false
}


class MessageFormat_PluralSelectorProvider <: PluralFormat_PluralSelector {
    public init(mf: MessageFormat, Type: PluralRules_PluralType) {
        msgFormat = mf
        this.Type = Type
    }

    public override func select(ctx: Object, number: Float64): String {
        if (rules.isNone()) {
            rules = PluralRules.forLocale(msgFormat.ulocale, Type)
        }
        let context = ctx
        let otherIndex = msgFormat.findOtherSubMessage(context.startIndex)
        context.numberArgIndex = msgFormat.findFirstPluralNumberArg(otherIndex, context.argName)
        if (context.numberArgIndex > 0 && msgFormat.cachedFormatters.isSome()) {
            context.formatter = msgFormat.cachedFormatters.get(context.numberArgIndex)
        }
        if (context.formatter.isNone()) {
            context.formatter = msgFormat.getStockNumberFormatter()
            context.forReplaceNumber = true
        }
        if (!(context.number.doubleValue() == number)) {
            throw AssertionError()
        }
        context.numberString = context.formatter.format(context.number)
        if (checkOptionalIs<DecimalFormat, Format>(context.formatter)) {
            let dec = context.formatter.getFixedDecimal(number)
            return rules.select(dec)
        } else {
            return rules.select(number)
        }
    }

    private var msgFormat: MessageFormat

    private var rules: PluralRules

    private var Type: PluralRules_PluralType
}


class MessageFormat_AppendableWrapper {
    public init(sb: StringBuilder) {
        app = sb
        length = Int32(sb.size)
        attributes = None
    }

    public init(sb: StringBuffer) {
        app = sb
        length = Int32(sb.size)
        attributes = None
    }

    public func useAttributes(): Unit {
        attributes = ArrayList<MessageFormat_AttributeAndPosition>()
    }

    public func append(s: String): Unit {
        try {
            app.append(s)
            length += s.size
        } catch (e: IOException) {
            throw ICUUncheckedIOException(e)
        }
    }

    public func append(s: String, start: Int32, limit: Int32): Unit {
        try {
            app.append(s, start, limit)
            length += limit - start
        } catch (e: IOException) {
            throw ICUUncheckedIOException(e)
        }
    }

    public func append(iterator: CharacterIterator): Unit {
        length += appendStatic(app, iterator)
    }

    public static func appendStatic(result: Appendable, iterator: CharacterIterator): Int32 {
        try {
            var start = iterator.getBeginIndex()
            let limit = iterator.getEndIndex()
            let length = limit - start
            if (start < limit) {
                result.append(iterator.first())
                while (match (0) { case _ => start++; start } < limit) {
                    result.append(iterator.next())
                }
            }
            return length
        } catch (e: IOException) {
            throw ICUUncheckedIOException(e)
        }
    }

    public func formatAndAppend(formatter: Format, arg: Object): Unit {
        if (attributes.isNone()) {
            append(formatter.format(arg))
        } else {
            let formattedArg = formatter.formatToCharacterIterator(arg)
            let prevLength = length
            append(formattedArg)
            formattedArg.first()
            var start = formattedArg.getIndex()
            let limit = formattedArg.getEndIndex()
            let offset = prevLength - start
            while (start < limit) {
                let map = formattedArg.getAttributes()
                let runLimit = formattedArg.getRunLimit()
                if (Int32(map.size) != 0) {
                    for (entry in map.entrySet()) {
                        attributes.append(MessageFormat_AttributeAndPosition(entry.getKey(), entry.getValue(), offset + start, offset + runLimit))
                    }
                }
                start = runLimit
                formattedArg.setIndex(start)
            }
        }
    }

    public func formatAndAppend(formatter: Format, arg: Object, argString: String): Unit {
        if (attributes.isNone() && argString.isSome()) {
            append(argString)
        } else {
            formatAndAppend(formatter, arg)
        }
    }

    private var app: Appendable = None

    var length: Int32 = 0

    var attributes: ArrayList<MessageFormat_AttributeAndPosition>
}


class MessageFormat_AttributeAndPosition {
    public init(fieldValue: Object, startIndex: Int32, limitIndex: Int32) {
        initself(MessageFormat_Field.ARGUMENT, fieldValue, startIndex, limitIndex)
    }

    public init(field: AttributedCharacterIterator_Attribute, fieldValue: Object, startIndex: Int32, limitIndex: Int32) {
        initself(field, fieldValue, startIndex, limitIndex)
    }

    public func initself(field: AttributedCharacterIterator_Attribute, fieldValue: Object, startIndex: Int32, limitIndex: Int32): Unit {
        key = field
        value = fieldValue
        start = startIndex
        limit = limitIndex
    }

    var key: AttributedCharacterIterator_Attribute = None

    var value: Object

    var start: Int32 = 0

    var limit: Int32 = 0
}
