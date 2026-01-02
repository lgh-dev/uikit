#!/usr/bin/env bash
# init.sh - 初始化命令

set -e
set -u

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 加载库
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/download.sh"
source "${SCRIPT_DIR}/lib/config.sh"

# 显示 Banner
show_banner() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                               ║${NC}"
    echo -e "${CYAN}║           UISpec CLI v2.0.0                   ║${NC}"
    echo -e "${CYAN}║         UI 规范管理和安装工具                 ║${NC}"
    echo -e "${CYAN}║                                               ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════╝${NC}"
    echo ""
}

# 初始化项目
init_project() {
    local platform="${1:-}"
    local project_dir="$(pwd)"
    local uispec_dir="${project_dir}/.uispec"
    local specs_dir="${uispec_dir}/specs"
    local config_file="${uispec_dir}/current-spec.json"

    # 确定平台名称
    local platform_name=""
    local platform_cmd_dir=""

    case "$platform" in
        claude|claude-code)
            platform_name="Claude Code"
            platform_cmd_dir="${project_dir}/.claude/commands"
            ;;
        qoder)
            platform_name="Qoder"
            platform_cmd_dir="${project_dir}/.qoder/commands"
            ;;
        all)
            # 安装到所有平台
            init_project "claude"
            init_project "qoder"
            return 0
            ;;
        "")
            print_error "请指定平台"
            echo ""
            echo -e "${CYAN}用法:${NC}"
            echo "  uispec init <platform>"
            echo ""
            echo -e "${CYAN}支持的平台:${NC}"
            echo "  claude    Claude Code"
            echo "  qoder     Qoder"
            echo "  all       安装到所有平台"
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

    show_banner

    print_info "正在为 ${platform_name} 初始化项目..."
    echo ""

    # 创建目录结构
    if [ ! -d "$uispec_dir" ]; then
        mkdir -p "$uispec_dir"
        print_success "创建 .uispec 目录"
    else
        print_info ".uispec 目录已存在"
    fi

    mkdir -p "$specs_dir"
    mkdir -p "$platform_cmd_dir"

    # 下载规范文件
    print_info "下载设计规范文件..."
    if download_specs "$specs_dir"; then
        print_success "设计规范文件下载完成"
    else
        print_error "设计规范文件下载失败"
        return 1
    fi
    echo ""

    # 下载命令文件
    print_info "安装命令到 ${platform_name}..."
    if download_commands "$platform_cmd_dir"; then
        print_success "命令安装完成"
    else
        print_error "命令安装失败"
        return 1
    fi
    echo ""

    # 创建配置文件
    write_config "$config_file" "null"
    print_success "创建配置文件"

    # 显示成功信息
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${GREEN}✅ UISpec 已成功初始化到项目!${NC}"
    echo ""
    echo -e "${CYAN}平台:${NC} ${platform_name}"
    echo -e "${CYAN}项目目录:${NC} ${project_dir}"
    echo ""
    echo -e "${CYAN}已创建的文件:${NC}"
    echo "  • .uispec/specs/              - 设计规范文件"
    echo "  • .uispec/current-spec.json   - 当前选中的规范"
    if [ "$platform" = "claude" ] || [ "$platform" = "claude-code" ]; then
        echo "  • .claude/commands/          - Claude Code 命令"
    elif [ "$platform" = "qoder" ]; then
        echo "  • .qoder/commands/           - Qoder 命令"
    fi
    echo ""
    echo -e "${CYAN}可用命令:${NC}"
    echo "  • /uispec-switch - 选择设计规范"
    echo "  • /uispec-do     - 按规范开发功能"
    echo "  • /uispec-check  - 审查功能合规性"
    echo ""
    echo -e "${CYAN}使用步骤:${NC}"
    echo -e "  1. ${YELLOW}重启 ${platform_name}${NC}"
    echo "  2. 输入 / 查看可用命令"
    echo "  3. 使用命令开始开发"
    echo ""
    echo -e "${GRAY}提示: 规范文件在 .uispec/specs/ 目录下，可以自由修改${NC}"
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
    echo ""
}

# 执行初始化
init_project "$@"
