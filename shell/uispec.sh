#!/usr/bin/env bash
# UISpec CLI - Shell Script Version
# Version: 2.0.0

set -e
set -u

# 版本号
readonly VERSION="2.0.0"

# 确定脚本目录
# 如果从 /usr/local/bin/uispec 调用，库文件在 /usr/local/share/uispec
# 如果从开发目录调用，库文件在同级 shell 目录
if [ -d "/usr/local/share/uispec" ]; then
    readonly SCRIPT_DIR="/usr/local/share/uispec"
elif [ -d "$(dirname "$0")/../shell" ]; then
    readonly SCRIPT_DIR="$(cd "$(dirname "$0")/../shell" && pwd)"
else
    readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi

# 加载库
source "${SCRIPT_DIR}/lib/colors.sh"

# 显示帮助
show_help() {
    echo -e "${CYAN}UISpec CLI v${VERSION}${NC}"
    echo "AI 时代的 UI 规范管理系统"
    echo ""
    echo -e "${CYAN}用法:${NC}"
    echo "  uispec <command> [options]"
    echo ""
    echo -e "${CYAN}命令:${NC}"
    echo "  init <platform>   初始化 UISpec 到指定平台"
    echo "  status            查看安装状态"
    echo "  uninstall         卸载命令"
    echo "  help, -h          显示帮助"
    echo "  -v, --version     显示版本号"
    echo ""
    echo -e "${CYAN}初始化示例:${NC}"
    echo "  uispec init claude     # 初始化到 Claude Code"
    echo "  uispec init qoder      # 初始化到 Qoder"
    echo "  uispec init all        # 初始化到所有平台"
    echo ""
    echo -e "${CYAN}支持的平台:${NC}"
    echo "  claude    Claude Code (当前支持)"
    echo "  qoder     Qoder (当前支持)"
    echo "  cursor    Cursor (计划支持)"
    echo "  windsurf  Windsurf (计划支持)"
    echo ""
    echo -e "${CYAN}示例:${NC}"
    echo -e "  ${GRAY}# 查看当前状态${NC}"
    echo "  uispec status"
    echo ""
    echo -e "  ${GRAY}# 初始化到 Claude Code${NC}"
    echo "  uispec init claude"
    echo ""
    echo -e "  ${GRAY}# 初始化到 Qoder${NC}"
    echo "  uispec init qoder"
    echo ""
    echo -e "  ${GRAY}# 查看版本${NC}"
    echo "  uispec -v"
    echo ""
    echo -e "${CYAN}版本:${NC} ${VERSION}"
    echo ""
}

# 主函数
main() {
    local command="${1:-}"

    case "$command" in
        init)
            shift
            bash "${SCRIPT_DIR}/commands/init.sh" "$@"
            ;;
        status)
            bash "${SCRIPT_DIR}/commands/status.sh"
            ;;
        uninstall)
            shift
            bash "${SCRIPT_DIR}/commands/uninstall.sh" "$@"
            ;;
        -v|--version|version)
            echo "UISpec CLI v${VERSION}"
            ;;
        -h|--help|help|"")
            show_help
            ;;
        *)
            print_error "未知命令: $command"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

main "$@"
