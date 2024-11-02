#!/bin/bash

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

# Menu para selecionar o sistema operacional e versão
echo "Selecione o sistema operacional:"
echo "1) Ubuntu"
echo "2) Debian"
echo "3) Fedora"
echo "4) Pular instalação, já tenho o mega instalado"
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

# Caminho para o arquivo de configuração das pastas e arquivos
CONFIG_FILE="/home/rafa/auto-bkp-mega/mega_items.conf" # Altere conforme seu path!

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

# Verifica se o script foi chamado com a opção -run
if [[ $1 == "-run" ]]; then
    backup_to_mega
    exit 0
fi

# Menu para adicionar, listar itens ou iniciar o backup
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

echo "Usando o backup_script.sh:"
echo "   - Com esse script, você pode adicionar, listar e executar o backup de pastas ou arquivos específicos."
echo "   - Opções:"
echo "       1) Adicionar itens ao backup: escolha essa opção para configurar pastas ou arquivos para backup, que serão salvos no arquivo 'mega_items.conf'."
echo "       2) Listar itens: exibe todas as pastas ou arquivos configurados para backup."
echo "       3) Executar backup: sincroniza imediatamente os itens configurados com a conta MEGA."
echo ""
echo "Automatizando o backup com Crontab:"
echo "   - Para agendar o backup automaticamente, você pode adicionar o 'backup_script.sh' ao crontab:"
echo "   - Execute 'crontab -e' para abrir o editor do crontab."
echo "   - Adicione uma linha no formato desejado. Por exemplo, para rodar o backup diariamente às 2h da manhã:"
echo ""
echo "       0 2 * * * echo "Backup iniciado em: $(date '+\%Y-\%m-\%d \%H:\%M:\%S')" >> /home/rafa/auto-bkp-mega/backup.log && /home/rafa/auto-bkp-mega/backup_script.sh -run >> /home/rafa/auto-bkp-mega/backup.log 2>&1"
echo ""
echo "   - Essa linha agenda o script para rodar automaticamente no horário configurado."


