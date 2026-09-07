/**
 * i2f-springboot-ops-starter · OpenAI 子系统技术全景
 * 数据层：导航、统计、章节元数据
 */
function getSpecData() {
    return {
        nav: [
            { id: 'ch01', no: '01', title: '概述' },
            { id: 'ch02', no: '02', title: '设计理念' },
            { id: 'ch03', no: '03', title: '分层架构' },
            { id: 'ch04', no: '04', title: '核心对话流程' },
            { id: 'ch05', no: '05', title: 'Re-Act 循环' },
            { id: 'ch06', no: '06', title: '消息模型' },
            { id: 'ch07', no: '07', title: '工具体系' },
            { id: 'ch08', no: '08', title: '技能系统' },
            { id: 'ch09', no: '09', title: 'RAG · 记忆系统' },
            { id: 'ch10', no: '10', title: 'MCP 动态工具 · 意图推荐' },
            { id: 'ch11', no: '11', title: '安全体系' },
            { id: 'ch12', no: '12', title: '高级特性' },
            { id: 'ch13', no: '13', title: '自动装配' },
            { id: 'ch14', no: '14', title: '前端工程' },
            { id: 'ch15', no: '15', title: '扩展指南' }
        ],
        stats: [
            { count: 49, label: 'Java 源文件', color: '#e8590c' },
            { count: 22, label: '内置工具类', color: '#0b7285' },
            { count: 16, label: '回显消息类型', color: '#2b8a3e' },
            { count: 8, label: 'REST 端点', color: '#1971c2' },
            { count: 22, label: '角色预设 (Role)', color: '#e67700' },
            { count: 4, label: 'AiModel 实现', color: '#c92a2a' }
        ],
        chapters: [
            { id: 'ch01', no: '01', en: 'Overview', title: '概述：运维控制台里的 AI 心脏' },
            { id: 'ch02', no: '02', en: 'Design Philosophy', title: '设计理念' },
            { id: 'ch03', no: '03', en: 'Layered Architecture', title: '分层架构' },
            { id: 'ch04', no: '04', en: 'Conversation Pipeline', title: '核心对话流程' },
            { id: 'ch05', no: '05', en: 'Re-Act Loop', title: 'Re-Act 循环：Agent 的心脏' },
            { id: 'ch06', no: '06', en: 'Message Model', title: '消息模型与回显协议' },
            { id: 'ch07', no: '07', en: 'Function Calling', title: '工具体系：注解驱动的能力池' },
            { id: 'ch08', no: '08', en: 'Skill System', title: '技能系统：懒加载的领域知识包' },
            { id: 'ch09', no: '09', en: 'RAG Pipeline & Memory', title: 'RAG 知识库 · 记忆系统：向量检索与三级记忆' },
            { id: 'ch10', no: '10', en: 'MCP Dynamic Tools', title: 'MCP 动态工具：三步发现 + LRU 装载 + 意图推荐' },
            { id: 'ch11', no: '11', en: 'SM Crypto Transfer', title: '安全体系：国密全链路传输' },
            { id: 'ch12', no: '12', en: 'Advanced Features', title: '高级特性：让对话长出记忆与手脚' },
            { id: 'ch13', no: '13', en: 'Auto Configuration', title: '自动装配：一个依赖即一个工作台' },
            { id: 'ch14', no: '14', en: 'Fat Client', title: '前端工程：浏览器里的 Agent 状态机' },
            { id: 'ch15', no: '15', en: 'Extension Guide', title: '扩展指南：三步接入一个新工具' }
        ],
        meta: [
            { k: 'Maven 坐标', v: 'i2f.turbo : i2f-springboot-ops-starter' },
            { k: '版本 / 基线', v: '1.0-jdk8 · Java 8', acc: true },
            { k: '运行框架', v: 'Spring Boot 2.7.18' },
            { k: '子系统包名', v: 'i2f.springboot.ops.openai' },
            { k: '访问入口', v: '/ops/open-ai/index.html' },
            { k: '安全传输', v: 'SM2 · SM3 · SM4 国密', acc: true }
        ]
    };
}