# Signal — AI & Tech RSS Feed Dashboard

A clean, dark-themed RSS aggregator dashboard that pulls and filters AI & technology articles from **Bloomberg Technology** and **Reuters Technology**, ranks the top 10 from each, and explains *why* each article made the cut.

![Signal Dashboard](https://img.shields.io/badge/Status-Active-brightgreen) ![HTML](https://img.shields.io/badge/Built%20With-HTML%2FCS%2FJS-orange) ![No Dependencies](https://img.shields.io/badge/Dependencies-None-blue)

---

## Features

- Side-by-side Bloomberg and Reuters columns
- Color-coded signal pills on every article (Threat, Market Mover, Breaking, Geopolitical, etc.)
- Filter by source or search by keyword
- "Why Top 10?" expandable panel on each article
- Live stats bar showing article counts
- Refresh button with animation
- One-click RSS feed URL copy
- Fully self-contained — no server, no dependencies, just open in a browser

---

## RSS Feeds Used

| Source | Feed URL |
|--------|----------|
| Bloomberg Technology | `https://feeds.bloomberg.com/technology/news.rss` |
| Reuters Technology | `https://news.google.com/rss/search?q=site%3Areuters.com&hl=en-US&gl=US&ceid=US%3Aen` |

---

## How to Use

1. Download `index.html`
2. Open it in any browser
3. That's it — no install, no server, no dependencies

### To host it online
Drop `index.html` into any static host:
- **Netlify**: Drag and drop the file at netlify.com/drop
- **GitHub Pages**: Push to a repo and enable Pages in settings
- **Vercel**: `vercel --prod` in the project folder

---

## How This Was Built — The Prompts

This entire project was built in a single Claude conversation using the following prompts in sequence:

---

### 1. Initial RSS Feed Test
> "Can you take a RSS feed like this and pull any articles related to tech and AI and give me a list of the top 10 most popular, titles only"
> `https://news.google.com/rss/search?q=site%3Areuters.com&hl=en-US&gl=US&ceid=US%3Aen`

**What happened:** Claude discovered that Google News RSS URLs and Reuters block direct headless fetches, so it used web search as a workaround to surface the top Reuters AI/tech headlines.

---

### 2. Adding Rationale
> "Can you add the reason why those are the top 10"

**What happened:** Claude added a rationale for each article explaining why it ranked — based on brand recognition, concrete consequences, audience fit, and virality signals.

---

### 3. Bloomberg Feed
> "Can you find the bloomberg rss feed and do the same thing"

**What happened:** Claude found the live Bloomberg Technology RSS feed at `feeds.bloomberg.com/technology/news.rss`, fetched real current headlines, and produced a ranked top 10 with rationale — noting Bloomberg's audience skews more financial/investor-focused vs Reuters' policy/regulatory angle.

---

### 4. Build the Dashboard
> "Can you build me a quick dashboard where I could see those two feeds as an RSS feed like an aggregator app"

**What happened:** Claude built a full single-file HTML dashboard called "Signal" with a dark editorial aesthetic, side-by-side columns, filtering, search, stats bar, and expandable "Why Top 10?" panels per article.

---

### 5. Add Signal Pills
> "Can you add a cool pill styled tag for each article on the reason why it was pulled in for context"

**What happened:** Claude added color-coded pill tags to every article card — always visible, no click needed — with a taxonomy of 8 signal types (Threat, Market Mover, Breaking, Geopolitical, Viral Potential, Policy Signal, Investor Alert, Industry Shift).

---

## Signal Pill Taxonomy

| Pill | Color | Meaning |
|------|-------|---------|
| High Threat Score | 🔴 Red | Security or societal threat |
| Breaking / Historic Milestone | 🟠 Orange | News urgency or recency |
| Market Mover | 🟡 Amber | Financial market impact |
| Investor Alert | 🟢 Green | Portfolio/investment relevance |
| Policy Signal / Regulatory Watch | 🔵 Blue | Government or regulatory angle |
| Geopolitical Risk | 🟣 Purple | Cross-border or national security |
| Viral Potential / High Engagement | 🩷 Pink | Audience reach and shareability |
| Trending / Industry Shift | 🩵 Teal | Macro trend or structural change |

---

## Next Steps / Roadmap

- [ ] Backend proxy to live-parse the RSS feeds on a schedule
- [ ] Node.js/serverless function for real-time feed fetching
- [ ] AI scoring layer to auto-rank and auto-tag incoming articles
- [ ] Add more feed sources (TechCrunch, WSJ, FT)
- [ ] Email digest / Slack webhook integration

---

## Built With

- Vanilla HTML/CSS/JS — zero frameworks, zero dependencies
- [IBM Plex Mono + IBM Plex Sans + Playfair Display](https://fonts.google.com) via Google Fonts
- Built entirely via prompt in [Claude](https://claude.ai) by Anthropic

---

*Built by [@pbomers](https://github.com/pbomers) with Claude*
