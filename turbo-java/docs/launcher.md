# i2f-launcher — 动态 Classpath 启动器

## 概述

`i2f-launcher` 是项目的 Java 应用动态 Classpath 启动器，参考了 Spring Boot Launcher 的设计思路并进行了简化。核心能力是在
Java 程序启动时加载额外的 classpath 或动态外部 JAR 包，实现插件模式的应用程序。

该模块解决了 Java JAR 包中 `MANIFEST.MF` 写死 classpath 无法运行时动态添加的限制，避免了使用 `java -cp` 需要重写全部
classpath 的繁琐操作。

## 模块信息

| 属性             | 值              |
|----------------|----------------|
| **ArtifactId** | `i2f-launcher` |
| **父模块**        | `i2f-jdk`      |
| **版本**         | `1.0-jdk8`     |
| **包路径**        | `i2f.launcher` |
| **源文件数**       | 2              |
| **外部依赖**       | Lombok         |

## 启动流程

```
命令行 java -jar app.jar
    ↓
执行 ExtApplicationLauncher.main()  ← JAR 的 Main-Class
    ↓
读取配置（系统属性 / Manifest / 默认值）
    ↓
解析 Ext-Path 指定的额外目录
    ↓
递归扫描目录，收集所有 JAR 和目录为 URL
    ↓
创建 ExtClasspathClassLoader（子优先加载策略）
    ↓
设置为线程上下文 ClassLoader
    ↓
反射调用 Ext-Main-Class 指定的真正入口 main() 方法
    ↓
进入实际应用逻辑
```

## 核心类

### ExtApplicationLauncher — 启动器入口

启动器主类，作为 JAR 的 `Main-Class`，负责：

1. **读取配置**：按优先级从 3 个来源获取配置
    - 命令行参数（`key=value`）
    - JVM 系统属性（`-Dkey=value` / `--key=value`）
    - JAR Manifest 属性

2. **解析额外路径**：解析 `Ext-Path` 指定的目录列表（默认 `lib,libs,plugin,plugins,ext-lib,ext-libs`）

3. **递归扫描资源**：
    - 目录本身加入 classpath
    - 目录中的 `.jar` 文件加入 classpath
    - JAR 中嵌套的 `.jar`（`jar:file://...!/...`）也加入 classpath

4. **创建 ClassLoader**：构建 `ExtClasspathClassLoader` 并设置为线程上下文 ClassLoader

5. **反射调用入口**：通过 `Class.forName` + `Method.invoke` 调用真正的 `main()` 方法

**关键常量：**

| 常量    | 系统属性键            | Manifest 键       | 默认值                                        |
|-------|------------------|------------------|--------------------------------------------|
| 真正入口类 | `ext.main.class` | `Ext-Main-Class` | 无（必填）                                      |
| 额外路径  | `ext.path`       | `Ext-Path`       | `lib,libs,plugin,plugins,ext-lib,ext-libs` |

### ExtClasspathClassLoader — 自定义类加载器

继承 `URLClassLoader`，实现**子优先（child-first）**加载策略，与 Java 默认的双亲委派模型相反：

**类加载策略：**

| 类名模式                                                                 | 加载策略                              |
|----------------------------------------------------------------------|-----------------------------------|
| `java.*` / `jdk.*` / `sun.*` / `com.sun.*` / `javax.*` / `jakarta.*` | 直接委派给父加载器（JDK 标准库）                |
| 其他类                                                                  | 优先从本加载器加载（`findClass`），失败时回退到父加载器 |

**资源加载策略：**

| 方法               | 策略                                |
|------------------|-----------------------------------|
| `getResource()`  | 优先本加载器（`findResource`），未找到时回退父加载器 |
| `getResources()` | 合并两者资源，本加载器优先，去重后返回               |

## Maven 打包配置

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-jar-plugin</artifactId>
    <version>3.0.2</version>
    <configuration>
        <archive>
            <manifest>
                <!-- 指定启动器为主入口 -->
                <mainClass>i2f.launcher.ExtApplicationLauncher</mainClass>
                <addClasspath>true</addClasspath>
                <addDefaultImplementationEntries>true</addDefaultImplementationEntries>
                <addDefaultSpecificationEntries>true</addDefaultSpecificationEntries>
            </manifest>
            <manifestEntries>
                <!-- 填写真正的入口 main 类 -->
                <Ext-Main-Class>com.example.Application</Ext-Main-Class>
                <!-- 额外 classpath 目录，多个用逗号分隔 -->
                <Ext-Path>plugins</Ext-Path>
            </manifestEntries>
        </archive>
    </configuration>
</plugin>
```

## 使用场景

1. **插件化应用**：运行时动态加载 `plugins/` 目录下的插件 JAR
2. **SPI 动态加载**：加载 JDBC Driver 等 SPI 组件，无需修改主 JAR
3. **热扩展**：添加新的 JAR 到指定目录即可被加载，无需重新打包
4. **Spring Boot 兼容**：`Ext-Main-Class` 指向 Spring Boot 入口类即可无缝集成

## 源文件清单

| 文件                             | 行数  | 说明                        |
|--------------------------------|-----|---------------------------|
| `ExtApplicationLauncher.java`  | 349 | 启动器入口（配置读取 + 路径扫描 + 反射调用） |
| `ExtClasspathClassLoader.java` | 117 | 自定义 ClassLoader（子优先加载策略）  |

## 设计特点

1. **零外部依赖**：仅依赖 Lombok，纯 JDK API 实现
2. **子优先加载**：自定义 ClassLoader 打破双亲委派，额外 classpath 优先级高于主 JAR
3. **多来源配置**：命令行参数 > JVM 系统属性 > Manifest 属性 > 默认值
4. **递归 JAR 扫描**：支持目录中的 JAR、JAR 中嵌套的 JAR
5. **智能路径解析**：支持相对路径、绝对路径、多种分隔符（逗号/分号/冒号）
6. **Spring Boot 兼容**：参考 Spring Boot Launcher 设计，可无缝集成
