#!/bin/bash
# UISpec CLI 卸载脚本
# 从系统中完全删除 UISpec CLI 工具

# 配置
INSTALL_BIN="/usr/local/bin"
INSTALL_SHARE="/usr/local/share/uispec"

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
    [ -f "${INSTALL_BIN}/uispec" ] || [ -d "${INSTALL_SHARE}" ]
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
                echo "  ./uninstall.sh              # 交互式卸载"
                echo "  ./uninstall.sh -y           # 自动确认卸载"
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
    echo "  UISpec CLI 卸载程序"
    echo "========================================="
    echo ""

    # 检查是否已安装
    if ! is_installed; then
        print_warning "UISpec 未安装，无需卸载"
        exit 0
    fi

    print_warning "此操作将从系统中完全删除 UISpec CLI"
    echo ""
    echo "将删除以下内容："
    echo "  - ${INSTALL_BIN}/uispec"
    echo "  - ${INSTALL_SHARE}/"
    echo ""
    echo -e "${YELLOW}注意：此操作不可逆！${NC}"
    echo ""

    # 确认卸载
    local confirmed=false
    local reply=""

    # 检查是否为自动确认模式
    if [ "$auto_yes" = true ]; then
        print_info "使用自动确认模式"
        confirmed=true
    else
        # 尝试从 /dev/tty 读取用户输入（适用于管道执行）
        if [ -e /dev/tty ]; then
            read -p "确定要继续吗？(y/N): " -n 1 -r reply < /dev/tty
            echo ""
            if [[ $reply =~ ^[Yy]$ ]]; then
                confirmed=true
            fi
        else
            # 如果 /dev/tty 不可用，则拒绝执行
            print_error "无法获取用户输入"
            echo ""
            echo "请使用 -y 参数跳过确认："
            echo "  curl -fsSL https://raw.githubusercontent.com/lgh-dev/uispec/main/uninstall.sh | bash -s -- -y"
            echo ""
            exit 1
        fi
    fi

    if [ "$confirmed" = false ]; then
        print_info "已取消卸载"
        exit 0
    fi

    # 先获取 sudo 权限（让用户输入密码）
    print_info "正在获取权限..."
    if ! sudo -v 2>/dev/null; then
        print_error "获取 sudo 权限失败"
        exit 1
    fi

    local failed=0

    # 删除主脚本
    print_info "删除主脚本..."
    if [ -f "${INSTALL_BIN}/uispec" ]; then
        sudo rm -f "${INSTALL_BIN}/uispec" && print_success "删除 ${INSTALL_BIN}/uispec" || { print_error "删除失败"; failed=1; }
    else
        print_info "${INSTALL_BIN}/uispec（不存在）"
    fi

    # 删除安装目录
    print_info "删除安装目录..."
    if [ -d "${INSTALL_SHARE}" ]; then
        sudo rm -rf "${INSTALL_SHARE}" && print_success "删除 ${INSTALL_SHARE}/" || { print_error "删除失败"; failed=1; }
    else
        print_info "${INSTALL_SHARE}/（不存在）"
    fi

    echo ""
    if [ $failed -eq 0 ]; then
        print_success "UISpec CLI 卸载完成！"
    else
        print_warning "部分操作失败，请检查上面的错误信息"
    fi

    echo ""
    echo "========================================="
    echo "  已删除的内容"
    echo "========================================="
    echo ""
    echo "  • ${INSTALL_BIN}/uispec"
    echo "  • ${INSTALL_SHARE}/"
    echo ""
    echo "如需重新安装，请运行："
    echo "  curl -fsSL https://raw.githubusercontent.com/lgh-dev/uispec/main/install.sh | bash"
    echo ""
    echo "========================================="
    echo ""
}

main "$@"
