import re
import markdown
from bs4 import BeautifulSoup

# 读取post1.html
with open('post1.html', 'r', encoding='utf-8') as f:
    html = f.read()

# 提取mdText
soup = BeautifulSoup(html, 'html.parser')
script = soup.find('script', string=lambda text: text and 'const mdText' in text)
script_text = script.get_text()
md_text = re.search(r'const mdText = `(.*?)`;', script_text, re.DOTALL).group(1)

# 替换日期格式
match = re.search(r'写于(\d+\.\d+\.\d+)</div>', md_text)
if match:
    date_str = match.group(1)
    if date_str.count('.') == 2:
        parts = date_str.split('.')
        new_date = f"{parts[0]}年{parts[1]}月{parts[2]}日"
        md_text = md_text.replace(date_str, new_date)

# 更新post1.html
with open('post1.html', 'r', encoding='utf-8') as f:
    post_html = f.read()
post_html = re.sub(r'(const mdText = `).*?(`;)', f'\\1{md_text}\\2', post_html, flags=re.DOTALL)
with open('post1.html', 'w', encoding='utf-8') as f:
    f.write(post_html)

# 解析markdown
md = markdown.Markdown()
html_content = md.convert(md_text)

# 提取h1, p (subtitle), p (content)
soup_md = BeautifulSoup(html_content, 'html.parser')
h1 = soup_md.find('h1').get_text()
p_sub = soup_md.find('p').get_text()  # 副标题
p_content = soup_md.find_all('p')[1].get_text()  # 内容开头

# 提取作者日期
author_date_div = soup_md.find('div', style=lambda value: value and 'text-align:right' in value)
if author_date_div:
    author_date = author_date_div.get_text()
    author_date = author_date.replace("2026.2.17", "2026年2月17日")
else:
    author_date = "2026年2月17日"  # 默认

# 更新index.html
with open('index.html', 'r', encoding='utf-8') as f:
    index_html = f.read()

# 替换.title
index_html = re.sub(r'(<a href="post1.html" class="title">).*?(</a>)', f'\\1{h1}\\2', index_html)

# 替换.subtitle
index_html = re.sub(r'(<p class="subtitle">).*?(</p>)', f'\\1{p_sub}\\2', index_html)

# 替换.desc
index_html = re.sub(r'(<section class="desc">).*?(</section>)', f'\\1{p_content}\\2', index_html)

# 替换.sub
index_html = re.sub(r'(<p class="sub">).*?(</p>)', f'\\1{author_date}\\2', index_html)

with open('index.html', 'w', encoding='utf-8') as f:
    f.write(index_html)

# 更新archive.html
with open('archive.html', 'r', encoding='utf-8') as f:
    archive_html = f.read()

# 提取MM-DD
date_match = re.search(r'写于(\d{4})年(\d{1,2})月(\d{1,2})日', author_date)
if date_match:
    year, month, day = date_match.groups()
    mm_dd = f"{int(month):02d}-{int(day):02d}"
else:
    mm_dd = "02-17"

# 更新archive.html
soup_archive = BeautifulSoup(archive_html, 'html.parser')
a_tag = soup_archive.find('a', href='post1.html')
if a_tag:
    a_tag.string = h1
span_tag = soup_archive.find('span', class_='archive-date')
if span_tag:
    span_tag.string = mm_dd
else:
    if a_tag:
        new_span = soup_archive.new_tag('span', class_='archive-date')
        new_span.string = mm_dd
        a_tag.insert_after(new_span)
archive_html = str(soup_archive)

with open('archive.html', 'w', encoding='utf-8') as f:
    f.write(archive_html)
