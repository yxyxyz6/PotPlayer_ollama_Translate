<p align="center">
  <a href="https://github.com/yxyxyz6/PotPlayer_ollama_Translate" target="_blank" align="center">
    <img width="120" height="120" alt="logo" src="https://github.com/user-attachments/assets/cabf933b-5388-4311-8077-04826683a2cf" />
  </a>
</p>

<div align="center">
    <a href="https://www.python.org/">
        <img src="https://img.shields.io/badge/python-3.10%2B-blue" alt="Python 3.10+">
    </a>
    <a href="https://ollama.com/">
        <img src="https://img.shields.io/badge/Ollama-Supported-black" alt="Ollama">
    </a>
    <a href="https://github.com/yxyxyz6/PotPlayer_ollama_Translate/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/license-MIT-green" alt="License">
    </a>
</div>

# 🎬 PotPlayer_ollama_Translate

**✨ 专业的 PotPlayer 本地 AI 实时字幕翻译解决方案，“生肉”变“熟肉”的最佳伴侣**

**⚠️ 重大更新：代码重构优化，新增“英译中”与“日译中”独立模式，针对不同语种语序单独优化，翻译更通顺！**

## 🎨 效果演示

### 📺 实时翻译效果图
<div align="center">
<img src="https://github.com/user-attachments/assets/c3edc453-b956-46f9-921d-4af73516edc8" width="45%" alt="Effect 1"/>
<img src="https://github.com/user-attachments/assets/cd999f42-3fde-4a56-9b53-07fa231b2de4" width="45%" alt="Effect 2"/>
<br>
<img src="https://github.com/user-attachments/assets/ab8bda57-1cd9-4e51-af56-34f597e4bd90" width="45%" alt="Effect 3"/>
<img src="https://github.com/user-attachments/assets/ddba1497-ec19-40ae-bd58-4110075d61d5" width="45%" alt="Effect 4"/>
</div>

## 🛠️ 快速开始

### 📥 下载与安装
1. 下载本项目 Release 或源码 Zip 包。
2. 解压所有文件到 PotPlayer 的翻译插件目录：
   `PotPlayer安装路径\Extension\Subtitle\Translate`

## 🎯 核心配置指南 (必读)

为了获得最佳体验，请严格按照以下步骤设置 PotPlayer。

### ⚙️ PotPlayer 推荐设置
请在视频画面 **右键** ➡️ **字幕** ➡️ **实时字幕翻译** ➡️ **实时字幕设置**：

1.  **功能开关**：✅ 勾选“生成有声字幕（实时）”
2.  **引擎**：保持默认推荐
3.  **模型**：强烈建议选择 **`large-v3-turbo`** （速度与精度平衡最佳）
4.  **语言**：务必手动选择！
    * 看日剧 ➡️ 选“日语”
    * 看美剧 ➡️ 选“英语”
5.  **翻译插件**：在列表里选择本项目对应的脚本（根据视频语言选择对应版本）

### 🖼️ 配置步骤截图
<div align="center">
<img src="https://github.com/user-attachments/assets/f66f1dd7-2cc0-459b-905d-ce0cb46cf77f" width="45%" alt="Config 1"/>
<img src="https://github.com/user-attachments/assets/3fed74da-b40f-4738-a58d-92508dff6e29" width="45%" alt="Config 2"/>
<br>
<img src="https://github.com/user-attachments/assets/d9d66241-041e-44c9-a9b0-b4ff99260114" width="45%" alt="Config 3"/>
<img src="https://github.com/user-attachments/assets/d01eba1e-a3b1-483a-be0e-e610b2aba4f2" width="45%" alt="Config 4"/>
</div>

## 📝 模型自定义说明

本项目默认配置使用的并强烈推荐的 Ollama 翻译模型为：
> **`huihui_ai/hy-mt1.5-abliterated:latest`**
> <br>
> ollama下载指令：ollama run huihui_ai/hy-mt1.5-abliterated

如果你需要更改为其他模型：
1. 请自行用记事本打开对应的 `.as` 脚本文件。
2. 查找模型名称字段，修改为你本地 Ollama 中的模型名称即可。

## 🤝 致谢与参考

本项目基于以下项目进行修改与优化，感谢原作者的贡献：
* [Felix3322/PotPlayer_Chatgpt_Translate](https://github.com/Felix3322/PotPlayer_Chatgpt_Translate)

## 🥤 赞助作者

如果这个项目帮助你愉快地看懂了生肉视频，欢迎请作者喝一杯奶茶！😊

<div align="center">
<img width="400" alt="微信收款码" src="https://github.com/user-attachments/assets/2aa25f58-a586-45ee-ab48-22a8cf01c783" />
<img width="400" alt="支付宝收款码" src="https://github.com/user-attachments/assets/710bc88d-75e9-4fac-a9a4-51b4ac52886f" />
</div>

## 📈 Star 趋势
<a href="https://www.star-history.com/#yxyxyz6/PotPlayer_ollama_Translate&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=yxyxyz6/PotPlayer_ollama_Translate&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=yxyxyz6/PotPlayer_ollama_Translate&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=yxyxyz6/PotPlayer_ollama_Translate&type=Date" />
 </picture>
</a>
