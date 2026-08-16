# Sharing Development Secrets Securely with SOPS + age

This is a demo of how to use [SOPS](https://github.com/getsops/sops) to encrypt and decrypt secrets in a development environment.

## Why SOPS?

`.env` secrets are often shared naively — committed to git in plain text, or protected with one password the whole team shares. Here's how SOPS + age compares to two well-known alternatives:

|  | [dotenv.org](https://www.dotenv.org/) | [dotenvx](https://dotenvx.com/) | **SOPS + age** |
| --- | --- | --- | --- |
| Encryption at rest | ❌ None — the classic `dotenv` library loads `.env` as plain text | ✅ ECIES + AES-256 — values become ciphertext, keys stay readable | ✅ AES-256 — values become ciphertext |
| Who holds the decryption key | N/A — nothing is encrypted | One shared `DOTENV_PRIVATE_KEY` per environment, kept in `.env.keys` and used by the whole team | Each team member has their own age key pair; the file is encrypted to every recipient's public key |
| Revoking one person's access | N/A | Rotate `DOTENV_PRIVATE_KEY` and re-encrypt — affects everyone, since the whole team shared that key | Remove their public key from `.sops.yaml` and run `sops updatekeys` — no shared secret to rotate |
| Safe to commit to git | ❌ Secrets sit in plain text in the repo and its history | ✅ Values are ciphertext; only the public key is committed | ✅ Values are ciphertext; only public keys are committed |
| Supported file formats | `.env` only | `.env` only | YAML, JSON, `.env`, INI, and binary |
| Needs an external/hosted service | No | No — self-hosted (a paid vault add-on exists but isn't required) | No — fully open-source and self-hosted |

This is what makes SOPS + age a more secure fit for sharing secrets across a team: everyone keeps their own key, and removing someone's access never means rotating a secret the whole team relies on.

<sub>Sources: [dotenvx encryption docs](https://dotenvx.com/docs/learn/encrypting/introduction), [dotenvx private keys docs](https://dotenvx.com/docs/learn/encrypting/private-keys), [dotenv-vault repo](https://github.com/dotenv-org/dotenv-vault), [SOPS age docs](https://getsops.io/docs/usage/identities/age/).</sub>

## Requirements

- Install [SOPS](https://github.com/getsops/sops)
    - `go install github.com/getsops/sops/v3/cmd/sops@latest`

- Install [age](https://github.com/FiloSottile/age)
    - `brew install age`
    - or `go install filippo.io/age/cmd/...@latest`

## Demo

```bash
## cat .env
JWT_SECRET=some-secret-value

export SOPS_AGE_RECIPIENTS="age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

## encrypt .env in place
sops encrypt \
  --input-type dotenv \
  --output-type dotenv \
  --in-place \
  .env

## cat .env
JWT_SECRET=ENC[AES256_GCM,data:+ZdkX501aUvs936QIUMwJPE=,iv:RsYWiUCYvM45+Y9x0oyCc0kIqJi84Rh4ht+4vS830aM=,tag:fhbm/g7a4dH+L8U8A/Iveg==,type:str]
sops_age__list_0__map_enc=-----BEGIN AGE ENCRYPTED FILE-----\nYWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IFgyNTUxOSA0akpQdGRmakxVZUZQaGpi\ncEdsYXZpVjU4eWtka2dmV1VGbSs0aXFKa3lvCjJyVE4vei9JZFoyWS83VWl2SFc0\nRTZlSTFCK3dENDZyTWhCSEhRb2J6N1EKLS0tIER4L2xmWDV0WVdJMzBoTFFpVUZN\nVWlielhQTUFPRHQ3WGdPR1F

## decrypt .env (prints to stdout, file stays encrypted)
export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt

sops decrypt \
  --input-type dotenv \
  --output-type dotenv \
  .env

## edit .env
sops edit \
  --input-type dotenv \
  --output-type dotenv \
  .env

## cat .env
JWT_SECRET=ENC[AES256_GCM,data:+ZdkX501aUvs936QIUMwJPE=,iv:RsYWiUCYvM45+Y9x0oyCc0kIqJi84Rh4ht+4vS830aM=,tag:fhbm/g7a4dH+L8U8A/Iveg==,type:str]
sops_age__list_0__map_enc=-----BEGIN AGE ENCRYPTED FILE-----\nYWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IFgyNTUxOSA0akpQdGRmakxVZUZQaGpi\ncEdsYXZpVjU4eWtka2dmV1VGbSs0aXFKa3lvCjJyVE4vei9JZFoyWS83VWl2SFc0\nRTZlSTFCK3dENDZyTWhCSEhRb2J6N1EKLS0tIER4L2xmWDV0WVdJMzBoTFFpVUZN\nVWlielhQTUFPR
```

## Learning steps

Assume we have a `.env` file with the following content:

```bash
JWT_SECRET=some-secret-value
```

We want to encrypt this file with SOPS.

### Try to encrypt a secret

```bash
sops encrypt \
  --input-type dotenv \
  --output-type dotenv \
  .env

## output error
config file not found, or has no creation rules, and no keys provided through command line options
```

### Problem: SOPS doesn't know which encryption key to use

SOPS recommends generating a key with `age-keygen`. Store the key in the `~/.config/sops/age/keys.txt` file.

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt

## output
public key: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

> ⚠️ Important: treat `keys.txt` as a secret file, since it contains your private key. Don't commit it to Git or share its contents.

### Try to encrypt a secret with the key

```bash
sops encrypt \
  --age age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx \
  --input-type dotenv \
  --output-type dotenv \
  .env
```

This produces:

```bash
JWT_SECRET=ENC[AES256_GCM,data:+ZdkX501aUvs936QIUMwJPE=,iv:RsYWiUCYvM45+Y9x0oyCc0kIqJi84Rh4ht+4vS830aM=,tag:fhbm/g7a4dH+L8U8A/Iveg==,type:str]
sops_age__list_0__map_enc=-----BEGIN AGE ENCRYPTED FILE-----\nYWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IFgyNTUxOSA0akpQdGRmakxVZUZQaGpi\ncEdsYXZpVjU4eWtka2dmV1VGbSs0aXFKa3lvCjJyVE4vei9JZFoyWS83VWl2SFc0\nRTZlSTFCK3dENDZyTWhCSEhRb2J6N1EKLS0tIER4L2xmWDV0WVdJMzBoTFFpVUZN\nVWlielhQTUFPRHQ3WGdPR1F0SHB3dUkKACP54bAF1N9MC5khI1eqpCJwUeFhfhVs\nGoK8Kk7eyC/u6NbWRUvfWyeDWCIqyoxBMvfFNTjcqUx9EyHoO9xuAw==\n-----END AGE ENCRYPTED FILE-----\n
sops_age__list_0__map_recipient=age1ec9sjup3ff4vfjj3dglhamwgrew8kcczcmqnuqvrjcpygxpzupdqftcluw
sops_lastmodified=2026-08-16T05:37:29Z
sops_mac=ENC[AES256_GCM,data:oPIc0wijg+/sHf82OZ9IKMAHtGuxg8OYHCFS+eeyWaTof9E1c0zjN3CzxBt0njqKNOUJ7AIxcKri2QOOQns5NzcO5lMGonnHHmikB0lBPlmeJIj0z76atUfmMmBpPI3ikXepEPUdOS+/FzY1T1NScLJZSq35+TdZHfbfyaThqoA=,iv:nLu74DkTfygTBpA13vXy9nxlLhS2FiJrLVPrQsxcFQs=,tag:iQ+tBYlzNpTgNBPJ06ZqWQ==,type:str]
sops_unencrypted_suffix=_unencrypted
sops_version=3.13.3
```

You can also set the recipient as an environment variable instead of passing `--age`:

```bash
export SOPS_AGE_RECIPIENTS="age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

sops encrypt \
  --input-type dotenv \
  --output-type dotenv \
  .env
```

To overwrite `.env` with its encrypted version instead of printing to stdout, use `--in-place`:

```bash
sops encrypt \
  --input-type dotenv \
  --output-type dotenv \
  --in-place \
  .env
```

### Decrypting a secret

You need to tell SOPS which private key to use to decrypt the secret.
`sops` looks for the key in these locations, in order: `SOPS_AGE_SSH_PRIVATE_KEY_FILE`, `SOPS_AGE_SSH_PRIVATE_KEY_CMD`, `SOPS_AGE_KEY`, `SOPS_AGE_KEY_FILE`, and `SOPS_AGE_KEY_CMD`.

| Variable                        | What it contains                                                     | Example                       |
| -------------------------------- | ---------------------------------------------------------------------| ------------------------------|
| `SOPS_AGE_KEY_FILE`             | Path to a file containing age private key(s)                         | `~/.config/sops/age/keys.txt` |
| `SOPS_AGE_KEY`                  | The actual age private key text                                      | `AGE-SECRET-KEY-1...`         |
| `SOPS_AGE_KEY_CMD`              | Command whose stdout contains the private key                        | `pass show sops/age-key`      |
| `SOPS_AGE_SSH_PRIVATE_KEY_FILE` | Path to an SSH private-key file that SOPS can use as an age identity | `~/.ssh/id_ed25519`           |
| `SOPS_AGE_SSH_PRIVATE_KEY_CMD`  | Command whose stdout provides the SSH private key                    | `op read ...`                 |

The simplest approach is to set `SOPS_AGE_KEY_FILE` to point at `~/.config/sops/age/keys.txt`:

```bash
export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt

sops decrypt \
  --input-type dotenv \
  --output-type dotenv \
  .env
```

### Using `sops edit` as an editor

Once `SOPS_AGE_KEY_FILE` is exported, you can use `sops edit` to edit the encrypted secret directly.

```bash
sops edit \
  --input-type dotenv \
  --output-type dotenv \
  .env
```

Change the values and save the file — SOPS re-encrypts them automatically.

### Challenge: some keys in `.env` don't need to be encrypted

Assume the following `.env` file:

```bash
LOG_LEVEL=DEBUG
SERVER_PORT=8080

DEMO_USER=demo
DEMO_PASSWORD=demo

DATABASE_URL=postgres://user:password@localhost:5432/mydb?sslmode=require
JWT_SECRET=7f3c9a2e1d8b4f6a9c0e7d2b5a1f8c3e6d9b4a7f2c5e8d1a6b9c3f0e7d4a2b8
API_ACCESS_TOKEN=at_live_8Fv3kP9xQ2mL7nR4tY6wC1aZ5sD9eG2hJ8kN3pV6xB
```

`LOG_LEVEL`, `SERVER_PORT`, and `DEMO_USER` don't need to be encrypted.

Pass `--unencrypted-regex` to `sops` to tell it which keys to leave unencrypted:

```bash
sops encrypt \
  --input-type dotenv \
  --output-type dotenv \
  --unencrypted-regex '^(LOG_LEVEL|SERVER_PORT|DEMO_USER)$' \
  .env

## output
LOG_LEVEL=DEBUG
SERVER_PORT=8080
DEMO_USER=demo
DEMO_PASSWORD=ENC[AES256_GCM,data:E5lwqg==,iv:7hLULv3aze5p06tybplOt+INh0q+/D4AWbL6WT97mnk=,tag:VXfdRtu0kPTY/F4WOyR/rw==,type:str]
DATABASE_URL=ENC[AES256_GCM,data:ZLvvzZXgkEu5eU9vlw4/uNXmUbXNZdK/rJrnr4ypicR3EeUlwACJCdlGh9jsxES86tu3RIJl1F/YaGMA,iv:AVqXT9H3Am2o/u7OGN0wFawhXoE+eTyna3fNCifbySQ=,tag:RKp67v2QWRDUR2a4QZ+B/Q==,type:str]
JWT_SECRET=ENC[AES256_GCM,data:gi2CpMOMggEOPOlaahNFTSUeGaKm/sAov5tyavJOIWr17/5VpdN9iVdFJ2xqiszY+fFskfaaJkELG4TxFCzk,iv:Whv5w1KhdkfIAQt/38VfkUITcVYK9JFBJQgGQDVkWlU=,tag:uveldicxnEkRpRCLEbXMlA==,type:str]
API_ACCESS_TOKEN=ENC[AES256_GCM,data:WIGpFUSpXUASJKvC58w9sy5xAZUAGkeqXuhLXsaXdM/5VYZYtAbDtyVoIQdvyxQ5Uq4=,iv:t1HXaM8gnqQ5kATjEW9sF0Vg5IoKLD+RBXe+H4s7Eiw=,tag:nStSZwANijGBdBhHPPhKog==,type:str]
sops_age__list_0__map_enc=-----BEGIN AGE ENCRYPTED FILE-----\nYWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IFgyNTUxOSBJRkNsRkFWUTFhYkNBMTRI\neWhDMFhUK0ZOcnFlcklXaUc0Vjh4RnZEbUdvCkc0WGhuemZvbVM0NjJvcU5qcldv\nYUlnT0I1alFlL01HYkJWbkM3U1ZLZnMKLS0tIDVCMnhGbGFwaXRhcXZaUEZaczYv\nY3F5MDhtbUVzNlZ6T0hrNDQrVk51dGsKIHbyL6R2Rc5DGVG6UvYS7u8z95951udR\nlJCUzcWRp54+hqBCEBDlSJtiBewNLb+fhVxquMiTmapBqI2QIHfpHA==\n-----END AGE ENCRYPTED FILE-----\n
sops_age__list_0__map_recipient=age1ec9sjup3ff4vfjj3dglhamwgrew8kcczcmqnuqvrjcpygxpzupdqftcluw
sops_lastmodified=2026-08-16T06:21:38Z
sops_mac=ENC[AES256_GCM,data:v9bdKzNsMNvXUgtL2P4qzzZDlSDhp6EuLJCISMP+aR/EYGjOGjCYlBBzYlL+k7XdPLJToIV9LUjFHF2HAglub+PYCwmIZ/hC3WyY/zKAaQczUW7ToQMQIg+cmzoz9g8G4ijLnVRMr4g47d7fnXWGoJ1xXCrwvcSEDrNV/lMMfNE=,iv:IZQItJjPuo2xOg+z2tPva3mA/ZCfRt+oMhTfk+VJ33M=,tag:hS3UftllNwgpMRfjcTyy8w==,type:str]
sops_unencrypted_regex=^(LOG_LEVEL|SERVER_PORT|DEMO_USER)$
sops_version=3.13.3
```

Notice that `LOG_LEVEL`, `SERVER_PORT`, and `DEMO_USER` stay in plain text because they match the regex — everything else is encrypted.

### The configuration file: `.sops.yaml`

You can also configure encryption with a `.sops.yaml` file, written in YAML.

```.sops.yaml
creation_rules:
  - age: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    unencrypted_regex: "^(LOG_LEVEL|SERVER_PORT|DEMO_USER)$"
```

You can also add a `path_regex` to target specific files, so running `sops` against a matching file lets you edit its encrypted content directly.

```.sops.yaml
creation_rules:
  - age: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    unencrypted_regex: "^(LOG_LEVEL|SERVER_PORT|DEMO_USER)$"
```

### How to share with a team

You can share the encrypted secret with a team member by adding their `age` public key.

1. Add the new team member's public key to `.sops.yaml`:

```.sops.yaml
creation_rules:
  - age:
        - age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
        - age1yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
    unencrypted_regex: "^(LOG_LEVEL|SERVER_PORT|DEMO_USER)$"
```

2. Run `sops updatekeys .env` so SOPS updates the file's metadata with the new recipient:

```bash
sops updatekeys .env

2026/08/16 14:37:58 Syncing keys for file .../demo-sops/.env
The following changes will be made to the file's groups:
Group 1
    age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
+++ age1yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
Is this okay? (y/n):y
```

> Changing `.sops.yaml` doesn't automatically re-encrypt your existing `.env` file — you'll need to re-encrypt it with `sops updatekeys .env`.

### Migrating an existing `.env` to SOPS

Say you already have:

- a plain-text `.env` file
- a `.sops.yaml` file
- your age key/recipient configured

Add a `path_regex` to `.sops.yaml` so SOPS recognizes `.env` files automatically:

```.sops.yaml
creation_rules:
  - path_regex: \.env$
    age: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    unencrypted_regex: "^(LOG_LEVEL|SERVER_PORT|DEMO_USER)$"
```

You can keep editing `.env` as a normal file, then encrypt it in place whenever you're ready:

```bash
sops encrypt --in-place .env
```

> ⚠️ No `path_regex` in `.sops.yaml`? Add `--input-type dotenv --output-type dotenv` explicitly, otherwise SOPS defaults to JSON output even though the file is `.env`:
> ```bash
> sops encrypt --input-type dotenv --output-type dotenv --in-place .env
> ```

This encrypts `.env` directly — no separate `.enc.env` file needed. To edit it again, use `sops edit .env`. Decrypt it back to plain text with `sops decrypt --in-place .env` (add the same `--input-type`/`--output-type` flags if you don't have `path_regex`).
