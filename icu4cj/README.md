# ICU4CJ - ICU for Cangjie

这是一个将ICU (International Components for Unicode) Java库转换为Cangjie语言的示例项目。

## 项目结构

```
icu4cj/
├── src/
│   ├── icu/
│   │   └── impl/
│   │       └── PatternProps.cj    # 转换后的PatternProps类
│   └── main.cj                    # 主程序，用于测试PatternProps类
└── README.md                      # 项目说明文档
```

## 转换说明

### PatternProps.java → PatternProps.cj

主要的转换包括：

1. **包声明**: `package com.ibm.icu.impl` → `package icu.impl`
2. **类声明**: `public final class` → `public final class`
3. **方法声明**: `public static boolean` → `public static func ...: Bool`
4. **参数类型**: `int` → `Int64`, `CharSequence` → `String`
5. **数组类型**: `byte[]` → `VArray<Int8, $256>`
6. **循环语法**: `for` → `while`
7. **字符串操作**: `s.charAt(i)` → `s[i]`, `s.length()` → `s.size`
8. **字符串切片**: `s.substring(start, limit)` → `s[start..limit]`

### 主要功能

PatternProps类实现了Unicode的Pattern_Syntax和Pattern_White_Space属性，包括：

- `isSyntax(c)`: 判断字符是否为语法字符
- `isWhiteSpace(c)`: 判断字符是否为空白字符
- `isSyntaxOrWhiteSpace(c)`: 判断字符是否为语法字符或空白字符
- `skipWhiteSpace(s, i)`: 跳过字符串中的空白字符
- `trimWhiteSpace(s)`: 去除字符串首尾的空白字符
- `isIdentifier(s)`: 判断字符串是否为标识符
- `skipIdentifier(s, i)`: 跳过标识符字符

## 编译和运行

### 前提条件

需要安装Cangjie工具链，参考[cangjie文档](cangjie_docs-main/docs/dev-guide/source_zh_cn/first_understanding/install.md)。

### 使用cjpm（推荐）

cjpm是Cangjie的包管理器，提供了完整的项目构建和运行功能。

#### 初始化项目（已配置）

项目已经使用cjpm初始化，可以直接使用以下命令：

```bash
cd icu4cj

# 构建项目
cjpm build

# 运行项目
cjpm run

# 清理构建文件
cjpm clean

# 检查依赖
cjpm check

# 查看依赖树
cjpm tree
```

#### 手动编译

```bash
cd icu4cj
cjc src/icu4cj.cj
```

#### 运行

```bash
./icu4cj
```

### 项目结构说明

项目使用cjpm管理，包含以下文件：

- `cjpm.toml`: cjpm项目配置文件
- `src/icu4cj.cj`: 主要的源代码文件，包含PatternProps类和main函数
- `README.md`: 项目说明文档

## 测试输出

程序会测试PatternProps类的各种功能，包括：

- 语法字符检测
- 空白字符检测
- 字符串修剪
- 标识符验证
- 字符跳过功能

## 注意事项

1. 这是一个示例转换，展示了Java到Cangjie的基本转换模式
2. 某些功能可能需要根据Cangjie语言的具体实现进行调整
3. 数组初始化语法可能需要根据Cangjie编译器版本进行调整

## 扩展

可以继续转换ICU库中的其他类，如：
- 日期时间格式化
- 数字格式化
- 文本处理
- 本地化支持

## 许可证

本项目遵循ICU项目的许可证条款。
