# Segurança do repositório

Este repositório deve permanecer **privado**.

## Nunca versionar

- Senhas, PSKs, tokens ou hashes.
- Chaves MAK/KMS e credenciais do Windows.
- Certificados com chave privada.
- Backups do AD, Entra Connect, pfSense ou Proxmox.
- `config.xml` integral do pfSense.
- Capturas que exibam credenciais ou informações pessoais.

Use valores como `<PSK-REDACTED>` e `<PASSWORD-REDACTED>` nos exemplos. Antes de cada `git push`, revise `git diff --cached` e `git status`.

