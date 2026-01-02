#!/usr/bin/env bash
# uninstall.sh - 卸载命令

set -e
set -u

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 加载库
source "${SCRIPT_DIR}/lib/colors.sh"

# 卸载项目中的 UISpec
uninstall_from_project() {
    local platform="${1:-}"
    local project_dir="$(pwd)"
    local uikit_dir="${project_dir}/.uispec"

    local platform_cmd_dir=""
    local platform_name=""

    case "$platform" in
        claude|claude-code)
            platform_cmd_dir="${project_dir}/.claude/commands"
            platform_name="Claude Code"
            ;;
        qoder)
            platform_cmd_dir="${project_dir}/.qoder/commands"
            platform_name="Qoder"
            ;;
        all)
            # 卸载所有
            uninstall_from_project "claude"
            uninstall_from_project "qoder"

            # 删除整个 .uispec 目录
            if [ -d "$uikit_dir" ]; then
                rm -rf "$uikit_dir"
                print_success "删除 .uispec 目录"
            fi
            echo ""
            print_success "UISpec 已从所有平台卸载"
            return 0
            ;;
        "")
            print_error "请指定平台"
            echo ""
            echo -e "${CYAN}用法:${NC}"
            echo "  uispec uninstall <platform>"
            echo ""
            echo -e "${CYAN}支持的平台:${NC}"
            echo "  claude    Claude Code"
            echo "  qoder     Qoder"
            echo "  all       从所有平台卸载"
            echo ""
            return 1
            ;;
        *)
            print_error "不支持的平台: $platform"
            echo ""
            echo -e "${CYAN}支持的平台:${NC} claude, qoder, all"
            return 1
            ;;
    esac

    print_info "正在从 ${platform_name} 卸载 UISpec..."

    # 删除平台命令
    if [ -d "$platform_cmd_dir" ]; then
        local commands=("uispec-switch.md" "uispec-do.md" "uispec-check.md")
        for cmd in "${commands[@]}"; do
            local cmd_path="${platform_cmd_dir}/${cmd}"
            local cmd_name="${cmd%.md}"

            if [ -f "$cmd_path" ]; then
                rm -f "$cmd_path"
                print_success "删除命令: /${cmd_name}"
            fi
        done
    fi

    echo ""
    print_success "UISpec 已从 ${platform_name} 卸载"
}

# 执行卸载
uninstall_from_project "$@"
