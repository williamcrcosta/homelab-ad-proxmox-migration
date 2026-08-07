# Windows Server 2025

## Configuração

- Nome: `SRVAD2025`.
- IP: `10.100.20.10/24`.
- Gateway: `10.100.20.1`.
- DNS durante a preparação: somente `10.100.10.11`.
- Domínio: `wcrpc.lan`.

## Validações concluídas

- DNS do domínio e registro SRV de LDAP resolvidos.
- Portas 53, 88, 135, 389 e 445 acessíveis.
- `nltest /dsgetdc:wcrpc.lan` encontrou o `SRVAD2022`.
- Ingresso no domínio concluído.
- `Test-ComputerSecureChannel` retornou `True`.
- Fonte de horário alterada para a hierarquia do domínio; fonte atual `srvad2022.wcrpc.lan`.

## Estado

Servidor é membro do domínio. AD DS e DNS ainda não foram instalados/promovidos no momento deste documento.

