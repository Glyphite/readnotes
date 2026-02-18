import re
import markdown
from bs4 import BeautifulSoup
import glob
import os

# 1. 获取assets中的所有HTML文件，确定需要处理的目标
posts = glob.glob('./assets/*.html')
post_data = {}

# 2. 处理每个post文件：提取内容、替换日期格式、更新文件
for post_file in posts:
    # 读取post文件
    with open(post_file, 'r', encoding='utf-8') as f:
        html = f.read()

    # 提取mdText
    soup = BeautifulSoup(html, 'html.parser')
    script = soup.find('script', string=lambda text: text and 'const mdText' in text)
    script_text = script.get_text()
    md_text = re.search(r'const mdText = `(.*?)`;', script_text, re.DOTALL).group(1)

    # 将日期从yyyy.mm.dd改为yyyy年mm月dd日格式
    match = re.search(r'写于(\d+\.\d+\.\d+)</div>', md_text)
    if match:
        date_str = match.group(1)
        if date_str.count('.') == 2:
            parts = date_str.split('.')
            new_date = f"{parts[0]}年{parts[1]}月{parts[2]}日"
            md_text = md_text.replace(date_str, new_date)

    # 更新post文件
    post_html = re.sub(r'(const mdText = `).*?(`;)', f'\\1{md_text}\\2', html, flags=re.DOTALL)
    with open(post_file, 'w', encoding='utf-8') as f:
        f.write(post_html)

    # 解析markdown，提取关键字
    md = markdown.Markdown()
    html_content = md.convert(md_text)
    soup_md = BeautifulSoup(html_content, 'html.parser')
    h1 = soup_md.find('h1').get_text()
    p_elements = soup_md.find_all('p')
    p_sub = p_elements[0].get_text() if p_elements else ''
    p_desc = p_elements[1].get_text() if len(p_elements) > 1 else ''
    
    # 以年月日格式进行关键字匹配
    date_match = re.search(r'写于(\d{4})年(\d{1,2})月(\d{1,2})日', md_text)
    if date_match:
        year, month, day = date_match.groups()
        mm_dd = f"{int(month):02d}-{int(day):02d}"
    else:
        mm_dd = "02-17"

    filename = os.path.basename(post_file)
    href = f'assets/{filename}'
    post_data[href] = {'h1': h1, 'p_sub': p_sub, 'p_desc': p_desc, 'date_str': f"昼行灯 写于{year}年{month}月{day}日", 'mm_dd': mm_dd}

# 3. 收集post数据用于更新索引

# 4. 更新index.html
with open('./index.html', 'r', encoding='utf-8') as f:
    index_html = f.read()
soup_index = BeautifulSoup(index_html, 'html.parser')
project_cards = soup_index.find_all('div', class_='project-card')
for card in project_cards:
    card_a = card.find('a', class_='title')
    if card_a:
        card_href = card_a.get('href', '')
        if card_href in post_data:
            data = post_data[card_href]
            card_a.string = data['h1']
            desc_section = card.find('section', class_='desc')
            if desc_section:
                desc_section.string = data['p_desc']
            sub_p = card.find('p', class_='subtitle')
            if sub_p:
                sub_p.string = data['p_sub']
            sub_sub = card.find('p', class_='sub')
            if sub_sub:
                sub_sub.string = data['date_str']

# 添加新卡片
for href, data in post_data.items():
    found = any(card.find('a', href=href) for card in project_cards)
    if not found:
        main = soup_index.find('div', id='main')
        if main:
            footer = soup_index.find('footer', id='footer')
            new_card = soup_index.new_tag('div', attrs={'class': 'project-card'})
            img_src = href.replace('.html', '.webp')
            img = soup_index.new_tag('img', src=img_src, alt='项目图片')
            new_card.append(img)
            ctnwrap = soup_index.new_tag('div', attrs={'class': 'ctnWrap'})
            title_a = soup_index.new_tag('a', href=href, attrs={'class': 'title'})
            title_a.string = data['h1']
            ctnwrap.append(title_a)
            desc_section = soup_index.new_tag('section', attrs={'class': 'desc'})
            desc_section.string = data['p_desc']
            ctnwrap.append(desc_section)
            sub_row = soup_index.new_tag('div', attrs={'class': 'sub-row'})
            sub_p = soup_index.new_tag('p', attrs={'class': 'subtitle'})
            sub_p.string = data['p_sub']
            sub_row.append(sub_p)
            sub_sub = soup_index.new_tag('p', attrs={'class': 'sub'})
            sub_sub.string = data['date_str']
            sub_row.append(sub_sub)
            ctnwrap.append(sub_row)
            new_card.append(ctnwrap)
            if footer:
                footer.insert_before(new_card)
            else:
                main.append(new_card)

index_html = str(soup_index)
with open('./index.html', 'w', encoding='utf-8') as f:
    f.write(index_html)

# 5. 更新archive.html
with open('./archive.html', 'r', encoding='utf-8') as f:
    archive_html = f.read()
soup_archive = BeautifulSoup(archive_html, 'html.parser')
ul = soup_archive.find('ul', class_='archive-posts')
existing_hrefs = set()
if ul:
    for li in ul.find_all('li'):
        a = li.find('a', attrs={'class': 'archive-title'})
        if a:
            a_href = a.get('href', '')
            existing_hrefs.add(a_href)
            if a_href in post_data:
                data = post_data[a_href]
                a.string = data['h1']
                span_date = li.find('span', attrs={'class': 'archive-date'})
                if span_date:
                    span_date.string = data['p_sub']

# 添加新条目
for href, data in post_data.items():
    if href not in existing_hrefs:
        if ul:
            new_li = soup_archive.new_tag('li')
            new_a = soup_archive.new_tag('a', href=href, attrs={'class': 'archive-title'})
            new_a.string = data['h1']
            new_li.append(new_a)
            new_span = soup_archive.new_tag('span', attrs={'class': 'archive-date'})
            new_span.string = data['p_sub']
            new_li.append(new_span)
            ul.append(new_li)

archive_html = str(soup_archive)
with open('./archive.html', 'w', encoding='utf-8') as f:
    f.write(archive_html)
