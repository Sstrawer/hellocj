package icu4cj.impl.number

public class Properties <: Serializable {

    private static let serialVersionUID = 4095518955889349243

     private var instance: DecimalFormatProperties

    public func getInstance(): DecimalFormatProperties {
        return instance
    }

    private func readObject(ois: ObjectInputStream): Unit {
        if (instance.isNone()) {
            instance = DecimalFormatProperties()
        }
        instance.readObjectImpl(ois)
    }

    private func writeObject(oos: ObjectOutputStream): Unit {
        if (instance.isNone()) {
            instance = DecimalFormatProperties()
        }
        instance.writeObjectImpl(oos)
    }
}
