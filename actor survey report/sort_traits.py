# 整理天赋.md文件的脚本
# 将名称相同的行移动到一起，使它们紧邻

import os

def sort_traits(file_path):
    # 读取文件内容
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    # 解析表格行，忽略表头和分隔符
    trait_lines = []
    header_lines = []
    in_table = False

    for line in lines:
        line = line.rstrip()  # 去除行尾换行
        if line.startswith('|') and '---' not in line:  # 表格行
            if not in_table:
                header_lines.append(line)
                in_table = True
            else:
                trait_lines.append(line)
        else:
            if in_table:
                # 表结束
                break
            else:
                header_lines.append(line)

    # 提取名称（第一列）
    trait_dict = {}
    for line in trait_lines:
        parts = line.split('|')
        if len(parts) >= 3:
            name = parts[1].strip()
            if name not in trait_dict:
                trait_dict[name] = []
            trait_dict[name].append(line)

    # 重新排列行，使相同名称的行紧邻
    sorted_lines = []
    for name in sorted(trait_dict.keys()):  # 按名称排序
        sorted_lines.extend(trait_dict[name])

    # 写入文件
    with open(file_path, 'w', encoding='utf-8') as f:
        # 写入非表格部分（如果有）
        for line in header_lines:
            f.write(line + '\n')
        # 写入排序后的表格行
        for line in sorted_lines:
            f.write(line + '\n')

if __name__ == "__main__":
    file_path = r"c:\Users\Administrator\Documents\ReadNotes\actor survey report\天赋.md"
    if os.path.exists(file_path):
        sort_traits(file_path)
        print("文件已整理完成。")
    else:
        print("文件不存在。")
