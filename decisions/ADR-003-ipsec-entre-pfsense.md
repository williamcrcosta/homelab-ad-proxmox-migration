# ADR-003: IPsec entre os pfSense

## Status

Aceito.

## Decisão

Criar túnel IKEv2 policy-based entre `192.168.50.15` e `192.168.50.16`, transportando LAN10 e LAN20.

## Motivo

O tráfego RPC/SMB não atravessava corretamente o caminho roteado original. O túnel assegurou transporte consistente para os protocolos do AD.

