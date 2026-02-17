// 配置
const CONFIG = {
    GITHUB_OWNER: 'Glyphite', // 替换为您的GitHub用户名
    GITHUB_REPO: 'glyphite-message', // 替换为您的仓库名
    GITHUB_API_BASE: 'https://api.github.com',
    ISSUES_PER_PAGE: 20,
    // 注意：公开仓库可以直接访问Issues API，但频率限制较严格（60次/小时）。
    // 如需更高频率，可在GitHub生成Token，但切勿在前端代码中硬编码！
    // 正确做法是在Vercel中配置环境变量，然后通过服务器端函数中转请求。
};

// 状态管理
let state = {
    issues: [],
    filteredIssues: [],
    allLabels: [],
    activeLabel: null,
    searchQuery: '',
    isLoading: true,
    error: null
};

// DOM 元素
const dom = {
    issueCount: document.getElementById('issue-count'),
    updateTime: document.getElementById('update-time'),
    refreshBtn: document.getElementById('refresh-btn'),
    searchInput: document.getElementById('search-input'),
    tagFilters: document.getElementById('tag-filters'),
    loadingEl: document.getElementById('loading'),
    issueList: document.getElementById('issue-list'),
    displayCount: document.getElementById('display-count'),
    noResults: document.getElementById('no-results'),
    errorMessage: document.getElementById('error-message'),
    errorDetail: document.querySelector('.error-detail')
};

// 工具函数：格式化时间
function formatTime(dateString) {
    const date = new Date(dateString);
    const now = new Date();
    const diffMs = now - date;
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);

    if (diffMins < 1) return '刚刚';
    if (diffMins < 60) return `${diffMins}分钟前`;
    if (diffHours < 24) return `${diffHours}小时前`;
    if (diffDays < 7) return `${diffDays}天前`;

    return date.toLocaleDateString('zh-CN', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
    });
}

// 工具函数：提取纯文本（移除Markdown格式）
function extractPlainText(markdown) {
    if (!markdown) return '';
    // 简单移除Markdown常见语法
    return markdown
        .replace(/\[([^\]]+)\]\([^)]+\)/g, '$1') // 链接
        .replace(/#{1,6}\s*/g, '') // 标题
        .replace(/\*\*([^*]+)\*\*/g, '$1') // 粗体
        .replace(/\*([^*]+)\*/g, '$1') // 斜体
        .replace(/`([^`]+)`/g, '$1') // 行内代码
        .replace(/