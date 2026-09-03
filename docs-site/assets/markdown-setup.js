function setupMarkdown() {
    // 初始化 markdown-it
    let md = (typeof markdownit === 'function') ? markdownit({
        html: false,        // 禁止原始 HTML 防止 XSS
        linkify: true,      // 自动识别 URL
        typographer: true,  // 智能标点替换
        breaks: true,       // \n 转为 <br>
        highlight: function (str, lang) {
            if (!lang || lang == '' || lang.trim() == '') {
                lang = 'text';
            }

            let innerHtml = '';
            let actionsHtml = '';
            let lineNumbersHtml = ''; // 新增：行号 HTML

            if (lang == 'mermaid') {

                let chartId = 'mermaid_' + new Date().getTime() + '_' + Math.random().toString(16).substring(2);
                innerHtml = `<div id="${chartId}" class="rich-code-block mermaid-code-block"></div>`;
                actionsHtml = ``;
                let count = 10;
                let applyFunc = () => {
                    let dom = document.querySelector('#' + chartId);
                    if (!dom && count > 0) {
                        count--;
                        setTimeout(applyFunc, 300);
                        return;
                    }

                    if (!dom) {
                        return;
                    }
                    dom.chartCode = str;

                    let graph = str.trim();
                    renderMermaid(dom, graph)
                };
                setTimeout(applyFunc, 300);
            } else if (lang && hljs.getLanguage(lang)) {
                // 检查语言是否受支持
                try {
                    innerHtml = hljs.highlight(str, {language: lang}).value;
                    // 新增：生成行号
                    const lines = str.split('\n');
                    // 如果末尾是空行（highlight.js 常见行为），去掉最后一行空行号
                    if (lines[lines.length - 1].trim() === '') {
                        lines.pop();
                    }
                    lineNumbersHtml = lines.map((_, i) => {
                        return `<span class="line-number">${i + 1}</span>`;
                    }).join('');
                } catch (__) {
                }
            } else {
                innerHtml = md.utils.escapeHtml(str);
                // 新增：纯文本也生成行号
                const lines = str.split('\n');
                if (lines[lines.length - 1].trim() === '') {
                    lines.pop();
                }
                lineNumbersHtml = lines.map((_, i) => {
                    return `<span class="line-number">${i + 1}</span>`;
                }).join('');
            }

            // 新增：mermaid 不显示行号，其他语言显示
            const lineNumbersBlock = (lang !== 'mermaid' && lineNumbersHtml)
                ? `<div class="markdown-code-lines">${lineNumbersHtml}</div>`
                : '';

            // 修改：在 <pre> 内部加入行号列
            /*language=html*/
            let text = `
            <div class="markdown-code-block">
                <div class="markdown-code-header">
                    <span class="markdown-header-lang">{{lang}}</span>
                    <span class="markdown-header-actions">
                        {{actionsHtml}}
                        <span class="code-action-btn" onclick="onSaveMarkdownCodeBlock(event,'${lang}')" title="保存">&#x2B07;&#xFE0F;</span>
                        <span class="code-action-btn" onclick="onCopyMarkdownCodeBlock(event,'${lang}')" title="复制">&#128203;</span>
                    </span>
                </div>
                <pre class="hljs markdown-code-body">
                    {{lineNumbersBlock}}<code>{{innerHtml}}</code>
                </pre>
            </div>`;
            text = text.replaceAll(/\s*\n\s*/g, '');
            text = text.replaceAll('{{lang}}', lang);
            text = text.replaceAll('{{innerHtml}}', innerHtml);
            text = text.replaceAll('{{actionsHtml}}', actionsHtml);
            text = text.replaceAll('{{lineNumbersBlock}}', lineNumbersBlock);
            return text;
        }
    }) : null;
    if (window.texmath && window.katex) {
        // 集成 katex 显示公式
        md.use(window.texmath, {
            engine: window.katex,     // 明确指定使用 KaTeX 作为渲染引擎
            delimiters: 'dollars',     // 使用 $...$ 和 $$...$$ 语法
            katexOptions: {
                strict: false,       // 关闭严格模式，不再抛出 LaTeX 兼容性警告
                throwOnError: false  // 遇到真正的语法错误时不抛出异常，防止页面崩溃
            }
        });
    }
    return md;
}

window.$md=setupMarkdown()

function renderMarkdown(content) {
    if (!content) {
        return '';
    }
    if (!window.$md) {
        return content.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    }
    try {
        return window.$md.render(content);
    } catch (e) {
        return content;
    }
}


function getMarkdownCodeBlockText(event) {
    return new Promise((resolve, reject) => {
        let searchDom = event.target;
        let findDom = null;
        let level = 10;
        while (searchDom) {
            if (level <= 0) {
                break;
            }
            findDom = searchDom.querySelector('.markdown-code-body');
            if (findDom) {
                break;
            }
            searchDom = searchDom.parentElement;
            level--;
        }
        if (!findDom) {
            reject('未找到代码块')
            return;
        }
        let text = findDom.innerText;
        let echartDom = findDom.querySelector('.rich-code-block');
        if (echartDom) {
            text = echartDom.chartCode;
        }
        resolve(text);
    })
}

function onCopyMarkdownCodeBlock(event, lang) {
    getMarkdownCodeBlockText(event).then(text => {
        copy2clipboard(text);
    }).catch(() => {
        window.app.$message.error('未找到代码块，复制失败')
    })
}

function onSaveMarkdownCodeBlock(event, lang) {
    getMarkdownCodeBlockText(event).then(text => {
        // 创建 Blob 并触发下载
        const blob = new Blob([text], {type: 'plain/text;charset=utf-8'});
        const url = URL.createObjectURL(blob);

        const link = document.createElement('a');
        link.href = url;
        link.download = (lang || 'text') + '_' + new Date().getTime() + '.txt';
        link.click();

        // 清理内存
        URL.revokeObjectURL(url);
    }).catch(() => {
        window.app.$message.error('未找到代码块，保存失败')
    })
}


function copy2clipboard(text) {
    const textarea = document.createElement("textarea");
    textarea.value = text;
    // 将元素移出可视区域，避免页面闪烁或滚动
    textarea.style.position = "fixed";
    textarea.style.opacity = "0";
    document.body.appendChild(textarea);

    textarea.select();
    try {
        document.execCommand("copy");
        window.app.$message.success('复制成功')
    } catch (err) {
        window.app.$message.success('复制失败')
    } finally {
        document.body.removeChild(textarea); // 清理临时元素
    }
}


function renderMermaid(dom, graph) {
    let bubbleDom = dom;
    if (bubbleDom) {
        if (bubbleDom.rendering) {
            setTimeout(() => {
                renderMermaid(dom, graph);
            }, 90);
            return;
        }
    }
    if (!window.mermaid) {
        setTimeout(() => {
            renderMermaid(dom, graph);
        }, 90);
        return;
    }
    setTimeout(async () => {
        if (bubbleDom) {
            bubbleDom.rendering = true;
        }
        try {
            // 核心：调用 render 方法
            // 参数1: 唯一ID (用于内部生成临时DOM)
            // 参数2: 图表定义文本
            const {svg, bindFunctions} = await window.mermaid.render('render_' + dom.id, graph);

            // 将生成的 SVG 代码插入到目标容器中
            dom.innerHTML = svg;

            // 如果图表包含交互（如点击事件、工具提示），需要绑定函数
            if (bindFunctions) {
                bindFunctions(dom);
            }
        } catch (error) {
            // 处理语法错误等异常情况
            console.error('Mermaid 渲染失败:', error);
            dom.innerHTML = `<p style="color:red;">图表语法错误，请检查代码！</p>`;
        } finally {
            const panzoom = Panzoom(dom, {
                maxScale: 5,       // 最大放大倍数
                minScale: 0.25,    // 最小缩小倍数
                contain: 'outside' // 可选：限制拖拽边界，防止拖出视野
            });

            dom.parentElement.addEventListener('wheel', panzoom.zoomWithWheel);
        }
        if (bubbleDom) {
            bubbleDom.rendering = false;
        }
    }, 0)
}
