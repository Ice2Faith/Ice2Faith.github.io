/**
 * 渲染工具函数 — CodeBlock / DiagramPanel 组件依赖
 */

function copy2clipboard(text) {
    var textarea = document.createElement("textarea");
    textarea.value = text;
    textarea.style.position = "fixed";
    textarea.style.opacity = "0";
    document.body.appendChild(textarea);
    textarea.select();
    try {
        document.execCommand("copy");
        if (window.app && window.app.$message) {
            window.app.$message.success('复制成功');
        }
    } catch (err) {
        if (window.app && window.app.$message) {
            window.app.$message.error('复制失败');
        }
    }
    document.body.removeChild(textarea);
}


function renderMermaid(dom, graph) {
    var bubbleDom = dom;
    if (bubbleDom) {
        if (bubbleDom.rendering) {
            setTimeout(function () {
                renderMermaid(dom, graph);
            }, 90);
            return;
        }
    }
    if (!window.mermaid) {
        setTimeout(function () {
            renderMermaid(dom, graph);
        }, 90);
        return;
    }
    setTimeout(async function () {
        if (bubbleDom) {
            bubbleDom.rendering = true;
        }
        try {
            var result = await mermaid.render('render_' + dom.id, graph);
            dom.innerHTML = result.svg;
            if (result.bindFunctions) {
                result.bindFunctions(dom);
            }
        } catch (error) {
            console.error('Mermaid 渲染失败:', error);
            dom.innerHTML = '<p style="color:red;">图表语法错误，请检查代码！</p>';
        } finally {
            var panzoom = Panzoom(dom, {
                maxScale: 5,
                minScale: 0.25,
                contain: 'outside'
            });
            dom.parentElement.addEventListener('wheel', panzoom.zoomWithWheel);
        }
        if (bubbleDom) {
            bubbleDom.rendering = false;
        }
    }, 0);
}

function renderSvg(dom, html) {
    setTimeout(function () {
        try {
            if (html.trim().startsWith('<')) {
                dom.innerHTML = html;
            } else {
                fetch(html.trim()).then(function (r) {
                    if (!r.ok) throw new Error('HTTP ' + r.status);
                    return r.text();
                }).then(function (text) {
                    dom.innerHTML = text;
                    dom.chartCode = text;
                }).catch(function (err) {
                    dom.innerHTML = '<p style="color:red;">SVG 加载失败：' + err.message + '</p>';
                });
            }
        } catch (e) {
            dom.innerHTML = '<p style="color:red;">SVG 渲染失败</p>';
        }
    }, 0);
}
