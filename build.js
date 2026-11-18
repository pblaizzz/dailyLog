import { promises as fs } from "fs";
import { execFileSync } from "node:child_process";
import { SITE } from "./src/config.ts";

async function main() {
  const publicIndexOnly = process.argv.includes('--public-only');
  const readmeContent = `# ${SITE.title}\n\n`;

  const files = await fs.readdir("./src/pages/posts");
  const mdFiles = files
    .filter((file) => file.endsWith(".md"))
    .sort((a, b) => {
      const numA = parseInt(a.match(/(\d+)/)[0]);
      const numB = parseInt(b.match(/(\d+)/)[0]);
      return numB - numA;
    });

  const posts = [];
  let recentContent = "";
  let readmeContent2 = "";

  for (let i = 0; i < mdFiles.length; i++) {
    const name = mdFiles[i];
    const filePath = `src/pages/posts/${name}`;
    const oldTitle = name.slice(0, -3);
    const [issueNumberPart, ...restTitleParts] = oldTitle.split("-");
    const num = parseInt(issueNumberPart);
    const shortTitle = restTitleParts.join("-") || issueNumberPart;
    const url = new URL(`/posts/${num}`, SITE.homePage).href;
    const title = `第 ${num} 期 - ${shortTitle}`;

    // Read markdown file to extract cover image and description
    const mdContent = await fs.readFile(filePath, "utf8");
    const imgMatch = mdContent.match(/<img\s+src="([^"]+)"/);
    const pic = imgMatch ? imgMatch[1] : "";
    
    const descMatch = mdContent.match(/<small>(.*?)<\/small>/s);
    const description = descMatch ? descMatch[1].trim() : "";

    posts.push({ num, title: shortTitle, url, pic, description });
    readmeContent2 += `* [${title}](${url})\n`;

    if (!publicIndexOnly && i < 5) {
      const modified = execFileSync('git', ['log', '-1', '--format=%cs', '--', filePath], { encoding: 'utf8' }).trim();
      if (!modified) throw new Error(`未找到文章的 Git 提交日期：${filePath}`);
      recentContent += `* [${title}](${url}) - ${modified}\n`;
    }
  }

  await fs.writeFile("public/posts.json", JSON.stringify(posts, null, 2));
  if (publicIndexOnly) return;
  await Promise.all([
    fs.writeFile("README.md", readmeContent + readmeContent2),
    fs.writeFile("RECENT.md", recentContent),
  ]);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
