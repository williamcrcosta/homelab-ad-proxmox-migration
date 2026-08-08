# ADR-005 — Modelo de CPU da VM Windows Server 2025

- Status: Aceito
- Data: 2026-08-07
- VM: `750 / SRVAD2025`

## Contexto

A VM do Windows Server 2025 foi criada no Proxmox com `cpu: host`. Após a promoção para controlador de domínio, o sistema iniciou um ciclo de reinicialização durante o boot.

As verificações offline não apontaram corrupção de disco, arquivos do sistema, component store, BCD ou partição EFI. Alterações de Secure Boot, VBS e parâmetros do BCD, isoladamente, não resolveram o incidente.

## Decisão

Utilizar o modelo de CPU `x86-64-v2-AES`:

```bash
qm set 750 --cpu x86-64-v2-AES
```

## Motivos

- permitiu a inicialização estável do Windows Server 2025;
- reduz a exposição direta a recursos específicos da CPU física;
- melhora previsibilidade e compatibilidade da VM;
- facilita eventual migração para outro host compatível.

## Consequências

- a VM pode não utilizar todas as extensões expostas por `cpu: host`;
- o modelo deve ser mantido em backups, restaurações e recriações;
- qualquer retorno para `host` exige teste controlado e rollback disponível.

## Evidências

- com `cpu: host`: reinicialização antes da entrada no Windows;
- com `x86-64-v2-AES`: inicialização concluída e serviços AD DS operacionais.

