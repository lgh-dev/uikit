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

# 检查是否需要 sudo
need_sudo() {
    # 检查文件所有者是否为当前用户
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
    # 检查目录是否可写
    if [ ! -w "$INSTALL_BIN" ] || [ ! -w "$(dirname "$INSTALL_SHARE")" ]; then
        return 0
    fi
    return 1
}

# 执行删除操作（支持 sudo）
delete_file_or_dir() {
    local path="$1"
    local description="$2"

    if [ -e "$path" ]; then
        if need_sudo; then
            if sudo rm -rf "$path" 2>/dev/null; then
                print_success "${description}"
                return 0
            else
                print_error "${description} 失败"
                return 1
            fi
        else
            if rm -rf "$path" 2>/dev/null; then
                print_success "${description}"
                return 0
            else
                print_error "${description} 失败"
                return 1
            fi
        fi
    else
        print_info "${description}（不存在，跳过）"
    fi
}

# 主卸载流程
main() {
    local auto_yes=false
    local force_sudo=false

    # 解析参数
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -y|--yes)
                auto_yes=true
                shift
                ;;
            --sudo)
                force_sudo=true
                shift
                ;;
            -h|--help)
                echo "用法: uninstall.sh [选项]"
                echo ""
                echo "选项:"
                echo "  -y, --yes   自动确认卸载（用于脚本调用）"
                echo "  --sudo      强制使用 sudo 执行"
                echo "  -h, --help  显示帮助信息"
                echo ""
                echo "示例:"
                echo "  ./uninstall.sh              # 交互式卸载"
                echo "  ./uninstall.sh -y           # 自动确认卸载"
                echo "  curl ... | bash             # 管道方式（需要 sudo）"
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
    if [ "$auto_yes" = false ]; then
        # 检查是否在交互式终端中
        if [ -t 0 ]; then
            read -p "确定要继续吗？(y/N): " -n 1 -r
            echo ""
        else
            # 非交互式终端，提示用户使用 -y 参数
            print_info "检测到非交互式终端，请使用 -y 参数自动确认"
            echo ""
            REPLY=""
        fi
    else
        print_info "自动确认模式"
        REPLY="y"
    fi

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "已取消卸载"
        exit 0
    fi

    # 检查是否需要 sudo
    if need_sudo || [ "$force_sudo" = true ]; then
        print_warning "需要管理员权限进行卸载"
        echo ""
        echo "如果使用管道方式安装，可能需要先获取 sudo 权限："
        echo ""
        echo "方案1：手动执行以下命令（推荐）："
        echo "  curl -fsSL https://raw.githubusercontent.com/lgh-dev/uikit/main/uninstall.sh -o /tmp/uninstall.sh"
        echo "  chmod +x /tmp/uninstall.sh"
        echo "  sudo /tmp/uninstall.sh"
        echo ""
        echo "方案2：如果已配置无密码 sudo，可以直接运行："
        echo "  curl -fsSL https://raw.githubusercontent.com/lgh-dev/uikit/main/uninstall.sh | sudo bash"
        echo ""
        echo "方案3：克隆仓库后本地运行："
        echo "  git clone https://github.com/lgh-dev/uikit.git"
        echo "  cd uikit && sudo ./uninstall.sh"
        echo ""

        # 检查是否可以获取 sudo 权限
        if sudo -n true 2>/dev/null; then
            print_info "检测到无密码 sudo，将自动执行..."
        else
            print_info "请手动执行上述命令之一"
            exit 1
        fi
    fi

    local failed=0

    # 删除主脚本
    print_info "删除主脚本..."
    delete_file_or_dir "${INSTALL_BIN}/uikit" "删除 ${INSTALL_BIN}/uikit" || failed=1

    # 删除安装目录
    print_info "删除安装目录..."
    delete_file_or_dir "${INSTALL_SHARE}" "删除 ${INSTALL_SHARE}/" || failed=1

    # 清理空目录
    if [ -d "/usr/local/share" ] && [ -z "$(ls -A /usr/local/share 2>/dev/null)" ]; then
        if need_sudo || [ "$force_sudo" = true ]; then
            sudo rmdir /usr/local/share 2>/dev/null || true
        else
            rmdir /usr/local/share 2>/dev/null || true
        fi
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
