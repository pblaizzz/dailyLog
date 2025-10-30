import rss from "@astrojs/rss";
import { SITE } from "@/config";
import { getIndex, parseTitle, toNumericUrl } from "@/util";
export async function GET() {
  let allPosts = import.meta.glob("./posts/*.md", { eager: true });
  let posts = Object.values(allPosts);

  posts = posts.sort((a, b) => getIndex(b.url) - getIndex(a.url));

  // Only 12 are kept
  posts = posts.slice(0, 12);

  // 处理 Markdown 内容，返回不过滤的标签的原始内容
  const processContent = async (item) => {
    const content = await item.compiledContent();
    return content;
  };

  return rss({
    title: "潮流周刊",
    description: "记录工程师 Paxton 的不枯燥生活",
    // 必须是带协议的绝对 URL；优先使用站点配置，开发环境回退到本地地址
    site: SITE.homePage || "http://localhost:4321/",
    customData: `<image><url>https://gw.alipayobjects.com/zos/k/qv/coffee-2-icon.png</url></image><follow_challenge><feedId>41147805276726275</feedId><userId>42909600318350336</userId></follow_challenge>`,
    items: await Promise.all(
      posts.map(async (item) => {
        const numericLink = item.frontmatter.numericUrl ?? toNumericUrl(item.url);
        const title = parseTitle(
          numericLink,
          item.frontmatter.legacySlug,
          item.frontmatter.issueTitle,
        );
        return {
          link: numericLink,
          title,
          description: await processContent(item),
          pubDate: item.frontmatter.date,
        };
      }),
    ),
  });
}
