// ── Category emoji map ──────────────────────
const categoryEmoji = {
  "Payments": "\u{1F4B3}",
  "Design": "\u{1F3A8}",
  "Agent Ops": "\u{1F916}",
  "Automation": "\u{2699}\u{FE0F}",
};
const categoryClass = {
  "Payments": "payments",
  "Design": "design",
  "Agent Ops": "agent-ops",
  "Automation": "automation",
};

// ── Skills data ────────────────────────────
const skills = [
  {
    id: "agent-commerce-kit",
    title: "Agent Commerce Kit",
    category: "Payments",
    summary: "A complete premium-skill checkout package with order states, SePay webhook rules, and entitlement logic.",
    price: 899000,
    compareAtPrice: 1299000,
    badge: "popular",
    includes: ["Checkout copy", "Webhook contract", "Entitlement model", "Launch checklist"],
    outcomes: ["Sell skills with a clear purchase path", "Keep payment secrets server-side", "Handle duplicate webhook events safely"],
    tags: ["SePay", "Webhook", "Access"]
  },
  {
    id: "taste-ui-pack",
    title: "Taste UI Pack",
    category: "Design",
    summary: "Premium storefront sections inspired by editorial layouts, dense bento grids, and confident CTAs.",
    price: 549000,
    compareAtPrice: 799000,
    badge: "new",
    includes: ["Hero patterns", "Skill cards", "Checkout modal", "Motion notes"],
    outcomes: ["Avoid generic landing pages", "Present skills as valuable products", "Ship a polished static storefront"],
    tags: ["UI", "AIDA", "Bento"]
  },
  {
    id: "review-agent-suite",
    title: "Review Agent Suite",
    category: "Agent Ops",
    summary: "A packaged review workflow for code, architecture, security, reliability, and release readiness.",
    price: 699000,
    compareAtPrice: 999000,
    badge: null,
    includes: ["Review prompts", "Finding templates", "Risk rubric", "PR summary format"],
    outcomes: ["Run sharper reviews", "Standardize findings", "Reduce release surprises"],
    tags: ["Review", "Quality", "Release"]
  },
  {
    id: "automation-rituals",
    title: "Automation Rituals",
    category: "Automation",
    summary: "Operational routines for recurring checks, cleanup, evals, and project memory hygiene.",
    price: 499000,
    compareAtPrice: null,
    badge: "deal",
    includes: ["Automation map", "Eval routine", "Memory ledger prompts", "Cleanup scripts plan"],
    outcomes: ["Make workflows repeatable", "Preserve project context", "Catch drift earlier"],
    tags: ["Ops", "Memory", "Evals"]
  },
  {
    id: "premium-launch-room",
    title: "Premium Launch Room",
    category: "Agent Ops",
    summary: "A launch command center for pricing, feature list, fulfillment, support, and buyer onboarding.",
    price: 799000,
    compareAtPrice: 1199000,
    badge: "popular",
    includes: ["Pricing matrix", "Buyer onboarding", "Support macros", "Launch QA"],
    outcomes: ["Launch with less chaos", "Know what buyers receive", "Create a support-ready process"],
    tags: ["Launch", "Support", "Pricing"]
  }
];

const apiBaseUrl = "http://localhost:5174";

const state = {
  filter: "all",
  storeFilter: "all",
  storeSearch: "",
  storeSort: "featured",
  selectedSkillId: skills[0].id,
  checkoutSkillId: skills[0].id,
  catalog: skills,
  apiOnline: false,
  authToken: localStorage.getItem("skillStoreToken") || "",
  storeLoading: false
};

// ── Theme ───────────────────────────────────
const savedTheme = localStorage.getItem("skillStoreTheme");
const preferredTheme = window.matchMedia("(prefers-color-scheme: light)").matches ? "light" : "dark";
const initialTheme = savedTheme || preferredTheme;
document.documentElement.dataset.theme = initialTheme;

const grid = document.querySelector("#skill-grid");
const storeGrid = document.querySelector("#store-grid");
const storeSkeleton = document.querySelector("#store-skeleton");
const storeCount = document.querySelector("#store-count");
const storeSearch = document.querySelector("#store-search");
const storeSort = document.querySelector("#store-sort");
const detail = document.querySelector("#skill-detail");
const modal = document.querySelector("#checkout-modal");
const modalSkillName = document.querySelector("#modal-skill-name");
const modalSkillPrice = document.querySelector("#modal-skill-price");
const modalOrderCode = document.querySelector("#modal-order-code");
const modalTransferContent = document.querySelector("#modal-transfer-content");
const paymentStatus = document.querySelector("#payment-status");
const checkoutForm = document.querySelector("#checkout-form");
const themeToggles = document.querySelectorAll("[data-theme-toggle]");
const toastEl = document.querySelector("#toast");

// ── Helpers ─────────────────────────────────
function syncThemeButtons() {
  const theme = document.documentElement.dataset.theme || "dark";
  themeToggles.forEach(function (button) {
    button.textContent = theme === "dark" ? "Dark" : "Light";
    button.setAttribute("aria-pressed", String(theme === "light"));
  });
}

function toggleTheme() {
  var current = document.documentElement.dataset.theme || "dark";
  var next = current === "dark" ? "light" : "dark";
  document.documentElement.dataset.theme = next;
  localStorage.setItem("skillStoreTheme", next);
  syncThemeButtons();
}

function formatVnd(value) {
  return new Intl.NumberFormat("vi-VN", { style: "currency", currency: "VND", maximumFractionDigits: 0 }).format(value);
}

function discountPercent(price, compareAt) {
  if (!compareAt || compareAt <= price) return 0;
  return Math.round((1 - price / compareAt) * 100);
}

function selectedSkill() {
  return state.catalog.find(function (s) { return s.id === state.selectedSkillId; }) || state.catalog[0];
}

function checkoutSkill() {
  return state.catalog.find(function (s) { return s.id === state.checkoutSkillId; }) || selectedSkill();
}

function showToast(msg) {
  if (!toastEl) return;
  toastEl.textContent = msg;
  toastEl.classList.add("show");
  clearTimeout(toastEl._timeout);
  toastEl._timeout = setTimeout(function () { toastEl.classList.remove("show"); }, 2200);
}

// ── Skeleton ────────────────────────────────
function showStoreSkeleton() {
  state.storeLoading = true;
  if (storeSkeleton) storeSkeleton.style.display = "";
  if (storeGrid) storeGrid.style.display = "none";
}

function hideStoreSkeleton() {
  state.storeLoading = false;
  if (storeSkeleton) storeSkeleton.style.display = "none";
  if (storeGrid) storeGrid.style.display = "";
}

// ── Render catalog grid (index page) ───────
function renderGrid() {
  if (!grid) return;
  var filtered = state.filter === "all" ? state.catalog : state.catalog.filter(function (s) { return s.category === state.filter; });

  grid.innerHTML = filtered.map(function (skill) {
    var price = skill.price || (skill.plans && skill.plans[0] && skill.plans[0].priceVnd) || 0;
    var cat = skill.category || "";
    var emoji = categoryEmoji[cat] || "\u{1F4E6}";
    return (
      '<button class="skill-card" type="button" data-skill-id="' + skill.id + '">' +
        '<div class="skill-meta">' +
          '<span>' + emoji + ' ' + cat + '</span>' +
          '<span>' + formatVnd(price) + '</span>' +
        '</div>' +
        '<h3>' + skill.title + '</h3>' +
        '<p>' + skill.summary + '</p>' +
        '<div class="tag-row">' +
          (skill.tags || []).map(function (tag) { return '<span class="tag">' + tag + '</span>'; }).join("") +
        '</div>' +
      '</button>'
    );
  }).join("");
}

// ── Render store grid ──────────────────────
function renderStore() {
  if (!storeGrid) return;

  var query = state.storeSearch.trim().toLowerCase();
  var filtered = state.catalog
    .filter(function (s) { return state.storeFilter === "all" || s.category === state.storeFilter; })
    .filter(function (s) {
      if (!query) return true;
      var haystack = [s.title, s.summary, s.category].concat(s.includes || [], s.outcomes || [], s.tags || []).join(" ").toLowerCase();
      return haystack.indexOf(query) !== -1;
    })
    .sort(function (a, b) {
      var pa = a.price || (a.plans && a.plans[0] && a.plans[0].priceVnd) || 0;
      var pb = b.price || (b.plans && b.plans[0] && b.plans[0].priceVnd) || 0;
      if (state.storeSort === "price-asc") return pa - pb;
      if (state.storeSort === "price-desc") return pb - pa;
      return state.catalog.indexOf(a) - state.catalog.indexOf(b);
    });

  if (storeCount) storeCount.textContent = filtered.length;

  hideStoreSkeleton();

  if (filtered.length === 0) {
    storeGrid.innerHTML = '<div class="store-empty"><div class="store-empty-emoji">\u{1F50D}</div><strong>Khong tim thay san pham</strong>Thu tu khoa khac hoac chon danh muc khac.</div>';
    return;
  }

  storeGrid.innerHTML = filtered.map(function (skill) {
    var price = skill.price || (skill.plans && skill.plans[0] && skill.plans[0].priceVnd) || 0;
    var compareAt = skill.compareAtPrice || (skill.plans && skill.plans[0] && skill.plans[0].compareAtPriceVnd) || null;
    var disc = discountPercent(price, compareAt);
    var cat = skill.category || "";
    var emoji = categoryEmoji[cat] || "\u{1F4E6}";
    var cssCat = categoryClass[cat] || "";
    var includes = skill.includes || ["Premium skill package", "Checkout usage notes", "Access after payment confirmation"];
    var outcomes = skill.outcomes || ["Unlock premium content", "Test checkout API", "Confirm payment by webhook"];
    var tags = skill.tags || [cat, "Premium"];
    var badge = skill.badge;
    var badgeHtml = "";
    if (badge === "popular") badgeHtml = '<span class="store-card-badge popular">Pho bien</span>';
    else if (badge === "new") badgeHtml = '<span class="store-card-badge new">Moi</span>';
    else if (badge === "deal") badgeHtml = '<span class="store-card-badge">Giam gia</span>';

    return (
      '<article class="store-product-card">' +
        badgeHtml +
        '<div class="store-product-topline">' +
          '<span>' + emoji + ' ' + cat + '</span>' +
          '<span class="store-card-icon ' + cssCat + '">' + emoji + '</span>' +
        '</div>' +
        '<h3>' + skill.title + '</h3>' +
        '<p>' + skill.summary + '</p>' +
        '<div class="store-price-row">' +
          '<div>' +
            '<strong>' + formatVnd(price) + '</strong>' +
            (compareAt ? ' <span>' + formatVnd(compareAt) + '</span>' : '') +
          '</div>' +
          (disc > 0 ? '<span class="store-discount-badge">-' + disc + '%</span>' : '') +
        '</div>' +
        '<div class="store-card-grid">' +
          '<div>' +
            '<span class="store-card-label">Ket qua</span>' +
            '<ul>' + outcomes.slice(0, 3).map(function (o) { return '<li>' + o + '</li>'; }).join("") + '</ul>' +
          '</div>' +
          '<div>' +
            '<span class="store-card-label">Bao gom</span>' +
            '<ul>' + includes.slice(0, 3).map(function (i) { return '<li>' + i + '</li>'; }).join("") + '</ul>' +
          '</div>' +
        '</div>' +
        '<div class="tag-row">' +
          tags.slice(0, 4).map(function (t) { return '<span class="tag">' + t + '</span>'; }).join("") +
        '</div>' +
        '<div class="store-product-actions">' +
          '<button class="button button-primary" type="button" data-buy-product="' + skill.id + '">Mua ngay</button>' +
          '<button class="button button-secondary button-small" type="button" data-preview-product="' + skill.id + '">Xem truoc</button>' +
        '</div>' +
      '</article>'
    );
  }).join("");
}

// ── Render detail panel ────────────────────
function renderDetail() {
  if (!detail) return;
  var skill = selectedSkill();
  var price = skill.price || (skill.plans && skill.plans[0] && skill.plans[0].priceVnd) || 0;
  var includes = skill.includes || ["Premium skill package", "Checkout-ready usage notes", "Access after payment confirmation"];
  var outcomes = skill.outcomes || ["Unlock premium content", "Use local checkout API", "Test SePay webhook confirmation"];
  detail.innerHTML =
    '<p class="eyebrow">Ky nang da chon</p>' +
    '<h2>' + skill.title + '</h2>' +
    '<p>' + skill.summary + '</p>' +
    '<div class="detail-price">' + formatVnd(price) + '</div>' +
    '<ul class="detail-list">' +
      outcomes.map(function (o) { return '<li>' + o + '</li>'; }).join("") +
    '</ul>' +
    '<p><strong>Bao gom:</strong> ' + includes.join(", ") + '</p>' +
    '<button class="button button-primary" type="button" data-buy-selected>Mua ky nang premium</button>';
}

function renderAll() {
  renderGrid();
  renderDetail();
  // only show skeleton on first render, then hide
  if (!state.storeLoading) hideStoreSkeleton();
  renderStore();
}

// ── Checkout ────────────────────────────────
function createOrderCode(skill) {
  var date = new Date().toISOString().slice(0, 10).replaceAll("-", "");
  var suffix = skill.id.split("-").map(function (p) { return p[0]; }).join("").toUpperCase().slice(0, 4);
  return "SKILL-" + date + "-" + suffix;
}

async function openCheckout(skillId) {
  if (!skillId) skillId = state.selectedSkillId;
  state.checkoutSkillId = skillId;
  var skill = checkoutSkill();
  var localPrice = skill.price || (skill.plans && skill.plans[0] && skill.plans[0].priceVnd) || 0;
  var orderCode = createOrderCode(skill);
  var amount = localPrice;
  var qrImageUrl = "";

  if (state.apiOnline && skill.plans && skill.plans[0]) {
    try {
      var headers = { "content-type": "application/json" };
      if (state.authToken) headers.authorization = "Bearer " + state.authToken;
      var resp = await fetch(apiBaseUrl + "/api/checkout/sessions", {
        method: "POST",
        headers: headers,
        body: JSON.stringify({ skillId: skill.id, planId: skill.plans[0].id, buyerEmail: document.querySelector("#buyer-email") ? document.querySelector("#buyer-email").value : "buyer@example.com" })
      });
      var data = await resp.json();
      if (resp.ok) {
        orderCode = data.order.orderCode;
        amount = data.order.amountVnd;
        qrImageUrl = data.paymentInstruction ? data.paymentInstruction.qrImageUrl : "";
      }
    } catch (_err) {
      state.apiOnline = false;
    }
  }

  modalSkillName.textContent = skill.title;
  modalSkillPrice.textContent = formatVnd(amount);
  modalOrderCode.textContent = orderCode;
  modalTransferContent.textContent = orderCode;
  var qrNoteEl = document.querySelector("#qr-note");
  if (qrNoteEl) qrNoteEl.textContent = qrImageUrl ? "QR tu backend SePay (demo)." : "QR placeholder. Thay bang SePay QR tu backend cua ban.";
  paymentStatus.textContent = "Doi webhook SePay";
  paymentStatus.classList.remove("is-paid");
  modal.classList.add("is-open");
  modal.setAttribute("aria-hidden", "false");
}

function closeCheckout() {
  modal.classList.remove("is-open");
  modal.setAttribute("aria-hidden", "true");
}

// ── Event delegation ───────────────────────
document.addEventListener("click", function (event) {
  var themeToggle = event.target.closest("[data-theme-toggle]");
  var filterBtn = event.target.closest("[data-filter]");
  var skillCard = event.target.closest("[data-skill-id]");
  var buySelected = event.target.closest("[data-buy-selected]");
  var openBtn = event.target.closest("[data-open-checkout]");
  var buyProduct = event.target.closest("[data-buy-product]");
  var previewProduct = event.target.closest("[data-preview-product]");
  var storeFilterBtn = event.target.closest("[data-store-filter]");
  var closeBtn = event.target.closest("[data-close-modal]");
  var accordionBtn = event.target.closest("[data-accordion]");

  if (themeToggle) toggleTheme();

  if (filterBtn) {
    state.filter = filterBtn.dataset.filter;
    document.querySelectorAll("[data-filter]").forEach(function (b) { b.classList.toggle("is-active", b === filterBtn); });
    renderGrid();
  }

  if (storeFilterBtn) {
    state.storeFilter = storeFilterBtn.dataset.storeFilter;
    document.querySelectorAll("[data-store-filter]").forEach(function (b) { b.classList.toggle("is-active", b === storeFilterBtn); });
    showStoreSkeleton();
    setTimeout(function () { renderStore(); }, 150);
  }

  if (skillCard) {
    state.selectedSkillId = skillCard.dataset.skillId;
    renderDetail();
    var premiumSection = document.querySelector("#premium");
    if (premiumSection) premiumSection.scrollIntoView({ behavior: "smooth", block: "start" });
  }

  if (buySelected) openCheckout(state.selectedSkillId);
  if (buyProduct) {
    openCheckout(buyProduct.dataset.buyProduct);
    showToast("\u{2705} Da them vao gio hang!");
  }
  if (previewProduct) {
    state.selectedSkillId = previewProduct.dataset.previewProduct;
    renderDetail();
    // scroll to detail if on index page; otherwise scroll to top smoothly
    var target = document.querySelector("#premium") || document.querySelector(".store-hero");
    if (target) target.scrollIntoView({ behavior: "smooth", block: "start" });
  }
  if (openBtn) openCheckout(state.selectedSkillId);
  if (closeBtn || event.target === modal) closeCheckout();

  if (accordionBtn) {
    document.querySelectorAll("[data-accordion]").forEach(function (b) { b.classList.toggle("is-open", b === accordionBtn); });
  }
});

if (storeSearch) {
  storeSearch.addEventListener("input", function (event) {
    state.storeSearch = event.target.value;
    showStoreSkeleton();
    clearTimeout(storeSearch._debounce);
    storeSearch._debounce = setTimeout(function () { renderStore(); }, 200);
  });
}

if (storeSort) {
  storeSort.addEventListener("change", function (event) {
    state.storeSort = event.target.value;
    showStoreSkeleton();
    setTimeout(function () { renderStore(); }, 100);
  });
}

if (checkoutForm) {
  checkoutForm.addEventListener("submit", function (event) {
    event.preventDefault();
    paymentStatus.textContent = "Da thanh toan. Premium da duoc mo khoa (demo).";
    paymentStatus.classList.add("is-paid");
    showToast("\u{1F389} Thanh toan thanh cong!");
  });
}

document.addEventListener("keydown", function (event) {
  if (event.key === "Escape") closeCheckout();
});

// ── API catalog loader ─────────────────────
async function loadApiCatalog() {
  try {
    var resp = await fetch(apiBaseUrl + "/api/skills");
    if (!resp.ok) return;
    var data = await resp.json();
    if (Array.isArray(data.skills) && data.skills.length > 0) {
      state.catalog = data.skills;
      state.selectedSkillId = data.skills[0].id;
      state.checkoutSkillId = data.skills[0].id;
      state.apiOnline = true;
      renderAll();
    }
  } catch (_err) {
    state.apiOnline = false;
    renderAll();
  }
}

// ── Init ────────────────────────────────────
syncThemeButtons();
showStoreSkeleton();
setTimeout(function () {
  renderAll();
  loadApiCatalog();
}, 100);
