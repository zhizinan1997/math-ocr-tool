class MathOCR {
    constructor() {
        this.initializeElements();
        this.bindEvents();
        this.currentImage = null;
        this.currentLatex = null;
    }

    initializeElements() {
        this.uploadArea = document.getElementById('uploadArea');
        this.fileInput = document.getElementById('fileInput');
        this.previewSection = document.getElementById('previewSection');
        this.previewImage = document.getElementById('previewImage');
        this.convertBtn = document.getElementById('convertBtn');
        this.clearBtn = document.getElementById('clearBtn');
        this.resultSection = document.getElementById('resultSection');
        this.latexResult = document.getElementById('latexResult');
        this.copyBtn = document.getElementById('copyBtn');
        this.downloadBtn = document.getElementById('downloadBtn');
        this.errorMessage = document.getElementById('errorMessage');
        this.mathPreview = document.getElementById('mathPreview');
        this.btnText = document.querySelector('.btn-text');
        this.loading = document.querySelector('.loading');
        this.totalCount = document.getElementById('totalCount');
    }

    bindEvents() {
        // 文件上传相关事件
        this.uploadArea.addEventListener('click', () => this.fileInput.click());
        this.fileInput.addEventListener('change', (e) => this.handleFileSelect(e));
        
        // 拖拽上传
        this.uploadArea.addEventListener('dragover', (e) => this.handleDragOver(e));
        this.uploadArea.addEventListener('dragleave', (e) => this.handleDragLeave(e));
        this.uploadArea.addEventListener('drop', (e) => this.handleDrop(e));
        
        // 粘贴上传
        document.addEventListener('paste', (e) => this.handlePaste(e));
        
        // 按钮事件
        this.convertBtn.addEventListener('click', () => this.convertImage());
        this.clearBtn.addEventListener('click', () => this.clearImage());
        this.copyBtn.addEventListener('click', () => this.copyResult());
        this.downloadBtn.addEventListener('click', () => this.downloadResult());
    }

    handleFileSelect(event) {
        const file = event.target.files[0];
        if (file) {
            this.processFile(file);
        }
    }

    handleDragOver(event) {
        event.preventDefault();
        this.uploadArea.classList.add('dragover');
    }

    handleDragLeave(event) {
        event.preventDefault();
        this.uploadArea.classList.remove('dragover');
    }

    handleDrop(event) {
        event.preventDefault();
        this.uploadArea.classList.remove('dragover');
        
        const files = event.dataTransfer.files;
        if (files.length > 0) {
            this.processFile(files[0]);
        }
    }

    handlePaste(event) {
        const items = event.clipboardData.items;
        for (let item of items) {
            if (item.type.indexOf('image') !== -1) {
                const file = item.getAsFile();
                this.processFile(file);
                break;
            }
        }
    }

    processFile(file) {
        // 检查文件类型
        const allowedTypes = ['image/png', 'image/jpeg', 'image/jpg', 'image/gif', 'image/bmp', 'image/webp'];
        if (!allowedTypes.includes(file.type)) {
            this.showError('不支持的文件格式，请上传图片文件');
            return;
        }

        // 检查文件大小 (16MB)
        if (file.size > 16 * 1024 * 1024) {
            this.showError('文件太大，请上传小于16MB的图片');
            return;
        }

        const reader = new FileReader();
        reader.onload = (e) => {
            this.currentImage = e.target.result;
            this.showPreview(e.target.result);
        };
        reader.readAsDataURL(file);
    }

    showPreview(imageSrc) {
        this.previewImage.src = imageSrc;
        this.previewSection.style.display = 'block';
        this.convertBtn.disabled = false;
        this.hideError();
        
        // 滚动到预览区域
        this.previewSection.scrollIntoView({ behavior: 'smooth' });
    }

    clearImage() {
        this.currentImage = null;
        this.currentLatex = null;
        this.previewSection.style.display = 'none';
        this.resultSection.style.display = 'none';
        this.convertBtn.disabled = true;
        this.fileInput.value = '';
        this.hideError();
    }

    async convertImage() {
        if (!this.currentImage) {
            this.showError('请先上传图片');
            return;
        }

        this.setLoading(true);
        this.hideError();

        try {
            const response = await fetch('/upload_base64', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    image: this.currentImage
                })
            });

            const result = await response.json();
            
            if (result.success) {
                this.currentLatex = result.latex;
                this.showResult(result.latex);
                // 更新转换次数
                if (result.total_conversions) {
                    this.updateConversionCount(result.total_conversions);
                }
            } else {
                this.showError(result.error || '转换失败，请重试');
            }
        } catch (error) {
            this.showError('网络错误，请检查连接后重试');
            console.error('转换错误:', error);
        } finally {
            this.setLoading(false);
        }
    }

    showResult(latex) {
        this.latexResult.value = latex;
        this.resultSection.style.display = 'block';
        this.updateMathPreview(latex);
        
        // 滚动到结果区域
        this.resultSection.scrollIntoView({ behavior: 'smooth' });
    }

    updateMathPreview(latex) {
        this.mathPreview.innerHTML = latex;
        
        // 如果MathJax已加载，重新渲染数学公式
        if (window.MathJax) {
            MathJax.typesetPromise([this.mathPreview]).catch((err) => {
                console.log('MathJax渲染错误:', err);
                this.mathPreview.innerHTML = '<p style="color: #6c757d;">LaTeX预览加载中...</p>';
            });
        }
    }

    updateConversionCount(newCount) {
        if (this.totalCount) {
            this.totalCount.textContent = newCount;
            // 添加动画效果
            this.totalCount.classList.add('count-updated');
            setTimeout(() => {
                this.totalCount.classList.remove('count-updated');
            }, 300);
        }
    }

    // 修正复制功能
    async copyResult() {
        const latexText = this.latexResult.value;
        if (!latexText) {
            this.showError('没有可复制的内容');
            return;
        }

        const originalHTML = this.copyBtn.innerHTML;
        
        try {
            // 现代浏览器的剪贴板API
            if (navigator.clipboard && window.isSecureContext) {
                await navigator.clipboard.writeText(latexText);
                this.copyBtn.innerHTML = '<span class="btn-icon">✅</span>已复制';
            } else {
                // 降级方案：使用传统方法
                this.latexResult.select();
                this.latexResult.setSelectionRange(0, 99999);
                const successful = document.execCommand('copy');
                
                if (successful) {
                    this.copyBtn.innerHTML = '<span class="btn-icon">✅</span>已复制';
                } else {
                    throw new Error('复制失败');
                }
            }
            
            // 2秒后恢复按钮状态
            setTimeout(() => {
                this.copyBtn.innerHTML = originalHTML;
            }, 2000);
            
        } catch (err) {
            console.error('复制失败:', err);
            this.showError('复制失败，请手动选择并复制文本');
            this.copyBtn.innerHTML = originalHTML;
        }
    }

    downloadResult() {
        const latex = this.latexResult.value;
        if (!latex) return;

        const blob = new Blob([latex], { type: 'text/plain;charset=utf-8' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `latex_formula_${new Date().getTime()}.txt`;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
    }

    setLoading(isLoading) {
        this.convertBtn.disabled = isLoading;
        if (isLoading) {
            this.btnText.style.display = 'none';
            this.loading.style.display = 'inline';
        } else {
            this.btnText.style.display = 'inline';
            this.loading.style.display = 'none';
        }
    }

    showError(message) {
        this.errorMessage.textContent = message;
        this.errorMessage.style.display = 'block';
        this.errorMessage.scrollIntoView({ behavior: 'smooth' });
    }

    hideError() {
        this.errorMessage.style.display = 'none';
    }
}

// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', () => {
    window.mathOCRInstance = new MathOCR();
});

// 添加一些实用的快捷键
document.addEventListener('keydown', (e) => {
    // Ctrl/Cmd + V 粘贴提示
    if ((e.ctrlKey || e.metaKey) && e.key === 'v') {
        const activeElement = document.activeElement;
        if (activeElement.tagName !== 'TEXTAREA' && activeElement.tagName !== 'INPUT') {
            // 显示粘贴提示
            const uploadArea = document.getElementById('uploadArea');
            if (uploadArea) {
                uploadArea.style.transform = 'scale(1.01)';
                uploadArea.style.borderColor = '#6c757d';
                setTimeout(() => {
                    uploadArea.style.transform = '';
                    uploadArea.style.borderColor = '';
                }, 300);
            }
        }
    }
    
    // Escape 键清除图片
    if (e.key === 'Escape') {
        const mathOCR = window.mathOCRInstance;
        if (mathOCR && mathOCR.currentImage) {
            mathOCR.clearImage();
        }
    }
});

// 防止整个页面的拖拽默认行为
document.addEventListener('dragover', (e) => e.preventDefault());
document.addEventListener('drop', (e) => e.preventDefault());

// 定期刷新统计数据（可选）
setInterval(async () => {
    try {
        const response = await fetch('/stats');
        const data = await response.json();
        if (data.total_conversions !== undefined) {
            const countElement = document.getElementById('totalCount');
            if (countElement && countElement.textContent !== data.total_conversions.toString()) {
                countElement.textContent = data.total_conversions;
            }
        }
    } catch (error) {
        // 静默处理错误
    }
}, 30000); // 每30秒刷新一次