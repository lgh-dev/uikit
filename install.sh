#!/bin/bash
# UIKit CLI 智能安装脚本
# 自动检测操作系统，下载对应的预编译二进制文件

set -e

# 配置
REPO="lgh-dev/uikit"
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="uikit"
VERSION_FILE="$HOME/.uikit-version"

# 颜色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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

# 检测操作系统和架构
detect_platform() {
    local os=""
    local arch=""

    # 检测操作系统
    case "$(uname -s)" in
        Darwin*)
            os="macos"
            ;;
        Linux*)
            os="linux"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            os="windows"
            ;;
        *)
            print_error "不支持的操作系统: $(uname -s)"
            exit 1
            ;;
    esac

    # 检测架构
    case "$(uname -m)" in
        x86_64|amd64)
            arch="x64"
            ;;
        arm64|aarch64)
            arch="arm64"
            ;;
        *)
            print_error "不支持的架构: $(uname -m)"
            exit 1
            ;;
    esac

    echo "${os}-${arch}"
}

# 获取最新版本号
get_latest_version() {
    # 从 GitHub API 获取最新 release 版本
    # 如果 API 调用失败，使用 package.json 中的版本
    local version=$(curl -s "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

    if [ -z "$version" ]; then
        # 尝试读取本地 package.json
        if [ -f "package.json" ]; then
            version=$(grep '"version"' package.json | sed -E 's/.*"([^"]+)".*/\1/')
            version="v${version}"
        else
            version="latest"
        fi
    fi

    echo "$version"
}

# 获取本地已安装版本
get_installed_version() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE"
    else
        echo "none"
    fi
}

# 下载二进制文件
download_binary() {
    local platform=$1
    local version=$2
    local binary_name="uikit-${platform}"

    if [ "$platform" = "windows-x64" ]; then
        binary_name="${binary_name}.exe"
    fi

    local download_url="https://github.com/${REPO}/releases/download/${version}/${binary_name}"
    local temp_file="/tmp/${binary_name}"

    print_info "下载 UIKit CLI ${version} (${platform})..."
    echo -e "${BLUE}URL:${NC} $download_url"

    # 使用 wget 显示进度（如果可用），否则用 curl
    if command -v wget >/dev/null 2>&1; then
        echo -e "${BLUE}使用 wget 下载（显示进度）${NC}"
        if ! wget --progress=bar:force --show-progress -O "$temp_file" "$download_url" 2>&1; then
            print_error "下载失败: $download_url"
            rm -f "$temp_file"
            return 1
        fi
    else
        echo -e "${BLUE}使用 curl 下载...${NC}"
        # curl 在管道模式下不显示进度，使用 -w 显示基本信息
        if ! curl -fL --progress-bar "$download_url" -o "$temp_file"; then
            print_error "下载失败: $download_url"
            rm -f "$temp_file"
            return 1
        fi
        print_success "下载完成"
    fi

    echo "$temp_file"
}

# 安装二进制文件
install_binary() {
    local temp_file=$1
    local install_path="${INSTALL_DIR}/${BINARY_NAME}"

    print_info "安装到 ${install_path}..."

    # 检查是否需要 sudo
    if [ -w "$INSTALL_DIR" ]; then
        cp "$temp_file" "$install_path"
        chmod +x "$install_path"
    else
        sudo cp "$temp_file" "$install_path"
        sudo chmod +x "$install_path"
    fi

    # 清理临时文件
    rm -f "$temp_file"
}

# 保存版本信息
save_version() {
    local version=$1
    echo "$version" > "$VERSION_FILE"
}

# 主安装流程
main() {
    echo ""
    echo "========================================="
    echo "  UIKit CLI 安装程序"
    echo "========================================="
    echo ""

    # 检测平台
    platform=$(detect_platform)
    print_success "检测到平台: ${platform}"

    # 获取版本信息
    latest_version=$(get_latest_version)
    installed_version=$(get_installed_version)

    print_info "最新版本: ${latest_version}"
    print_info "已安装版本: ${installed_version}"

    # 检查是否需要更新
    if [ "$installed_version" = "$latest_version" ]; then
        print_success "已是最新版本，无需更新"

        # 询问是否重新安装
        read -p "是否重新安装？(y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo ""
            print_info "安装已取消"
            exit 0
        fi
    elif [ "$installed_version" != "none" ]; then
        print_warning "发现新版本，将进行更新"
    fi

    # 下载并安装
    temp_file=$(download_binary "$platform" "$latest_version")
    download_status=$?

    # 检查下载是否成功
    if [ $download_status -ne 0 ] || [ -z "$temp_file" ] || [ ! -f "$temp_file" ]; then
        print_error "下载失败，安装中止"
        exit 1
    fi

    install_binary "$temp_file"
    save_version "$latest_version"

    echo ""
    print_success "UIKit CLI ${latest_version} 安装成功！"
    echo ""
    echo "========================================="
    echo "  下一步操作"
    echo "========================================="
    echo ""
    echo "1. 进入你的项目目录"
    echo "   cd /path/to/your/project"
    echo ""
    echo "2. 初始化 UIKit 到 AI 工具"
    echo "   uikit init claude    # Claude Code"
    echo "   uikit init qoder     # Qoder"
    echo ""
    echo "3. 重启 AI 工具"
    echo ""
    echo "4. 开始使用"
    echo "   /uikit-switch dark-elegant"
    echo "   /uikit-do 创建登录页面"
    echo "   /uikit-check"
    echo ""
    echo "========================================="
    echo ""
    echo "查看帮助: uikit -h"
    echo "查看状态: uikit status"
    echo ""
}

main
