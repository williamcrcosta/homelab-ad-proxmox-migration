# Complemento de documentação — incidente SRVAD2025

Este pacote complementa o repositório `homelab-ad-proxmox-migration` com a documentação do primeiro ensaio de promoção do `SRVAD2025`.

## Como incorporar

Copie o conteúdo deste pacote para a raiz do repositório, preservando as pastas. Revise o texto, acrescente as evidências finais e então publique:

```powershell
git status
git add docs decisions evidence scripts CHANGELOG-snippet.md
git commit -m "docs: registra incidente de boot na promocao do SRVAD2025"
git push
```

## Conteúdo

- `docs/incidents/INC-20260807-srvad2025-boot-failure.md`: registro principal do incidente.
- `docs/runbooks/RUN-DC-promotion-prechecks.md`: checklist aprimorado antes de uma promoção.
- `docs/runbooks/RUN-failed-dc-promotion.md`: fluxo seguro para recuperação ou reconstrução.
- `decisions/ADR-005-recover-or-rebuild-srvad2025.md`: decisão ainda pendente.
- `evidence/INC-20260807/README.md`: índice de evidências.
- `scripts/windows/Collect-DC-Promotion-Incident.ps1`: coletor somente leitura.
- `CHANGELOG-snippet.md`: trecho para incorporar ao changelog existente.

## Segurança

O repositório deve permanecer privado, pois os documentos contêm hostnames, endereços IP e detalhes de topologia. Não publique:

- senhas DSRM ou de domínio;
- PSK do IPsec;
- chaves de produto;
- tokens, certificados privados ou arquivos de configuração completos sem sanitização.

