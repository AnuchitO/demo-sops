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
