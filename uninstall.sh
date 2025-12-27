#!/bin/bash
# UIKit CLI 卸载脚本
# 从系统中完全删除 UIKit CLI 工具

set -e

# 配置
INSTALL_BIN="/usr/local/bin"
INSTALL_SHARE="/usr/local/share/uikit"

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

# 检查是否已安装
is_installed() {
    [ -f "${INSTALL_BIN}/uikit" ] || [ -d "${INSTALL_SHARE}" ]
}

# 主卸载流程
main() {
    echo ""
    echo "========================================="
    echo "  UIKit CLI 卸载程序"
    echo "========================================="
    echo ""

    # 检查是否已安装
    if ! is_installed; then
        print_warning "UIKit 未安装，无需卸载"
        exit 0
    fi

    print_warning "此操作将从系统中完全删除 UIKit CLI"
    echo ""
    echo "将删除以下内容："
    echo "  - ${INSTALL_BIN}/uikit"
    echo "  - ${INSTALL_SHARE}/"
    echo ""
    echo -e "${YELLOW}注意：此操作不可逆！${NC}"
    echo ""

    read -p "确定要继续吗？(y/N): " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "已取消卸载"
        exit 0
    fi

    # 检查权限
    local need_sudo=false
    if [ ! -w "$INSTALL_BIN" ] || [ ! -w "$(dirname "$INSTALL_SHARE")" ]; then
        need_sudo=true
    fi

    # 删除主脚本
    print_info "删除主脚本..."
    if [ -f "${INSTALL_BIN}/uikit" ]; then
        if $need_sudo; then
            sudo rm -f "${INSTALL_BIN}/uikit"
        else
            rm -f "${INSTALL_BIN}/uikit"
        fi
        print_success "删除 uikit 主脚本"
    fi

    # 删除安装目录
    print_info "删除安装目录..."
    if [ -d "${INSTALL_SHARE}" ]; then
        if $need_sudo; then
            sudo rm -rf "${INSTALL_SHARE}"
        else
            rm -rf "${INSTALL_SHARE}"
        fi
        print_success "删除 ${INSTALL_SHARE}/"
    fi

    # 清理空目录
    if [ -d "/usr/local/share" ] && [ -z "$(ls -A /usr/local/share 2>/dev/null)" ]; then
        if $need_sudo; then
            sudo rmdir /usr/local/share 2>/dev/null || true
        else
            rmdir /usr/local/share 2>/dev/null || true
        fi
    fi

    echo ""
    print_success "UIKit CLI 卸载完成！"
    echo ""
    echo "========================================="
    echo "  已删除的内容"
    echo "========================================="
    echo ""
    echo "  • ${INSTALL_BIN}/uikit"
    echo "  • ${INSTALL_SHARE}/"
    echo ""
    echo "如需重新安装，请运行："
    echo "  curl -fsSL https://raw.githubusercontent.com/lgh-dev/uikit/main/install.sh | bash"
    echo ""
    echo "========================================="
    echo ""
}

main
