#!/bin/bash
# UISpec CLI Shell 版本安装脚本
# 自动从 GitHub 下载并安装 Shell 脚本

set -e

# 配置
INSTALL_BIN="/usr/local/bin"
INSTALL_SHARE="/usr/local/share/uispec"
GITHUB_REPO="lgh-dev/uispec"
GITHUB_BRANCH="main"

# 颜色
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# 下载文件
download_file() {
    local url="$1"
    local output="$2"

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$output"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$output" "$url"
    else
        print_error "需要 curl 或 wget"
        exit 1
    fi
}

# 主安装流程
main() {
    echo ""
    echo "========================================="
    echo "  UISpec CLI 安装程序 (Shell 版本)"
    echo "========================================="
    echo ""

    print_info "开始安装 UISpec CLI v2.0.0..."
    echo ""

    # 创建目录
    print_info "创建安装目录..."
    if [ -w "$INSTALL_BIN" ] && [ -w "$(dirname "$INSTALL_SHARE")" ]; then
        mkdir -p "${INSTALL_SHARE}"/{commands,lib}
    else
        sudo mkdir -p "${INSTALL_SHARE}"/{commands,lib}
    fi
    print_success "目录创建完成"

    # 下载主脚本
    print_info "下载主脚本..."
    local temp_main="/tmp/uispec-main.sh"
    download_file "https://raw.githubusercontent.com/${GITHUB_REPO}/${GITHUB_BRANCH}/shell/uispec.sh" "$temp_main"

    if [ -w "$INSTALL_BIN" ]; then
        cp "$temp_main" "${INSTALL_BIN}/uispec"
        chmod +x "${INSTALL_BIN}/uispec"
    else
        sudo cp "$temp_main" "${INSTALL_BIN}/uispec"
        sudo chmod +x "${INSTALL_BIN}/uispec"
    fi
    rm -f "$temp_main"
    print_success "主脚本安装完成 (2 KB)"

    # 下载命令脚本
    print_info "下载命令脚本..."
    local commands=("init" "status" "uninstall")
    for cmd in "${commands[@]}"; do
        local temp_cmd="/tmp/uispec-${cmd}.sh"
        download_file "https://raw.githubusercontent.com/${GITHUB_REPO}/${GITHUB_BRANCH}/shell/commands/${cmd}.sh" "$temp_cmd"

        if [ -w "$INSTALL_SHARE" ]; then
            cp "$temp_cmd" "${INSTALL_SHARE}/commands/${cmd}.sh"
            chmod +x "${INSTALL_SHARE}/commands/${cmd}.sh"
        else
            sudo cp "$temp_cmd" "${INSTALL_SHARE}/commands/${cmd}.sh"
            sudo chmod +x "${INSTALL_SHARE}/commands/${cmd}.sh"
        fi
        rm -f "$temp_cmd"
    done
    print_success "命令脚本安装完成 (10 KB)"

    # 下载库文件
    print_info "下载库文件..."
    local libs=("colors" "download" "config")
    for lib in "${libs[@]}"; do
        local temp_lib="/tmp/uispec-${lib}.sh"
        download_file "https://raw.githubusercontent.com/${GITHUB_REPO}/${GITHUB_BRANCH}/shell/lib/${lib}.sh" "$temp_lib"

        if [ -w "$INSTALL_SHARE" ]; then
            cp "$temp_lib" "${INSTALL_SHARE}/lib/${lib}.sh"
        else
            sudo cp "$temp_lib" "${INSTALL_SHARE}/lib/${lib}.sh"
        fi
        rm -f "$temp_lib"
    done
    print_success "库文件安装完成 (3 KB)"

    echo ""
    print_success "UISpec CLI v2.0.0 安装成功！"
    echo ""
    echo "========================================="
    echo "  下一步操作"
    echo "========================================="
    echo ""
    echo "1. 进入你的项目目录"
    echo "   cd /path/to/your/project"
    echo ""
    echo "2. 初始化 UISpec 到 AI 工具"
    echo "   uispec init claude    # Claude Code"
    echo "   uispec init qoder     # Qoder"
    echo ""
    echo "3. 重启 AI 工具"
    echo ""
    echo "4. 开始使用"
    echo "   /uispec-switch dark-elegant"
    echo "   /uispec-do 创建登录页面"
    echo "   /uispec-check"
    echo ""
    echo "========================================="
    echo ""
    echo "查看帮助: uikit -h"
    echo "查看状态: uispec status"
    echo ""
    echo "卸载命令:"
    echo "  curl -fsSL https://raw.githubusercontent.com/lgh-dev/uispec/main/uninstall.sh -o /tmp/uninstall.sh"
    echo "  chmod +x /tmp/uninstall.sh && sudo /tmp/uninstall.sh"
    echo ""
    echo "总大小: ~15 KB (vs 旧版本 57 MB)"
    echo ""
}

main
