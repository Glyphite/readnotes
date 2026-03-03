import re

# 文件路径
file_path = r'c:\Users\Administrator\Documents\ReadNotes\actor survey report\变异体系与路线详解 _ CDDA中文攻略手册.html'

# 读取文件内容
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 删除以 <p><strong>评价： 开头的行
content = re.sub(r'<p><strong>评价：.*?</strong></p>', '', content, flags=re.DOTALL)

# 写回文件
with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("删除完成")
