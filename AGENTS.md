# math-learn-pdf

小学数学学习 PDF 资源仓库。上海教育出版社（五·四学制）教材扫描 PDF 及配套文本、知识点分析。

## 文件

| 文件 | 说明 |
|------|------|
| `二年级上册数学.pdf` | 教材扫描 PDF |
| `二年级上册数学.txt` | Apple Vision OCR 提取的完整文本 |
| `大纲与知识点.md` | 全书 7 单元结构树 + 逐节知识点 + 能力图谱 |
| `拓展阅读.md` | 与《十万个为什么（第六版）·数学》的逐单元关联映射 |
| `预习指南_九九乘法表.md` | 九九乘法表亲子预习指南（6 阶段 + 附录） |
| `数学 十万个为什么 第六版.txt` | 十万个为什么·数学卷的 OCR 完整文本 |
| `数学 十万个为什么 第六版.pdf` | 十万个为什么·数学卷扫描 PDF（>100 MB，Git 忽略） |
| `extract_text.swift` | 零依赖 OCR 提取脚本（macOS 专用） |

## 命名规则

新增 PDF 按 `{年级}{上下册}数学.pdf` 命名，例如 `三年级下册数学.pdf`。

## 文本提取

```bash
swift extract_text.swift "二年级上册数学.pdf"
# 输出同目录下的 二年级上册数学.txt
```

依赖 Apple Vision Framework（macOS Ventura+），无需安装第三方库。

## 提交

```bash
git-cz --non-interactive --type docs --scope pdf --subject "<描述>"
```
