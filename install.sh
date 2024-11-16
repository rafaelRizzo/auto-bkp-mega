#!/bin/bash

# Restaura as configurações padrão do terminal, caso algo tenha sido corrompido
stty sane

# Solicita o usuário e a senha antes de continuar
read -rp "Digite seu usuário MEGA: " mega_user
read -srp "Digite sua senha MEGA: " mega_password
echo ""

# Caminho para o arquivo de configuração das pastas
DIR_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$DIR_PATH/mega_folders.conf"

# Cria o arquivo de configuração se ele não existir
if [[ ! -f $CONFIG_FILE ]]; then
    touch "$CONFIG_FILE"
    echo "Arquivo de configuração $CONFIG_FILE criado."
fi

# Função para exibir o help
help_menu() {
    echo "Uso: ./install_mega.sh"
    echo ""
    echo "Este script automatiza a instalação do MEGAcmd, configura pastas/arquivos para backup"
    echo "e cria um script para gerenciar backups na conta MEGA."
    echo ""
    echo "Passos principais:"
    echo "  1. Instalação: Seleciona o sistema operacional e instala o MEGAcmd."
    echo "  2. Login: Realiza o login automático no MEGA com as credenciais fornecidas."
    echo "  3. Configuração: Cria um script de backup configurável para gerenciar arquivos e pastas."
    echo ""
    echo "Opções automáticas no script de backup:"
    echo "  - Adicionar itens: Configura as pastas ou arquivos que serão enviados para o MEGA."
    echo "  - Listar itens: Mostra as pastas ou arquivos já configurados para backup."
    echo "  - Executar backup: Faz upload imediato dos itens configurados para sua conta MEGA."
    echo ""
    echo "Agendamento de backup com Crontab:"
    echo "  - Para automatizar o backup, adicione o script de backup ao crontab."
    echo "    Exemplo de entrada no crontab para execução diária às 2h da manhã:"
    echo "    0 2 * * * /caminho/para/backup_script.sh -run >> /caminho/para/backup.log 2>&1"
    echo ""
    echo "Para exibir este menu de ajuda, execute o script com a opção --help:"
    echo "  ./install_mega.sh --help"
    exit 0
}

# Verifica se a opção --help foi passada
if [[ $1 == "--help" ]]; then
    help_menu
fi

# Função para instalar MEGAcmd para Ubuntu e Debian
install_deb() {
    local distro="$1"
    local version="$2"
    echo "Baixando e instalando MEGAcmd para $distro $version..."

    wget "https://mega.nz/linux/repo/${distro}_${version}/amd64/megacmd-${distro}_${version}_amd64.deb" -O megacmd.deb
    sudo apt install -y "./megacmd.deb"
    rm -f megacmd.deb
}

# Função para instalar MEGAcmd no Fedora
install_fedora() {
    local version="$1"
    echo "Baixando e instalando MEGAcmd para Fedora $version..."

    wget "https://mega.nz/linux/repo/Fedora_${version}/x86_64/megacmd-Fedora_${version}.x86_64.rpm" -O megacmd.rpm
    sudo dnf install -y "./megacmd.rpm"
    rm -f megacmd.rpm
}

# Função para instalar MEGAcmd no CentOS 7
install_centos7() {
    echo "Baixando e instalando MEGAcmd para CentOS 7..."
    yum install dnf -y
    wget https://mega.nz/linux/repo/CentOS_7/x86_64/megacmd-1.6.3-1.1.x86_64.rpm
    dnf install -y megacmd-1.6.3-1.1.x86_64.rpm
    rm -f megacmd-1.6.3-1.1.x86_64.rpm
}

# Menu para selecionar o sistema operacional e versão
echo "Selecione o sistema operacional:"
echo "1) Ubuntu"
echo "2) Debian"
echo "3) Fedora"
echo "4) CentOS 7"
echo "5) Pular instalação, já tenho o mega instalado"
read -rp "Opção: " os_choice

if [[ $os_choice -eq 1 ]]; then
    echo "Selecione a versão do Ubuntu:"
    echo "1) 24.10"
    echo "2) 24.04"
    echo "3) 23.10"
    echo "4) 23.04"
    echo "5) 22.04"
    echo "6) 20.10"
    echo "7) 20.04"
    echo "8) 19.10"
    echo "9) 18.04"
    read -rp "Opção: " version_choice

    case $version_choice in
        1) install_deb "xUbuntu" "24.10" ;;
        2) install_deb "xUbuntu" "24.04" ;;
        3) install_deb "xUbuntu" "23.10" ;;
        4) install_deb "xUbuntu" "23.04" ;;
        5) install_deb "xUbuntu" "22.04" ;;
        6) install_deb "xUbuntu" "20.10" ;;
        7) install_deb "xUbuntu" "20.04" ;;
        8) install_deb "xUbuntu" "19.10" ;;
        9) install_deb "xUbuntu" "18.04" ;;
        *) echo "Opção inválida."; exit 1 ;;
    esac

elif [[ $os_choice -eq 2 ]]; then
    echo "Selecione a versão do Debian:"
    echo "1) 12 (bookworm)"
    echo "2) 11 (bullseye)"
    read -rp "Opção: " version_choice

    case $version_choice in
        1) install_deb "Debian" "12" ;;
        2) install_deb "Debian" "11" ;;
        *) echo "Opção inválida."; exit 1 ;;
    esac

elif [[ $os_choice -eq 3 ]]; then
    echo "Selecione a versão do Fedora:"
    echo "1) 40"
    echo "2) 39"
    echo "3) 38"
    read -rp "Opção: " version_choice

    case $version_choice in
        1) install_fedora 40 ;;
        2) install_fedora 39 ;;
        3) install_fedora 38 ;;
        *) echo "Opção inválida."; exit 1 ;;
    esac

elif [[ $os_choice -eq 4 ]]; then
    install_centos7

elif [[ $os_choice -eq 5 ]]; then
    echo "Ok! pulando instalação..."

else
    echo "Opção inválida. Saindo."
    exit 1
fi

# Comando para logar automaticamente no MEGA
echo "Logando no mega..."
mega-login ${mega_user} ${mega_password}

# Nome do arquivo que você deseja criar
FILE_NAME="backup_script.sh"

# Cria o arquivo e adiciona o conteúdo
cat << 'EOF' > "$FILE_NAME"
#!/bin/bash

# Caminho padrão do arquivo de configuração
DEFAULT_CONFIG_FILE="$(pwd)/mega_items.conf"

# Função para exibir o uso do script
usage() {
    echo "Uso: $0 [--config-dir <diretório> | -run]"
    echo ""
    echo "  --config-dir <diretório>  Define o diretório para salvar o arquivo de configuração."
    echo "  -run                      Executa o backup automaticamente."
    exit 1
}

# Processa argumentos de linha de comando
CONFIG_FILE="$DEFAULT_CONFIG_FILE"
while [[ $# -gt 0 ]]; do
    case $1 in
        --config-dir)
            shift
            if [[ -z $1 ]]; then
                echo "Erro: Nenhum diretório informado após --config-dir."
                usage
            fi
            CONFIG_FILE="$1/mega_items.conf"
            shift
            ;;
        -run)
            backup_to_mega
            exit 0
            ;;
        *)
            echo "Erro: Opção desconhecida: $1"
            usage
            ;;
    esac
done

# Função para adicionar várias pastas ou arquivos ao arquivo de configuração
add_items() {
    read -rp "Digite os caminhos das pastas ou arquivos para backup, separados por espaço: " -a paths

    for item in "${paths[@]}"; do
        if [[ -e $item ]]; then  # Verifica se o item (arquivo ou pasta) existe
            echo "$item" >> "$CONFIG_FILE"
            echo "Item adicionado: $item"
        else
            echo "Item não encontrado: $item"
        fi
    done
}

# Função para listar itens configurados para backup
list_items() {
    if [[ -f $CONFIG_FILE ]]; then
        echo "Itens configurados para backup:"
        cat "$CONFIG_FILE"
    else
        echo "Nenhum item configurado para backup ainda."
    fi
}

# Função para fazer o upload dos itens (pastas ou arquivos) para o MEGA
backup_to_mega() {
    if [[ ! -f $CONFIG_FILE ]]; then
        echo "Nenhum item configurado para backup. Adicione uma pasta ou arquivo primeiro."
        exit 1
    fi

    while IFS= read -r item; do
        if [[ -d $item ]]; then
            echo "Fazendo upload da pasta: $item"
            mega-put -c "$item" /
        elif [[ -f $item ]]; then
            echo "Fazendo upload do arquivo: $item"
            mega-put -c "$item" /
        else
            echo "Item não encontrado: $item"
        fi
    done < "$CONFIG_FILE"
}

# Menu para adicionar, listar itens ou iniciar o backup
echo "Arquivo de configuração: $CONFIG_FILE"
echo "Escolha uma opção:"
echo "1) Adicionar itens (pastas ou arquivos) ao backup"
echo "2) Listar itens configurados"
echo "3) Executar backup para MEGA"
read -rp "Opção: " choice

case $choice in
    1) add_items ;;
    2) list_items ;;
    3) backup_to_mega ;;
    *) echo "Opção inválida." ;;
esac
EOF

# Torna o arquivo executável
chmod +x "$FILE_NAME"

echo "$FILE_NAME criado com sucesso!"

echo "Instalação e configurações finalizadas"

# Verifica se já foi executado antes
STATE_FILE="$DIR_PATH/.installed"

if [[ ! -f $STATE_FILE ]]; then
    # Exibe o menu de ajuda na primeira execução
    help_menu
    touch "$STATE_FILE"
else
    echo "Configuração já realizada. Para ajuda, execute com --help."
fi