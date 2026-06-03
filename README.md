# MaisonLooks Grid

A static spreadsheet-style streetwear directory built to promote:

https://streetstyle.maisonlooks.com/

## Files

- `index.html` - SEO landing page and product grid
- `styles.css` - responsive layout and visual design
- `js/products.js` - editable product data
- `js/main.js` - search, category filters, and sorting
- `robots.txt` and `sitemap.xml` - basic crawl setup

## Update Products

Edit `js/products.js` and replace the sample entries with real MaisonLooks products.
Each product supports:

```js
{
  title: "Product name",
  category: "Hoodies",
  price: 46,
  rating: 4.9,
  qc: "QC note",
  note: "Short buyer-facing description",
  image: "https://..."
}
```

## Deploy

This is a static site. Upload the folder to Cloudflare Pages, Vercel, Netlify, or any static host.
