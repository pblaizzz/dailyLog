# 开发教程

### 一、准备工作

1. Fork 本仓库到自己的 Github 仓库
2. Clone 代码到本地，并确保已安装 node / npm 环境
3. 使用 Node.js 24（安装了 nvm 时可执行 `nvm install && nvm use`），执行 `npm ci`，然后用 `npm run dev` 本地预览，或用 `npm run build` 验证生产构建。请将 `package-lock.json` 随依赖变更一起提交。

### 二、文档格式说明

1. 确认项目能运行后，进入 `src/pages/posts`，只保留一个 markdown 文件作为格式参考，或添加自己的文件，文档说明如下：
2. 第一行建议展示图片，代码会自动将第一行作为头图，也可以通过 front matter 规范使用 image 字段表示，若未填写，将使用默认图片
3. 第二行留空，第三行是文档描述，可以用 `small` 标签包裹，或通过 front matter 规范使用 description 字段表示，若未填写，将使用默认描述
4. 文档时间默认通过 node 获取文档创建时间，若不需要，可通过 front matter 规范使用 date 字段表示
5. 文章标题可用 `数字-标题` 方式，便于统一处理

### 部署说明

1. 由于 Astro 最终打包为静态文件，支持所有资源部署平台，如 Github Pages、Vercel、Netlify。推荐使用 Vercel 部署，简单高效。其他平台可参考 [astro](https://docs.astro.build/en/guides/deploy/) 文档。以下为 Vercel 部署教程：
2. 确保 Fork 的代码已上传到 Github，进入 [Vercel](https://vercel.com/new) 选择 `Continue with GitHub`，将对应仓库导入
3. 导入后，确认 FRAMEWORK PRESET 为 Astro（[截图](https://gw.alipayobjects.com/zos/k/ic/0BffKE.png)），若未选中，请选择 Astro，点击 Deploy，稍等片刻，等待部署完成
4. 部署完成后，参考[截图](https://gw.alipayobjects.com/zos/k/e3/QLS7dG.png)位置，即为你的域名地址，点击即可访问，非常简单
5. **评论系统使用的是我的 key，若需自用，请参考 [giscus](https://giscus.app/zh-CN) 自行配置**
6. 请务必将 `config.ts` 中的信息配置为你自己的信息，特别是 repo，防止出现不可预料的错误

### GitHub 与 Vercel 的分工

- Vercel 连接此仓库，生产分支选 `main`，根目录选仓库根目录。构建使用 Node.js 24、`npm ci`、`npm run build`，发布 `dist`。构建会先生成文章 JSON，再生成静态页面和 Pagefind 搜索索引，不需要等 Actions 回写，也不需要在 Actions 配置 Vercel Token。
- GitHub Actions 的 `Verify site` 在推送或 PR 时独立验证构建。`Update article index` 在 `main` 的文章或生成配置变更时按 Git 历史更新 README、近期文章及 JSON，仅在结果变化时回写；如禁止机器人直推 `main`，目录回写会失败，但不影响 Vercel 自行构建。
- 新文章使用不重复的 `数字-标题.md` 文件名。建议显式填写 `date: YYYY/MM/DD`，否则文件创建时间可能随重新检出而变化。文章提交后可手动运行 `Update article index` 重建目录。

### 最后

1. 若你不是程序员，遇到不懂的名词，请谷歌解决，这个过程很有趣，若仍有问题，可直接问程序员，或提交 issue 问我
2. 期待你玩得开心，欢迎给我提建议，或推荐 dailyLog 给你的朋友
