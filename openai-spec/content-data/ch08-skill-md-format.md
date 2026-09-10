---
name: search_website
description: 调用搜索引擎检索实时网页信息
tags: [search, web]
version: 1.0.0
---

# 网站搜索技能

## 何时使用
当用户询问实时信息、新闻、天气……

## 使用步骤
1. 调用 run_skill_script，脚本路径 script/search.py
2. 解析返回的 JSON 结果并归纳回答