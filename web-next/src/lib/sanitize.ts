/**
 * sanitizeHtml — lightweight server/client HTML sanitizer.
 *
 * No external dependencies. Uses an allowlist approach:
 * - Strips dangerous tags: <script>, <iframe>, <object>, <embed>, <form>
 * - Strips on* event handlers (onclick, onerror, onload, …)
 * - Strips javascript: URLs in href/src attributes
 * - Allows safe structural/inline tags with a limited set of attributes
 *
 * Safe tags allowed:
 *   p, br, strong, em, b, i, u, ul, ol, li,
 *   h1, h2, h3, h4, h5, h6,
 *   div, span,
 *   img (src, alt, width, height only),
 *   a (href only — javascript: stripped),
 *   table, thead, tbody, tr, td, th
 */

/** Tags whose full content (including children) must be removed. */
const DANGEROUS_TAGS = ['script', 'iframe', 'object', 'embed', 'form', 'style', 'base'];

/** Tags that are allowed through (case-insensitive). Everything else is tag-stripped (content kept). */
const ALLOWED_TAGS = new Set([
  'p', 'br', 'strong', 'em', 'b', 'i', 'u',
  'ul', 'ol', 'li',
  'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
  'div', 'span',
  'img',
  'a',
  'table', 'thead', 'tbody', 'tr', 'td', 'th',
]);

/** Attributes allowed per tag. '*' means any listed tag can have them. */
const ALLOWED_ATTRS: Record<string, Set<string>> = {
  '*': new Set(['class', 'id']),
  'a': new Set(['href', 'title', 'target', 'rel']),
  'img': new Set(['src', 'alt', 'width', 'height']),
  'td': new Set(['colspan', 'rowspan']),
  'th': new Set(['colspan', 'rowspan', 'scope']),
};

// ---------------------------------------------------------------------------
// Step 1: strip dangerous tags and all their content
// ---------------------------------------------------------------------------
function stripDangerousTags(html: string): string {
  for (const tag of DANGEROUS_TAGS) {
    // Match opening tag (with attributes) through closing tag including all content
    const re = new RegExp(`<${tag}[\\s\\S]*?<\\/${tag}\\s*>`, 'gi');
    html = html.replace(re, '');
    // Also strip self-closing variants and unclosed tags
    const reSelf = new RegExp(`<${tag}[^>]*?>`, 'gi');
    html = html.replace(reSelf, '');
  }
  return html;
}

// ---------------------------------------------------------------------------
// Step 2: strip on* event handlers from all remaining tags
// ---------------------------------------------------------------------------
function stripEventHandlers(html: string): string {
  // Replace on[event]="..." or on[event]='...' or on[event]=value inside tag attributes
  return html.replace(/(<[a-z][^>]*?)\s+on\w+\s*=\s*(?:"[^"]*"|'[^']*'|[^\s>]*)/gi, '$1');
}

// ---------------------------------------------------------------------------
// Step 3: strip javascript: URLs from href/src attributes
// ---------------------------------------------------------------------------
function stripJavascriptUrls(html: string): string {
  // href="javascript:..." → href="#"
  return html.replace(/(href|src|action)\s*=\s*["']?\s*javascript\s*:[^"'\s>]*/gi, '$1="#"');
}

// ---------------------------------------------------------------------------
// Step 4: allowlist — strip disallowed tags (keep their text content) and
//          strip disallowed attributes from allowed tags.
// ---------------------------------------------------------------------------
function applyAllowlist(html: string): string {
  // Process tag by tag
  return html.replace(/<\/?([a-z][a-z0-9]*)\b([^>]*)>/gi, (match, tagName: string, attrString: string) => {
    const tag = tagName.toLowerCase();

    // Closing tags: allow if tag is in allowlist
    if (match.trimStart().startsWith('</')) {
      return ALLOWED_TAGS.has(tag) ? `</${tag}>` : '';
    }

    // Opening tags not in allowlist: drop the tag but keep content
    if (!ALLOWED_TAGS.has(tag)) {
      return '';
    }

    // Parse and filter attributes
    const globalAttrs = ALLOWED_ATTRS['*'] ?? new Set<string>();
    const tagAttrs = ALLOWED_ATTRS[tag] ?? new Set<string>();
    const allowedForTag = new Set([...globalAttrs, ...tagAttrs]);

    // Match attribute key=value pairs
    const filteredAttrs: string[] = [];
    const attrRe = /(\w[\w-]*)\s*=\s*(?:"([^"]*)"|'([^']*)'|(\S+))/g;
    let m: RegExpExecArray | null;
    while ((m = attrRe.exec(attrString)) !== null) {
      const attrName = m[1].toLowerCase();
      const attrValue = m[2] ?? m[3] ?? m[4] ?? '';
      if (allowedForTag.has(attrName)) {
        // Extra safety: strip javascript: from any remaining attr values
        const safeValue = attrValue.replace(/^\s*javascript\s*:/i, '');
        filteredAttrs.push(`${attrName}="${safeValue.replace(/"/g, '&quot;')}"`);
      }
    }

    // Also handle boolean attributes (no value)
    const boolRe = /(?:^|\s)(\w[\w-]*)(?=\s|$|>)/g;
    while ((m = boolRe.exec(attrString)) !== null) {
      const attrName = m[1].toLowerCase();
      // Skip if it looks like it has a value (already matched above)
      if (allowedForTag.has(attrName) && !attrString.match(new RegExp(`${attrName}\\s*=`))) {
        filteredAttrs.push(attrName);
      }
    }

    const isSelfClosing = attrString.trimEnd().endsWith('/') || tag === 'br' || tag === 'img';
    const attrsStr = filteredAttrs.length > 0 ? ' ' + filteredAttrs.join(' ') : '';
    return isSelfClosing ? `<${tag}${attrsStr} />` : `<${tag}${attrsStr}>`;
  });
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/**
 * Sanitize an HTML string to prevent XSS.
 *
 * @param html - Raw HTML string (e.g. from a CMS or database field)
 * @returns Sanitized HTML safe to render via dangerouslySetInnerHTML
 */
export function sanitizeHtml(html: string): string {
  if (!html) return '';
  let result = html;
  result = stripDangerousTags(result);
  result = stripEventHandlers(result);
  result = stripJavascriptUrls(result);
  result = applyAllowlist(result);
  return result;
}
