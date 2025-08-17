package icu4cj.text


public class MessagePatternUtil {

    public static func buildMessageNode(patternString: String): MessagePatternUtil_MessageNode {
        return buildMessageNode(MessagePattern(patternString))
    }

    public static func buildMessageNode(pattern: MessagePattern): MessagePatternUtil_MessageNode {
        let limit = pattern.countParts() - 1
        if (limit < 0) {
            throw IllegalArgumentException("The MessagePattern is empty")
        } else if (!refEq(pattern.getPartType(0), MessagePattern_Part_Type.MSG_START)) {
            throw IllegalArgumentException("The MessagePattern does not represent a MessageFormat pattern")
        }
        return buildMessageNode(pattern, 0, limit)
    }

    private static func buildMessageNode(pattern: MessagePattern, start: Int32, limit: Int32): MessagePatternUtil_MessageNode {
        var prevPatternIndex = pattern.getPart(start).getLimit()
        let node = MessagePatternUtil_MessageNode()
        var i = start + 1
        while (true) {
            var part = pattern.getPart(i)
            let patternIndex = part.getIndex()
            if (prevPatternIndex < patternIndex) {
                node.addContentsNode(MessagePatternUtil_TextNode(pattern.getPatternString()[Int64(prevPatternIndex)..Int64(patternIndex)]))
            }
            if (i == limit) {
                break
            }
            let partType = part.getType()
            if (refEq(partType, MessagePattern_Part_Type.ARG_START)) {
                let argLimit = pattern.getLimitPartIndex(i)
                node.addContentsNode(buildArgNode(pattern, i, argLimit))
                i = argLimit
                part = pattern.getPart(i)
            } else if (refEq(partType, MessagePattern_Part_Type.REPLACE_NUMBER)) {
                node.addContentsNode(MessagePatternUtil_MessageContentsNode.createReplaceNumberNode())
            }
            prevPatternIndex = part.getLimit()
            i++
        }
        return node.freeze()
    }

    private static func buildArgNode(pattern: MessagePattern, start: Int32, limit: Int32): MessagePatternUtil_ArgNode {
        var tempstart = start
        let node = MessagePatternUtil_ArgNode.createArgNode()
        var part = pattern.getPart(tempstart)
        let argType = match (0) { case _ => node.argType = part.getArgType(); node.argType }
        part = pattern.getPart(match (0) { case _ => tempstart++; tempstart })
        node.name = pattern.getSubstring(part)
        if (refEq(part.getType(), MessagePattern_Part_Type.ARG_NUMBER)) {
            node.number = part.getValue()
        }
        tempstart++
        match (argType) {
            case MessagePattern_ArgType.SIMPLE =>
                node.typeName = pattern.getSubstring(pattern.getPart(match (0) { case _ => tempstart++; tempstart - 1 }))
                if (tempstart < limit) {
                    node.style = pattern.getSubstring(pattern.getPart(tempstart))
                }
            case MessagePattern_ArgType.CHOICE =>
                node.typeName = "choice"
                node.complexStyle = buildChoiceStyleNode(pattern, tempstart, limit)
            case MessagePattern_ArgType.PLURAL =>
                node.typeName = "plural"
                node.complexStyle = buildPluralStyleNode(pattern, tempstart, limit, argType)
            case MessagePattern_ArgType.SELECT =>
                node.typeName = "select"
                node.complexStyle = buildSelectStyleNode(pattern, tempstart, limit)
            case MessagePattern_ArgType.SELECTORDINAL =>
                node.typeName = "selectordinal"
                node.complexStyle = buildPluralStyleNode(pattern, tempstart, limit, argType)
            case _ => ()
        }
        return node
    }

    private static func buildChoiceStyleNode(pattern: MessagePattern, start: Int32, limit: Int32): MessagePatternUtil_ComplexArgStyleNode {
        var tempstart = start
        let node = MessagePatternUtil_ComplexArgStyleNode(MessagePattern_ArgType.CHOICE)
        while (tempstart < limit) {
            let valueIndex = tempstart
            let part = pattern.getPart(tempstart)
            let value = pattern.getNumericValue(part)
            tempstart += 2
            let msgLimit = pattern.getLimitPartIndex(tempstart)
            let variant = MessagePatternUtil_VariantNode()
            variant.selector = pattern.getSubstring(pattern.getPart(valueIndex + 1))
            variant.numericValue = value
            variant.msgNode = buildMessageNode(pattern, tempstart, msgLimit)
            node.addVariant(variant)
            tempstart = msgLimit + 1
        }
        return node.freeze()
    }

    private static func buildPluralStyleNode(pattern: MessagePattern, start: Int32, limit: Int32, argType: MessagePattern_ArgType): MessagePatternUtil_ComplexArgStyleNode {
        var tempstart = start
        let node = MessagePatternUtil_ComplexArgStyleNode(argType)
        let offset = pattern.getPart(tempstart)
        if (offset.getType().hasNumericValue()) {
            node.explicitOffset = true
            node.offset = pattern.getNumericValue(offset)
            tempstart++
        }
        while (tempstart < limit) {
            let selector = pattern.getPart(match (0) { case _ => tempstart++; tempstart - 1 })
            var value = MessagePattern.NO_NUMERIC_VALUE
            let part = pattern.getPart(tempstart)
            if (part.getType().hasNumericValue()) {
                value = pattern.getNumericValue(part)
                tempstart++
            }
            let msgLimit = pattern.getLimitPartIndex(tempstart)
            let variant = MessagePatternUtil_VariantNode()
            variant.selector = pattern.getSubstring(selector)
            variant.numericValue = value
            variant.msgNode = buildMessageNode(pattern, tempstart, msgLimit)
            node.addVariant(variant)
            tempstart = msgLimit + 1
        }
        return node.freeze()
    }

    private static func buildSelectStyleNode(pattern: MessagePattern, start: Int32, limit: Int32): MessagePatternUtil_ComplexArgStyleNode {
        var tempstart = start
        let node = MessagePatternUtil_ComplexArgStyleNode(MessagePattern_ArgType.SELECT)
        while (tempstart < limit) {
            let selector = pattern.getPart(match (0) { case _ => tempstart++; tempstart - 1 })
            let msgLimit = pattern.getLimitPartIndex(tempstart)
            let variant = MessagePatternUtil_VariantNode()
            variant.selector = pattern.getSubstring(selector)
            variant.msgNode = buildMessageNode(pattern, tempstart, msgLimit)
            node.addVariant(variant)
            tempstart = msgLimit + 1
        }
        return node.freeze()
    }
}


public class MessagePatternUtil_Node {
}


public class MessagePatternUtil_MessageNode <: MessagePatternUtil_Node {
    public func getContents(): ArrayList<MessagePatternUtil_MessageContentsNode> {
        return list
    }

    public override func toString(): String {
        return toString(list)
    }

    init() {
        super()
    }

    public func addContentsNode(node: MessagePatternUtil_MessageContentsNode): Unit {
        if (checkOptionalIs<MessagePatternUtil_TextNode, MessagePatternUtil_MessageContentsNode>(node) && !list.isEmpty()) {
            let lastNode = list[Int64(Int32(list.size) - 1)]
            if (checkOptionalIs<MessagePatternUtil_TextNode, MessagePatternUtil_MessageContentsNode>(lastNode)) {
                let textNode = lastNode
                textNode.text = (textNode.text) + (node.text)
                return
            }
        }
        list.append(node)
    }

    public func freeze(): MessagePatternUtil_MessageNode {
        list = Collections.unmodifiableList(list)
        return this
    }

     private var list: ArrayList<MessagePatternUtil_MessageContentsNode> = ArrayList<MessagePatternUtil_MessageContentsNode>()
}


public class MessagePatternUtil_MessageContentsNode <: MessagePatternUtil_Node {
    public func getType(): MessagePatternUtil_MessageContentsNode_Type {
        return Type
    }

    public override func toString(): String {
        return "{REPLACE_NUMBER}"
    }

    init(Type: MessagePatternUtil_MessageContentsNode_Type) {
        super()
        this.Type = Type
    }

    static func createReplaceNumberNode(): MessagePatternUtil_MessageContentsNode {
        return MessagePatternUtil_MessageContentsNode(MessagePatternUtil_MessageContentsNode_Type.REPLACE_NUMBER)
    }

    private var Type: MessagePatternUtil_MessageContentsNode_Type
}


public class MessagePatternUtil_MessageContentsNode_Type <: Enum<MessagePatternUtil_MessageContentsNode_Type> {
    public static let TEXT = MessagePatternUtil_MessageContentsNode_Type("TEXT", 0)

    public static let ARG = MessagePatternUtil_MessageContentsNode_Type("ARG", 1)

    public static let REPLACE_NUMBER = MessagePatternUtil_MessageContentsNode_Type("REPLACE_NUMBER", 2)

    private static func _values(): Array<MessagePatternUtil_MessageContentsNode_Type> {
        return [MessagePatternUtil_MessageContentsNode_Type.TEXT, MessagePatternUtil_MessageContentsNode_Type.ARG, MessagePatternUtil_MessageContentsNode_Type.REPLACE_NUMBER]
    }

    private static let _VALUES = MessagePatternUtil_MessageContentsNode_Type._values()

    public static func values(): Array<MessagePatternUtil_MessageContentsNode_Type> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): MessagePatternUtil_MessageContentsNode_Type {
        return (TypeInfo.of<MessagePatternUtil_MessageContentsNode_Type>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as MessagePatternUtil_MessageContentsNode_Type
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class MessagePatternUtil_TextNode <: MessagePatternUtil_MessageContentsNode {
    public func getText(): String {
        return text
    }

    public override func toString(): String {
        return "\u{00ab}" + (text) + "\u{00bb}"
    }

    init(text: String) {
        super(MessagePatternUtil_MessageContentsNode_Type.TEXT)
        this.text = text
    }

    var text: String
}


public class MessagePatternUtil_ArgNode <: MessagePatternUtil_MessageContentsNode {
    public func getArgType(): MessagePattern_ArgType {
        return argType
    }

    public func getName(): String {
        return name
    }

    public func getNumber(): Int32 {
        return number
    }

    public func getTypeName(): String {
        return typeName
    }

    public func getSimpleStyle(): String {
        return style
    }

    public func getComplexStyle(): MessagePatternUtil_ComplexArgStyleNode {
        return complexStyle
    }

    public override func toString(): String {
        let sb = StringBuilder()
        sb.append('{').append(name)
        if (!refEq(argType, MessagePattern_ArgType.NONE)) {
            sb.append(',').append(typeName)
            if (refEq(argType, MessagePattern_ArgType.SIMPLE)) {
                if (style.isSome()) {
                    sb.append(',').append(style)
                }
            } else {
                sb.append(',').append(complexStyle.toString())
            }
        }
        return sb.append('}').toString()
    }

    private init() {
        super(MessagePatternUtil_MessageContentsNode_Type.ARG)
    }

    static func createArgNode(): MessagePatternUtil_ArgNode {
        return MessagePatternUtil_ArgNode()
    }

    var argType: MessagePattern_ArgType

    var name: String

    var number = -1

    var typeName: String

    var style: String

    var complexStyle: MessagePatternUtil_ComplexArgStyleNode
}


public class MessagePatternUtil_ComplexArgStyleNode <: MessagePatternUtil_Node {
    public func getArgType(): MessagePattern_ArgType {
        return argType
    }

    public func hasExplicitOffset(): Bool {
        return explicitOffset
    }

    public func getOffset(): Float64 {
        return offset
    }

    public func getVariants(): ArrayList<MessagePatternUtil_VariantNode> {
        return list
    }

    public func getVariantsByType(numericVariants: ArrayList<MessagePatternUtil_VariantNode>, keywordVariants: ArrayList<MessagePatternUtil_VariantNode>): MessagePatternUtil_VariantNode {
        if (numericVariants.isSome()) {
            numericVariants.clear()
        }
        keywordVariants.clear()
        var other: MessagePatternUtil_VariantNode
        for (variant in list) {
            if (variant.isSelectorNumeric()) {
                numericVariants.append(variant)
            } else if ("other".equals(variant.getSelector())) {
                if (other.isNone()) {
                    other = variant
                }
            } else {
                keywordVariants.append(variant)
            }
        }
        return other
    }

    public override func toString(): String {
        let sb = StringBuilder()
        sb.append('(').append(argType.toString()).append(" style) ")
        if (hasExplicitOffset()) {
            sb.append("offset:").append(offset).append(' ')
        }
        return sb.append(toString(list)).toString()
    }

    init(argType: MessagePattern_ArgType) {
        super()
        this.argType = argType
    }

    public func addVariant(variant: MessagePatternUtil_VariantNode): Unit {
        list.append(variant)
    }

    public func freeze(): MessagePatternUtil_ComplexArgStyleNode {
        list = Collections.unmodifiableList(list)
        return this
    }

    private var argType: MessagePattern_ArgType

    var offset: Float64 = 0.0

    var explicitOffset: Bool = false

     private var list: ArrayList<MessagePatternUtil_VariantNode> = ArrayList<MessagePatternUtil_VariantNode>()
}


public class MessagePatternUtil_VariantNode <: MessagePatternUtil_Node {
    public func getSelector(): String {
        return selector
    }

    public func isSelectorNumeric(): Bool {
        return numericValue != MessagePattern.NO_NUMERIC_VALUE
    }

    public func getSelectorValue(): Float64 {
        return numericValue
    }

    public func getMessage(): MessagePatternUtil_MessageNode {
        return msgNode
    }

    public override func toString(): String {
        let sb = StringBuilder()
        if (isSelectorNumeric()) {
            sb.append(numericValue).append(" (").append(selector).append(") {")
        } else {
            sb.append(selector).append(" {")
        }
        return sb.append(msgNode.toString()).append('}').toString()
    }

    init() {
        super()
    }

    var selector: String

    var numericValue = MessagePattern.NO_NUMERIC_VALUE

    var msgNode: MessagePatternUtil_MessageNode
}
