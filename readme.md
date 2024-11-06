# Automação de backup com o MEGA para servidores  

Este script em Bash automatiza o processo de backup de pastas e arquivos para o MEGA, com suporte para instalação do `MEGAcmd`, configuração de itens a serem sincronizados e agendamento de execuções pelo `crontab`.

O script é indicado para servidores locais e em nuvem com pelo menos acesso a rede externa, ou seja, precisa conseguir se comunicar com o servidor do MEGA para que possa enviar os arquivos.
Pode ser instalado em servidores Ubuntu, Debian e derivados do Fedora mais recente.

## Descrição do Script

O script realiza as seguintes operações:
1. **Solicitação de credenciais MEGA**: Pede ao usuário o login e senha para acesso ao MEGA.
2. **Configuração**: Verifica ou cria o arquivo de configuração `mega_folders.conf` que armazena as pastas a serem sincronizadas.
3. **Instalação do MEGAcmd**: Permite ao usuário escolher o sistema operacional (Ubuntu, Debian ou Fedora) e versão para instalar o `MEGAcmd` automaticamente, facilitando o upload dos arquivos para o MEGA.
4. **Gerenciamento de Itens de Backup**: Oferece opções para adicionar, listar e fazer upload de pastas ou arquivos especificados no arquivo de configuração.
5. **Agendamento com Crontab**: Permite automatizar o backup em horários definidos pelo usuário.

## Configurações e Utilização

Clone esse repositório com: `git clone https://github.com/rafaelRizzo/auto-bkp-mega`

Dê permissão com chomd -x para o instalador: `chmod x install.sh`

E execute o instalador: `bash install.sh`

### 1. Instalação do MEGAcmd

O script solicita a escolha do sistema operacional e versão. Dependendo da seleção, ele baixa e instala o pacote correto para a plataforma:

- **Ubuntu**: Suporte para versões de 18.04 até 24.10.
- **Debian**: Suporte para versões 11 e 12.
- **Fedora**: Suporte para versões 38, 39 e 40.

OBS: PARA VERSÕES CENTOS7 PRECISA RODAR O SEGUINTE COMANDO PARA INSTALAÇÃO:

`yum install dnf -y && wget https://mega.nz/linux/repo/CentOS_7/x86_64/megacmd-1.6.3-1.1.x86_64.rpm && dnf install megacmd-1.6.3-1.1.x86_64.rpm`

### 2. Logando no MEGA

Após a instalação, o script realiza o login automático no MEGA com as credenciais fornecidas.

### 3. Configuração de Itens para Backup

#### Funções principais:
- **Adicionar pastas**: Permite adicionar pastas específicas para backup. O caminho de cada pasta é salvo no arquivo `mega_folders.conf`.
- **Listar pastas**: Exibe todas as pastas configuradas para backup.
- **Fazer upload das pastas**: Carrega as pastas listadas para a conta MEGA do usuário.

### 4. Automação do Backup

Após a configuração, o script cria um arquivo chamado `backup_script.sh` com funcionalidades adicionais para adicionar e listar itens de backup, além de permitir o agendamento de execução automatizada via `crontab`.

Para agendar o backup:
1. Edite o `crontab` usando `crontab -e`.
2. Adicione a linha abaixo para executar o backup diariamente às 2h da manhã e registrar o horário de início no log:

    ```bash
    0 2 * * * echo "Backup iniciado em: $(date '+\%Y-\%m-\%d \%H:\%M:\%S')" >> /home/rafa/auto-bkp-mega/backup.log && /home/rafa/auto-bkp-mega/backup_script.sh -run >> /home/rafa/auto-bkp-mega/backup.log 2>&1
    ```

### Uso do `backup_script.sh`

1. **Adicionar itens ao backup**: Adiciona pastas ou arquivos específicos ao arquivo de configuração.
2. **Listar itens configurados**: Exibe todos os itens configurados para backup.
3. **Executar backup**: Sincroniza imediatamente os itens configurados com a conta MEGA.

## Observação

Este script foi desenvolvido para facilitar backups periódicos e gerenciar itens para backup na conta MEGA. Certifique-se de configurar corretamente o `crontab` para garantir a automação do processo de backup.

**Importante**: A segurança das credenciais MEGA é responsabilidade do usuário, e é recomendável proteger o script e o arquivo de configuração com permissões restritas.

### Informações adicionais
Você pode criar seu próprio script com base na documentação do mega cmd no link: https://mega.io/pt-br/

ou digitando `mega`
Os comando básicos são:
mega-login usuario_mega senha_mega
mega-logout
mega-put diretório_ou_arquivo diretório_no_mega
mega-get nome_do_arquivo_no_mega

Você também consegue criar várias pastas "recursivamente" com a flag -c, exemplo: mega-put /backup/2024/11/05/arquivo.txt / -c

