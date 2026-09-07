function setupMarkdown(resourceResolver) {
    if (!resourceResolver) {
        resourceResolver = function (url) {
            return url;
        }
    }
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
                    renderMermaid(dom, graph, resourceResolver)
                };
                setTimeout(applyFunc, 300);
            } else if (lang == 'svg') {
                let chartId = 'svg_' + new Date().getTime() + '_' + Math.random().toString(16).substring(2);
                innerHtml = `<div id="${chartId}" class="rich-code-block svg-code-block"></div>`;
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
                    renderSvg(dom, graph, resourceResolver)
                };
                setTimeout(applyFunc, 300);
            } else if (lang == 'css-embed') {
                let chartId = 'css_embed_' + new Date().getTime() + '_' + Math.random().toString(16).substring(2);
                innerHtml = `<style id="${chartId}"></style>`;
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
                    renderCssEmbed(dom, graph, resourceResolver)
                };
                setTimeout(applyFunc, 300);
                // 只进行样式注入，不实际显示
                return innerHtml
            } else if (lang == 'js-embed') {
                let chartId = 'js_embed_' + new Date().getTime() + '_' + Math.random().toString(16).substring(2);
                innerHtml = `<style id="${chartId}"></style>`;
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
                    renderJsEmbed(dom, graph, resourceResolver)
                };
                setTimeout(applyFunc, 300);
                // 只进行样式注入，不实际显示
                return innerHtml
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

            // 设置原始代码
            let codeId = 'code_' + new Date().getTime() + '_' + Math.random().toString(16).substring(2);
            let codeTaskCount = 10;
            let setCodeTask = () => {
                let element = document.querySelector('#' + codeId);
                if (!element) {
                    codeTaskCount--;
                    if (codeTaskCount > 0) {
                        setTimeout(() => {
                            setCodeTask()
                        }, 300)
                    }
                    return
                }
                element.chartCode = str;
            }
            setCodeTask()

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
                        <span class="code-action-btn" onclick="onSwitchMarkdownCodeBlock(event,'${lang}')" title="切换">↔️</span>
                    </span>
                    </div>
                    <pre id="${codeId}" class="hljs markdown-code-body">
                    {{lineNumbersBlock}}<code>{{innerHtml}}</code>
                </pre>
                </div>`
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

    md.renderMarkdown = function (content) {
        if (!content) {
            return '';
        }
        if (!md) {
            return content.replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
        }
        try {
            return md.render(content);
        } catch (e) {
            return content;
        }
    }

    return md;
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
        let text = null;
        if (!text) {
            if (findDom.chartCode) {
                text = findDom.chartCode;
            }
        }
        if (!text) {
            let echartDom = findDom.querySelector('.rich-code-block');
            if (echartDom) {
                text = echartDom.chartCode;
            }
        }
        if (!text) {
            let codeDom = findDom.querySelector('code');
            if (codeDom) {
                text = codeDom.innerText;
            }
        }
        if (!text) {
            text = findDom.innerText
        }
        resolve({
            text: text,
            dom: findDom
        });
    })
}

function onCopyMarkdownCodeBlock(event, lang) {
    getMarkdownCodeBlockText(event).then(resp => {
        copy2clipboard(resp.text);
    }).catch(() => {
        Vue2Loader.notify.error('未找到代码块，复制失败')
    })
}

function onSaveMarkdownCodeBlock(event, lang) {
    getMarkdownCodeBlockText(event).then(resp => {
        // 创建 Blob 并触发下载
        const blob = new Blob([resp.text], {type: 'plain/text;charset=utf-8'});
        const url = URL.createObjectURL(blob);

        const link = document.createElement('a');
        link.href = url;
        link.download = (lang || 'text') + '_' + new Date().getTime() + '.txt';
        link.click();

        // 清理内存
        URL.revokeObjectURL(url);
    }).catch(() => {
        Vue2Loader.notify.error('未找到代码块，保存失败')
    })
}

function onSwitchMarkdownCodeBlock(event, lang){
    getMarkdownCodeBlockText(event).then(resp => {
        let dom = resp.dom;
        if (dom.showText) {
            dom.innerHTML = dom.codeHtml;
            dom.showText = false;
        } else {
            dom.codeHtml = dom.innerHTML;
            dom.innerHTML = '';

            const textarea = document.createElement('textarea');
            const autoResize = () => {
                textarea.style.width = '100%';
                // 1. 先将高度重置为 auto，以便在内容减少时高度能随之缩小
                textarea.style.height = 'auto';
                // 2. 将高度设置为内容的实际滚动高度
                textarea.style.height = (textarea.scrollHeight+6) + 'px';
            }
            textarea.addEventListener('input', autoResize);
            dom.appendChild(textarea)
            textarea.value = dom.chartCode;
            autoResize()
            dom.showText = true;
        }

    }).catch(() => {
        Vue2Loader.notify.error('未找到代码块，复制失败')
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
        Vue2Loader.notify.success('复制成功')
    } catch (err) {
        Vue2Loader.notify.success('复制失败')
    } finally {
        document.body.removeChild(textarea); // 清理临时元素
    }
}


function renderMermaid(dom, graph, resourceResolver) {
    let bubbleDom = dom;
    if (bubbleDom) {
        if (bubbleDom.rendering) {
            setTimeout(() => {
                renderMermaid(dom, graph, resourceResolver);
            }, 90);
            return;
        }
    }
    if (!window.mermaid) {
        setTimeout(() => {
            renderMermaid(dom, graph, resourceResolver);
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


function renderSvg(dom, graph, resourceResolver) {
    let bubbleDom = dom;
    if (bubbleDom) {
        if (bubbleDom.rendering) {
            setTimeout(() => {
                renderSvg(dom, graph, resourceResolver);
            }, 90);
            return;
        }
    }
    setTimeout(async () => {
        if (bubbleDom) {
            bubbleDom.rendering = true;
        }
        try {
            let str = graph.trim();
            if (str.startsWith('link:')) {
                str = str.substring('link:'.length).trim()
                graph = await fetch(resourceResolver(str)).then(r => r.text())
            } else if (!str.startsWith('<')) {
                graph = await fetch(resourceResolver(str)).then(r => r.text())
            }
            // 将生成的 SVG 代码插入到目标容器中
            dom.innerHTML = graph;

        } catch (error) {
            // 处理语法错误等异常情况
            console.error('Svg 渲染失败:', error);
            dom.innerHTML = `<p style="color:red;">Svg语法错误，请检查代码！</p>`;
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

function renderCssEmbed(dom, graph, resourceResolver) {
    let bubbleDom = dom;
    if (bubbleDom) {
        if (bubbleDom.rendering) {
            setTimeout(() => {
                renderCssEmbed(dom, graph, resourceResolver);
            }, 90);
            return;
        }
    }
    setTimeout(async () => {
        if (bubbleDom) {
            bubbleDom.rendering = true;
        }
        try {
            let str = graph.trim();
            if (str.startsWith('link:')) {
                str = str.substring('link:'.length).trim()
                graph = await fetch(resourceResolver(str)).then(r => r.text())
            }
            // 直接进行样式注入，允许引入样式
            let cssDom = document.createElement('style')
            cssDom.innerText = graph;
            document.body.appendChild(cssDom)

        } catch (error) {
            // 处理语法错误等异常情况
            console.error('Css 渲染失败:', error);
            dom.innerHTML = `<p style="color:red;">Css语法错误，请检查代码！</p>`;
        }
        if (bubbleDom) {
            bubbleDom.rendering = false;
        }
    }, 0)
}

function renderJsEmbed(dom, graph, resourceResolver) {
    let bubbleDom = dom;
    if (bubbleDom) {
        if (bubbleDom.rendering) {
            setTimeout(() => {
                renderJsEmbed(dom, graph, resourceResolver);
            }, 90);
            return;
        }
    }
    setTimeout(async () => {
        if (bubbleDom) {
            bubbleDom.rendering = true;
        }
        try {
            let str = graph.trim();
            if (str.startsWith('link:')) {
                str = str.substring('link:'.length).trim()
                graph = await fetch(resourceResolver(str)).then(r => r.text())
            }
            // 直接进行脚本注入，允许引入脚本
            let jsDom = document.createElement('script')
            jsDom.innerText = graph;
            document.body.appendChild(jsDom)

        } catch (error) {
            // 处理语法错误等异常情况
            console.error('Javascript 渲染失败:', error);
            dom.innerHTML = `<p style="color:red;">Javascript语法错误，请检查代码！</p>`;
        }
        if (bubbleDom) {
            bubbleDom.rendering = false;
        }
    }, 0)
}