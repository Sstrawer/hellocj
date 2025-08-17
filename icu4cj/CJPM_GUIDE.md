# ICU4CJ cjpm 使用指南

本指南介绍如何使用Cangjie包管理器(cjpm)来管理ICU4CJ项目。

## cjpm 简介

cjpm是Cangjie语言的官方包管理器，提供了完整的项目构建、依赖管理和运行功能。

## 主要命令

### 项目初始化
```bash
cjpm init --name icu4cj --type=executable
```

### 构建项目
```bash
cjpm build
```
- 编译源代码
- 生成可执行文件
- 处理依赖关系

### 运行项目
```bash
cjpm run
```
- 自动构建（如果需要）
- 运行可执行文件

### 项目维护
```bash
cjpm check      # 检查依赖关系
cjpm tree       # 显示依赖树
cjpm clean      # 清理构建文件
```

## 项目结构

```
icu4cj/
├── cjpm.toml          # 项目配置文件
├── cjpm.lock          # 依赖锁定文件
├── src/
│   └── icu4cj.cj     # 源代码
├── target/            # 构建输出目录
│   └── release/
│       └── bin/      # 可执行文件
└── README.md          # 项目说明
```

## 工作流程

1. **开发阶段**
   - 编辑 `src/icu4cj.cj`
   - 使用 `cjpm build` 编译
   - 使用 `cjpm run` 测试

2. **调试阶段**
   - 使用 `cjpm clean` 清理
   - 重新构建和运行

3. **发布阶段**
   - 确保所有测试通过
   - 使用 `cjpm build` 生成最终版本

## 优势

- **自动化构建**: 无需手动指定编译参数
- **依赖管理**: 自动处理项目依赖
- **缓存优化**: 智能缓存提高构建速度
- **标准化**: 遵循Cangjie项目标准

## 故障排除

### 常见问题

1. **构建失败**
   - 检查源代码语法
   - 确认包名正确
   - 使用 `cjpm clean` 清理后重试

2. **依赖问题**
   - 使用 `cjpm check` 检查依赖
   - 查看 `cjpm tree` 输出

3. **运行错误**
   - 检查main函数是否存在
   - 确认输出类型设置正确

## 示例

查看 `test_cjpm.sh` 脚本了解完整的工作流程演示。
