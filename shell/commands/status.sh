#!/usr/bin/env bash
# status.sh - 查看状态命令

set -e
set -u

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 加载库
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/config.sh"

# 显示状态
show_status() {
    local project_dir="$(pwd)"
    local uispec_dir="${project_dir}/.uispec"
    local config_file="${uispec_dir}/current-spec.json"
    local specs_dir="${uispec_dir}/specs"
    local claude_cmd_dir="${project_dir}/.claude/commands"
    local qoder_cmd_dir="${project_dir}/.qoder/commands"

    local commands=("uispec-switch.md" "uispec-do.md" "uispec-check.md")

    echo ""
    echo -e "${CYAN}📊 UISpec 项目状态${NC}"
    echo "──────────────────────────────────────────────────"
    echo ""

    echo -e "${CYAN}项目目录:${NC} ${project_dir}"

    # 检查是否初始化
    if [ ! -d "$uispec_dir" ]; then
        echo ""
        echo -e "${GRAY}项目尚未初始化${NC}"
        echo -e "运行 ${CYAN}uispec init claude${NC} 或 ${CYAN}uispec init qoder${NC} 开始初始化"
        echo ""
        return 0
    fi

    # 读取配置
    if [ -f "$config_file" ]; then
        local current_spec=$(read_config "$config_file" "spec")
        local installed_at=$(read_config "$config_file" "installedAt")

        if [ -n "$current_spec" ] && [ "$current_spec" != "null" ]; then
            echo -e "${CYAN}当前规范:${NC} ${current_spec}"
        else
            echo -e "${GRAY}尚未选择规范${NC}"
        fi

        if [ -n "$installed_at" ]; then
            local date_str=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$installed_at" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "$installed_at")
            echo -e "${CYAN}初始化时间:${NC} ${date_str}"
        fi
    fi

    # Claude Code 状态
    echo ""
    echo -e "${CYAN}Claude Code:${NC}"
    local claude_count=0
    for cmd in "${commands[@]}"; do
        local cmd_path="${claude_cmd_dir}/${cmd}"
        local cmd_name="${cmd%.md}"

        if [ -f "$cmd_path" ]; then
            echo -e "  ${GREEN}✓${NC} /${cmd_name} ${GRAY}(已安装)${NC}"
            ((claude_count++))
        else
            echo -e "  ${GRAY}○${NC} /${cmd_name} ${GRAY}(未安装)${NC}"
        fi
    done

    # Qoder 状态
    echo ""
    echo -e "${CYAN}Qoder:${NC}"
    local qoder_count=0
    for cmd in "${commands[@]}"; do
        local cmd_path="${qoder_cmd_dir}/${cmd}"
        local cmd_name="${cmd%.md}"

        if [ -f "$cmd_path" ]; then
            echo -e "  ${GREEN}✓${NC} /${cmd_name} ${GRAY}(已安装)${NC}"
            ((qoder_count++))
        else
            echo -e "  ${GRAY}○${NC} /${cmd_name} ${GRAY}(未安装)${NC}"
        fi
    done

    # 规范文件状态
    echo ""
    echo -e "${CYAN}设计规范:${NC}"
    if [ -d "$specs_dir" ]; then
        local spec_count=$(find "$specs_dir" -name "*.md" -type f | wc -l | tr -d ' ')
        if [ "$spec_count" -gt 0 ]; then
            echo -e "  ${GREEN}✓${NC} ${spec_count} 个规范文件"
            find "$specs_dir" -name "*.md" -type f | while read -r spec_file; do
                local spec_name=$(basename "$spec_file" .md)
                echo -e "    ${GRAY}• ${spec_name}${NC}"
            done
        else
            echo -e "  ${GRAY}○${NC} 无规范文件"
        fi
    else
        echo -e "  ${GRAY}○${NC} 无规范文件"
    fi

    echo ""
    echo "──────────────────────────────────────────────────"

    # 总结
    local total_installed=$((claude_count + qoder_count))
    if [ $total_installed -gt 0 ]; then
        echo -e "${GREEN}✅ 项目已初始化${NC}"
    else
        echo -e "${YELLOW}⚠️  命令尚未安装到任何平台${NC}"
        echo -e "运行 ${CYAN}uispec init claude${NC} 或 ${CYAN}uispec init qoder${NC} 安装命令"
    fi

    echo ""
}

# 执行状态显示
show_status "$@"
