package icu4cj.impl.number

public interface ModifierStore {
    func getModifier(signum: Modifier_Signum, plural: StandardPlural): Modifier
}