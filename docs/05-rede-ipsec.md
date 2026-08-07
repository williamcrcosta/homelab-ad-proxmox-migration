# Rede, pfSense e IPsec

## Rotas do roteador físico

| Destino | Próximo salto |
|---|---|
| `10.100.10.0/24` | `192.168.50.15` |
| `10.100.20.0/24` | `192.168.50.16` |

## Diagnóstico

DNS, Kerberos e LDAP atravessavam o caminho entre redes, mas RPC 135 e SMB 445 expiravam. Capturas demonstraram SYNs sem resposta no caminho original. Os dois pfSense possuíam conectividade WAN direta.

## Solução

- IKEv2, Mutual PSK.
- Phase 1: AES-256, SHA256, DH14, lifetime 28800.
- Phase 2: ESP, AES-256, SHA256, PFS14, lifetime 3600.
- Seletores: `10.100.10.0/24` ↔ `10.100.20.0/24`.
- Regras IPsec limitadas às duas redes internas.
- Regras No-NAT preservam os endereços de origem.

> A PSK não deve ser armazenada neste repositório.

## Resultado

`Test-NetConnection` do `SRVAD2025` para `10.100.10.11` nas portas 135 e 445 passou após o estabelecimento da Phase 2.

