# ICU4J到Cangjie翻译项目 - Cursor规则

## 项目背景
本项目旨在将ICU4J（Java版本的International Components for Unicode）翻译为Cangjie语言。

## cangjie规则
- cangjie语言开发者文档:https://gitcode.com/Cangjie/cangjie_docs
- cangjie语言运行时与标准库:https://gitcode.com/Cangjie/cangjie_runtime

## 项目结构规则

### 1. 使用cjpm项目管理
- **必须使用cjpm**：所有代码都应该在标准的cjpm项目结构中
- **目录结构**：
  ```
  icu4cj/
  ├── cjpm.toml          # 项目配置
  ├── src/               # 源代码目录 package:icu4cj
  │   ├── Cangjie类名.cj # 核心类
  │   └── testcase       # 测试包 package:icu4cj.testcase
  │     └── Cangjie类名_test.cj      # 测试文件
  ```
- **包名规范**：根据目录层级

### 2. 文件命名和组织
- **源码文件**：Java类名.java -> Cangjie类名.cj
- **测试文件**：必须以`_test.cj`结尾
- 每个包都应有一个testcase的子包,存放此包的用例
- 原则上icu4cj/src下的目录分级应与src/main/java/com/ibm/icu一致
- 不允许空包,可以添加一个package.cj文件避免编译报错
- 父包不要引用子包,同级包可以互相引用,但包之间不能循环引用,遇到循环依赖就把class放入上级包
- cangjie子包能直接引用父包中默认作用域的class/function,这有利于减少暴露

### 内部类
- cangjie不支持内部类,将翻译后的内部类与父类一起放在同一文件中

## 测试编写规则

### 1. 测试函数命名
- **必须以`test_`开头**
- **添加`@Test`注解**
- **函数签名**：`func test_功能名(): Unit`

### 2. 断言使用
```cangjie
@Test
func test_basic_functionality(): Unit {
    @Assert(PatternProps.isSyntax(40))  // '(' 是语法字符
    @Assert(!PatternProps.isSyntax(97)) // 'a' 不是语法字符
}
```

### 3. UTF-8测试
必须包含多字节字符测试：
```cangjie
@Test
func test_utf8_characters(): Unit {
    @Assert(PatternProps.isIdentifier("你好世界"))
    @Assert(!PatternProps.isIdentifier("Hello@世界"))
}
```

## 项目构建和测试

### 1. 基本命令
```bash
# 增量构建项目
cjpm build -i

# 运行测试
cjpm test
```

### 2. 调试流程
1. **编译错误**：先解决语法问题
2. **链接错误**：检查包名和导入
3. **测试失败**：检查断言逻辑和UTF-8处理
4. **运行时错误**：检查类型转换和边界条件

## 翻译优先级

- 分析java类的依赖关系,从底层类开始
- 略过完全没有被引用的类
- 暂时不生成用例

## 质量保证

### 1. 代码质量
- **完整性**：保留原有功能
- **正确性**：通过所有测试用例
- **性能**：合理的执行效率
- **可读性**：清晰的代码结构

### 2. 测试覆盖
- **基本功能测试**：核心方法的正确性
- **边界条件测试**：极值和异常情况
- **Unicode测试**：多语言字符支持
- **UTF-8特定测试**：编码转换正确性

## 注意事项

1. **严格遵循UTF-8处理规则**：这是项目成功的关键
2. **保持与原Java代码的功能一致性**
3. **充分测试Unicode字符处理能力**
4. **遵循Cangjie语言最佳实践**
5. **维护清晰的项目结构和文档**

---

*此规则文档基于icu4cj项目的实际开发经验总结，持续更新中。*
