# Windows Server 2025

## Configuração

- Nome: `SRVAD2025`.
- IP: `10.100.20.10/24`.
- Gateway: `10.100.20.1`.
- DNS atual: `10.100.10.11` preferencial e `10.100.20.10` alternativo.
- Domínio: `wcrpc.lan`.

## Validações concluídas

- DNS do domínio e registro SRV de LDAP resolvidos.
- Portas 53, 88, 135, 389 e 445 acessíveis.
- `nltest /dsgetdc:wcrpc.lan` encontrou o `SRVAD2022`.
- Ingresso no domínio concluído.
- `Test-ComputerSecureChannel` retornou `True`.
- Fonte de horário alterada para a hierarquia do domínio; fonte atual `srvad2022.wcrpc.lan`.

## Estado

Servidor promovido como controlador adicional, DNS e Global Catalog.

- DFSR `State 4`.
- `SysvolReady = 1`.
- Compartilhamentos `SYSVOL` e `NETLOGON` publicados.
- DNS, Advertising, SysVolCheck e NetLogons aprovados.
- Replicação bidirecional sem falhas.
- Canal seguro e registro DNS validados com `NERR_Success`.
- Nenhuma função FSMO transferida até o momento.

## Configuração de virtualização estabilizada

- CPU: `x86-64-v2-AES`.
- UEFI/OVMF e Q35.
- Secure Boot desabilitado até teste controlado posterior.
- QEMU Guest Agent operacional e utilizado na consistência do backup online.
