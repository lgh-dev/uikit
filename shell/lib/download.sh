#!/usr/bin/env bash
# download.sh - 下载功能库

# GitHub 配置
readonly GITHUB_REPO="lgh-dev/uispec"
readonly GITHUB_BRANCH="main"

# 下载单个文件
download_file() {
    local url="$1"
    local output="$2"

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$output"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$output" "$url"
    else
        print_error "需要 curl 或 wget 来下载文件"
        return 1
    fi
}

# 下载规范文件
download_specs() {
    local target_dir="$1"
    local base_url="https://raw.githubusercontent.com/${GITHUB_REPO}/${GITHUB_BRANCH}/specs"

    local specs=(
        "modern-minimal.md"
        "dark-elegant.md"
        "creative-playful.md"
        "professional-business.md"
        "vibrant-tech.md"
    )

    for spec in "${specs[@]}"; do
        print_info "下载规范: $spec"
        if download_file "${base_url}/${spec}" "${target_dir}/${spec}"; then
            print_success "✓ ${spec}"
        else
            print_error "下载失败: ${spec}"
            return 1
        fi
    done

    print_success "下载了 ${#specs[@]} 个规范文件"
}

# 下载命令文件
download_commands() {
    local target_dir="$1"
    local base_url="https://raw.githubusercontent.com/${GITHUB_REPO}/${GITHUB_BRANCH}/commands"

    local commands=(
        "uispec-switch.md"
        "uispec-do.md"
        "uispec-check.md"
    )

    for cmd in "${commands[@]}"; do
        local cmd_name="${cmd%.md}"
        print_info "安装命令: /${cmd_name}"
        if download_file "${base_url}/${cmd}" "${target_dir}/${cmd}"; then
            print_success "✓ /${cmd_name}"
        else
            print_error "下载失败: ${cmd}"
            return 1
        fi
    done

    print_success "安装了 ${#commands[@]} 个命令"
}
