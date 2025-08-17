# ICU4CJ 项目结构

本项目已经重新组织，遵循专业的软件工程最佳实践，将源码、测试类和main函数分离。

## 📁 项目结构

```
icu4cj/
├── src/                    # 源码目录
│   └── icu/
│       └── impl/
│           └── PatternProps.cj    # 核心实现类
├── tests/                  # 测试目录
│   └── test_pattern.cj     # 测试套件
├── examples/               # 示例目录
│   └── main.cj            # 演示程序
├── cjpm.toml              # 项目配置文件
├── README.md               # 项目说明
├── CJPM_GUIDE.md          # cjpm使用指南
└── PROJECT_STRUCTURE.md   # 本文档
```

## 🔧 各组件说明

### 1. 源码 (src/)
- **位置**: `src/icu/impl/PatternProps.cj`
- **内容**: 纯业务逻辑，不包含main函数
- **职责**: 实现ICU PatternProps的核心功能
- **特点**: 可重用、可测试、无副作用

### 2. 测试 (tests/)
- **位置**: `tests/test_pattern.cj`
- **内容**: 单元测试和集成测试
- **职责**: 验证源码的正确性
- **特点**: 自动化测试、覆盖所有功能

### 3. 示例 (examples/)
- **位置**: `examples/main.cj`
- **内容**: 演示程序和实际使用示例
- **职责**: 展示如何使用PatternProps类
- **特点**: 教学性质、实际应用场景

## 🚀 使用方法

### 编译源码
```bash
cjc src/icu/impl/PatternProps.cj
```

### 运行测试
```bash
cjc tests/test_pattern.cj src/icu/impl/PatternProps.cj
./main
```

### 运行示例
```bash
cjc examples/main.cj src/icu/impl/PatternProps.cj
./main
```

## 💡 设计优势

### 1. **关注点分离**
- 源码专注于业务逻辑
- 测试专注于验证功能
- 示例专注于使用演示

### 2. **可维护性**
- 代码结构清晰
- 职责明确
- 易于扩展

### 3. **可重用性**
- 源码可以被多个程序使用
- 测试可以独立运行
- 示例可以作为模板

### 4. **专业标准**
- 符合软件工程最佳实践
- 便于团队协作
- 支持持续集成

## 🔄 开发工作流

1. **开发阶段**: 在 `src/` 中编写业务逻辑
2. **测试阶段**: 在 `tests/` 中编写和运行测试
3. **演示阶段**: 在 `examples/` 中创建使用示例
4. **发布阶段**: 确保所有测试通过，示例正常运行

## 📚 扩展建议

- 可以添加更多测试用例
- 可以创建更多使用示例
- 可以添加性能测试
- 可以添加文档生成工具

这种结构使得项目更加专业、可维护，并且符合现代软件开发的标准化要求。
