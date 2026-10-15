---
theme: default
title: Sharing Development Secrets Securely with SOPS + age
info: |
  ## Sharing Development Secrets Securely with SOPS + age
  A hands-on walkthrough of encrypting .env secrets with SOPS and age.
colorSchema: auto
fonts:
  sans: 'Roboto'
  mono: 'Fira Code'
highlighter: shiki
transition: fade
layout: default
class: g-slide
---

<div class="g-cover">
  <div class="g-dots"></div>
  <div class="g-eyebrow">Secure secrets, developer-friendly workflow</div>
  <h1>Sharing Development Secrets Securely with SOPS + age</h1>
  <p class="g-sub">
    A hands-on demo of encrypting and decrypting <code>.env</code> secrets
    with <strong>SOPS</strong> and <strong>age</strong> — so every teammate
    keeps their own key, and nothing sensitive ever hits git in plain text.
  </p>
</div>

<div class="g-brand">
  <img src="/anuchito_logo.svg" alt="AnuchitO" />
</div>

<div class="g-footer">
  <span>demo-sops</span>
  <span>github.com/getsops/sops</span>
</div>

---
layout: default
---

# Agenda

<div class="g-grid-2" style="margin-top: 1.5rem;">
  <div class="g-card accent-blue">
    <h3>01 · Setup</h3>
    <p>Requirements and a first look at the full encrypt/decrypt workflow.</p>
  </div>
  <div class="g-card accent-red">
    <h3>02 · Learning the basics</h3>
    <p>Generating an age key, encrypting, decrypting, and editing in place.</p>
  </div>
  <div class="g-card accent-yellow">
    <h3>03 · Real-world config</h3>
    <p>Leaving some keys unencrypted, <code>.sops.yaml</code>, and sharing with a team.</p>
  </div>
  <div class="g-card accent-green">
    <h3>04 · Scaling up</h3>
    <p>Migrating an existing <code>.env</code> and managing multiple environments.</p>
  </div>
</div>

<div class="g-callout info" style="margin-top: 1.6rem;">
  <p>We'll close with a side-by-side comparison of SOPS + age against two popular
  alternatives — dotenv.org and dotenvx.</p>
</div>

---
layout: default
---

# The problem with `.env` files

<h2>Secrets are often shared the easy — and risky — way</h2>

<div class="g-grid-2" style="margin-top: 0.5rem;">
  <div class="g-card accent-red">
    <h3>❌ Committed in plain text</h3>
    <p>The classic <code>.env</code> file gets pushed to git "just this once,"
    and now it's in the repo's history forever.</p>
  </div>
  <div class="g-card accent-yellow">
    <h3>⚠️ One shared password</h3>
    <p>A single team password or key gets passed around Slack — everyone has
    it, and no one can revoke just one person's access.</p>
  </div>
</div>

<div class="g-callout" style="margin-top: 1.4rem;">
  <p><strong>Goal:</strong> encrypt secrets at rest, let every teammate hold
  their own key, and make revoking access as simple as removing one line
  from a config file.</p>
</div>

---
layout: default
---

# Scenario 1 · The new teammate is stuck

<p>Sam joins, clones the repo and runs it — but <strong>there is no <code>.env</code></strong>.
Git only has <code>.env.example</code>: the keys, none of the values.</p>

<div class="sc-wrap" style="aspect-ratio: 840 / 290">
<div class="sc-layer">
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs></defs>
<rect class="sc-panel" x="10" y="10" width="215" height="160" rx="12"/>
<path class="sc-thin sc-blue" style="stroke-width:1.8" d="M30 25 V37 M30 29 C30 35 40 32 40 37"/><circle class="sc-fill-blue" cx="30" cy="24" r="3.5"/><circle class="sc-fill-blue" cx="30" cy="38" r="3.5"/><circle class="sc-fill-blue" cx="40" cy="38" r="3.5"/>
<rect class="sc-tint-blue" x="169" y="21" width="44" height="20" rx="10"/>
<rect class="sc-nofill" x="24" y="68" width="187" height="90" rx="8" style="fill:var(--g-bg)"/>
<path class="sc-hd-blue" d="M24 94 V76 a8 8 0 0 1 8 -8 H203 a8 8 0 0 1 8 8 V94 Z"/>
<path class="sc-thin sc-blue" d="M24 94 H211"/>
<rect class="sc-nofill sc-blue" style="stroke-width:1.8" x="24" y="68" width="187" height="90" rx="8"/>
<path class="sc-thin sc-blue" d="M33 74 H41 L45 78 V88 H33 Z M41 74 V78 H45"/>
<g class="sc-person sc-fill-blue"><circle cx="355" cy="40" r="14"/><path d="M329 92 Q329 60 355 60 Q381 60 381 92 Z"/></g>
</svg>
<span class="sc-tx sc-b" style="left:5.95%;top:8.60%">Git repo</span>
<span class="sc-tx sc-center sc-mono sc-t-blue" style="left:22.74%;top:8.84%">main</span>
<span class="sc-tx sc-sub sc-mono" style="left:3.10%;top:17.61%">src/   package.json   …</span>
<span class="sc-tx sc-mono sc-b" style="left:6.07%;top:26.28%">.env.example</span>
<span class="sc-tx sc-mono" style="left:4.05%;top:34.91%">DB_PASSWORD=</span>
<span class="sc-tx sc-mono" style="left:4.05%;top:40.42%">API_KEY=</span>
<span class="sc-tx sc-mono sc-t-red" style="left:4.05%;top:45.94%">keys only, no values</span>
<span class="sc-tx sc-center sc-b" style="left:42.26%;top:34.81%">Sam</span>
<span class="sc-tx sc-center sc-sub" style="left:42.26%;top:40.77%">new teammate</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s1-1-blue" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-blue" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<path class="sc-arrow sc-blue" d="M235 80 H318" marker-end="url(#s1-1-blue)"/>
<rect class="sc-chip" x="240.3" y="53" width="73.4" height="18" rx="9"/>
<rect class="sc-tint-red" x="280" y="150" width="150" height="46" rx="10"/><rect class="sc-nofill sc-red" style="stroke-width:1.8" x="280" y="150" width="150" height="46" rx="10"/>
</svg>
<span class="sc-tx sc-center sc-chip-t" style="left:32.98%;top:19.68%">git clone</span>
<span class="sc-tx sc-center sc-b sc-t-red" style="left:42.26%;top:54.64%">.env is missing</span>
<span class="sc-tx sc-center " style="left:42.26%;top:60.50%">app won't start</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s1-2-yellow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-yellow" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<g class="sc-person sc-fill-yellow"><circle cx="785" cy="40" r="14"/><path d="M759 92 Q759 60 785 60 Q811 60 811 92 Z"/></g>
<rect class="sc-nofill" x="545" y="30" width="170" height="90" rx="8" style="fill:var(--g-bg)"/>
<path class="sc-hd-yellow" d="M545 56 V38 a8 8 0 0 1 8 -8 H707 a8 8 0 0 1 8 8 V56 Z"/>
<path class="sc-thin sc-yellow" d="M545 56 H715"/>
<rect class="sc-nofill sc-yellow" style="stroke-width:1.8" x="545" y="30" width="170" height="90" rx="8"/>
<path class="sc-thin sc-yellow" d="M554 36 H562 L566 40 V50 H554 Z M562 36 V40 H566"/>
<path class="sc-arrow sc-yellow sc-dash" d="M392 70 H533" marker-end="url(#s1-2-yellow)"/>
<rect class="sc-chip" x="379.1" y="41" width="165.8" height="18" rx="9"/>
</svg>
<span class="sc-tx sc-center sc-b" style="left:93.45%;top:34.81%">Alice</span>
<span class="sc-tx sc-center sc-sub" style="left:93.45%;top:40.77%">existing teammate</span>
<span class="sc-tx sc-mono sc-b" style="left:68.10%;top:13.18%">.env</span>
<span class="sc-tx sc-mono" style="left:66.07%;top:21.80%">DB_PASSWORD=s3cr3t</span>
<span class="sc-tx sc-mono" style="left:66.07%;top:27.32%">API_KEY=sk_live_9f</span>
<span class="sc-tx sc-mono sc-t-green" style="left:66.07%;top:32.84%">the real values</span>
<span class="sc-tx sc-center sc-chip-t" style="left:55.00%;top:15.54%">"can you send me .env?"</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s1-3-red" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-red" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<rect class="sc-nofill" x="14" y="214" width="190" height="58" rx="8" style="fill:var(--g-bg)"/>
<path class="sc-hd-yellow" d="M14 240 V222 a8 8 0 0 1 8 -8 H196 a8 8 0 0 1 8 8 V240 Z"/>
<path class="sc-thin sc-yellow" d="M14 240 H204"/>
<rect class="sc-nofill sc-yellow" style="stroke-width:1.8" x="14" y="214" width="190" height="58" rx="8"/>
<path class="sc-thin sc-yellow" d="M23 220 H31 L35 224 V234 H23 Z M31 220 V224 H35"/>
<path class="sc-arrow sc-red sc-dash" d="M109 208 V176" marker-end="url(#s1-3-red)"/>
<circle class="sc-fill-red" cx="109" cy="192" r="10"/><path d="M105 188 L113 196 M113 188 L105 196" style="stroke:var(--g-bg)" stroke-width="2.2" stroke-linecap="round"/>
</svg>
<span class="sc-tx sc-mono sc-b" style="left:4.88%;top:76.63%">.env</span>
<span class="sc-tx sc-mono" style="left:2.86%;top:85.25%">DB_PASSWORD=s3cr3t</span>
<span class="sc-tx sc-sub" style="left:25.71%;top:79.39%">real secrets can't</span>
<span class="sc-tx sc-sub" style="left:25.71%;top:84.91%">be pushed to git</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s1-4-red" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-red" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<rect class="sc-tint-red" x="500" y="200" width="230" height="72" rx="10"/><rect class="sc-nofill sc-red" style="stroke-width:1.8" x="500" y="200" width="230" height="72" rx="10"/>
<path class="sc-arrow sc-red sc-dash" d="M640 128 V188" marker-end="url(#s1-4-red)"/>
<rect class="sc-chip" x="669.4" y="149" width="93.2" height="18" rx="9"/>
<path class="sc-arrow sc-red sc-dash" d="M490 236 H355 V206" marker-end="url(#s1-4-red)"/>
<rect class="sc-chip" x="398.5" y="227" width="47.0" height="18" rx="9"/>
</svg>
<span class="sc-tx sc-center sc-b" style="left:73.21%;top:73.43%">LINE / MS Teams chat</span>
<span class="sc-tx sc-center sc-t-red" style="left:73.21%;top:79.29%">.env pasted in plain text</span>
<span class="sc-tx sc-center sc-sub" style="left:73.21%;top:85.16%">read · forward · backed up</span>
<span class="sc-tx sc-center sc-chip-t" style="left:85.24%;top:52.78%">copy &amp; paste</span>
<span class="sc-tx sc-center sc-chip-t" style="left:50.24%;top:79.68%">paste</span>
</div>
</div>

<div class="g-callout danger" style="margin-top: 0.6rem;">
  <p>The real <code>.env</code> can't go in git, so it travels through chat —
  <strong>secrets end up in message history</strong>.</p>
</div>

---
layout: default
---

# Scenario 2 · A new key appears silently

<p>Everyone is in sync. Then one teammate adds a <strong>new required key</strong>
and pushes the code — without telling the team.</p>

<div class="sc-wrap" style="aspect-ratio: 840 / 290">
<div class="sc-layer">
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs></defs>
<g class="sc-person sc-fill-blue"><circle cx="60" cy="40" r="14"/><path d="M34 92 Q34 60 60 60 Q86 60 86 92 Z"/></g>
<rect class="sc-nofill" x="10" y="160" width="180" height="58" rx="8" style="fill:var(--g-bg)"/>
<path class="sc-hd-green" d="M10 186 V168 a8 8 0 0 1 8 -8 H182 a8 8 0 0 1 8 8 V186 Z"/>
<path class="sc-thin sc-green" d="M10 186 H190"/>
<rect class="sc-nofill sc-green" style="stroke-width:1.8" x="10" y="160" width="180" height="58" rx="8"/>
<path class="sc-thin sc-green" d="M19 166 H27 L31 170 V180 H19 Z M27 166 V170 H31"/>
</svg>
<span class="sc-tx sc-center sc-b" style="left:7.14%;top:34.81%">Dev A</span>
<span class="sc-tx sc-center sc-sub" style="left:7.14%;top:40.77%">adds a feature</span>
<span class="sc-tx sc-mono sc-b" style="left:4.40%;top:58.01%">.env</span>
<span class="sc-tx sc-mono sc-t-green" style="left:2.38%;top:66.63%">+ PAYMENT_API_KEY=sk_…</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s2-1-blue" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-blue" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<rect class="sc-panel" x="235" y="10" width="215" height="160" rx="12"/>
<path class="sc-thin sc-blue" style="stroke-width:1.8" d="M255 25 V37 M255 29 C255 35 265 32 265 37"/><circle class="sc-fill-blue" cx="255" cy="24" r="3.5"/><circle class="sc-fill-blue" cx="255" cy="38" r="3.5"/><circle class="sc-fill-blue" cx="265" cy="38" r="3.5"/>
<rect class="sc-tint-blue" x="394" y="21" width="44" height="20" rx="10"/>
<rect class="sc-nofill" x="249" y="68" width="187" height="74" rx="8" style="fill:var(--g-bg)"/>
<path class="sc-hd-blue" d="M249 94 V76 a8 8 0 0 1 8 -8 H428 a8 8 0 0 1 8 8 V94 Z"/>
<path class="sc-thin sc-blue" d="M249 94 H436"/>
<rect class="sc-nofill sc-blue" style="stroke-width:1.8" x="249" y="68" width="187" height="74" rx="8"/>
<path class="sc-thin sc-blue" d="M258 74 H266 L270 78 V88 H258 Z M266 74 V78 H270"/>
<path class="sc-arrow sc-blue" d="M100 76 H223" marker-end="url(#s2-1-blue)"/>
<rect class="sc-chip" x="128.6" y="49" width="66.8" height="18" rx="9"/>
</svg>
<span class="sc-tx sc-b" style="left:32.74%;top:8.60%">Git repo</span>
<span class="sc-tx sc-center sc-mono sc-t-blue" style="left:49.52%;top:8.84%">main</span>
<span class="sc-tx sc-sub sc-mono" style="left:29.88%;top:17.61%">src/   package.json   …</span>
<span class="sc-tx sc-mono sc-b" style="left:32.86%;top:26.28%">payment.js</span>
<span class="sc-tx sc-mono" style="left:30.83%;top:34.91%">pay(process.env.</span>
<span class="sc-tx sc-mono" style="left:30.83%;top:40.42%">  PAYMENT_API_KEY)</span>
<span class="sc-tx sc-center sc-chip-t" style="left:19.29%;top:18.30%">git push</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s2-2-blue" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-blue" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<g class="sc-person sc-fill-yellow"><circle cx="565" cy="40" r="14"/><path d="M539 92 Q539 60 565 60 Q591 60 591 92 Z"/></g>
<circle class="sc-tint-red" cx="597" cy="30" r="11"/><circle class="sc-nofill sc-red" style="stroke-width:1.6" cx="597" cy="30" r="11"/>
<g class="sc-person sc-fill-yellow"><circle cx="680" cy="40" r="14"/><path d="M654 92 Q654 60 680 60 Q706 60 706 92 Z"/></g>
<circle class="sc-tint-red" cx="712" cy="30" r="11"/><circle class="sc-nofill sc-red" style="stroke-width:1.6" cx="712" cy="30" r="11"/>
<g class="sc-person sc-fill-yellow"><circle cx="795" cy="40" r="14"/><path d="M769 92 Q769 60 795 60 Q821 60 821 92 Z"/></g>
<circle class="sc-tint-red" cx="827" cy="30" r="11"/><circle class="sc-nofill sc-red" style="stroke-width:1.6" cx="827" cy="30" r="11"/>
<path class="sc-arrow sc-blue" d="M462 76 H528" marker-end="url(#s2-2-blue)"/>
<rect class="sc-chip" x="461.6" y="49" width="66.8" height="18" rx="9"/>
</svg>
<span class="sc-tx sc-center sc-b" style="left:67.26%;top:34.81%">Bob</span>
<span class="sc-tx sc-center sc-b sc-t-red" style="left:71.07%;top:8.26%">?</span>
<span class="sc-tx sc-center sc-b" style="left:80.95%;top:34.81%">Carol</span>
<span class="sc-tx sc-center sc-b sc-t-red" style="left:84.76%;top:8.26%">?</span>
<span class="sc-tx sc-center sc-b" style="left:94.64%;top:34.81%">Dave</span>
<span class="sc-tx sc-center sc-b sc-t-red" style="left:98.45%;top:8.26%">?</span>
<span class="sc-tx sc-center sc-chip-t" style="left:58.93%;top:18.30%">git pull</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs></defs>
<rect class="sc-tint-red" x="480" y="152" width="345" height="40" rx="10"/><rect class="sc-nofill sc-red" style="stroke-width:1.8" x="480" y="152" width="345" height="40" rx="10"/>
</svg>
<span class="sc-tx sc-center sc-b sc-t-red" style="left:77.68%;top:57.22%">app crashes — PAYMENT_API_KEY is missing</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s2-4-red" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-red" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<rect class="sc-tint-yellow" x="290" y="226" width="290" height="56" rx="10"/><rect class="sc-nofill sc-yellow" style="stroke-width:1.8" x="290" y="226" width="290" height="56" rx="10"/>
<path class="sc-arrow sc-red sc-dash" d="M700 202 V254 H592" marker-end="url(#s2-4-red)"/>
<rect class="sc-chip" x="656.7" y="219" width="86.6" height="18" rx="9"/>
</svg>
<span class="sc-tx sc-center sc-b" style="left:51.79%;top:82.57%">"Who added the new key?"</span>
<span class="sc-tx sc-center sc-sub" style="left:51.79%;top:88.43%">"What's the value?" — asking around…</span>
<span class="sc-tx sc-center sc-chip-t" style="left:83.33%;top:76.92%">ask in chat</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s2-5-red" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-red" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<path class="sc-arrow sc-red sc-dash" d="M278 254 H100 V222" marker-end="url(#s2-5-red)"/>
<rect class="sc-chip" x="113.7" y="245" width="152.6" height="18" rx="9"/>
</svg>
<span class="sc-tx sc-center sc-chip-t" style="left:22.62%;top:85.89%">paste the value again</span>
</div>
</div>

<div class="g-callout danger" style="margin-top: 0.6rem;">
  <p>Files drift out of sync, time is lost hunting for the value, and every fix
  <strong>leaks the secret through chat again</strong>.</p>
</div>

---
layout: default
---

# Scenario 3 · Encrypt `.env.example`

<p>What if the file in git <strong>held the real values — encrypted</strong>?
Change it, commit, push. Teammates just decrypt it into <code>.env</code>.</p>

<div class="sc-wrap" style="aspect-ratio: 840 / 290">
<div class="sc-layer">
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs></defs>
<g class="sc-person sc-fill-blue"><circle cx="60" cy="40" r="14"/><path d="M34 92 Q34 60 60 60 Q86 60 86 92 Z"/></g>
<rect class="sc-nofill" x="10" y="160" width="190" height="74" rx="8" style="fill:var(--g-bg)"/>
<path class="sc-hd-yellow" d="M10 186 V168 a8 8 0 0 1 8 -8 H192 a8 8 0 0 1 8 8 V186 Z"/>
<path class="sc-thin sc-yellow" d="M10 186 H200"/>
<rect class="sc-nofill sc-yellow" style="stroke-width:1.8" x="10" y="160" width="190" height="74" rx="8"/>
<path class="sc-thin sc-yellow" d="M19 166 H27 L31 170 V180 H19 Z M27 166 V170 H31"/>
</svg>
<span class="sc-tx sc-center sc-b" style="left:7.14%;top:34.81%">Dev A</span>
<span class="sc-tx sc-center sc-sub" style="left:7.14%;top:40.77%">edits one file</span>
<span class="sc-tx sc-mono sc-b" style="left:4.40%;top:58.01%">.env.example</span>
<span class="sc-tx sc-mono" style="left:2.38%;top:66.63%">API_KEY=abc123</span>
<span class="sc-tx sc-mono" style="left:2.38%;top:72.15%">+ NEW_KEY=xyz789</span>
<span class="sc-tx sc-sub" style="left:25.24%;top:64.22%">plain text,</span>
<span class="sc-tx sc-sub" style="left:25.24%;top:69.73%">local only</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s3-1-blue" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-blue" d="M0 0 L10 5 L0 10 z"/></marker><marker id="s3-1-green" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-green" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<path class="sc-arrow sc-blue" d="M100 80 H210" marker-end="url(#s3-1-blue)"/>
<rect class="sc-chip" x="108.4" y="53" width="93.2" height="18" rx="9"/>
<path class="sc-arrow sc-green" style="stroke-width:3" d="M233 72 V66 a7 7 0 0 1 14 0 V72"/><rect class="sc-fill-green" x="229" y="72" width="22" height="16" rx="3"/>
<path class="sc-arrow sc-green" d="M272 80 H294" marker-end="url(#s3-1-green)"/>
<rect class="sc-panel" x="305" y="10" width="215" height="160" rx="12"/>
<path class="sc-thin sc-blue" style="stroke-width:1.8" d="M325 25 V37 M325 29 C325 35 335 32 335 37"/><circle class="sc-fill-blue" cx="325" cy="24" r="3.5"/><circle class="sc-fill-blue" cx="325" cy="38" r="3.5"/><circle class="sc-fill-blue" cx="335" cy="38" r="3.5"/>
<rect class="sc-tint-blue" x="464" y="21" width="44" height="20" rx="10"/>
<rect class="sc-nofill" x="319" y="68" width="187" height="90" rx="8" style="fill:var(--g-bg)"/>
<path class="sc-hd-green" d="M319 94 V76 a8 8 0 0 1 8 -8 H498 a8 8 0 0 1 8 8 V94 Z"/>
<path class="sc-thin sc-green" d="M319 94 H506"/>
<rect class="sc-nofill sc-green" style="stroke-width:1.8" x="319" y="68" width="187" height="90" rx="8"/>
<path class="sc-thin sc-green" d="M328 74 H336 L340 78 V88 H328 Z M336 74 V78 H340"/>
</svg>
<span class="sc-tx sc-center sc-chip-t" style="left:18.45%;top:19.68%">sops encrypt</span>
<span class="sc-tx sc-b" style="left:41.07%;top:8.60%">Git repo</span>
<span class="sc-tx sc-center sc-mono sc-t-blue" style="left:57.86%;top:8.84%">main</span>
<span class="sc-tx sc-sub sc-mono" style="left:38.21%;top:17.61%">src/   package.json   …</span>
<span class="sc-tx sc-mono sc-b" style="left:41.19%;top:26.28%">.env.example</span>
<span class="sc-tx sc-mono" style="left:39.17%;top:34.91%">API_KEY=ENC[AES…]</span>
<span class="sc-tx sc-mono" style="left:39.17%;top:40.42%">NEW_KEY=ENC[AES…]</span>
<span class="sc-tx sc-mono sc-t-green" style="left:39.17%;top:45.94%">encrypted, safe in git</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s3-2-blue" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-blue" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<path class="sc-arrow sc-blue" d="M536 80 H593" marker-end="url(#s3-2-blue)"/>
<rect class="sc-chip" x="531.6" y="53" width="66.8" height="18" rx="9"/>
<g class="sc-person sc-fill-yellow"><circle cx="630" cy="40" r="14"/><path d="M604 92 Q604 60 630 60 Q656 60 656 92 Z"/></g>
<g class="sc-person sc-fill-yellow"><circle cx="772" cy="40" r="14"/><path d="M746 92 Q746 60 772 60 Q798 60 798 92 Z"/></g>
</svg>
<span class="sc-tx sc-center sc-chip-t" style="left:67.26%;top:19.68%">git pull</span>
<span class="sc-tx sc-center sc-b" style="left:75.00%;top:34.81%">Sam</span>
<span class="sc-tx sc-center sc-sub" style="left:75.00%;top:40.77%">new teammate</span>
<span class="sc-tx sc-center sc-b" style="left:91.90%;top:34.81%">Bob</span>
<span class="sc-tx sc-center sc-sub" style="left:91.90%;top:40.77%">existing</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s3-3-green" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-green" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<path class="sc-arrow sc-green" d="M630 138 V186" marker-end="url(#s3-3-green)"/>
<rect class="sc-chip" x="583.4" y="151" width="93.2" height="18" rx="9"/>
<rect class="sc-nofill" x="564" y="196" width="132" height="74" rx="8" style="fill:var(--g-bg)"/>
<path class="sc-hd-green" d="M564 222 V204 a8 8 0 0 1 8 -8 H688 a8 8 0 0 1 8 8 V222 Z"/>
<path class="sc-thin sc-green" d="M564 222 H696"/>
<rect class="sc-nofill sc-green" style="stroke-width:1.8" x="564" y="196" width="132" height="74" rx="8"/>
<path class="sc-thin sc-green" d="M573 202 H581 L585 206 V216 H573 Z M581 202 V206 H585"/>
<path class="sc-arrow sc-green" d="M772 138 V186" marker-end="url(#s3-3-green)"/>
<rect class="sc-chip" x="725.4" y="151" width="93.2" height="18" rx="9"/>
<rect class="sc-nofill" x="706" y="196" width="132" height="74" rx="8" style="fill:var(--g-bg)"/>
<path class="sc-hd-green" d="M706 222 V204 a8 8 0 0 1 8 -8 H830 a8 8 0 0 1 8 8 V222 Z"/>
<path class="sc-thin sc-green" d="M706 222 H838"/>
<rect class="sc-nofill sc-green" style="stroke-width:1.8" x="706" y="196" width="132" height="74" rx="8"/>
<path class="sc-thin sc-green" d="M715 202 H723 L727 206 V216 H715 Z M723 202 V206 H727"/>
<circle class="sc-fill-green" cx="330" cy="250" r="10"/><path d="M325.5 250 L329 253.5 L335 246.5" fill="none" style="stroke:var(--g-bg)" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
<span class="sc-tx sc-center sc-chip-t" style="left:75.00%;top:53.47%">sops decrypt</span>
<span class="sc-tx sc-mono sc-b" style="left:70.36%;top:70.42%">.env</span>
<span class="sc-tx sc-mono" style="left:68.33%;top:79.04%">API_KEY=abc123</span>
<span class="sc-tx sc-mono" style="left:68.33%;top:84.56%">NEW_KEY=xyz789</span>
<span class="sc-tx sc-center sc-chip-t" style="left:91.90%;top:53.47%">sops decrypt</span>
<span class="sc-tx sc-mono sc-b" style="left:87.26%;top:70.42%">.env</span>
<span class="sc-tx sc-mono" style="left:85.24%;top:79.04%">API_KEY=abc123</span>
<span class="sc-tx sc-mono" style="left:85.24%;top:84.56%">NEW_KEY=xyz789</span>
<span class="sc-tx sc-b" style="left:41.43%;top:84.12%">everyone gets the same .env</span>
</div>
</div>

<div class="g-callout success" style="margin-top: 0.6rem;">
  <p>One source of truth in git, no chat needed — <strong>SOPS</strong> to the
  rescue. Next slides call the encrypted file <code>.enc.env</code>.</p>
</div>

---
layout: default
---

# Key Pair

<p>Sam makes a <strong>key pair</strong> with <code>age-keygen</code>. The public half is safe
to share; Alice adds it as a <strong>recipient</strong>, and Sam can decrypt.</p>

<div class="sc-wrap" style="aspect-ratio: 840 / 310">
<div class="sc-layer">
<svg class="sc-svg" viewBox="0 0 840 310" xmlns="http://www.w3.org/2000/svg" role="img"><defs></defs>
<g class="sc-person sc-fill-blue"><circle cx="60" cy="30" r="14"/><path d="M34 82 Q34 50 60 50 Q86 50 86 82 Z"/></g>
<rect class="sc-nofill" x="10" y="146" width="160" height="58" rx="8" style="fill:var(--g-bg)"/>
<path class="sc-hd-red" d="M10 172 V154 a8 8 0 0 1 8 -8 H162 a8 8 0 0 1 8 8 V172 Z"/>
<path class="sc-thin sc-red" d="M10 172 H170"/>
<rect class="sc-nofill sc-red" style="stroke-width:1.8" x="10" y="146" width="160" height="58" rx="8"/>
<path class="sc-thin sc-red" d="M19 152 H27 L31 156 V166 H19 Z M27 152 V156 H31"/>
</svg>
<span class="sc-tx sc-center sc-b" style="left:7.14%;top:29.34%">Sam</span>
<span class="sc-tx sc-center sc-sub" style="left:7.14%;top:34.91%">runs age-keygen</span>
<span class="sc-tx sc-mono sc-b" style="left:4.40%;top:49.75%">private.key</span>
<span class="sc-tx sc-mono sc-t-red" style="left:2.38%;top:57.81%">AGE-SECRET-KEY-…</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 310" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s4-1-blue" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-blue" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<g class="sc-person sc-fill-yellow"><circle cx="780" cy="30" r="14"/><path d="M754 82 Q754 50 780 50 Q806 50 806 82 Z"/></g>
<path class="sc-arrow sc-blue" d="M98 66 H742" marker-end="url(#s4-1-blue)"/>
<rect class="sc-chip" x="340.4" y="57" width="159.2" height="18" rx="9"/>
</svg>
<span class="sc-tx sc-center sc-b" style="left:92.86%;top:29.34%">Alice</span>
<span class="sc-tx sc-center sc-chip-t" style="left:50.00%;top:19.70%">public key: age1sam7x…</span>
<span class="sc-tx sc-center sc-sub" style="left:50.00%;top:27.81%">safe to send over any channel — chat, email, PR</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 310" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s4-2-yellow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-yellow" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<path class="sc-arrow sc-yellow" d="M780 112 V140" marker-end="url(#s4-2-yellow)"/>
<rect class="sc-nofill" x="655" y="146" width="180" height="90" rx="8" style="fill:var(--g-bg)"/>
<path class="sc-hd-yellow" d="M655 172 V154 a8 8 0 0 1 8 -8 H827 a8 8 0 0 1 8 8 V172 Z"/>
<path class="sc-thin sc-yellow" d="M655 172 H835"/>
<rect class="sc-nofill sc-yellow" style="stroke-width:1.8" x="655" y="146" width="180" height="90" rx="8"/>
<path class="sc-thin sc-yellow" d="M664 152 H672 L676 156 V166 H664 Z M672 152 V156 H676"/>
</svg>
<span class="sc-tx sc-mono sc-b" style="left:81.19%;top:49.75%">.sops.yaml</span>
<span class="sc-tx sc-mono" style="left:79.17%;top:57.81%">age:</span>
<span class="sc-tx sc-mono" style="left:79.17%;top:62.98%">  - age1alice…</span>
<span class="sc-tx sc-mono sc-t-green" style="left:79.17%;top:68.14%">  + age1sam7x…</span>
<span class="sc-tx sc-sub" style="left:77.98%;top:81.36%">Alice adds Sam</span>
<span class="sc-tx sc-sub" style="left:77.98%;top:86.52%">as a recipient</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 310" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s4-3-blue" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-blue" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<rect class="sc-panel" x="290" y="142" width="215" height="144" rx="12"/>
<path class="sc-thin sc-blue" style="stroke-width:1.8" d="M310 157 V169 M310 161 C310 167 320 164 320 169"/><circle class="sc-fill-blue" cx="310" cy="156" r="3.5"/><circle class="sc-fill-blue" cx="310" cy="170" r="3.5"/><circle class="sc-fill-blue" cx="320" cy="170" r="3.5"/>
<rect class="sc-tint-blue" x="449" y="153" width="44" height="20" rx="10"/>
<rect class="sc-nofill" x="304" y="200" width="187" height="74" rx="8" style="fill:var(--g-bg)"/>
<path class="sc-hd-green" d="M304 226 V208 a8 8 0 0 1 8 -8 H483 a8 8 0 0 1 8 8 V226 Z"/>
<path class="sc-thin sc-green" d="M304 226 H491"/>
<rect class="sc-nofill sc-green" style="stroke-width:1.8" x="304" y="200" width="187" height="74" rx="8"/>
<path class="sc-thin sc-green" d="M313 206 H321 L325 210 V220 H313 Z M321 206 V210 H325"/>
<path class="sc-arrow sc-blue" d="M645 200 H517" marker-end="url(#s4-3-blue)"/>
<rect class="sc-chip" x="517.9" y="171" width="126.2" height="18" rx="9"/>
</svg>
<span class="sc-tx sc-b" style="left:39.29%;top:50.63%">Git repo</span>
<span class="sc-tx sc-center sc-mono sc-t-blue" style="left:56.07%;top:50.85%">main</span>
<span class="sc-tx sc-sub sc-mono" style="left:36.43%;top:59.06%">src/   package.json   …</span>
<span class="sc-tx sc-mono sc-b" style="left:39.40%;top:67.17%">.env.example</span>
<span class="sc-tx sc-mono" style="left:37.38%;top:75.23%">API_KEY=ENC[AES…]</span>
<span class="sc-tx sc-mono sc-t-green" style="left:37.38%;top:80.40%">for: Alice + Sam</span>
<span class="sc-tx sc-center sc-chip-t" style="left:69.17%;top:56.48%">updatekeys + push</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 310" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s4-4-blue" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-blue" d="M0 0 L10 5 L0 10 z"/></marker><marker id="s4-4-green" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-green" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<path class="sc-arrow sc-blue" d="M280 175 H182" marker-end="url(#s4-4-blue)"/>
<rect class="sc-chip" x="197.6" y="166" width="66.8" height="18" rx="9"/>
<path class="sc-arrow sc-green" d="M90 210 V240" marker-end="url(#s4-4-green)"/>
<rect class="sc-chip" x="101.4" y="216" width="93.2" height="18" rx="9"/>
<rect class="sc-nofill" x="10" y="246" width="160" height="58" rx="8" style="fill:var(--g-bg)"/>
<path class="sc-hd-green" d="M10 272 V254 a8 8 0 0 1 8 -8 H162 a8 8 0 0 1 8 8 V272 Z"/>
<path class="sc-thin sc-green" d="M10 272 H170"/>
<rect class="sc-nofill sc-green" style="stroke-width:1.8" x="10" y="246" width="160" height="58" rx="8"/>
<path class="sc-thin sc-green" d="M19 252 H27 L31 256 V266 H19 Z M27 252 V256 H31"/>
<circle class="sc-fill-green" cx="188" cy="275" r="10"/><path d="M183.5 275 L187 278.5 L193 271.5" fill="none" style="stroke:var(--g-bg)" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
<span class="sc-tx sc-center sc-chip-t" style="left:27.50%;top:54.86%">git pull</span>
<span class="sc-tx sc-center sc-chip-t" style="left:17.62%;top:70.99%">sops decrypt</span>
<span class="sc-tx sc-mono sc-b" style="left:4.40%;top:82.01%">.env</span>
<span class="sc-tx sc-mono sc-t-green" style="left:2.38%;top:90.07%">API_KEY=abc123</span>
<span class="sc-tx sc-b" style="left:24.29%;top:86.76%">ready</span>
</div>
</div>

<div class="g-callout info" style="margin-top: 0.6rem;">
  <p>Like HTTPS: the <strong>public key</strong> can travel anywhere, only the
  <strong>private key</strong> — which never leaves the laptop — can decrypt.</p>
</div>

---
layout: default
---

# The Flow

<p>Everyone changes <code>.env.example</code> only. <code>.env</code> is never touched — it is just the <strong>decrypted result</strong>.</p>

<div class="sc-wrap" style="aspect-ratio: 840 / 300">
<div class="sc-layer">
<svg class="sc-svg" viewBox="0 0 840 300" xmlns="http://www.w3.org/2000/svg" role="img"><defs></defs>
<g class="sc-person sc-fill-blue"><circle cx="50" cy="40" r="14"/><path d="M24 92 Q24 60 50 60 Q76 60 76 92 Z"/></g>
<g class="sc-person sc-fill-blue"><circle cx="130" cy="40" r="14"/><path d="M104 92 Q104 60 130 60 Q156 60 156 92 Z"/></g>
</svg>
<span class="sc-tx sc-center sc-b" style="left:5.95%;top:33.65%">Alice</span>
<span class="sc-tx sc-center sc-b" style="left:15.48%;top:33.65%">Bob</span>
<span class="sc-tx sc-center sc-sub" style="left:10.71%;top:46.74%">add · edit · update · delete</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 300" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s5-1-blue" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-blue" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<path class="sc-arrow sc-blue" d="M182 82 H280" marker-end="url(#s5-1-blue)"/>
<rect class="sc-chip" x="174.5" y="55" width="113.0" height="18" rx="9"/>
<rect class="sc-panel" x="290" y="10" width="215" height="144" rx="12"/>
<path class="sc-thin sc-blue" style="stroke-width:1.8" d="M310 25 V37 M310 29 C310 35 320 32 320 37"/><circle class="sc-fill-blue" cx="310" cy="24" r="3.5"/><circle class="sc-fill-blue" cx="310" cy="38" r="3.5"/><circle class="sc-fill-blue" cx="320" cy="38" r="3.5"/>
<rect class="sc-tint-blue" x="449" y="21" width="44" height="20" rx="10"/>
<rect class="sc-nofill" x="304" y="68" width="187" height="74" rx="8" style="fill:var(--g-bg)"/>
<path class="sc-hd-green" d="M304 94 V76 a8 8 0 0 1 8 -8 H483 a8 8 0 0 1 8 8 V94 Z"/>
<path class="sc-thin sc-green" d="M304 94 H491"/>
<rect class="sc-nofill sc-green" style="stroke-width:1.8" x="304" y="68" width="187" height="74" rx="8"/>
<path class="sc-thin sc-green" d="M313 74 H321 L325 78 V88 H313 Z M321 74 V78 H325"/>
</svg>
<span class="sc-tx sc-center sc-chip-t" style="left:27.50%;top:19.69%">edit + git push</span>
<span class="sc-tx sc-b" style="left:39.29%;top:8.32%">Git repo</span>
<span class="sc-tx sc-center sc-mono sc-t-blue" style="left:56.07%;top:8.55%">main</span>
<span class="sc-tx sc-sub sc-mono" style="left:36.43%;top:17.03%">src/   package.json   …</span>
<span class="sc-tx sc-mono sc-b" style="left:39.40%;top:25.41%">.env.example</span>
<span class="sc-tx sc-mono" style="left:37.38%;top:33.74%">API_KEY=ENC[AES…]</span>
<span class="sc-tx sc-mono" style="left:37.38%;top:39.07%">DB_URL=ENC[AES…]</span>
<span class="sc-tx sc-center sc-b sc-t-green" style="left:47.26%;top:54.98%">the single source of truth</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 300" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s5-2-blue" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-blue" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<path class="sc-arrow sc-blue" d="M517 82 H645" marker-end="url(#s5-2-blue)"/>
<rect class="sc-chip" x="547.6" y="55" width="66.8" height="18" rx="9"/>
<g class="sc-person sc-fill-yellow"><circle cx="680" cy="40" r="14"/><path d="M654 92 Q654 60 680 60 Q706 60 706 92 Z"/></g>
</svg>
<span class="sc-tx sc-center sc-chip-t" style="left:69.17%;top:19.69%">git pull</span>
<span class="sc-tx sc-center sc-b" style="left:80.95%;top:33.65%">Sam</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 300" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s5-3-green" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-green" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<path class="sc-arrow sc-green" d="M680 124 V170" marker-end="url(#s5-3-green)"/>
<rect class="sc-chip" x="590.5" y="138" width="179.0" height="18" rx="9"/>
<rect class="sc-nofill" x="618" y="180" width="124" height="74" rx="8" style="fill:var(--g-bg)"/>
<path class="sc-hd-green" d="M618 206 V188 a8 8 0 0 1 8 -8 H734 a8 8 0 0 1 8 8 V206 Z"/>
<path class="sc-thin sc-green" d="M618 206 H742"/>
<rect class="sc-nofill sc-green" style="stroke-width:1.8" x="618" y="180" width="124" height="74" rx="8"/>
<path class="sc-thin sc-green" d="M627 186 H635 L639 190 V200 H627 Z M635 186 V190 H639"/>
</svg>
<span class="sc-tx sc-center sc-chip-t" style="left:80.95%;top:47.36%">sops decrypt .env.example</span>
<span class="sc-tx sc-mono sc-b" style="left:76.79%;top:62.74%">.env</span>
<span class="sc-tx sc-mono" style="left:74.76%;top:71.08%">API_KEY=abc123</span>
<span class="sc-tx sc-mono" style="left:74.76%;top:76.41%">DB_URL=pg://…</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 300" xmlns="http://www.w3.org/2000/svg" role="img"><defs></defs>
<rect class="sc-tint-green" x="10" y="196" width="270" height="40" rx="10"/><rect class="sc-nofill sc-green" style="stroke-width:1.8" x="10" y="196" width="270" height="40" rx="10"/>
<rect class="sc-tint-red" x="10" y="248" width="270" height="40" rx="10"/><rect class="sc-nofill sc-red" style="stroke-width:1.8" x="10" y="248" width="270" height="40" rx="10"/>
</svg>
<span class="sc-tx sc-center sc-b sc-t-green" style="left:17.26%;top:69.98%">✓  change only .env.example</span>
<span class="sc-tx sc-center sc-b sc-t-red" style="left:17.26%;top:87.32%">✗  never edit .env by hand</span>
<span class="sc-tx sc-center sc-sub" style="left:80.95%;top:88.74%">a result, gitignored</span>
</div>
</div>

<div class="g-callout success" style="margin-top: 0.6rem;">
  <p>If your <code>.env</code> looks wrong, don't fix it — pull and <strong>decrypt again</strong>.</p>
</div>

---
layout: default
---

# Flow · Adding a new team member

<p>The new member shares only a <strong>public key</strong>. No <code>.env</code> is ever sent around.</p>

<div class="sc-wrap" style="aspect-ratio: 840 / 290">
<div class="sc-layer">
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs></defs>
<circle class="sc-fill-blue" cx="12" cy="18" r="12"/>
<g class="sc-person sc-fill-blue"><circle cx="85" cy="70" r="14"/><path d="M59 122 Q59 90 85 90 Q111 90 111 122 Z"/></g>
<rect class="sc-nofill" x="0" y="160" width="170" height="74" rx="8" style="fill:var(--g-bg)"/>
<path class="sc-hd-blue" d="M0 186 V168 a8 8 0 0 1 8 -8 H162 a8 8 0 0 1 8 8 V186 Z"/>
<path class="sc-thin sc-blue" d="M0 186 H170"/>
<rect class="sc-nofill sc-blue" style="stroke-width:1.8" x="0" y="160" width="170" height="74" rx="8"/>
<path class="sc-thin sc-blue" d="M9 166 H17 L21 170 V180 H9 Z M17 166 V170 H21"/>
</svg>
<span class="sc-tx sc-center sc-b sc-t-bg" style="left:1.43%;top:4.12%">1</span>
<span class="sc-tx sc-b" style="left:3.81%;top:4.12%">Generate keys</span>
<span class="sc-tx sc-mono sc-sub" style="left:3.81%;top:11.06%">age-keygen</span>
<span class="sc-tx sc-center sc-b" style="left:10.12%;top:45.16%">Sam</span>
<span class="sc-tx sc-mono sc-b" style="left:3.21%;top:58.01%">key pair</span>
<span class="sc-tx sc-mono sc-t-green" style="left:1.19%;top:66.63%">age1sam7x… public</span>
<span class="sc-tx sc-mono sc-t-red" style="left:1.19%;top:72.15%">AGE-SECRET-… private</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s6-1-blue" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-blue" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<path class="sc-arrow sc-blue" d="M178 106 H215" marker-end="url(#s6-1-blue)"/>
<circle class="sc-fill-blue" cx="235" cy="18" r="12"/>
<g class="sc-person sc-fill-yellow"><circle cx="308" cy="70" r="14"/><path d="M282 122 Q282 90 308 90 Q334 90 334 122 Z"/></g>
<rect class="sc-tint-blue" x="223" y="160" width="170" height="58" rx="10"/><rect class="sc-nofill sc-blue" style="stroke-width:1.8" x="223" y="160" width="170" height="58" rx="10"/>
</svg>
<span class="sc-tx sc-center sc-b sc-t-bg" style="left:27.98%;top:4.12%">2</span>
<span class="sc-tx sc-b" style="left:30.36%;top:4.12%">Send public key</span>
<span class="sc-tx sc-mono sc-sub" style="left:30.36%;top:11.06%">any channel</span>
<span class="sc-tx sc-center sc-b" style="left:36.67%;top:45.16%">Alice</span>
<span class="sc-tx sc-center sc-sub" style="left:36.67%;top:60.16%">"my public key:"</span>
<span class="sc-tx sc-center sc-b sc-t-green" style="left:36.67%;top:66.02%">age1sam7x…</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s6-2-blue" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-blue" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<path class="sc-arrow sc-blue" d="M401 106 H438" marker-end="url(#s6-2-blue)"/>
<circle class="sc-fill-blue" cx="458" cy="18" r="12"/>
<g class="sc-person sc-fill-yellow"><circle cx="531" cy="70" r="14"/><path d="M505 122 Q505 90 531 90 Q557 90 557 122 Z"/></g>
<rect class="sc-nofill" x="446" y="160" width="170" height="106" rx="8" style="fill:var(--g-bg)"/>
<path class="sc-hd-yellow" d="M446 186 V168 a8 8 0 0 1 8 -8 H608 a8 8 0 0 1 8 8 V186 Z"/>
<path class="sc-thin sc-yellow" d="M446 186 H616"/>
<rect class="sc-nofill sc-yellow" style="stroke-width:1.8" x="446" y="160" width="170" height="106" rx="8"/>
<path class="sc-thin sc-yellow" d="M455 166 H463 L467 170 V180 H455 Z M463 166 V170 H467"/>
</svg>
<span class="sc-tx sc-center sc-b sc-t-bg" style="left:54.52%;top:4.12%">3</span>
<span class="sc-tx sc-b" style="left:56.90%;top:4.12%">Add recipient</span>
<span class="sc-tx sc-mono sc-sub" style="left:56.90%;top:11.06%">sops updatekeys</span>
<span class="sc-tx sc-center sc-b" style="left:63.21%;top:45.16%">Alice</span>
<span class="sc-tx sc-mono sc-b" style="left:56.31%;top:58.01%">.sops.yaml</span>
<span class="sc-tx sc-mono" style="left:54.29%;top:66.63%">age:</span>
<span class="sc-tx sc-mono" style="left:54.29%;top:72.15%">  - age1alice…</span>
<span class="sc-tx sc-mono" style="left:54.29%;top:77.66%">  - age1bob…</span>
<span class="sc-tx sc-mono sc-t-green" style="left:54.29%;top:83.18%">  + age1sam7x…</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s6-3-blue" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-blue" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<path class="sc-arrow sc-blue" d="M624 106 H662" marker-end="url(#s6-3-blue)"/>
<circle class="sc-fill-green" cx="682" cy="18" r="12"/>
<g class="sc-person sc-fill-blue"><circle cx="755" cy="70" r="14"/><path d="M729 122 Q729 90 755 90 Q781 90 781 122 Z"/></g>
<rect class="sc-nofill" x="670" y="160" width="170" height="90" rx="8" style="fill:var(--g-bg)"/>
<path class="sc-hd-green" d="M670 186 V168 a8 8 0 0 1 8 -8 H832 a8 8 0 0 1 8 8 V186 Z"/>
<path class="sc-thin sc-green" d="M670 186 H840"/>
<rect class="sc-nofill sc-green" style="stroke-width:1.8" x="670" y="160" width="170" height="90" rx="8"/>
<path class="sc-thin sc-green" d="M679 166 H687 L691 170 V180 H679 Z M687 166 V170 H691"/>
</svg>
<span class="sc-tx sc-center sc-b sc-t-bg" style="left:81.19%;top:4.12%">4</span>
<span class="sc-tx sc-b" style="left:83.57%;top:4.12%">Pull &amp; decrypt</span>
<span class="sc-tx sc-mono sc-sub" style="left:83.57%;top:11.06%">sops decrypt</span>
<span class="sc-tx sc-center sc-b" style="left:89.88%;top:45.16%">Sam</span>
<span class="sc-tx sc-mono sc-b" style="left:82.98%;top:58.01%">.env</span>
<span class="sc-tx sc-mono" style="left:80.95%;top:66.63%">API_KEY=abc123</span>
<span class="sc-tx sc-mono" style="left:80.95%;top:72.15%">DB_URL=pg://…</span>
<span class="sc-tx sc-mono sc-t-green" style="left:80.95%;top:77.66%">ready to run</span>
</div>
</div>

<div class="g-callout info" style="margin-top: 0.6rem;">
  <p>Only <strong>Alice</strong> needs to edit <code>.sops.yaml</code>; Sam's <strong>private key</strong> never leaves his laptop.</p>
</div>

---
layout: default
---

# Flow · Add, edit or delete a key

<p>Open the file with <code>sops edit</code>, change it like any text file, and save — <strong>encryption is automatic</strong>.</p>

<div class="sc-wrap" style="aspect-ratio: 840 / 290">
<div class="sc-layer">
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs></defs>
<circle class="sc-fill-blue" cx="12" cy="18" r="12"/>
<g class="sc-person sc-fill-blue"><circle cx="85" cy="70" r="14"/><path d="M59 122 Q59 90 85 90 Q111 90 111 122 Z"/></g>
<rect class="sc-nofill" x="0" y="160" width="170" height="90" rx="8" style="fill:var(--g-bg)"/>
<path class="sc-hd-blue" d="M0 186 V168 a8 8 0 0 1 8 -8 H162 a8 8 0 0 1 8 8 V186 Z"/>
<path class="sc-thin sc-blue" d="M0 186 H170"/>
<rect class="sc-nofill sc-blue" style="stroke-width:1.8" x="0" y="160" width="170" height="90" rx="8"/>
<path class="sc-thin sc-blue" d="M9 166 H17 L21 170 V180 H9 Z M17 166 V170 H21"/>
</svg>
<span class="sc-tx sc-center sc-b sc-t-bg" style="left:1.43%;top:4.12%">1</span>
<span class="sc-tx sc-b" style="left:3.81%;top:4.12%">Open in editor</span>
<span class="sc-tx sc-mono sc-sub" style="left:3.81%;top:11.06%">sops edit</span>
<span class="sc-tx sc-center sc-b" style="left:10.12%;top:45.16%">Alice</span>
<span class="sc-tx sc-mono sc-b" style="left:3.21%;top:58.01%">editor (plain)</span>
<span class="sc-tx sc-mono sc-t-green" style="left:1.19%;top:66.63%">+ NEW_KEY=xyz789</span>
<span class="sc-tx sc-mono sc-t-yellow" style="left:1.19%;top:72.15%">~ API_KEY=changed</span>
<span class="sc-tx sc-mono sc-t-red" style="left:1.19%;top:77.66%">- OLD_KEY=gone</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s7-1-blue" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-blue" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<path class="sc-arrow sc-blue" d="M178 106 H215" marker-end="url(#s7-1-blue)"/>
<circle class="sc-fill-green" cx="235" cy="18" r="12"/>
<path class="sc-arrow sc-green" style="stroke-width:3" d="M301 78 V72 a7 7 0 0 1 14 0 V78"/><rect class="sc-fill-green" x="297" y="78" width="22" height="16" rx="3"/>
<rect class="sc-nofill" x="223" y="160" width="170" height="90" rx="8" style="fill:var(--g-bg)"/>
<path class="sc-hd-green" d="M223 186 V168 a8 8 0 0 1 8 -8 H385 a8 8 0 0 1 8 8 V186 Z"/>
<path class="sc-thin sc-green" d="M223 186 H393"/>
<rect class="sc-nofill sc-green" style="stroke-width:1.8" x="223" y="160" width="170" height="90" rx="8"/>
<path class="sc-thin sc-green" d="M232 166 H240 L244 170 V180 H232 Z M240 166 V170 H244"/>
</svg>
<span class="sc-tx sc-center sc-b sc-t-bg" style="left:27.98%;top:4.12%">2</span>
<span class="sc-tx sc-b" style="left:30.36%;top:4.12%">Save = encrypt</span>
<span class="sc-tx sc-mono sc-sub" style="left:30.36%;top:11.06%">automatic</span>
<span class="sc-tx sc-center sc-b" style="left:36.67%;top:45.16%">sops encrypts</span>
<span class="sc-tx sc-mono sc-b" style="left:29.76%;top:58.01%">.env.example</span>
<span class="sc-tx sc-mono" style="left:27.74%;top:66.63%">NEW_KEY=ENC[…]</span>
<span class="sc-tx sc-mono" style="left:27.74%;top:72.15%">API_KEY=ENC[…]</span>
<span class="sc-tx sc-mono sc-t-red" style="left:27.74%;top:77.66%">OLD_KEY removed</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s7-2-blue" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-blue" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<path class="sc-arrow sc-blue" d="M401 106 H438" marker-end="url(#s7-2-blue)"/>
<circle class="sc-fill-blue" cx="458" cy="18" r="12"/>
<rect class="sc-panel" x="446" y="56" width="170" height="150" rx="12"/>
<path class="sc-thin sc-blue" style="stroke-width:1.8" d="M466 71 V83 M466 75 C466 81 476 78 476 83"/><circle class="sc-fill-blue" cx="466" cy="70" r="3.5"/><circle class="sc-fill-blue" cx="466" cy="84" r="3.5"/><circle class="sc-fill-blue" cx="476" cy="84" r="3.5"/>
<rect class="sc-tint-blue" x="560" y="67" width="44" height="20" rx="10"/>
<rect class="sc-nofill" x="456" y="114" width="150" height="74" rx="8" style="fill:var(--g-bg)"/>
<path class="sc-hd-green" d="M456 140 V122 a8 8 0 0 1 8 -8 H598 a8 8 0 0 1 8 8 V140 Z"/>
<path class="sc-thin sc-green" d="M456 140 H606"/>
<rect class="sc-nofill sc-green" style="stroke-width:1.8" x="456" y="114" width="150" height="74" rx="8"/>
<path class="sc-thin sc-green" d="M465 120 H473 L477 124 V134 H465 Z M473 120 V124 H477"/>
</svg>
<span class="sc-tx sc-center sc-b sc-t-bg" style="left:54.52%;top:4.12%">3</span>
<span class="sc-tx sc-b" style="left:56.90%;top:4.12%">Commit &amp; push</span>
<span class="sc-tx sc-mono sc-sub" style="left:56.90%;top:11.06%">git push</span>
<span class="sc-tx sc-b" style="left:57.86%;top:24.47%">Git repo</span>
<span class="sc-tx sc-center sc-mono sc-t-blue" style="left:69.29%;top:24.71%">main</span>
<span class="sc-tx sc-sub sc-mono" style="left:55.00%;top:33.47%">src/   package.json   …</span>
<span class="sc-tx sc-mono sc-b" style="left:57.50%;top:42.15%">.env.example</span>
<span class="sc-tx sc-mono" style="left:55.48%;top:50.77%">NEW_KEY=ENC[…]</span>
<span class="sc-tx sc-mono" style="left:55.48%;top:56.28%">API_KEY=ENC[…]</span>
<span class="sc-tx sc-center sc-sub" style="left:63.21%;top:76.63%">diff shows only the</span>
<span class="sc-tx sc-center sc-sub" style="left:63.21%;top:82.15%">changed lines</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s7-3-blue" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-blue" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<path class="sc-arrow sc-blue" d="M624 106 H662" marker-end="url(#s7-3-blue)"/>
<circle class="sc-fill-green" cx="682" cy="18" r="12"/>
<g class="sc-person sc-fill-yellow"><circle cx="755" cy="70" r="14"/><path d="M729 122 Q729 90 755 90 Q781 90 781 122 Z"/></g>
<rect class="sc-nofill" x="670" y="160" width="170" height="90" rx="8" style="fill:var(--g-bg)"/>
<path class="sc-hd-green" d="M670 186 V168 a8 8 0 0 1 8 -8 H832 a8 8 0 0 1 8 8 V186 Z"/>
<path class="sc-thin sc-green" d="M670 186 H840"/>
<rect class="sc-nofill sc-green" style="stroke-width:1.8" x="670" y="160" width="170" height="90" rx="8"/>
<path class="sc-thin sc-green" d="M679 166 H687 L691 170 V180 H679 Z M687 166 V170 H691"/>
</svg>
<span class="sc-tx sc-center sc-b sc-t-bg" style="left:81.19%;top:4.12%">4</span>
<span class="sc-tx sc-b" style="left:83.57%;top:4.12%">Pull &amp; decrypt</span>
<span class="sc-tx sc-mono sc-sub" style="left:83.57%;top:11.06%">sops decrypt</span>
<span class="sc-tx sc-center sc-b" style="left:89.88%;top:45.16%">Bob</span>
<span class="sc-tx sc-mono sc-b" style="left:82.98%;top:58.01%">.env</span>
<span class="sc-tx sc-mono sc-t-green" style="left:80.95%;top:66.63%">+ NEW_KEY=xyz789</span>
<span class="sc-tx sc-mono sc-t-yellow" style="left:80.95%;top:72.15%">~ API_KEY=changed</span>
<span class="sc-tx sc-mono sc-t-red" style="left:80.95%;top:77.66%">- OLD_KEY gone</span>
</div>
</div>

<div class="g-callout info" style="margin-top: 0.6rem;">
  <p>Git history shows <strong>which key changed</strong> and who changed it — without exposing any value.</p>
</div>

---
layout: default
---

# Flow · Someone leaves the team

<p>Removing a <strong>recipient</strong> stops them decrypting <em>new</em> commits — but they may still hold old values.</p>

<div class="sc-wrap" style="aspect-ratio: 840 / 290">
<div class="sc-layer">
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs></defs>
<circle class="sc-fill-blue" cx="12" cy="18" r="12"/>
<g class="sc-person sc-fill-blue"><circle cx="85" cy="70" r="14"/><path d="M59 122 Q59 90 85 90 Q111 90 111 122 Z"/></g>
<rect class="sc-nofill" x="0" y="160" width="170" height="106" rx="8" style="fill:var(--g-bg)"/>
<path class="sc-hd-yellow" d="M0 186 V168 a8 8 0 0 1 8 -8 H162 a8 8 0 0 1 8 8 V186 Z"/>
<path class="sc-thin sc-yellow" d="M0 186 H170"/>
<rect class="sc-nofill sc-yellow" style="stroke-width:1.8" x="0" y="160" width="170" height="106" rx="8"/>
<path class="sc-thin sc-yellow" d="M9 166 H17 L21 170 V180 H9 Z M17 166 V170 H21"/>
</svg>
<span class="sc-tx sc-center sc-b sc-t-bg" style="left:1.43%;top:4.12%">1</span>
<span class="sc-tx sc-b" style="left:3.81%;top:4.12%">Remove recipient</span>
<span class="sc-tx sc-mono sc-sub" style="left:3.81%;top:11.06%">.sops.yaml</span>
<span class="sc-tx sc-center sc-b" style="left:10.12%;top:45.16%">Alice</span>
<span class="sc-tx sc-mono sc-b" style="left:3.21%;top:58.01%">.sops.yaml</span>
<span class="sc-tx sc-mono" style="left:1.19%;top:66.63%">age:</span>
<span class="sc-tx sc-mono" style="left:1.19%;top:72.15%">  - age1alice…</span>
<span class="sc-tx sc-mono" style="left:1.19%;top:77.66%">  - age1bob…</span>
<span class="sc-tx sc-mono sc-t-red" style="left:1.19%;top:83.18%">  - age1eve9z…  ✗</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s8-1-blue" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-blue" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<path class="sc-arrow sc-blue" d="M178 106 H215" marker-end="url(#s8-1-blue)"/>
<circle class="sc-fill-blue" cx="235" cy="18" r="12"/>
<g class="sc-person sc-fill-red"><circle cx="308" cy="70" r="14"/><path d="M282 122 Q282 90 308 90 Q334 90 334 122 Z"/></g>
<circle class="sc-fill-red" cx="351" cy="66" r="10"/><path d="M347 62 L355 70 M355 62 L347 70" style="stroke:var(--g-bg)" stroke-width="2.2" stroke-linecap="round"/>
<rect class="sc-nofill" x="223" y="160" width="170" height="90" rx="8" style="fill:var(--g-bg)"/>
<path class="sc-hd-green" d="M223 186 V168 a8 8 0 0 1 8 -8 H385 a8 8 0 0 1 8 8 V186 Z"/>
<path class="sc-thin sc-green" d="M223 186 H393"/>
<rect class="sc-nofill sc-green" style="stroke-width:1.8" x="223" y="160" width="170" height="90" rx="8"/>
<path class="sc-thin sc-green" d="M232 166 H240 L244 170 V180 H232 Z M240 166 V170 H244"/>
</svg>
<span class="sc-tx sc-center sc-b sc-t-bg" style="left:27.98%;top:4.12%">2</span>
<span class="sc-tx sc-b" style="left:30.36%;top:4.12%">Re-wrap &amp; rotate</span>
<span class="sc-tx sc-mono sc-sub" style="left:30.36%;top:11.06%">updatekeys + rotate</span>
<span class="sc-tx sc-center sc-b" style="left:36.67%;top:45.16%">Eve (left)</span>
<span class="sc-tx sc-mono sc-b" style="left:29.76%;top:58.01%">.env.example</span>
<span class="sc-tx sc-mono" style="left:27.74%;top:66.63%">new data key</span>
<span class="sc-tx sc-mono sc-t-green" style="left:27.74%;top:72.15%">for: Alice + Bob</span>
<span class="sc-tx sc-mono sc-t-red" style="left:27.74%;top:77.66%">Eve: no access</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s8-2-blue" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-blue" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<path class="sc-arrow sc-blue" d="M401 106 H438" marker-end="url(#s8-2-blue)"/>
<circle class="sc-fill-blue" cx="458" cy="18" r="12"/>
<rect class="sc-panel" x="446" y="56" width="170" height="150" rx="12"/>
<path class="sc-thin sc-blue" style="stroke-width:1.8" d="M466 71 V83 M466 75 C466 81 476 78 476 83"/><circle class="sc-fill-blue" cx="466" cy="70" r="3.5"/><circle class="sc-fill-blue" cx="466" cy="84" r="3.5"/><circle class="sc-fill-blue" cx="476" cy="84" r="3.5"/>
<rect class="sc-tint-blue" x="560" y="67" width="44" height="20" rx="10"/>
<rect class="sc-nofill" x="456" y="114" width="150" height="74" rx="8" style="fill:var(--g-bg)"/>
<path class="sc-hd-green" d="M456 140 V122 a8 8 0 0 1 8 -8 H598 a8 8 0 0 1 8 8 V140 Z"/>
<path class="sc-thin sc-green" d="M456 140 H606"/>
<rect class="sc-nofill sc-green" style="stroke-width:1.8" x="456" y="114" width="150" height="74" rx="8"/>
<path class="sc-thin sc-green" d="M465 120 H473 L477 124 V134 H465 Z M473 120 V124 H477"/>
</svg>
<span class="sc-tx sc-center sc-b sc-t-bg" style="left:54.52%;top:4.12%">3</span>
<span class="sc-tx sc-b" style="left:56.90%;top:4.12%">Commit &amp; push</span>
<span class="sc-tx sc-mono sc-sub" style="left:56.90%;top:11.06%">git push</span>
<span class="sc-tx sc-b" style="left:57.86%;top:24.47%">Git repo</span>
<span class="sc-tx sc-center sc-mono sc-t-blue" style="left:69.29%;top:24.71%">main</span>
<span class="sc-tx sc-sub sc-mono" style="left:55.00%;top:33.47%">src/   package.json   …</span>
<span class="sc-tx sc-mono sc-b" style="left:57.50%;top:42.15%">.env.example</span>
<span class="sc-tx sc-mono" style="left:55.48%;top:50.77%">API_KEY=ENC[…]</span>
<span class="sc-tx sc-mono" style="left:55.48%;top:56.28%">DB_URL=ENC[…]</span>
<span class="sc-tx sc-center sc-sub" style="left:63.21%;top:76.63%">only Alice + Bob</span>
<span class="sc-tx sc-center sc-sub" style="left:63.21%;top:82.15%">can decrypt now</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s8-3-yellow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-yellow" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<path class="sc-arrow sc-yellow" d="M624 106 H662" marker-end="url(#s8-3-yellow)"/>
<circle class="sc-fill-yellow" cx="682" cy="18" r="12"/>
<g class="sc-person sc-fill-blue"><circle cx="755" cy="70" r="14"/><path d="M729 122 Q729 90 755 90 Q781 90 781 122 Z"/></g>
<rect class="sc-tint-yellow" x="670" y="160" width="170" height="86" rx="10"/><rect class="sc-nofill sc-yellow" style="stroke-width:1.8" x="670" y="160" width="170" height="86" rx="10"/>
</svg>
<span class="sc-tx sc-center sc-b sc-t-bg" style="left:81.19%;top:4.12%">4</span>
<span class="sc-tx sc-b" style="left:83.57%;top:4.12%">Rotate real secrets</span>
<span class="sc-tx sc-mono sc-sub" style="left:83.57%;top:11.06%">at the provider</span>
<span class="sc-tx sc-center sc-b" style="left:89.88%;top:45.16%">Alice</span>
<span class="sc-tx sc-center sc-b" style="left:89.88%;top:62.05%">Eve saw the old values</span>
<span class="sc-tx sc-center sc-sub" style="left:89.88%;top:67.91%">change DB password,</span>
<span class="sc-tx sc-center sc-sub" style="left:89.88%;top:73.78%">API keys at the source</span>
</div>
</div>

<div class="g-callout danger" style="margin-top: 0.6rem;">
  <p>Always <strong>rotate the real credentials</strong>: the old ciphertext stays in git history.</p>
</div>

---
layout: default
---

# Flow · Rotating the data key

<p><code>sops rotate</code> swaps the <strong>data key</strong> and re-encrypts every value — same recipients, same plain values.</p>

<div class="sc-wrap" style="aspect-ratio: 840 / 290">
<div class="sc-layer">
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs></defs>
<circle class="sc-fill-blue" cx="12" cy="18" r="12"/>
<g class="sc-person sc-fill-blue"><circle cx="85" cy="70" r="14"/><path d="M59 122 Q59 90 85 90 Q111 90 111 122 Z"/></g>
<rect class="sc-nofill" x="0" y="160" width="170" height="90" rx="8" style="fill:var(--g-bg)"/>
<path class="sc-hd-red" d="M0 186 V168 a8 8 0 0 1 8 -8 H162 a8 8 0 0 1 8 8 V186 Z"/>
<path class="sc-thin sc-red" d="M0 186 H170"/>
<rect class="sc-nofill sc-red" style="stroke-width:1.8" x="0" y="160" width="170" height="90" rx="8"/>
<path class="sc-thin sc-red" d="M9 166 H17 L21 170 V180 H9 Z M17 166 V170 H21"/>
</svg>
<span class="sc-tx sc-center sc-b sc-t-bg" style="left:1.43%;top:4.12%">1</span>
<span class="sc-tx sc-b" style="left:3.81%;top:4.12%">Run rotate</span>
<span class="sc-tx sc-mono sc-sub" style="left:3.81%;top:11.06%">sops rotate -i</span>
<span class="sc-tx sc-center sc-b" style="left:10.12%;top:45.16%">Alice</span>
<span class="sc-tx sc-mono sc-b" style="left:3.21%;top:58.01%">before</span>
<span class="sc-tx sc-mono" style="left:1.19%;top:66.63%">API_KEY=ENC[…a1f]</span>
<span class="sc-tx sc-mono" style="left:1.19%;top:72.15%">DB_URL=ENC[…9c2]</span>
<span class="sc-tx sc-mono sc-t-red" style="left:1.19%;top:77.66%">data key v1</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s9-1-blue" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-blue" d="M0 0 L10 5 L0 10 z"/></marker><marker id="s9-1-green" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-green" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<path class="sc-arrow sc-blue" d="M178 106 H215" marker-end="url(#s9-1-blue)"/>
<circle class="sc-fill-green" cx="235" cy="18" r="12"/>
<circle class="sc-arrow sc-red" style="stroke-width:2.6" cx="245" cy="76" r="7"/><path class="sc-arrow sc-red" style="stroke-width:2.6" d="M252 76 H279 M271 76 V83 M278 76 V82"/>
<path class="sc-arrow sc-green" d="M291 76 H321" marker-end="url(#s9-1-green)"/>
<circle class="sc-arrow sc-green" style="stroke-width:2.6" cx="337" cy="76" r="7"/><path class="sc-arrow sc-green" style="stroke-width:2.6" d="M344 76 H371 M363 76 V83 M370 76 V82"/>
<rect class="sc-tint-green" x="223" y="160" width="170" height="58" rx="10"/><rect class="sc-nofill sc-green" style="stroke-width:1.8" x="223" y="160" width="170" height="58" rx="10"/>
</svg>
<span class="sc-tx sc-center sc-b sc-t-bg" style="left:27.98%;top:4.12%">2</span>
<span class="sc-tx sc-b" style="left:30.36%;top:4.12%">New data key</span>
<span class="sc-tx sc-mono sc-sub" style="left:30.36%;top:11.06%">random, automatic</span>
<span class="sc-tx sc-center sc-sub" style="left:29.17%;top:32.49%">v1</span>
<span class="sc-tx sc-center sc-sub" style="left:40.12%;top:32.49%">v2</span>
<span class="sc-tx sc-center sc-b" style="left:36.67%;top:45.16%">data key</span>
<span class="sc-tx sc-center sc-sub" style="left:36.67%;top:60.16%">re-wrapped for</span>
<span class="sc-tx sc-center sc-b" style="left:36.67%;top:66.02%">Alice + Bob</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s9-2-blue" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-blue" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<path class="sc-arrow sc-blue" d="M401 106 H438" marker-end="url(#s9-2-blue)"/>
<circle class="sc-fill-green" cx="458" cy="18" r="12"/>
<path class="sc-arrow sc-green" style="stroke-width:3" d="M524 78 V72 a7 7 0 0 1 14 0 V78"/><rect class="sc-fill-green" x="520" y="78" width="22" height="16" rx="3"/>
<rect class="sc-nofill" x="446" y="160" width="170" height="90" rx="8" style="fill:var(--g-bg)"/>
<path class="sc-hd-green" d="M446 186 V168 a8 8 0 0 1 8 -8 H608 a8 8 0 0 1 8 8 V186 Z"/>
<path class="sc-thin sc-green" d="M446 186 H616"/>
<rect class="sc-nofill sc-green" style="stroke-width:1.8" x="446" y="160" width="170" height="90" rx="8"/>
<path class="sc-thin sc-green" d="M455 166 H463 L467 170 V180 H455 Z M463 166 V170 H467"/>
</svg>
<span class="sc-tx sc-center sc-b sc-t-bg" style="left:54.52%;top:4.12%">3</span>
<span class="sc-tx sc-b" style="left:56.90%;top:4.12%">Values re-encrypted</span>
<span class="sc-tx sc-mono sc-sub" style="left:56.90%;top:11.06%">same values</span>
<span class="sc-tx sc-center sc-b" style="left:63.21%;top:45.16%">new ciphertext</span>
<span class="sc-tx sc-mono sc-b" style="left:56.31%;top:58.01%">after</span>
<span class="sc-tx sc-mono" style="left:54.29%;top:66.63%">API_KEY=ENC[…7be]</span>
<span class="sc-tx sc-mono" style="left:54.29%;top:72.15%">DB_URL=ENC[…e40]</span>
<span class="sc-tx sc-mono sc-t-green" style="left:54.29%;top:77.66%">data key v2</span>
</div>
<div class="sc-layer" v-click>
<svg class="sc-svg" viewBox="0 0 840 290" xmlns="http://www.w3.org/2000/svg" role="img"><defs><marker id="s9-3-blue" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path class="sc-fill-blue" d="M0 0 L10 5 L0 10 z"/></marker></defs>
<path class="sc-arrow sc-blue" d="M624 106 H662" marker-end="url(#s9-3-blue)"/>
<circle class="sc-fill-green" cx="682" cy="18" r="12"/>
<g class="sc-person sc-fill-yellow"><circle cx="715" cy="70" r="14"/><path d="M689 122 Q689 90 715 90 Q741 90 741 122 Z"/></g>
<g class="sc-person sc-fill-yellow"><circle cx="795" cy="70" r="14"/><path d="M769 122 Q769 90 795 90 Q821 90 821 122 Z"/></g>
<rect class="sc-nofill" x="670" y="160" width="170" height="74" rx="8" style="fill:var(--g-bg)"/>
<path class="sc-hd-green" d="M670 186 V168 a8 8 0 0 1 8 -8 H832 a8 8 0 0 1 8 8 V186 Z"/>
<path class="sc-thin sc-green" d="M670 186 H840"/>
<rect class="sc-nofill sc-green" style="stroke-width:1.8" x="670" y="160" width="170" height="74" rx="8"/>
<path class="sc-thin sc-green" d="M679 166 H687 L691 170 V180 H679 Z M687 166 V170 H691"/>
<circle class="sc-fill-green" cx="755" cy="122" r="10"/><path d="M750.5 122 L754 125.5 L760 118.5" fill="none" style="stroke:var(--g-bg)" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
<span class="sc-tx sc-center sc-b sc-t-bg" style="left:81.19%;top:4.12%">4</span>
<span class="sc-tx sc-b" style="left:83.57%;top:4.12%">Same access</span>
<span class="sc-tx sc-mono sc-sub" style="left:83.57%;top:11.06%">nothing else changes</span>
<span class="sc-tx sc-center sc-b" style="left:85.12%;top:45.16%">Alice</span>
<span class="sc-tx sc-center sc-b" style="left:94.64%;top:45.16%">Bob</span>
<span class="sc-tx sc-mono sc-b" style="left:82.98%;top:58.01%">.env</span>
<span class="sc-tx sc-mono" style="left:80.95%;top:66.63%">same plain values</span>
<span class="sc-tx sc-mono sc-t-green" style="left:80.95%;top:72.15%">same recipients</span>
</div>
</div>

<div class="g-callout success" style="margin-top: 0.6rem;">
  <p>Do it on a schedule, or when a key may have leaked. Nobody has to re-share anything.</p>
</div>

---
layout: default
---

# Requirements

<h2>Two small, open-source tools</h2>

<div class="g-grid-2" style="margin-top: 1rem;">
  <div class="g-card accent-blue">
    <h3>SOPS</h3>
    <p>Encrypts/decrypts structured files (YAML, JSON, ENV, INI, binary).</p>

```bash
go install github.com/getsops/sops/v3/cmd/sops@latest
```
  </div>
  <div class="g-card accent-green">
    <h3>age</h3>
    <p>A simple, modern encryption tool used as the key backend for SOPS.</p>

```bash
brew install age
# or
go install filippo.io/age/cmd/...@latest
```
  </div>
</div>

<p style="margin-top: 1.2rem; color: var(--g-text-secondary); font-size: 0.85rem;">
Links: <a href="https://github.com/getsops/sops">github.com/getsops/sops</a> ·
<a href="https://github.com/FiloSottile/age">github.com/FiloSottile/age</a>
</p>

---
layout: default
---

# The demo, end to end

<h2>Encrypt to <code>.enc.env</code>, decrypt to stdout, edit transparently</h2>

```bash {1-3|4|5-11|12-15}
## cat .env
JWT_SECRET=some-secret-value

export SOPS_AGE_RECIPIENTS="age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

## encrypt .env into a new file, .enc.env
sops encrypt \
  --input-type dotenv \
  --output-type dotenv \
  .env > .enc.env

## cat .enc.env
JWT_SECRET=ENC[AES256_GCM,data:+ZdkX501aUvs936Q...,type:str]
```

<div class="g-callout success" style="margin-top: 1rem;">
  <p><code>.env</code> stays plain text for your own tools; <code>.enc.env</code> is the
  encrypted file that's safe to commit and share.</p>
</div>

---
layout: default
---

# The `.enc.env` pattern

<p>Keep <strong>one encrypted file in git</strong>, and let every developer decrypt
their own local <code>.env</code> — the exact file dotenv-based tools already
expect, with zero config or code changes.</p>

<div class="dp-diagram">
  <div class="dp-step">
    <div class="dp-icon dp-icon-blue">📦</div>
    <div class="dp-label"><code>.enc.env</code></div>
    <div class="dp-sub">committed to git — ciphertext only</div>
  </div>
  <div class="dp-connector">
    <span class="dp-connector-line"></span>
    <span class="dp-connector-chip">sops decrypt</span>
  </div>
  <div class="dp-step">
    <div class="dp-icon dp-icon-yellow">📄</div>
    <div class="dp-label"><code>.env</code></div>
    <div class="dp-sub">local only — gitignored</div>
  </div>
  <div class="dp-connector">
    <span class="dp-connector-line"></span>
    <span class="dp-connector-chip">auto-loaded</span>
  </div>
  <div class="dp-step">
    <div class="dp-icon dp-icon-success">🚀</div>
    <div class="dp-label">your app</div>
    <div class="dp-sub">any dotenv tool, completely unmodified</div>
  </div>
</div>

```bash
echo ".env" >> .gitignore

export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt

## SOPS auto-detects the format — .enc.env still ends in .env
sops decrypt .enc.env > .env
```

<div class="g-callout info" style="margin-top: 0.9rem;">
  <p>Edit the source of truth directly with <code>sops edit .enc.env</code>, and scope
  <code>.sops.yaml</code>'s <code>path_regex</code> to <code>\.enc\.env$</code> so a
  stray plain <code>.env</code> is never accidentally treated as a SOPS file.</p>
</div>

---
layout: default
---

<div class="g-section">
  <div class="g-eyebrow">Learning steps</div>
  <h1>Let's build this up from scratch</h1>
  <p class="g-sub">
    Starting from a plain <code>.env</code> with one secret:
  </p>

```bash
JWT_SECRET=some-secret-value
```

</div>

---
layout: default
---

# Step 1 · Try to encrypt a secret

```bash
sops encrypt \
  --input-type dotenv \
  --output-type dotenv \
  .env
```

```bash
## output error
config file not found, or has no creation rules,
and no keys provided through command line options
```

<div class="g-callout danger" style="margin-top: 1.2rem;">
  <p><strong>Problem:</strong> SOPS doesn't yet know <em>which encryption key</em> to use.</p>
</div>

---
layout: default
---

# Step 2 · Generate an age key

<h2>SOPS recommends <code>age-keygen</code></h2>

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt

## output
public key: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

<div class="g-callout danger" style="margin-top: 1.2rem;">
  <p>⚠️ <strong>Important:</strong> treat <code>keys.txt</code> as a secret file —
  it contains your <strong>private</strong> key. Never commit it or share its contents.</p>
</div>

---
layout: default
---

# Step 3 · Encrypt with the key

<p>Pass the key explicitly, or via <code>SOPS_AGE_RECIPIENTS</code> — either way,
<code>sops encrypt</code> prints the ciphertext to stdout by default. Nothing is
written to disk yet:</p>

```bash
sops encrypt \
  --age age1xxxxxxxxxxxxxxxxxxxxxxxx \
  --input-type dotenv \
  --output-type dotenv \
  .env

## prints to stdout — .env on disk is untouched
JWT_SECRET=ENC[AES256_GCM,data:+ZdkX501aUvs936Q...,type:str]
```

<div class="g-callout info" style="margin-top: 1rem;">
  <p>FYI: <code>--in-place</code> re-encrypts <code>.env</code> itself instead of
  printing to stdout. We won't use it here — the next slide redirects the
  output into a separate <code>.enc.env</code> file instead, so the plaintext
  and the ciphertext are never the same file.</p>
</div>

---
layout: default
---

# Step 3 · Save the encrypted copy

<p>Redirect stdout into <code>.enc.env</code> to keep it:</p>

<div class="g-grid-2">
  <div>
    <h3>Pass the key explicitly</h3>

```bash
sops encrypt \
  --age age1xxxxxxxxxxxxxxxxxxxxxxxx \
  --input-type dotenv \
  --output-type dotenv \
  .env > .enc.env
```
  </div>
  <div>
    <h3>...or via environment variable</h3>

```bash
export SOPS_AGE_RECIPIENTS=\
"age1xxxxxxxxxxxxxxxxxxxxxxxx"

sops encrypt \
  --input-type dotenv \
  --output-type dotenv \
  .env > .enc.env
```
  </div>
</div>

<div class="g-callout success" style="margin-top: 1rem;">
  <p><code>.env</code> stays exactly as it was; <code>.enc.env</code> is the new
  encrypted file — this is the one you'll commit.</p>
</div>

---
layout: default
---

# Step 3 · The encrypted result

<p>Peek inside <code>.enc.env</code>:</p>

```bash {1|2-3|4-5}
JWT_SECRET=ENC[AES256_GCM,data:+ZdkX501aUvs936Q...,type:str]
sops_age__list_0__map_enc=-----BEGIN AGE ENCRYPTED FILE-----\n...
sops_age__list_0__map_recipient=age1ec9sjup3ff4vfjj3dglhamwgrew8kcczcmqnuqvrjcpygxpzupdqftcluw
sops_lastmodified=2026-08-16T05:37:29Z
sops_mac=ENC[AES256_GCM,data:oPIc0wijg+/sHf82OZ9...,type:str]
sops_unencrypted_suffix=_unencrypted
sops_version=3.13.3
```

<div class="g-grid-3" style="margin-top: 1rem;">
  <div class="g-card accent-blue">
    <h3>Value</h3>
    <p>Ciphertext, per key (<code>ENC[...]</code>)</p>
  </div>
  <div class="g-card accent-green">
    <h3>Metadata</h3>
    <p>Recipient list, MAC, and SOPS version — safe to commit</p>
  </div>
  <div class="g-card accent-yellow">
    <h3>Structure</h3>
    <p>Key <em>names</em> stay readable — only values are encrypted</p>
  </div>
</div>

---
layout: default
---

# Step 4 · Decrypting a secret

<p>SOPS checks these in order and stops at the first one that's set — every
variable is prefixed <code>SOPS_AGE_</code>:</p>

<div class="dl-group-label"><span class="dl-group-num">1</span> Provide the age key directly</div>

<div class="dp-diagram">
  <div class="dp-step">
    <div class="dp-icon dp-icon-blue">📁</div>
    <div class="dp-label"><code>KEY_FILE</code></div>
    <div class="dp-sub">path to a keys file</div>
  </div>
  <div class="dp-connector">
    <span class="dp-connector-line"></span>
    <span class="dp-connector-chip">not set?</span>
  </div>
  <div class="dp-step">
    <div class="dp-icon dp-icon-yellow">🔑</div>
    <div class="dp-label"><code>KEY</code></div>
    <div class="dp-sub">the private key text</div>
  </div>
  <div class="dp-connector">
    <span class="dp-connector-line"></span>
    <span class="dp-connector-chip">not set?</span>
  </div>
  <div class="dp-step">
    <div class="dp-icon dp-icon-green">⚙️</div>
    <div class="dp-label"><code>KEY_CMD</code></div>
    <div class="dp-sub">command outputs the key</div>
  </div>
</div>

<div class="dl-elbow">
  <span class="dl-elbow-line"></span>
  <span class="dl-elbow-label">still not set → also try reusing an SSH key</span>
  <span class="dl-elbow-line"></span>
</div>

<div class="dl-group-label"><span class="dl-group-num">2</span> …or reuse an existing SSH key</div>

<div class="dp-diagram dl-narrow">
  <div class="dp-step">
    <div class="dp-icon dp-icon-blue">📁</div>
    <div class="dp-label"><code>SSH_PRIVATE_KEY_FILE</code></div>
    <div class="dp-sub">an SSH private key file</div>
  </div>
  <div class="dp-connector">
    <span class="dp-connector-line"></span>
    <span class="dp-connector-chip">not set?</span>
  </div>
  <div class="dp-step">
    <div class="dp-icon dp-icon-green">⚙️</div>
    <div class="dp-label"><code>SSH_PRIVATE_KEY_CMD</code></div>
    <div class="dp-sub">command outputs an SSH key</div>
  </div>
</div>

```bash
export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt

## .enc.env still ends in .env, so the format is auto-detected
sops decrypt .enc.env
```

---
layout: default
---

# Step 5 · `sops edit` as an editor

<p>Once <code>SOPS_AGE_KEY_FILE</code> is exported, edit <code>.enc.env</code>
directly — no manual decrypt/re-encrypt cycle.</p>

```bash
sops edit .enc.env
```

<div class="g-callout success" style="margin-top: 1.2rem;">
  <p>Change the values in your editor and save — SOPS re-encrypts everything automatically on write.</p>
</div>

---
layout: default
---

# Step 6 · Not everything needs encryption

```bash
LOG_LEVEL=DEBUG
SERVER_PORT=8080

DEMO_USER=demo
DEMO_PASSWORD=demo

DATABASE_URL=postgres://user:password@localhost:5432/mydb
JWT_SECRET=7f3c9a2e1d8b4f6a9c0e7d2b5a1f8c3e6d9b4a7f2c5e8d1a
```

<p style="margin-top: 0.8rem;"><code>LOG_LEVEL</code>, <code>SERVER_PORT</code>, and <code>DEMO_USER</code>
don't need to be secret. Use <code>--unencrypted-regex</code> to leave matching keys in plain text:</p>

```bash
sops encrypt --input-type dotenv --output-type dotenv \
  --unencrypted-regex '^(LOG_LEVEL|SERVER_PORT|DEMO_USER)$' \
  .env > .enc.env
```

---
layout: default
---

# Step 6 · The result

<p><code>.enc.env</code> now looks like this:</p>

```bash {1-3|4-7}
LOG_LEVEL=DEBUG
SERVER_PORT=8080
DEMO_USER=demo
DEMO_PASSWORD=ENC[AES256_GCM,data:E5lwqg==,type:str]
DATABASE_URL=ENC[AES256_GCM,data:ZLvvzZXgkEu5...,type:str]
JWT_SECRET=ENC[AES256_GCM,data:gi2CpMOMggEOP...,type:str]
API_ACCESS_TOKEN=ENC[AES256_GCM,data:WIGpFUSpXUAS...,type:str]
```

<div class="g-callout success" style="margin-top: 1.2rem;">
  <p><code>LOG_LEVEL</code>, <code>SERVER_PORT</code>, and <code>DEMO_USER</code> stay
  plain text because they match the regex — everything else is encrypted.</p>
</div>

---
layout: default
---

# Step 7 · `.sops.yaml` config file

<p>Configure encryption declaratively instead of long CLI flags.</p>

```yaml
# .sops.yaml
creation_rules:
  - age: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    unencrypted_regex: "^(LOG_LEVEL|SERVER_PORT|DEMO_USER)$"
```

<p style="margin-top: 1rem;">Add a <code>path_regex</code> scoped to <code>.enc.env</code>, so running
<code>sops</code> against that file edits its encrypted content directly, and a
stray plain <code>.env</code> is never accidentally matched:</p>

```yaml
# .sops.yaml
creation_rules:
  - path_regex: \.enc\.env$
    age: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    unencrypted_regex: "^(LOG_LEVEL|SERVER_PORT|DEMO_USER)$"
```

---
layout: default
---

# Step 8 · Sharing with a team

<div class="g-step-row">
  <div class="g-step">1</div>
  <div class="g-step-body">
    <h3>Add their public key to <code>.sops.yaml</code></h3>
  </div>
</div>

```yaml
# .sops.yaml
creation_rules:
  - age:
      - age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  # alice
      - age1yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy  # bob (new teammate)
    unencrypted_regex: "^(LOG_LEVEL|SERVER_PORT|DEMO_USER)$"
```

<p style="margin-top: 0.6rem; font-size: 0.85rem; color: var(--g-text-secondary);">
A trailing <code># name</code> comment is a plain YAML comment — SOPS ignores it, but it
saves you from guessing whose key <code>age1xxx...</code> is when you're reading
<code>.sops.yaml</code> months later.</p>

<div class="g-step-row" style="margin-top: 1rem;">
  <div class="g-step">2</div>
  <div class="g-step-body">
    <h3>Re-key the file</h3>
    <p><code>sops updatekeys .enc.env</code> re-encrypts the data key for the new recipient.</p>
  </div>
</div>

<div class="g-callout info" style="margin-top: 0.8rem;">
  <p>Editing <code>.sops.yaml</code> alone doesn't re-encrypt anything — <code>updatekeys</code> is required.</p>
</div>

---
layout: default
---

# Step 9 · Migrating an existing `.env`

<p>You already have a plain-text <code>.env</code>, a <code>.sops.yaml</code>, and your age key configured.
Add a <code>path_regex</code>, then create <code>.enc.env</code> whenever you're ready:</p>

```yaml
# .sops.yaml
creation_rules:
  - path_regex: \.enc\.env$
    age: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    unencrypted_regex: "^(LOG_LEVEL|SERVER_PORT|DEMO_USER)$"
```

```bash
sops encrypt .env > .enc.env
```

<div class="g-callout" style="margin-top: 1rem;">
  <p>⚠️ SOPS auto-detects the dotenv format from a filename ending in <code>.env</code> —
  <code>.enc.env</code> still qualifies. A different suffix (e.g. <code>.env.production</code>)
  needs <code>--input-type dotenv --output-type dotenv</code> explicitly.</p>
</div>

---
layout: default
---

# Step 10 · Multiple environments, different access

<p>Give each environment file its own <code>path_regex</code> and its own recipients —
a developer's key only unlocks what they're meant to access.</p>

```yaml
# .sops.yaml
creation_rules:
  - path_regex: dev\.enc\.env$
    age:
      - age1devxxxx...  # alice
      - age1devyyyy...  # bob
    unencrypted_regex: "^(LOG_LEVEL|SERVER_PORT)$"

  - path_regex: prod\.enc\.env$
    age:
      - age1opsxxxx...  # carol
      - age1opsyyyy...  # dave
    unencrypted_regex: "^(LOG_LEVEL|SERVER_PORT)$"
```

---
layout: default
---

# Step 10 · Who can decrypt what

<div class="g-grid-2" style="margin-top: 1rem;">
  <div class="g-card accent-green">
    <h3>dev.enc.env</h3>
    <p>Encrypted to alice and bob (the dev team's public keys).</p>
  </div>
  <div class="g-card accent-red">
    <h3>prod.enc.env</h3>
    <p>Encrypted to carol and dave (the ops/production team's public keys).</p>
  </div>
</div>

<div class="g-callout info" style="margin-top: 1.2rem;">
  <p>Same repo, same <code>.sops.yaml</code> — <code>path_regex</code> just routes each
  file to its own recipient list, so a dev key never even wraps prod's data key.</p>
</div>

---
layout: default
---

# Step 10 · Access is enforced per key

```bash
export SOPS_AGE_KEY_FILE=~/.config/sops/age/dev-keys.txt

sops decrypt dev.enc.env
## DB_PASSWORD=dev-secret

sops decrypt prod.enc.env
## Failed to get the data key required to decrypt the SOPS file.
## Group 0: FAILED
##   age1opsxxxx...: FAILED
##     - age: no identity matched any of the recipients.
```

<div class="g-callout success" style="margin-top: 1.2rem;">
  <p>To grant or revoke access to one environment, edit that environment's <code>age</code> list
  and run <code>sops updatekeys &lt;file&gt;</code> — the other environment is untouched.</p>
</div>

---
layout: default
---

# Step 11 · `sops rotate` — new data key, same access

<p>Every SOPS file has one random <strong>data key</strong> that encrypts the
values; each recipient's <code>age</code> key only wraps a copy of it.
<code>rotate</code> replaces that data key without changing who can decrypt.</p>

```bash
sops rotate --in-place .enc.env
```

<div class="g-callout info" style="margin-top: 1rem;">
  <p>The file stays named <code>.enc.env</code> and keeps the same recipients —
  only the data key underneath, and the ciphertext it produced, is new.</p>
</div>

---
layout: default
---

# Step 11 · What `rotate` does (and doesn't) change

<div class="g-grid-2">
  <div class="g-card accent-blue">
    <h3>What changes</h3>
    <p>A fresh data key is generated, every value is re-encrypted with it, and
    each recipient gets a freshly wrapped copy of the new key.</p>
  </div>
  <div class="g-card accent-yellow">
    <h3>What doesn't change</h3>
    <p>The recipient list in <code>.sops.yaml</code> and the actual secret
    values themselves stay exactly the same.</p>
  </div>
</div>

<div class="g-callout danger" style="margin-top: 1.2rem;">
  <p><strong>Not the same as revoking access:</strong> if a recipient already
  extracted the old data key, rotating alone doesn't undo that. Removing
  someone needs <code>updatekeys</code> (Step 8) <em>and</em> <code>rotate</code>
  together — more on that in the deep dive.</p>
</div>

---
layout: default
---

<div class="g-section">
  <div class="g-eyebrow">Putting it in context</div>
  <h1>Why SOPS + age?</h1>
  <p class="g-sub">
    How it stacks up against two well-known alternatives for sharing
    <code>.env</code> secrets.
  </p>
</div>

---
layout: default
---

# SOPS + age vs. the alternatives

<div class="g-table g-compare" style="margin-top: 0.6rem;">

|  | dotenv.org | dotenvx | **SOPS + age** |
|---|---|---|---|
| Encryption at rest | ❌ None — plain text | ✅ ECIES + AES-256 | ✅ AES-256 |
| Decryption key | N/A | One shared key/environment | Each teammate has their own key pair |
| Revoking access | N/A | Rotate the shared key — affects everyone | Remove one public key + `updatekeys` |
| Safe to commit | ❌ Plain text in history | ✅ Ciphertext + public key | ✅ Ciphertext + public keys |
| File formats | `.env` only | `.env` only | YAML, JSON, `.env`, INI, binary |
| Hosted service needed | No | No (paid vault add-on optional) | No — fully open-source |

</div>

<div class="g-callout success" style="margin-top: 1.2rem;">
  <p><strong>The takeaway:</strong> everyone keeps their own key, and removing someone's
  access never means rotating a secret the whole team relies on.</p>
</div>

<p style="margin-top: 0.8rem; font-size: 0.7rem; color: var(--g-text-secondary);">
Sources: dotenvx encryption &amp; private-key docs · dotenv-vault repo · SOPS age docs.
</p>

---
layout: default
---

<div class="g-section">
  <div class="g-eyebrow">Deep dive</div>
  <h1>What's actually inside an encrypted file?</h1>
  <p class="g-sub">
    A closer look at the DATA_KEY, why <code>rotate</code> and
    <code>updatekeys</code> are two different operations, and what to do
    when a recipient's key is compromised.
  </p>
</div>

---
layout: default
---

# Deep dive · One DATA_KEY, wrapped per recipient

<p>SOPS generates one random 256-bit <strong>data key</strong> per file. Every
value in the file is encrypted with that same data key (each with its own IV
and auth tag) — then the data key itself is encrypted once for
<em>each</em> configured master key, and all of those wrapped copies are
stored under the file's <code>sops</code> metadata.</p>

<div class="dk-diagram">
  <svg class="dk-svg" viewBox="0 0 1000 320" preserveAspectRatio="none">
    <defs>
      <marker id="dk-arrow-wrap" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
        <path d="M0,0 L10,5 L0,10 z" fill="var(--g-blue)" />
      </marker>
      <marker id="dk-arrow-enc" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
        <path d="M0,0 L10,5 L0,10 z" fill="var(--g-green)" />
      </marker>
    </defs>
    <g>
      <path class="dk-path dk-path-wrap" d="M235,32 C360,32 360,160 460,160" marker-end="url(#dk-arrow-wrap)" />
      <path class="dk-path dk-path-wrap" d="M235,160 C360,160 360,160 460,160" marker-end="url(#dk-arrow-wrap)" />
      <path class="dk-path dk-path-wrap" d="M235,288 C360,288 360,160 460,160" marker-end="url(#dk-arrow-wrap)" />
      <path class="dk-path dk-path-enc" d="M540,160 C650,160 650,32 765,32" marker-end="url(#dk-arrow-enc)" />
      <path class="dk-path dk-path-enc" d="M540,160 C650,160 650,160 765,160" marker-end="url(#dk-arrow-enc)" />
      <path class="dk-path dk-path-enc" d="M540,160 C650,160 650,288 765,288" marker-end="url(#dk-arrow-enc)" />
    </g>
  </svg>

  <div class="dk-col dk-col-left">
    <div class="dk-node" style="left: 11.5%; top: 10%;"><span>Azure Key Vault</span></div>
    <div class="dk-node" style="left: 11.5%; top: 50%;"><span>alice's age key</span></div>
    <div class="dk-node" style="left: 11.5%; top: 90%;"><span>bob's age key</span></div>
  </div>

  <div class="dk-datakey">
    <span class="dk-datakey-label">DATA_KEY</span>
    <span class="dk-datakey-sub">random 256-bit</span>
  </div>
  <div class="dk-tag dk-tag-wrap">wraps</div>
  <div class="dk-tag dk-tag-enc">encrypts</div>

  <div class="dk-col dk-col-right">
    <div class="dk-node" style="left: 88%; top: 10%;"><span>DATABASE_PASSWORD</span></div>
    <div class="dk-node" style="left: 88%; top: 50%;"><span>JWT_SECRET</span></div>
    <div class="dk-node" style="left: 88%; top: 90%;"><span>API_TOKEN</span></div>
  </div>
</div>

<div class="g-callout info" style="margin-top: 0.8rem;">
  <p>Any <em>one</em> of the wrapped copies is enough to recover the data key —
  that's why adding a recipient in <code>.sops.yaml</code> (Step 8) doesn't
  re-encrypt every value, it just wraps the existing data key one more time.</p>
</div>

---
layout: default
---

# Deep dive · How `sops decrypt` finds the key

<p>You never hand SOPS a data key directly — it reads the wrapped copies out
of the file's metadata and asks your identity (age key, KMS, PGP) to unwrap
the one meant for you.</p>

<div class="dp-diagram">
  <div class="dp-step">
    <div class="dp-icon dp-icon-blue">🖥️</div>
    <div class="dp-label">sops decrypt</div>
    <div class="dp-sub">reads the wrapped copy for my recipient</div>
  </div>
  <div class="dp-connector">
    <span class="dp-connector-line"></span>
    <span class="dp-connector-chip">enc(DATA_KEY)</span>
  </div>
  <div class="dp-step">
    <div class="dp-icon dp-icon-yellow">📄</div>
    <div class="dp-label">sops metadata</div>
    <div class="dp-sub">the wrapped copies stored in the file</div>
  </div>
  <div class="dp-connector">
    <span class="dp-connector-line"></span>
    <span class="dp-connector-chip">unwrap</span>
  </div>
  <div class="dp-step">
    <div class="dp-icon dp-icon-green">🔑</div>
    <div class="dp-label">your age identity</div>
    <div class="dp-sub">private key, never leaves your machine</div>
  </div>
  <div class="dp-connector">
    <span class="dp-connector-line"></span>
    <span class="dp-connector-chip">DATA_KEY</span>
  </div>
  <div class="dp-step">
    <div class="dp-icon dp-icon-success">✅</div>
    <div class="dp-label">plaintext .env</div>
    <div class="dp-sub">every ENC[...] value decrypted</div>
  </div>
</div>

<div class="g-callout success" style="margin-top: 0.8rem;">
  <p>Any recipient whose wrapped copy is still in the metadata can unwrap the
  same data key this way — that's the whole mechanism behind Steps 8–10.</p>
</div>

---
layout: default
---

# Deep dive · Three things people call "rotation"

<div class="g-table" style="margin-top: 0.6rem;">

|  | Rotate the DATA_KEY | Change who can decrypt | Rotate the credential |
|---|---|---|---|
| Command | `sops rotate -i file` | `sops updatekeys file` | *(outside SOPS — change the actual value)* |
| What changes | A new random data key; every value is re-encrypted with it | The set of recipients whose wrapped copy is stored in the file | The secret itself, e.g. `DATABASE_PASSWORD` |
| What stays the same | The recipient list and the actual secret values | The data key and encrypted values (until you also rotate) | Everything about SOPS and the data key |
| Use it when | Routine cryptographic hygiene, or right after removing a recipient | Someone joins or leaves the team | The credential leaked, or on its normal expiry schedule |

</div>

<div class="g-callout danger" style="margin-top: 1rem;">
  <p>These three are independent. Running <code>sops rotate</code> after a
  leaked password does not change the password — and removing someone with
  <code>updatekeys</code> does not undo a data key they already saw.</p>
</div>

---
layout: default
---

# Deep dive · When a recipient is compromised

<p>Someone leaves the team, or their key leaks. Removing them from
<code>.sops.yaml</code> alone isn't enough — <strong>they may already have
extracted the old data key</strong> while they still had access.</p>

<div class="dp-diagram">
  <div class="dp-step">
    <div class="dp-icon dp-icon-red">🚨</div>
    <div class="dp-label">Recipient compromised</div>
    <div class="dp-sub">may already hold the old DATA_KEY</div>
  </div>
  <div class="dp-connector">
    <span class="dp-connector-line"></span>
    <span class="dp-connector-chip">not enough alone</span>
  </div>
  <div class="dp-step">
    <div class="dp-icon dp-icon-blue">🔒</div>
    <div class="dp-label"><code>updatekeys</code></div>
    <div class="dp-sub">removes them from .sops.yaml metadata</div>
  </div>
  <div class="dp-connector">
    <span class="dp-connector-line"></span>
    <span class="dp-connector-chip">new key</span>
  </div>
  <div class="dp-step">
    <div class="dp-icon dp-icon-yellow">🔄</div>
    <div class="dp-label"><code>sops rotate</code></div>
    <div class="dp-sub">the old DATA_KEY is now useless</div>
  </div>
  <div class="dp-connector">
    <span class="dp-connector-line"></span>
    <span class="dp-connector-chip">assume leaked</span>
  </div>
  <div class="dp-step">
    <div class="dp-icon dp-icon-success">✅</div>
    <div class="dp-label">Rotate credentials</div>
    <div class="dp-sub">the real passwords/API keys, not just SOPS</div>
  </div>
</div>

<div class="g-callout info" style="margin-top: 0.6rem;">
  <p>This is the sequence SOPS itself recommends for a compromised key:
  <code>updatekeys</code> → <code>rotate</code> → rotate the credentials.</p>
</div>

---
layout: default
---

<div class="g-section">
  <div class="g-eyebrow">Real scenarios</div>
  <h1>Three days in the life of <code>.enc.env</code></h1>
  <p class="g-sub">
    Alice, Bob, and Eve — cryptography's usual cast — starting a project,
    growing the team, and testing what a public repo actually exposes.
  </p>
</div>

---
layout: default
---

# Day 1 · Alice starts a new project

<p>👩‍💻 Alice is starting a brand-new service. She wants it safe to commit
from the very first push:</p>

<div class="dp-diagram">
  <div class="dp-step">
    <div class="dp-icon dp-icon-blue">👩‍💻</div>
    <div class="dp-label">Alice</div>
    <div class="dp-sub">writes .env locally</div>
  </div>
  <div class="dp-connector">
    <span class="dp-connector-line"></span>
    <span class="dp-connector-chip">age-keygen</span>
  </div>
  <div class="dp-step">
    <div class="dp-icon dp-icon-yellow">🔑</div>
    <div class="dp-label">her own key pair</div>
    <div class="dp-sub">public half in .sops.yaml</div>
  </div>
  <div class="dp-connector">
    <span class="dp-connector-line"></span>
    <span class="dp-connector-chip">sops encrypt</span>
  </div>
  <div class="dp-step">
    <div class="dp-icon dp-icon-green">🔒</div>
    <div class="dp-label"><code>.enc.env</code></div>
    <div class="dp-sub">.env → ciphertext</div>
  </div>
  <div class="dp-connector">
    <span class="dp-connector-line"></span>
    <span class="dp-connector-chip">git push</span>
  </div>
  <div class="dp-step">
    <div class="dp-icon dp-icon-success">📦</div>
    <div class="dp-label">the repo</div>
    <div class="dp-sub">only .enc.env + .sops.yaml committed</div>
  </div>
</div>

<div class="g-callout success" style="margin-top: 1rem;">
  <p><code>.env</code> never leaves Alice's laptop — the repo only ever sees
  ciphertext and public keys, from the very first commit.</p>
</div>

---
layout: default
---

# Day 12 · Bob joins the team

<p>🧑‍💻 A new teammate needs access — without anyone re-sharing a password
over Slack:</p>

<div class="dp-diagram">
  <div class="dp-step">
    <div class="dp-icon dp-icon-blue">🧑‍💻</div>
    <div class="dp-label">Bob</div>
    <div class="dp-sub">generates his own key pair</div>
  </div>
  <div class="dp-connector">
    <span class="dp-connector-line"></span>
    <span class="dp-connector-chip">public key only</span>
  </div>
  <div class="dp-step">
    <div class="dp-icon dp-icon-yellow">📤</div>
    <div class="dp-label">sends it to Alice</div>
    <div class="dp-sub">safe over Slack, email, anywhere</div>
  </div>
  <div class="dp-connector">
    <span class="dp-connector-line"></span>
    <span class="dp-connector-chip">updatekeys</span>
  </div>
  <div class="dp-step">
    <div class="dp-icon dp-icon-green">👩‍💻</div>
    <div class="dp-label">Alice</div>
    <div class="dp-sub">adds it to .sops.yaml, re-keys</div>
  </div>
  <div class="dp-connector">
    <span class="dp-connector-line"></span>
    <span class="dp-connector-chip">sops decrypt</span>
  </div>
  <div class="dp-step">
    <div class="dp-icon dp-icon-success">🔓</div>
    <div class="dp-label">Bob</div>
    <div class="dp-sub">clones the repo, decrypts his own .env</div>
  </div>
</div>

<div class="g-callout success" style="margin-top: 1rem;">
  <p>Bob's <strong>private</strong> key never travels anywhere either —
  only the public half ever left his machine.</p>
</div>

---
layout: default
---

# Day 40 · Eve finds the public repo

<p>🕵️ The repo goes public. Eve isn't on the team — but anyone can now read
<code>.enc.env</code> and <code>.sops.yaml</code>:</p>

<div class="dp-diagram">
  <div class="dp-step">
    <div class="dp-icon dp-icon-blue">🕵️</div>
    <div class="dp-label">Eve</div>
    <div class="dp-sub">clones the public repo</div>
  </div>
  <div class="dp-connector">
    <span class="dp-connector-line"></span>
    <span class="dp-connector-chip">only ciphertext</span>
  </div>
  <div class="dp-step">
    <div class="dp-icon dp-icon-yellow">👀</div>
    <div class="dp-label">reads .enc.env</div>
    <div class="dp-sub">every value is ENC[...]</div>
  </div>
  <div class="dp-connector">
    <span class="dp-connector-line"></span>
    <span class="dp-connector-chip">edits the yaml</span>
  </div>
  <div class="dp-step">
    <div class="dp-icon dp-icon-yellow">🔑</div>
    <div class="dp-label">adds her own key</div>
    <div class="dp-sub">to .sops.yaml — just a text edit</div>
  </div>
  <div class="dp-connector">
    <span class="dp-connector-line"></span>
    <span class="dp-connector-chip">tries</span>
  </div>
  <div class="dp-step">
    <div class="dp-icon dp-icon-red">⚠️</div>
    <div class="dp-label"><code>sops updatekeys</code></div>
    <div class="dp-sub">to grant herself access</div>
  </div>
</div>

<div class="g-callout danger" style="margin-top: 1rem;">
  <p>Editing <code>.sops.yaml</code> is just editing text in her own fork — it
  never touches the ciphertext. What happens when she runs that command?</p>
</div>

---
layout: default
---

# Day 40 · Why Eve's attempt fails

```bash
sops updatekeys .enc.env

## Failed to get the data key required to decrypt the SOPS file.
## Group 0: FAILED
##   age1evexxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: FAILED
##     - age: no identity matched any of the recipients.
```

<div class="g-callout info" style="margin-top: 1rem;">
  <p><code>updatekeys</code> re-wraps the <strong>current</strong> DATA_KEY for
  whoever is listed in <code>.sops.yaml</code> — but first it has to unwrap
  that DATA_KEY using one of the file's <em>existing</em> recipients. Eve
  holds neither Alice's nor Bob's private key, so there's nothing for her to
  re-wrap in the first place — the same wrapped-DATA_KEY mechanism from the
  deep dive.</p>
</div>

<div class="g-callout success" style="margin-top: 0.8rem;">
  <p>Adding a public key to <code>.sops.yaml</code> only ever <em>declares
  intent</em> — someone who can already decrypt the file still has to run
  <code>updatekeys</code> for it to mean anything. A public repo stays safe.</p>
</div>

---
layout: default
---

<div class="g-section">
  <div class="g-eyebrow">Bonus</div>
  <h1>How SOPS handles file formats</h1>
  <p class="g-sub">
    YAML, JSON, <code>.env</code>, and INI all go through the same encryption
    strategy under the hood — here's what that actually means.
  </p>
</div>

---
layout: default
---

# Bonus · One tree, four formats

<p>SOPS parses every file into a <strong>tree</strong> of keys and values, walks to
every leaf, and encrypts only the leaf values in place — keys, nesting, and
structure all stay in plain text.</p>

<div class="g-grid-4" style="margin-top: 1.2rem;">
  <div class="g-card accent-blue">
    <h3>YAML</h3>
    <p>Nested — encrypts every leaf under any depth</p>
  </div>
  <div class="g-card accent-yellow">
    <h3>JSON</h3>
    <p>Same tree, wrapped in JSON syntax</p>
  </div>
  <div class="g-card accent-green">
    <h3>ENV</h3>
    <p>Flat tree — already covered in Steps 1–10</p>
  </div>
  <div class="g-card accent-red">
    <h3>INI</h3>
    <p>One level: section → key → value</p>
  </div>
</div>

<div class="g-callout info" style="margin-top: 1.2rem;">
  <p>Every encrypted file also gets a <strong>MAC</strong> computed over the whole
  tree. Hand-edit a key or value outside <code>sops</code> and the MAC no longer
  matches — <code>sops decrypt</code>/<code>sops edit</code> refuses the file
  instead of silently trusting it.</p>
</div>

---
layout: default
---

# Bonus · YAML

<div class="g-grid-2">
  <div>
    <h3>Before</h3>

```yaml
## cat config.yaml
database:
  host: localhost
  port: 5432
  password: super-secret
```
  </div>
  <div>
    <h3>After <code>sops encrypt --in-place config.yaml</code></h3>

```yaml
database:
  host: ENC[AES256_GCM,data:r7o0T9RQ21ZE,...,type:str]
  port: ENC[AES256_GCM,data:x1LEzQ==,...,type:int]
  password: ENC[AES256_GCM,data:Vzvb/Q0...,type:str]
sops:
  age:
    - recipient: age1lm37nkhmqrgy...
      enc: |
        -----BEGIN AGE ENCRYPTED FILE-----
  mac: ENC[AES256_GCM,data:8v+rRrtr...,type:str]
  version: 3.13.3
```
  </div>
</div>

<div class="g-callout success" style="margin-top: 1rem;">
  <p>No <code>--input-type</code>/<code>--output-type</code> needed — SOPS reads YAML
  from the <code>.yaml</code> extension. Note <code>port</code> keeps <code>type:int</code>,
  so it decrypts back to <code>5432</code>, not the string <code>"5432"</code>.</p>
</div>

---
layout: default
---

# Bonus · JSON

<div class="g-grid-2">
  <div>
    <h3>Before</h3>

```json
## cat config.json
{
  "database": {
    "host": "localhost",
    "port": 5432,
    "password": "super-secret"
  }
}
```
  </div>
  <div>
    <h3>After <code>sops encrypt --in-place config.json</code></h3>

```json
{
  "database": {
    "host": "ENC[AES256_GCM,data:avdSjy...,type:str]",
    "port": "ENC[AES256_GCM,data:hQK+Bw==,...,type:int]",
    "password": "ENC[AES256_GCM,data:23eqK1...,type:str]"
  },
  "sops": {
    "age": [{ "recipient": "age1lm37...", "enc": "..." }],
    "mac": "ENC[AES256_GCM,data:A71Mud...,type:str]",
    "version": "3.13.3"
  }
}
```
  </div>
</div>

<div class="g-callout success" style="margin-top: 1rem;">
  <p>Same tree as YAML, just JSON syntax. Every <code>ENC[...]</code> value is still a
  valid quoted string, so the file stays parseable while encrypted — only
  SOPS-aware tooling knows to treat it as ciphertext.</p>
</div>

---
layout: default
---

# Bonus · INI

<div class="g-grid-2">
  <div>
    <h3>Before</h3>

```ini
## cat config.ini
[database]
host = localhost
password = super-secret
```
  </div>
  <div>
    <h3>After <code>--input-type ini --output-type ini</code></h3>

```ini
[database]
host     = ENC[AES256_GCM,data:Sas/g3...,type:str]
password = ENC[AES256_GCM,data:tEGD8U...,type:str]

[sops]
age__list_0__map_recipient = age1lm37...
age__list_0__map_enc       = -----BEGIN AGE...
mac                        = ENC[AES256_GCM,...,type:str]
version                    = 3.13.3
```
  </div>
</div>

<div class="g-callout" style="margin-top: 1rem;">
  <p>INI has sections but no deeper nesting, so metadata gets flattened into a
  <code>[sops]</code> section — the same trick dotenv uses. SOPS can't guess this
  format from the extension, so <code>--input-type</code>/<code>--output-type</code>
  are required, same as dotenv.</p>
</div>

---
layout: default
---

# Bonus · Why this matters

<p>Because encryption happens leaf-by-leaf instead of on the whole file:</p>

<div class="g-grid-2" style="margin-top: 0.6rem; gap: 0.9rem;">
  <div class="g-card compact accent-blue">
    <h3>Diffable</h3>
    <p><code>git diff</code> shows which key changed, even though you can't see
    its new value.</p>
  </div>
  <div class="g-card compact accent-green">
    <h3>Partial decryption</h3>
    <p><code>sops decrypt --extract '["database"]["password"]'</code> pulls one
    value without decrypting the rest.</p>
  </div>
  <div class="g-card compact accent-yellow">
    <h3>Selective encryption</h3>
    <p><code>--unencrypted-regex</code> / <code>--unencrypted-suffix</code> can leave
    specific leaves in plain text.</p>
  </div>
  <div class="g-card compact accent-red">
    <h3>Tamper-evident</h3>
    <p>The MAC over the tree means a hand-edited value breaks decryption
    instead of silently succeeding.</p>
  </div>
</div>

<div class="g-callout" style="margin-top: 0.8rem;">
  <p>A format SOPS doesn't recognize as a tree (binary, an unrecognized extension)
  falls back to encrypting the whole file as one blob — none of the above
  applies, and decryption becomes all-or-nothing.</p>
</div>

---
layout: default
---

<div class="g-section">
  <div class="g-eyebrow">In practice</div>
  <h1>Using SOPS with Docker &amp; other CLI tools</h1>
  <p class="g-sub">
    Docker, <code>docker-compose</code>, and most other CLIs have no idea
    what SOPS is — they just read whatever bytes are in the file you point
    them at.
  </p>
</div>

---
layout: default
---

# The pitfall

<p>Point a tool straight at the encrypted <code>.enc.env</code> and it won't fail —
take a minimal <code>docker-compose.yml</code> that passes a couple of its
keys into a container:</p>

```yaml
## cat docker-compose.yml
services:
  app:
    image: alpine:3.20
    command: ["sh", "-c", "echo DATABASE_URL=$DATABASE_URL JWT_SECRET=$JWT_SECRET"]
    environment:
      - DATABASE_URL
      - JWT_SECRET
```

```bash
docker compose --env-file .enc.env run --rm app

## output
DATABASE_URL=ENC[AES256_GCM,data:peUXSKCZ...] JWT_SECRET=ENC[AES256_GCM,data:Zb6BKAEn...]
```

<div class="g-callout danger" style="margin-top: 1rem;">
  <p><strong>No error, no warning</strong> — the app just received two useless
  ciphertext strings instead of a database URL and a secret. Never
  <code>env_file: .enc.env</code> / <code>--env-file .enc.env</code> a SOPS-encrypted
  file directly — always decrypt it into the command first.</p>
</div>

---
layout: default
---

# Fix 1 · `sops exec-env`

<p><code>sops exec-env &lt;file&gt; '&lt;command&gt;'</code> decrypts in memory,
exports every key as an environment variable, runs the command with that
environment, and discards the plaintext the moment it exits.</p>

<div class="dp-diagram">
  <div class="dp-step">
    <div class="dp-icon dp-icon-blue">🔒</div>
    <div class="dp-label"><code>.enc.env</code></div>
    <div class="dp-sub">ENC[...] values on disk</div>
  </div>
  <div class="dp-connector">
    <span class="dp-connector-line"></span>
    <span class="dp-connector-chip">exec-env</span>
  </div>
  <div class="dp-step">
    <div class="dp-icon dp-icon-yellow">🧠</div>
    <div class="dp-label">decrypted in memory</div>
    <div class="dp-sub">exported as real env vars</div>
  </div>
  <div class="dp-connector">
    <span class="dp-connector-line"></span>
    <span class="dp-connector-chip">runs</span>
  </div>
  <div class="dp-step">
    <div class="dp-icon dp-icon-green">⚙️</div>
    <div class="dp-label">your command</div>
    <div class="dp-sub">sees plaintext values</div>
  </div>
  <div class="dp-connector">
    <span class="dp-connector-line"></span>
    <span class="dp-connector-chip">exits →</span>
  </div>
  <div class="dp-step">
    <div class="dp-icon dp-icon-success">🗑️</div>
    <div class="dp-label">discarded</div>
    <div class="dp-sub">plaintext never touches disk</div>
  </div>
</div>

```bash
sops exec-env .enc.env 'docker compose run --rm app'

## output
DATABASE_URL=postgres://user:pass@db:5432/mydb JWT_SECRET=7f3c9a2e1d8b4f6a...
```

<div class="g-callout success" style="margin-top: 0.6rem;">
  <p>Works for <code>docker compose</code>'s <code>environment:</code> passthrough
  above because compose picks up bare <code>- VAR</code> names from whatever
  process launched it — <code>exec-env</code> <em>is</em> that process. It also
  works for anything that just reads env vars: <code>go run</code>,
  <code>npm run start</code>, <code>psql</code>, CI steps.</p>
</div>

---
layout: default
---

# Fix 2 · `sops exec-file`

<p>Some flags only accept a path — <code>docker compose --env-file &lt;path&gt;</code>
is one, since it populates values <em>substituted into the compose file</em>,
not just the container's environment.</p>

```bash
sops exec-file --no-fifo --input-type dotenv --output-type dotenv \
  --filename decrypted.env .enc.env \
  'docker compose --env-file {} run --rm app'
## output
DATABASE_URL=postgres://user:pass@db:5432/mydb JWT_SECRET=7f3c9a2e1d8b4f6a...
```

<div class="g-grid-2" style="margin-top: 0.7rem;">
  <div class="g-card compact accent-blue">
    <h3><code>{}</code></h3>
    <p>The path to a real, temporary decrypted file — deleted automatically
    once the command returns.</p>
  </div>
  <div class="g-card compact accent-yellow">
    <h3><code>--no-fifo</code></h3>
    <p>Forces a real temp file. By default <code>exec-file</code> hands over a
    named pipe, which hangs a tool that opens the file more than once.</p>
  </div>
</div>

<div class="g-callout info" style="margin-top: 0.6rem;">
  <p><code>--input-type</code>/<code>--output-type</code> are needed because
  <code>decrypted.env</code> doesn't end in <code>.env</code>, so SOPS can't
  infer the format the way it does for <code>.env</code> itself.</p>
</div>

---
layout: default
---

# Which one to reach for

<div class="g-grid-3" style="margin-top: 0.8rem;">
  <div class="g-card accent-green">
    <h3>sops exec-env</h3>
    <p>The default choice. Anything that just needs environment variables:
    <code>docker compose</code> (via <code>environment:</code>), a locally-run
    app, a migration script, <code>psql</code>/<code>redis-cli</code>, CI steps.</p>
  </div>
  <div class="g-card accent-yellow">
    <h3>sops exec-file</h3>
    <p>Only when a tool's flag hard-requires a real file path — like
    <code>docker compose --env-file</code> — and the process environment
    isn't an option.</p>
  </div>
  <div class="g-card accent-red">
    <h3>Never</h3>
    <p><code>sops decrypt --in-place .enc.env</code>, run your command, then
    <code>encrypt --in-place</code> to "put it back." A crash or a stray
    <code>git add .</code> in between leaves plaintext exposed.</p>
  </div>
</div>

<div class="g-callout" style="margin-top: 1rem;">
  <p><code>exec-env</code> / <code>exec-file</code> decrypt straight into a
  process or a throwaway temp file — there's never a window where a fully
  decrypted <code>.env</code> sits on disk waiting to be committed or leaked.</p>
</div>

---
layout: default
---

# Tip · Auto-decrypt with direnv

<p><a href="https://direnv.net">direnv</a> loads environment variables the moment you
<code>cd</code> into a project — pair it with SOPS and no one ever has to
remember to run <code>sops decrypt</code> by hand:</p>

```bash
# .envrc
sops -d .enc.env > .env
set -a
source .env
set +a
```

<div class="g-grid-2" style="margin-top: 1rem;">
  <div class="g-card accent-blue">
    <h3><code>set -a</code> / <code>set +a</code></h3>
    <p>Toggles shell auto-export around the <code>source</code>, so every
    variable from <code>.env</code> lands in the real environment — not just
    as a local shell variable.</p>
  </div>
  <div class="g-card accent-green">
    <h3>One-time setup</h3>
    <p><code>direnv allow</code> approves the file once; every <code>cd</code>
    after that re-decrypts and reloads automatically.</p>
  </div>
</div>

<div class="g-callout info" style="margin-top: 1rem;">
  <p>Commit <code>.envrc</code> right alongside <code>.enc.env</code> — it's just
  automation, not a secret. <code>.env</code> stays gitignored, same as always.</p>
</div>
