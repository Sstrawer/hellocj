package icu4cj.message2



public interface Selector {
    
    func matches(value: Object, keys: ArrayList<String>, variableOptions: Map<String, Object>): ArrayList<String>
}