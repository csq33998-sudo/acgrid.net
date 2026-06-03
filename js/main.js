(function () {
  const storeUrl = "https://maisonlooks.com/en/products";
  const products = window.MAISONLOOKS_PRODUCTS || [];
  const categoryGrid = document.querySelector("#categoryGrid");
  const filterTabs = document.querySelector("#filterTabs");
  const productGrid = document.querySelector("#productGrid");
  const resultsMeta = document.querySelector("#resultsMeta");
  const searchInput = document.querySelector("#searchInput");
  const sortSelect = document.querySelector("#sortSelect");
  const searchPanel = document.querySelector(".search-panel");

  const state = {
    category: "All",
    query: new URLSearchParams(window.location.search).get("q") || "",
    sort: "featured"
  };

  const categories = ["All", ...Array.from(new Set(products.map((product) => product.category)))];

  function formatPrice(price) {
    return "$" + Number(price).toFixed(0);
  }

  function getCategorySummary(category) {
    const count = category === "All" ? products.length : products.filter((product) => product.category === category).length;
    const labels = {
      All: "All curated MaisonLooks picks",
      Shoes: "Sneakers and daily footwear",
      Hoodies: "Fleece, zip-ups, and pullovers",
      "T-Shirts": "Boxy tees and graphics",
      Bags: "Crossbody and utility bags",
      Pants: "Cargos, denim, and relaxed bottoms",
      Jackets: "Outerwear and statement layers",
      Accessories: "Caps, belts, and small add-ons",
      Sweaters: "Knits and soft layers"
    };
    return `${count} finds - ${labels[category] || "Streetwear picks"}`;
  }

  function productMatches(product) {
    const query = state.query.trim().toLowerCase();
    const matchesCategory = state.category === "All" || product.category === state.category;
    const haystack = [product.title, product.category, product.qc, product.note].join(" ").toLowerCase();
    return matchesCategory && (!query || haystack.includes(query));
  }

  function sortProducts(items) {
    return [...items].sort((a, b) => {
      if (state.sort === "price-low") return a.price - b.price;
      if (state.sort === "price-high") return b.price - a.price;
      if (state.sort === "rating") return b.rating - a.rating;
      return products.indexOf(a) - products.indexOf(b);
    });
  }

  function renderCategories() {
    categoryGrid.innerHTML = categories
      .map(
        (category) => `
          <button class="category-card ${state.category === category ? "is-active" : ""}" type="button" data-category="${category}">
            <strong>${category}</strong>
            <span>${getCategorySummary(category)}</span>
          </button>
        `
      )
      .join("");
  }

  function renderTabs() {
    filterTabs.innerHTML = categories
      .map(
        (category) => `
          <button class="${state.category === category ? "is-active" : ""}" type="button" data-category="${category}" role="tab" aria-selected="${
          state.category === category ? "true" : "false"
        }">
            ${category}
          </button>
        `
      )
      .join("");
  }

  function renderProducts() {
    const items = sortProducts(products.filter(productMatches));
    resultsMeta.textContent = `${items.length} finds shown for ${state.category}${state.query ? ` matching "${state.query}"` : ""}.`;
    productGrid.innerHTML = items
      .map(
        (product) => `
          <article class="product-card">
            <img src="${product.image}" alt="${product.title}, ${product.category} streetwear find in the AlIChinaBuy AllChinaBuy spreadsheet with QC photo notes" loading="lazy" decoding="async" />
            <div class="product-body">
              <div class="card-top">
                <span class="tag">${product.category}</span>
                <span class="rating">${product.rating.toFixed(1)} QC</span>
              </div>
              <h3>${product.title}</h3>
              <p>${product.note}</p>
              <div class="price-row">
                <span class="price">${formatPrice(product.price)}</span>
                <span class="qc">${product.qc}</span>
              </div>
              <a href="${storeUrl}" target="_blank" rel="noopener noreferrer">Shop at MaisonLooks</a>
            </div>
          </article>
        `
      )
      .join("");
  }

  function render() {
    renderCategories();
    renderTabs();
    renderProducts();
  }

  function setCategory(category) {
    state.category = category;
    render();
    document.querySelector("#finds").scrollIntoView({ behavior: "smooth", block: "start" });
  }

  categoryGrid.addEventListener("click", (event) => {
    const button = event.target.closest("[data-category]");
    if (button) setCategory(button.dataset.category);
  });

  filterTabs.addEventListener("click", (event) => {
    const button = event.target.closest("[data-category]");
    if (button) setCategory(button.dataset.category);
  });

  searchPanel.addEventListener("submit", (event) => {
    event.preventDefault();
    state.query = searchInput.value;
    renderProducts();
    document.querySelector("#finds").scrollIntoView({ behavior: "smooth", block: "start" });
  });

  searchInput.addEventListener("input", () => {
    state.query = searchInput.value;
    renderProducts();
  });

  sortSelect.addEventListener("change", () => {
    state.sort = sortSelect.value;
    renderProducts();
  });

  if (state.query) {
    searchInput.value = state.query;
  }

  render();
})();
