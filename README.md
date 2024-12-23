# ustcthss-typst 中国科学技术大学本科生毕业论文typst模版

中国科学技术大学本科生毕业论文的 typst 模版，能够一键生成论文 pdf 文件。

按照[2024年中国科学技术大学教务处毕业论文格式要求](https://www.teach.ustc.edu.cn/notice/notice-teaching/17071.html) 编写。

**欢迎提出任何 Issue 和 PR 帮助完善这个模板。**

![ustcthss-typst](./images/cover_ustc.png)

## 使用方式

### 方式一：本地编译

- 下载安装最新版本的 [Typst](https://github.com/typst/typst)。
- 克隆本仓库。
- 修改 `thesis.typ` 完成你的论文写作，`thesis.typ` 是论文模版，其中包含了标题、段落、图片、公式、表格、引用、参考文献等的几乎所有毕业论文可能用到的特性。
- 在命令行中，执行 `typst compile thesis.typ --font-path fonts` 进行编译，生成同名的 `thesis.pdf` 文件。

### 方式二：在线编译

进入 [Typst](https://typst.app/) 官网，并导入本模板的文件，包括 `typ` 文件、`fonts/` 下的字体、图片文件。然后修改 `thesis.typ` 完成你的论文写作。

### 方式三：使用 Tinymist Typst

- 克隆本仓库。
- 在 VSCode 中打开本仓库。
- 安装并启用 [Tinymist Typst](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) 插件。
- 打开 `thesis.typ` 文件，按下：
    - `Ctrl + K V` 进行侧边浏览；
    - `Ctrl + Shift + B` (或手动执行 `Typst: Show exported PDF` 命令) 生成 `thesis.pdf` 文件。

## 致谢

- 本仓库基于 [PKUTHSS-Typst](https://github.com/pku-typst/pkuthss-typst) 修改得到，感谢开发者的贡献。
- 本仓库双语参考文献的实现参考了 [SEU-Typst-Template](https://github.com/csimide/SEU-Typst-Template/tree/master?tab=readme-ov-file#%E5%8F%82%E8%80%83%E6%96%87%E7%8C%AE)，感谢开发者的贡献。

