// 这是一个最简单的示例：只获取仓库的 Issue 总数并显示
// 请将 YOUR_USERNAME 和 YOUR_REPO 替换为您的信息
const owner = 'Glyphite';
const repo = 'glyphite-message';
const apiUrl = `https://gitee.com/api/v5/repos/${owner}/${repo}`;

// 注意：公开仓库可以无需令牌访问基础信息，但频繁调用可能受限。
// 如需稳定使用，建议在Gitee申请私人令牌，但不要将令牌直接暴露在前端代码中。

fetch(apiUrl)
  .then(response => response.json())
  .then(data => {
    // 更新页面上的 Issue 数量
    const issueCountElement = document.getElementById('issue-count');
    if (issueCountElement && data.open_issues_count !== undefined) {
      issueCountElement.textContent = data.open_issues_count;
    }
  })
  .catch(error => {
    console.error('获取数据失败:', error);
    document.getElementById('issue-count').textContent = 'N/A';
  });