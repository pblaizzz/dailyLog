// Helper function to extract and decode the title part from the URL
const extractTitlePart = (currentPage: string) => {
  const [, raw = ""] = currentPage.split("/posts/");
  return decodeURIComponent(raw.replace(/\/$/, ""));
};

const getSlugParts = (slug: string) => {
  const [numberPart = "", ...nameParts] = slug.split("-");
  return {
    numberPart,
    name: nameParts.join("-"),
  };
};

// Convert to title
export const parseTitle = (currentPage: string, legacySlug?: string, fallbackName = "") => {
  const slug = legacySlug ?? extractTitlePart(currentPage);
  const { numberPart, name } = getSlugParts(slug);
  const displayName = name || fallbackName;
  let title = `第${numberPart}期`;
  if (displayName) {
    title += ` - ${displayName}`;
  }
  return title;
};

// Get the current article number.
export const getIndex = (currentPage: string) => {
  const { numberPart } = getSlugParts(extractTitlePart(currentPage));
  return Number.parseInt(numberPart, 10);
};

// Normalize URL to numeric form.
export const toNumericUrl = (currentPage: string) => {
  const index = getIndex(currentPage);
  return Number.isNaN(index) ? currentPage : `/posts/${index}`;
};

// Sort all articles.
export const sortPosts = (allPosts: any) => {
  return allPosts.sort((a, b) => getIndex(b.url) - getIndex(a.url));
};
