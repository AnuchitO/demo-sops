# Sharing Development Secrets Securely with SOPS + age

This is a demo of how to use [SOPS](https://github.com/mozilla/sops) to encrypt and decrypt secrets in a development environment.

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

## encrypt .env file to .enc.env
sops encrypt \
  --input-type dotenv \
  --output-type dotenv \
  .env > .enc.env

## cat .enc.env
JWT_SECRET=ENC[AES256_GCM,data:+ZdkX501aUvs936QIUMwJPE=,iv:RsYWiUCYvM45+Y9x0oyCc0kIqJi84Rh4ht+4vS830aM=,tag:fhbm/g7a4dH+L8U8A/Iveg==,type:str]
sops_age__list_0__map_enc=-----BEGIN AGE ENCRYPTED FILE-----\nYWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IFgyNTUxOSA0akpQdGRmakxVZUZQaGpi\ncEdsYXZpVjU4eWtka2dmV1VGbSs0aXFKa3lvCjJyVE4vei9JZFoyWS83VWl2SFc0\nRTZlSTFCK3dENDZyTWhCSEhRb2J6N1EKLS0tIER4L2xmWDV0WVdJMzBoTFFpVUZN\nVWlielhQTUFPRHQ3WGdPR1F

## decrypt .enc.env
export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt

sops decrypt \
  --input-type dotenv \
  --output-type dotenv \
  .enc.env

## edit .enc.env
sops edit \
  --input-type dotenv \
  --output-type dotenv \
  .enc.env

## cat .enc.env
JWT_SECRET=ENC[AES256_GCM,data:+ZdkX501aUvs936QIUMwJPE=,iv:RsYWiUCYvM45+Y9x0oyCc0kIqJi84Rh4ht+4vS830aM=,tag:fhbm/g7a4dH+L8U8A/Iveg==,type:str]
sops_age__list_0__map_enc=-----BEGIN AGE ENCRYPTED FILE-----\nYWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IFgyNTUxOSA0akpQdGRmakxVZUZQaGpi\ncEdsYXZpVjU4eWtka2dmV1VGbSs0aXFKa3lvCjJyVE4vei9JZFoyWS83VWl2SFc0\nRTZlSTFCK3dENDZyTWhCSEhRb2J6N1EKLS0tIER4L2xmWDV0WVdJMzBoTFFpVUZN\nVWlielhQTUFPR
```

## Learning steps

Assume we have a `.env` file with the following content:

```bash
JWT_SECRET=some-secret-value
```

We want to encrypt this file with SOPS.

### try to encrypt a secret

```bash
sops encrypt \
  --input-type dotenv \
  --output-type dotenv \
  .env

## output error

config file not found, or has no creation rules, and no keys provided through command line options
```

### Problem: SOPS doesn't know which encryption key to use.

SOPS recommends using `age-keygen` to generate a key. we can store the key in the `~/.config/sops/age/keys.txt` file.

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt

## output
public key: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

> ⚠️ Important: treat keys.txt as a secret file because it contains the private key. Don't commit it to Git or share its contents.


### Try to encrypt a secret with the key

```bash
sops encrypt \
  --age age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx \
  --input-type dotenv \
  --output-type dotenv \
  .env
```

### output

```bash
JWT_SECRET=ENC[AES256_GCM,data:+ZdkX501aUvs936QIUMwJPE=,iv:RsYWiUCYvM45+Y9x0oyCc0kIqJi84Rh4ht+4vS830aM=,tag:fhbm/g7a4dH+L8U8A/Iveg==,type:str]
sops_age__list_0__map_enc=-----BEGIN AGE ENCRYPTED FILE-----\nYWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IFgyNTUxOSA0akpQdGRmakxVZUZQaGpi\ncEdsYXZpVjU4eWtka2dmV1VGbSs0aXFKa3lvCjJyVE4vei9JZFoyWS83VWl2SFc0\nRTZlSTFCK3dENDZyTWhCSEhRb2J6N1EKLS0tIER4L2xmWDV0WVdJMzBoTFFpVUZN\nVWlielhQTUFPRHQ3WGdPR1F0SHB3dUkKACP54bAF1N9MC5khI1eqpCJwUeFhfhVs\nGoK8Kk7eyC/u6NbWRUvfWyeDWCIqyoxBMvfFNTjcqUx9EyHoO9xuAw==\n-----END AGE ENCRYPTED FILE-----\n
sops_age__list_0__map_recipient=age1ec9sjup3ff4vfjj3dglhamwgrew8kcczcmqnuqvrjcpygxpzupdqftcluw
sops_lastmodified=2026-08-16T05:37:29Z
sops_mac=ENC[AES256_GCM,data:oPIc0wijg+/sHf82OZ9IKMAHtGuxg8OYHCFS+eeyWaTof9E1c0zjN3CzxBt0njqKNOUJ7AIxcKri2QOOQns5NzcO5lMGonnHHmikB0lBPlmeJIj0z76atUfmMmBpPI3ikXepEPUdOS+/FzY1T1NScLJZSq35+TdZHfbfyaThqoA=,iv:nLu74DkTfygTBpA13vXy9nxlLhS2FiJrLVPrQsxcFQs=,tag:iQ+tBYlzNpTgNBPJ06ZqWQ==,type:str]
sops_unencrypted_suffix=_unencrypted
sops_version=3.13.3
```

you can also set the recipient in the environment variable

```bash
export SOPS_AGE_RECIPIENTS="age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

sops encrypt \
  --input-type dotenv \
  --output-type dotenv \
  .env
```

you can output the encrypted secret to a file using simple bash redirection `>` operator.

```bash
sops encrypt \
  --input-type dotenv \
  --output-type dotenv \
  .env > .enc.env
```

### Decrypting a secret

You NEED to tell SOPS the private key to decrypt the secret.
`sops` will look for keys in locations `SOPS_AGE_SSH_PRIVATE_KEY_FILE`, `SOPS_AGE_SSH_PRIVATE_KEY_CMD`, `SOPS_AGE_KEY`, `SOPS_AGE_KEY_FILE`, and `SOPS_AGE_KEY_CMD`.

| Variable                        | What it contains                                                     | Example                       |
| ------------------------------- | -------------------------------------------------------------------- | ----------------------------- |
| `SOPS_AGE_KEY_FILE`             | Path to a file containing age private key(s)                         | `~/.config/sops/age/keys.txt` |
| `SOPS_AGE_KEY`                  | The actual age private key text                                      | `AGE-SECRET-KEY-1...`         |
| `SOPS_AGE_KEY_CMD`              | Command whose stdout contains the private key                        | `pass show sops/age-key`      |
| `SOPS_AGE_SSH_PRIVATE_KEY_FILE` | Path to an SSH private-key file that SOPS can use as an age identity | `~/.ssh/id_ed25519`           |
| `SOPS_AGE_SSH_PRIVATE_KEY_CMD`  | Command whose stdout provides the SSH private key                    | `op read ...`                 |


use `SOPS_AGE_KEY_FILE` to store the key in the `~/.config/sops/age/keys.txt` file. simple as that.

```bash
export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt

 sops decrypt \
  --input-type dotenv \
  --output-type dotenv \
  .enc.env
```

### Sops edit mode as editor

after you export the `SOPS_AGE_KEY_FILE` you can use `sops edit` to edit the encrypted secret.

```bash
 sops edit \
  --input-type dotenv \
  --output-type dotenv \
  .enc.env
```

change the content of the file and save it. the encrypted secret will be updated.


### Challenge: in .env file, there are keys that are no need to be encrypted

```.env
LOG_LEVEL=DEBUG
SERVER_PORT=8080

DEMO_USER=demo
DEMO_PASSWORD=demo

DATABASE_URL=postgres://user:password@localhost:5432/mydb?sslmode=require
JWT_SECRET=7f3c9a2e1d8b4f6a9c0e7d2b5a1f8c3e6d9b4a7f2c5e8d1a6b9c3f0e7d4a2b8
API_ACCESS_TOKEN=at_live_8Fv3kP9xQ2mL7nR4tY6wC1aZ5sD9eG2hJ8kN3pV6xB
```

the `LOG_LEVEL`, `SERVER_PORT` and `DEMO_USER` are not need to be encrypted.

you can pass the `--unencrypted-regex` to `sops` to tell it to ignore the keys that match the regex.

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

see the `LOG_LEVEL`, `SERVER_PORT` and `DEMO_USER` are not encrypted because they match the regex. it just store in the plain text.

### the configuration file: .sops.yaml

you can also use the `.sops.yaml` file to configure the encryption. the file is in the YAML format.

```.sops.yaml
creation_rules:
  - age: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    unencrypted_regex: "^(LOG_LEVEL|SERVER_PORT|DEMO_USER)$"
```

you also specify the `path_regex` to encrypt the file. so that you can run `sops` then you will be able to edit the encrypted file right the way.

```.sops.yaml
creation_rules:
  - age: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    unencrypted_regex: "^(LOG_LEVEL|SERVER_PORT|DEMO_USER)$"
```

### How to share with a team

you can use the `age` key to share the encrypted secret with a team member.

1. add public key of new team member to `.sops.yaml`

```.sops.yaml
creation_rules:
  - age:
        - age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
        - age1yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
    unencrypted_regex: "^(LOG_LEVEL|SERVER_PORT|DEMO_USER)$"
```

2. run `sops updatekeys .enc.env` SOPS metadata includes the new recipient.

```bash
sops updatekeys .enc.env

2026/08/16 14:37:58 Syncing keys for file .../demo-sops/.enc.env
The following changes will be made to the file's groups:
Group 1
    age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
+++ age1yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
Is this okay? (y/n):y
```

> Changing `.sops.yaml` doesn't automatically re-encrypt your existing `.enc.env` file. You'll need to re-encrypt it with `sops updatekeys .enc.env`


