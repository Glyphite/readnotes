# 整理天赋.md文件的脚本
# 将名称相同的行移动到一起，使它们紧邻，支持部分索引匹配
# 删除完全重复的行

import os

def sort_traits(file_path):
    # 读取文件内容
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    # 收集所有表行，跳过表头和分隔符
    trait_lines = []
    header_line = "| 名称 | 价格 | 描述 |"
    separator_line = "|------|------|------|"

    for line in lines:
        stripped = line.strip()
        if stripped == header_line or stripped == separator_line:
            continue  # 跳过表头和分隔符
        if stripped.startswith('|') and stripped.endswith('|'):
            # 表行
            trait_lines.append(line.rstrip('\n'))

    # 按名称分组，支持部分匹配
    traits = {}  # key: root_name, value: list of lines
    for line in trait_lines:
        parts = line.split('|')
        if len(parts) >= 3:
            name = parts[1].strip()
            matched = False
            for key in list(traits.keys()):
                if key in name or name in key:
                    traits[key].append(line)
                    matched = True
                    break
            if not matched:
                traits[name] = [line]

    # 生成排序后的行，去重
    sorted_lines = []
    for key in sorted(traits.keys()):  # 按根名称排序
        unique_lines = list(dict.fromkeys(traits[key]))  # 去重，保留顺序
        sorted_lines.extend(unique_lines)

    # 写入文件
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(header_line + '\n')
        f.write(separator_line + '\n')
        for line in sorted_lines:
            f.write(line + '\n')

if __name__ == "__main__":
    file_path = r"c:\Users\Administrator\Documents\ReadNotes\actor survey report\天赋.md"
    if os.path.exists(file_path):
        sort_traits(file_path)
        print("文件已整理完成。")
    else:
        print("文件不存在。")
