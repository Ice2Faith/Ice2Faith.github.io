# jdbc procedure
- 又名 XProc4J (XML Procedure for Java)
- 旨在提供一个基于xml顺序执行的类似存储过程的执行引擎
- 能够在不依赖数据库的情况下运行过程脚本
- 同时作为一个过渡手段，为不熟悉java开发的人员，但熟悉存储过程的开发人员，提供一个中间途径
- 参考mybatis的xml技术，构建在一个xml中按照xml标签定义的顺序执行各个标签的内容的执行引擎

## 技术文档

框架整体文档资料。

- 框架总体架构及功能介绍：[framework.md](./framework.md)
- 框架设计思想：[design.md](./design.md)
- 快速入门手册：[quick-start.md](./quick-start.md)
- Oracle过程转换指南：[procedure.md](./procedure.md)
- 存储过程转换对照指南：[convert-guide.md](./convert-guide.md)
- XML节点定义白皮书：[node-definition.md](./node-definition.md)
- TinyScript语法：[TinyScript.md](./TinyScript.md)
- Funic语法：[Funic.md](./Funic.md)

## 过程文档

框架设计的过程文档，中间文档，补充文档。

- XML节点语法定义参考：[procedure.xml](./procedure.xml)
- XML节点的DTD约束文件：[procedure.dtd](./procedure.dtd)
- 产品对比分析文档：[product-compare.md](./product-compare.md)
- 插件预览：[demo-preview.md](plugin/demo-preview.md)

## 项目地址

- 本文档以及文档中提到的实现代码
- 均在项目地址中可以检索到

**github 源仓库**

- 核心模块：[i2f-jdbc-procedure](https://github.com/Ice2Faith/i2f-turbo-java/tree/main/i2f-jdk/i2f-jdbc-procedure/src/main)
- springboot 启动模块：[i2f-springboot-xproc4j-starter](https://github.com/Ice2Faith/i2f-turbo-java/tree/main/i2f-springboot/i2f-springboot-xproc4j-starter/src/main/java/i2f/springboot/xproc4j)

**gitee 镜像仓库**

- 核心模块：[i2f-jdbc-procedure](https://gitee.com/Ice2Faith/i2f-turbo-java/tree/main/i2f-jdk/i2f-jdbc-procedure/src/main)
- springboot 启动模块：[i2f-springboot-xproc4j-starter](https://gitee.com/Ice2Faith/i2f-turbo-java/tree/main/i2f-springboot/i2f-springboot-xproc4j-starter/src/main/java/i2f/springboot/xproc4j)



---

**文档版本：** 1.0  
**最后更新：** 2026-04-02  
**维护者：** Ice2Faith