# ADR-001: criar um novo DC em vez de P2V

## Status

Aceito.

## Decisão

Criar um Windows Server 2025 limpo no Proxmox, ingressá-lo no domínio e promovê-lo como DC adicional.

## Motivo

Reduz riscos associados à conversão de um DC em execução e permite validação e rollback sem alterar o servidor atual.

