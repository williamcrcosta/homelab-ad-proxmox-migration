# Recuperação do SRVAD2025: boot, promoção e SYSVOL/DFSR

## Resumo executivo

Durante a implantação do `SRVAD2025` como controlador de domínio adicional do domínio `wcrpc.lan`, ocorreram dois incidentes consecutivos:

1. A VM entrou em ciclo de reinicialização após a promoção a controlador de domínio.
2. Após a recuperação do boot, o novo DC permaneceu sem publicar `SYSVOL` e `NETLOGON`, falhando nos testes `Advertising` e `NetLogons`.

O boot foi recuperado alterando o modelo de CPU da VM no Proxmox de `host` para `x86-64-v2-AES`. O SYSVOL foi recuperado por uma sincronização DFSR autoritativa no `SRVAD2022` e não autoritativa no `SRVAD2025`, seguindo o procedimento suportado pela Microsoft.

## Ambiente envolvido

| Componente | Função | Endereço |
|---|---|---|
| `SRVAD2022` | DC existente, DNS, GC e fonte autoritativa do SYSVOL | `10.100.10.11` |
| `SRVAD2025` | Novo DC adicional, DNS e GC | `10.100.20.10` |
| pfSense antigo | Gateway da rede antiga | LAN `10.100.10.0/24` |
| pfSense novo | Gateway da rede nova | LAN `10.100.20.0/24` |
| Proxmox | Hipervisor do novo ambiente | VMID `750` |

As redes são interligadas por um túnel IPsec entre os dois pfSense.

## Linha do tempo técnica

### 1. Preparação e promoção

- Windows Server 2025 Standard instalado em VM UEFI/Q35.
- VM conectada à bridge isolada `vmbr10`.
- IP estático configurado como `10.100.20.10/24`.
- Gateway configurado como `10.100.20.1`.
- DNS inicial apontado exclusivamente para `10.100.10.11`.
- Comunicação AD validada nas portas TCP necessárias.
- Horário sincronizado com `srvad2022.wcrpc.lan`.
- Servidor ingressou no domínio `wcrpc.lan`.
- Pré-requisitos de promoção validados com `Test-ADDSDomainControllerInstallation`.
- Funções AD DS e DNS instaladas.
- Promoção concluída; o `DCPROMO.LOG` registrou replicação dos objetos e conclusão da operação.

### 2. Falha de boot após a promoção

Após o reinício, a VM apresentava o Windows Boot Manager no UEFI, iniciava o carregamento e reiniciava antes de concluir o boot.

Foram validados:

- integridade do disco com `chkdsk`;
- integridade da imagem com DISM;
- integridade de arquivos do sistema com SFC offline;
- BCD e partição EFI;
- driver VirtIO SCSI;
- Secure Boot;
- VBS e inicialização do hypervisor.

Não foram encontradas corrupções no sistema de arquivos, component store ou arquivos protegidos.

#### Causa operacional identificada

O modelo de CPU `host` utilizado pela VM provocava incompatibilidade durante a inicialização do Windows Server 2025 após a promoção.

Correção aplicada no Proxmox:

```bash
qm set 750 --cpu x86-64-v2-AES
```

Após a alteração, o Windows iniciou normalmente.

> Manter a VM com `x86-64-v2-AES`. Não retornar para `cpu: host` sem uma janela de testes e um ponto de recuperação válido.

### 3. Estado do AD após recuperar o boot

A replicação do banco de dados do Active Directory estava funcional:

- `repadmin /replsummary`: zero falhas;
- `repadmin /showrepl`: cinco naming contexts replicados;
- `repadmin /syncall /AdeP`: concluído sem erros;
- DNS aprovado no `dcdiag`;
- ambos os DCs identificados como Global Catalog.

Porém, o `SRVAD2025` apresentava:

- ausência dos compartilhamentos `SYSVOL` e `NETLOGON`;
- `SysvolReady = 0`;
- DFSR `State 2` (`Initial Sync`);
- evento DFSR `4614`;
- falha no `dcdiag /test:Advertising`;
- falha no `dcdiag /test:NetLogons`.

O `SRVAD2022` também reportava DFSR `State 2`, embora continuasse publicando `SYSVOL` e `NETLOGON` com `SysvolReady = 1`. Isso formava um bloqueio de sincronização: o novo DC aguardava uma origem que também estava em estado de sincronização inicial.

## Seleção da fonte autoritativa

O `SRVAD2022` foi escolhido como fonte autoritativa porque:

- publicava `SYSVOL` e `NETLOGON`;
- possuía `SysvolReady = 1`;
- sua pasta `Policies` continha as duas GPOs registradas no AD;
- a pasta `Scripts` estava acessível;
- havia backup recente com System State, NTDS, Registry, EFI e SYSVOL;
- foi criada uma cópia adicional em `C:\Backup-SYSVOL-20260807-230011`.

GPOs confirmadas:

| GPO | GUID |
|---|---|
| Default Domain Policy | `{31B2F340-016D-11D2-945F-00C04FB984F9}` |
| Default Domain Controllers Policy | `{6AC1786C-016F-11D2-945F-00C04FB984F9}` |

## Recuperação do SYSVOL

Foi utilizado o procedimento de sincronização autoritativa/não autoritativa do DFSR.

### SRVAD2022 — autoritativo

1. DFSR configurado como Manual e parado nos dois DCs.
2. No objeto `SYSVOL Subscription` do `SRVAD2022`:
   - `msDFSR-Enabled = FALSE`
   - `msDFSR-Options = 1`
3. No objeto do `SRVAD2025`:
   - `msDFSR-Enabled = FALSE`
4. Replicação do AD forçada e validada.
5. DFSR iniciado somente no `SRVAD2022`.
6. Evento `4114` confirmado.
7. `msDFSR-Enabled` alterado para `TRUE` no `SRVAD2022`.
8. `repadmin /syncall /AdeP` e `dfsrdiag pollad` executados.
9. Evento `4602` confirmado, designando o DC como membro primário.

Resultado no `SRVAD2022`:

- DFSR `State 4`;
- `SysvolReady = 1`;
- `SYSVOL` e `NETLOGON` publicados.

### SRVAD2025 — não autoritativo

1. DFSR iniciado com `msDFSR-Enabled = FALSE`.
2. Evento `4114` confirmado.
3. `msDFSR-Enabled` alterado para `TRUE`.
4. Replicação do AD forçada.
5. `dfsrdiag pollad` executado.
6. Eventos `4614` e `4604` confirmados.

Resultado no `SRVAD2025`:

- DFSR `State 4`;
- `SysvolReady = 1`;
- `SYSVOL` e `NETLOGON` publicados;
- `Advertising`, `SysVolCheck`, `NetLogons` e `DNS` aprovados.

## Validação final

```powershell
dcdiag /test:Advertising
dcdiag /test:SysVolCheck
dcdiag /test:NetLogons
dcdiag /test:DNS

repadmin /syncall /AdeP
repadmin /replsummary
repadmin /showrepl
```

Estado final esperado e obtido:

| Verificação | SRVAD2022 | SRVAD2025 |
|---|---:|---:|
| DFSR State | 4 | 4 |
| SysvolReady | 1 | 1 |
| SYSVOL publicado | Sim | Sim |
| NETLOGON publicado | Sim | Sim |
| Replicação AD | Saudável | Saudável |

## Decisões e restrições

- Não despromover o `SRVAD2022` nesta etapa.
- Não transferir FSMO antes do período de observação.
- Não alterar o DNS dos clientes antes da auditoria pós-promoção.
- Manter `x86-64-v2-AES` como CPU da VM 750.
- Não publicar senhas DSRM, PSKs do IPsec, chaves, tokens ou backups no Git.
- Validar Secure Boot e configurações VBS em janela posterior, pois foram alterados durante o diagnóstico.

## Próximos passos

1. Observar replicação AD e DFSR por pelo menos 24 horas.
2. Executar auditoria completa nos dois DCs.
3. Confirmar DNS, GC, NTP, eventos e compartilhamentos.
4. Configurar o DNS do `SRVAD2025` para operação com dois DCs.
5. Validar backup do novo DC.
6. Planejar transferência das funções FSMO.
7. Planejar migração do Microsoft Entra Connect separadamente.

## Referências

- [Microsoft — Force authoritative and non-authoritative synchronization for DFSR-replicated SYSVOL](https://learn.microsoft.com/en-us/troubleshoot/windows-server/group-policy/force-authoritative-non-authoritative-synchronization)
- [Microsoft — Troubleshoot missing SYSVOL and Netlogon shares](https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/troubleshoot-missing-sysvol-and-netlogon-shares)

