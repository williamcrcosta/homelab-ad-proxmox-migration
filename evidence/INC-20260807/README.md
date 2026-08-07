# Índice de evidências — INC-20260807

Armazenar somente evidências sanitizadas. Evitar dumps, configurações completas ou arquivos que possam conter segredos.

## Evidências já observadas

| Evidência | Resultado |
|---|---|
| `Test-ADDSDomainControllerInstallation` | Success |
| Portas AD entre LAN20 e SRVAD2022 | Todas testadas com sucesso |
| `dcpromo.log` | Operação concluída, retorno 0 |
| `bcdedit /enum {default}` | Windows em `C:`, carregador `winload.efi` |
| `chkdsk C:` | Nenhum problema encontrado |
| Minidump/MEMORY.DMP | Não encontrados |
| `ntbtlog.txt` | Não criado |
| Lista de DCs | SRVAD2022 e SRVAD2025 registrados como GC |
| `repadmin /showrepl` | Erro 8524/DNS para o novo DC offline |

## Convenção de nomes

```text
YYYYMMDD-HHMM-origem-comando-ou-tela.ext
```

Exemplos:

```text
20260807-162824-srvad2025-dcpromo-final.txt
20260807-173150-srvad2022-repadmin-showrepl.txt
20260807-boot-winre.jpg
```

## Checklist de sanitização

- [ ] Sem senhas ou PSKs
- [ ] Sem chaves de produto
- [ ] Sem tokens ou cookies
- [ ] Sem certificados privados
- [ ] Sem URLs assinadas
- [ ] IPs e hostnames aprovados para repositório privado

