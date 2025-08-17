package icu4cj.message2



public class MFFunctionRegistry {
    let formattersMap: Map<String, FormatterFactory>

    let selectorsMap: Map<String, SelectorFactory>

    let classToFormatter: Map<ClassTypeInfo, String>

    init(builder: MFFunctionRegistry_Builder) {
        this.formattersMap = HashMap<String, FormatterFactory>(builder.formattersMap)
        this.selectorsMap = HashMap<String, SelectorFactory>(builder.selectorsMap)
        this.classToFormatter = HashMap<ClassTypeInfo, String>(builder.classToFormatter) as Map<ClassTypeInfo, String>
    }

    
    public static func builder(): MFFunctionRegistry_Builder {
        return MFFunctionRegistry_Builder()
    }

    
    public func getFormatter(formatterName: String): FormatterFactory {
        return formattersMap.get(formatterName)
    }

    
    public func getFormatterNames(): Set<String> {
        return SetCollectionView<String>(formattersMap.keys())
    }

    
    public func getDefaultFormatterNameForType(clazz: ClassTypeInfo): String {
        let result = classToFormatter.get(clazz)
        if (result.isSome()) {
            return result
        }
        for (e in classToFormatter.entrySet()) {
            if (e.getKey().isAssignableFrom(clazz)) {
                return e.getValue()
            }
        }
        return None
    }

    
    public func getDefaultFormatterTypes(): Set<ClassTypeInfo> {
        return // Мapping is present but failed: SetCollectionView<ClassTypeInfo>(classToFormatter.keys()) as Set<ClassTypeInfo>
    }

    
    public func getSelector(selectorName: String): SelectorFactory {
        return selectorsMap.get(selectorName)
    }

    
    public func getSelectorNames(): Set<String> {
        return SetCollectionView<String>(selectorsMap.keys())
    }
}



public class MFFunctionRegistry_Builder {
    let formattersMap: Map<String, FormatterFactory> = HashMap<String, FormatterFactory>()

    let selectorsMap: Map<String, SelectorFactory> = HashMap<String, SelectorFactory>()

    let classToFormatter = HashMap<ClassTypeInfo, String>()


    
    public func addAll(functionRegistry: MFFunctionRegistry): MFFunctionRegistry_Builder {
        formattersMap.putAll(functionRegistry.formattersMap)
        selectorsMap.putAll(functionRegistry.selectorsMap)
        classToFormatter.putAll(functionRegistry.classToFormatter)
        return this
    }

    
    public func setFormatter(formatterName: String, formatterFactory: FormatterFactory): MFFunctionRegistry_Builder {
        formattersMap.put(formatterName, formatterFactory)
        return this
    }

    
    public func removeFormatter(formatterName: String): MFFunctionRegistry_Builder {
        formattersMap.remove(formatterName)
        return this
    }

    
    public func clearFormatters(): MFFunctionRegistry_Builder {
        formattersMap.clear()
        return this
    }

    
    public func setDefaultFormatterNameForType(clazz: ClassTypeInfo, formatterName: String): MFFunctionRegistry_Builder {
        classToFormatter.put(clazz, formatterName)
        return this
    }

    
    public func removeDefaultFormatterNameForType(clazz: ClassTypeInfo): MFFunctionRegistry_Builder {
        classToFormatter.remove(clazz)
        return this
    }

    
    public func clearDefaultFormatterNames(): MFFunctionRegistry_Builder {
        classToFormatter.clear()
        return this
    }

    
    public func setSelector(selectorName: String, selectorFactory: SelectorFactory): MFFunctionRegistry_Builder {
        selectorsMap.put(selectorName, selectorFactory)
        return this
    }

    
    public func removeSelector(selectorName: String): MFFunctionRegistry_Builder {
        selectorsMap.remove(selectorName)
        return this
    }

    
    public func clearSelectors(): MFFunctionRegistry_Builder {
        selectorsMap.clear()
        return this
    }

    
    public func build(): MFFunctionRegistry {
        return MFFunctionRegistry(this)
    }
}
