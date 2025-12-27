#!/bin/bash
# UIKit CLI 卸载脚本
# 从系统中完全删除 UIKit CLI 工具

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

# 检查是否需要 sudo
need_sudo() {
    if [ -f "${INSTALL_BIN}/uikit" ]; then
        local owner=$(stat -f "%Su" "${INSTALL_BIN}/uikit" 2>/dev/null)
        if [ "$owner" != "$(whoami)" ]; then
            return 0
        fi
    fi
    if [ -d "${INSTALL_SHARE}" ]; then
        local owner=$(stat -f "%Su" "${INSTALL_SHARE}" 2>/dev/null)
        if [ "$owner" != "$(whoami)" ]; then
            return 0
        fi
    fi
    if [ ! -w "$INSTALL_BIN" ] || [ ! -w "$(dirname "$INSTALL_SHARE")" ]; then
        return 0
    fi
    return 1
}

# 主卸载流程
main() {
    local auto_yes=false

    # 解析参数
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -y|--yes)
                auto_yes=true
                shift
                ;;
            -h|--help)
                echo "用法: uninstall.sh [选项]"
                echo ""
                echo "选项:"
                echo "  -y, --yes   自动确认卸载"
                echo "  -h, --help  显示帮助信息"
                echo ""
                echo "示例:"
                echo "  curl ... | sudo bash        # 一键卸载（需要 sudo 密码）"
                exit 0
                ;;
            *)
                echo "未知参数: $1"
                echo "使用 -h 查看帮助"
                exit 1
                ;;
        esac
    done

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

    # 确认卸载
    local confirmed=false

    # 如果在交互式终端中，需要用户确认
    if [ -t 0 ]; then
        read -p "确定要继续吗？(y/N): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            confirmed=true
        fi
    elif [ "$auto_yes" = true ]; then
        print_info "自动确认模式"
        confirmed=true
    else
        # 非交互式终端，直接继续，让 sudo 提示密码
        confirmed=true
        echo -e "${YELLOW}继续执行卸载...（sudo 将提示输入密码）${NC}"
        echo ""
    fi

    if [ "$confirmed" = false ]; then
        print_info "已取消卸载"
        exit 0
    fi

    local failed=0

    # 删除主脚本
    print_info "删除主脚本..."
    if [ -f "${INSTALL_BIN}/uikit" ]; then
        if need_sudo; then
            sudo rm -f "${INSTALL_BIN}/uikit" && print_success "删除 ${INSTALL_BIN}/uikit" || { print_error "删除失败"; failed=1; }
        else
            rm -f "${INSTALL_BIN}/uikit" && print_success "删除 ${INSTALL_BIN}/uikit" || { print_error "删除失败"; failed=1; }
        fi
    else
        print_info "${INSTALL_BIN}/uikit（不存在）"
    fi

    # 删除安装目录
    print_info "删除安装目录..."
    if [ -d "${INSTALL_SHARE}" ]; then
        if need_sudo; then
            sudo rm -rf "${INSTALL_SHARE}" && print_success "删除 ${INSTALL_SHARE}/" || { print_error "删除失败"; failed=1; }
        else
            rm -rf "${INSTALL_SHARE}" && print_success "删除 ${INSTALL_SHARE}/" || { print_error "删除失败"; failed=1; }
        fi
    else
        print_info "${INSTALL_SHARE}/（不存在）"
    fi

    echo ""
    if [ $failed -eq 0 ]; then
        print_success "UIKit CLI 卸载完成！"
    else
        print_warning "部分操作失败，请检查上面的错误信息"
    fi

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

main "$@"
