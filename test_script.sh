#!/bin/bash

# 测试脚本：用于本地验证Xcode构建和测试
# 确保在推送代码到GitHub之前，所有测试都能正常运行

# 项目路径
PROJECT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/CICD_iOS"

# 输出彩色文本
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# 函数：显示带颜色的消息
print_message() {
    echo -e "${GREEN}=== $1 ===${NC}"
}

print_error() {
    echo -e "${RED}=== $1 ===${NC}"
}

# 切换到项目目录
cd "$PROJECT_PATH" || exit 1

print_message "开始本地测试"

# 检查Xcode版本
print_message "检查Xcode版本"
xcodebuild -version

# 安装CocoaPods依赖（如果需要）
if [ -f "Podfile.lock" ]; then
    print_message "更新CocoaPods依赖"
    pod install
else
    print_message "未找到Podfile.lock，跳过依赖安装"
fi

# 运行单元测试
print_message "运行单元测试"
xcodebuild test \
    -workspace CICD_iOS.xcworkspace \
    -scheme CICD_iOSTests \
    -destination 'platform=iOS Simulator,name=iPhone 13,OS=18.2' \
    -configuration Debug

if [ $? -ne 0 ]; then
    print_error "单元测试失败！"
    exit 1
fi

# 运行UI测试
print_message "运行UI测试"
xcodebuild test \
    -workspace CICD_iOS.xcworkspace \
    -scheme CICD_iOSUITests \
    -destination 'platform=iOS Simulator,name=iPhone 13,OS=18.2' \
    -configuration Debug

if [ $? -ne 0 ]; then
    print_error "UI测试失败！"
    exit 1
fi

print_message "所有测试通过！"
print_message "本地测试完成。您现在可以推送代码到GitHub，GitHub Actions将自动运行相同的测试流程。"