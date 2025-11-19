# iOS项目CI/CD配置指南

本文档提供了在本地Jenkins上为AWS CodeCommit托管的iOS项目配置CI/CD流程的步骤说明。

## 1. Jenkins配置

### 1.1 安装必要插件

1. 登录Jenkins管理界面
2. 进入 `管理Jenkins` > `插件管理` > `可用插件`
3. 安装以下插件：
   - AWS CodeCommit Trigger
   - Pipeline
   - XCode Integration
   - Git

### 1.2 配置AWS凭证

#### 使用SSH连接方式

如果您通过SSH连接AWS CodeCommit，请按照以下步骤配置：

1. **确保Jenkins服务器上已配置SSH密钥**：
   - 在Jenkins服务器上生成SSH密钥对（如果尚未生成）
   - 将公钥上传到AWS IAM用户的安全凭证中
   - 在AWS IAM中，将CodeCommit相关权限附加到该用户

2. **在Jenkins中配置SSH凭证**：
   - 进入 `管理Jenkins` > `管理凭证`
   - 点击 `全局凭证` > `添加凭证`
   - 选择 `SSH Username with private key` 类型
   - Username字段填写 `git-codecommit`（或任何您喜欢的标识）
   - 选择 `From the Jenkins master ~/.ssh` 或直接粘贴私钥内容
   - 设置ID为 `aws-codecommit-ssh`（或其他您喜欢的ID）

3. **配置SSH配置文件**（在Jenkins服务器上）：
   - 编辑或创建 `~/.ssh/config` 文件
   - 添加以下内容：
   ```
   Host git-codecommit.*.amazonaws.com
       User SSH-密钥-ID（在AWS IAM中配置的SSH密钥ID）
       IdentityFile ~/.ssh/id_rsa（您的私钥文件路径）
   ```

#### 使用AWS凭证方式（可选）

如果您仍想使用AWS访问密钥方式，请按照以下步骤：

1. 进入 `管理Jenkins` > `管理凭证`
2. 点击 `全局凭证` > `添加凭证`
3. 选择 `AWS Credentials` 类型
4. 输入您的AWS访问密钥ID和密钥
5. 设置ID为 `aws-codecommit-credentials`（或其他您喜欢的ID）

### 1.3 创建Jenkins项目

#### 1.3.1 任务类型选择

在新建任务页面，请根据您的需求选择以下两种类型之一：

**选项A：流水线（推荐初学者使用）**
- 这是标准的Pipeline项目类型
- 适用于单分支管理或简单CI/CD流程
- 可以明确指定要构建的分支

**选项B：多分支流水线（推荐高级使用）**
- 会自动检测仓库中的所有分支
- 为每个包含Jenkinsfile的分支创建独立的流水线
- 适合多分支开发团队，自动管理各分支构建

#### 1.3.2 配置标准流水线项目

如果选择了**流水线**类型，请按以下步骤配置：

1. 点击 `新建任务`
2. 输入项目名称（如"ios_CICD"）
3. 选择 `流水线` 类型
4. 点击 `确定`
5. 在 `流水线` 部分：
   - 选择 `从SCM获取流水线脚本`
   - SCM选择 `Git`
   - **如果使用SSH连接**：仓库URL输入SSH格式（如 `ssh://git-codecommit.区域.amazonaws.com/v1/repos/仓库名`）
   - **如果使用HTTPS连接**：仓库URL输入HTTPS格式（如 `https://git-codecommit.区域.amazonaws.com/v1/repos/仓库名`）
   - 凭证选择您刚刚配置的凭证（SSH连接选择 `aws-codecommit-ssh`，HTTPS连接选择 `aws-codecommit-credentials`）
   - 分支规格填写 `*/develop`（根据您的实际分支名）
   - 脚本路径保持默认的 `Jenkinsfile`
6. 点击 `保存`

#### 1.3.3 配置多分支流水线项目

如果选择了**多分支流水线**类型，请按以下步骤配置：

1. 点击 `新建任务`
2. 输入项目名称（如"ios_CICD"）
3. 选择 `多分支流水线` 类型
4. 点击 `确定`
5. 在 `分支源` 部分：
   - 点击 `添加分支源` → 选择 `Git`
   - **如果使用SSH连接**：仓库URL输入SSH格式（如 `ssh://git-codecommit.区域.amazonaws.com/v1/repos/仓库名`）
   - **如果使用HTTPS连接**：仓库URL输入HTTPS格式（如 `https://git-codecommit.区域.amazonaws.com/v1/repos/仓库名`）
   - 凭证选择您刚刚配置的凭证（SSH连接选择 `aws-codecommit-ssh`，HTTPS连接选择 `aws-codecommit-credentials`）
6. 在 `构建配置` 部分：
   - 脚本路径保持默认的 `Jenkinsfile`
7. 在 `扫描触发器` 部分：
   - 勾选 `定期扫描SCM`
   - 设置扫描间隔（如H/15 * * * *，表示每15分钟扫描一次）
8. 点击 `保存`
9. 保存后，Jenkins会自动开始首次分支索引，查找包含Jenkinsfile的分支

## 2. 测试Jenkins与CodeCommit连接

在创建项目后，您可以按照以下步骤测试Jenkins是否能与AWS CodeCommit正常连接：

### 2.1 验证凭证连接

1. 进入Jenkins项目配置页面
2. 向下滚动到「流水线」部分
3. 点击「验证」按钮（如果使用流水线项目）
4. 或者在「源代码管理」部分点击「连接测试」按钮（如果使用自由风格项目）
5. 查看是否显示「连接成功」消息

### 2.2 执行测试构建

1. 返回Jenkins项目首页
2. 点击左侧的「立即构建」按钮
3. 观察构建过程：
   - 构建应该能够成功从CodeCommit拉取代码
   - 控制台输出中应该显示Git拉取日志
   - 没有认证错误或连接超时

### 2.3 检查关键日志信息

在构建历史中点击最新构建，然后查看「控制台输出」，检查以下内容：

- 成功克隆仓库的消息
- 拉取代码的时间戳
- 没有以下错误：
  - 认证失败（Authentication failed）
  - 连接超时（Connection timed out）
  - 权限被拒绝（Permission denied）

### 2.4 日志解读：分支索引与实际构建

#### 分支索引日志分析

如果您看到类似以下内容的日志：
```
Starting branch indexing...
> git ls-remote --symref -- ssh://git-codecommit.us-east-1.amazonaws.com/v1/repos/ios_CICD
Checking branches...
  Checking branch develop
      'Jenkinsfile' found
    Met criteria
Finished branch indexing. Indexing took 1 min 10 sec
Finished: NOT_BUILT
```

**这表示**：
- Jenkins成功连接到了AWS CodeCommit仓库
- 成功检测到了develop分支上的Jenkinsfile
- 满足了构建条件（Met criteria）
- 但这只是分支索引过程，而不是实际构建过程

#### 下一步操作

当看到"Finished: NOT_BUILT"状态时，请执行以下操作：

1. **手动触发首次构建**：
   - 回到项目首页
   - 点击左侧的「立即构建」按钮
   - 选择要构建的分支（如develop）

2. **配置自动触发**（后续优化）：
   - 配置轮询SCM或webhook来实现代码提交时自动触发构建
   - 参考文档后续章节的webhook配置说明

### 2.4 常见连接问题排查

如果连接失败，检查以下几点：

1. **SSH密钥配置**：
   - 确认私钥正确配置在Jenkins凭证中
   - 检查SSH配置文件权限（应为600）
   - 验证公钥已正确添加到AWS IAM用户

2. **网络连接**：
   - Jenkins服务器能否访问AWS CodeCommit端点
   - 检查防火墙设置是否允许SSH连接（端口22）

3. **权限配置**：
   - 确认IAM用户有CodeCommit的读取权限
   - 检查SSH密钥ID是否正确

### 2.5 代码拉取成功但未执行流水线步骤

#### 情况分析

如果您看到类似以下日志：
```
Running as SYSTEM 
Building in workspace /Users/ios/.jenkins/workspace/iOS_cicd 
Selected Git installation does not exist. Using Default 
The recommended git tool is: NONE 
using credential 89d48e88-41d2-402b-830d-9c22fd7c50aa 
 > git rev-parse --resolve-git-dir /Users/ios/.jenkins/workspace/iOS_cicd/.git # timeout=10 
Fetching changes from the remote Git repository 
 > git config remote.origin.url ssh://git-codecommit.us-east-1.amazonaws.com/v1/repos/ios_CICD # timeout=10 
Fetching upstream changes from ssh://git-codecommit.us-east-1.amazonaws.com/v1/repos/ios_CICD 
 > git --version # timeout=10 
 > git --version # 'git version 2.39.5 (Apple Git-154)' 
using GIT_SSH to set credentials 
Verifying host key using known hosts file 
 > git fetch --tags --force --progress -- ssh://git-codecommit.us-east-1.amazonaws.com/v1/repos/ios_CICD +refs/heads/*:refs/remotes/origin/* # timeout=10 
 > git rev-parse refs/remotes/origin/develop^{commit} # timeout=10 
Checking out Revision 99f74f4b826a4c211edd59abbabd5957cdd118b0 (refs/remotes/origin/develop) 
 > git config core.sparsecheckout # timeout=10 
 > git checkout -f 99f74f4b826a4c211edd59abbabd5957cdd118b0 # timeout=10 
Commit message: "temp" 
 > git rev-list --no-walk 99f74f4b826a4c211edd59abbabd5957cdd118b0 # timeout=10 
Finished: SUCCESS
```

**这表示**：
- Jenkins成功连接到了AWS CodeCommit仓库
- 成功拉取了develop分支的代码
- 但没有执行Jenkinsfile中定义的流水线步骤

#### 可能的原因

1. **Jenkinsfile未被正确识别**：
   - Jenkinsfile可能不在正确的位置（应该在仓库根目录）
   - Jenkinsfile可能命名不正确（大小写敏感）

2. **项目配置问题**：
   - 流水线配置可能设置为「流水线脚本」而非「流水线脚本从SCM」
   - 脚本路径配置可能不正确

#### 解决方案

1. **检查Jenkinsfile位置**：
   - 确认Jenkinsfile在仓库根目录（不是在子目录中）
   - 确保文件名是「Jenkinsfile」（注意大小写）

2. **验证项目配置**：
   - 进入项目配置页面
   - 确认「流水线」部分选择的是「从SCM获取流水线脚本」
   - 检查脚本路径是否为「Jenkinsfile」
   - 确保分支规格正确（如 */develop）

3. **重新配置并构建**：
   - 保存项目配置
   - 点击「立即构建」重新触发构建
   - 观察控制台输出是否开始执行流水线步骤

4. **检查Jenkins系统日志**：
   - 进入「管理Jenkins」>「系统日志」>「查看完整日志」
   - 搜索是否有关于Jenkinsfile解析错误的信息

## 3. AWS CodeCommit Webhook配置

### 3.1 配置Jenkins安全

1. 进入 `管理Jenkins` > `安全` > `全局安全配置`
2. 确保 `启用代理` 已启用
3. 记录Jenkins URL（用于配置webhook）

### 3.2 创建Webhook

**注意**：由于AWS CodeCommit不直接支持Jenkins webhook，您需要使用以下方法之一来实现代码推送时自动触发Jenkins构建：

#### 方法A：使用轮询SCM（推荐初学者使用）

这是最简单的实现方式，适合刚开始设置CI/CD流程的用户：

1. 打开Jenkins中您的项目配置页面
2. 向下滚动到「构建触发器」部分
3. 勾选 `轮询SCM` 选项
4. 在日程表字段中设置轮询间隔：
   - `* * * * *` - 每分钟检查一次（最常用）
   - `*/5 * * * *` - 每5分钟检查一次（减少服务器负载）
   - `0 * * * *` - 每小时检查一次（适合低频更新的项目）
5. 点击 `保存` 按钮应用更改

**优点**：
- 配置简单，无需额外的AWS服务
- 无需处理身份验证和网络配置

**缺点**：
- 可能有延迟（最长为轮询间隔时间）
- 会产生不必要的Git请求，增加服务器负载

#### 方法B：使用AWS Lambda和SNS（高级用户推荐）

这种方法更高效，没有轮询延迟，但配置稍复杂：

1. **创建SNS主题**：
   - 登录AWS管理控制台
   - 导航到 `Amazon SNS` > `主题` > `创建主题`
   - 选择「标准」类型
   - 输入名称（如 `jenkins-build-trigger`）
   - 点击「创建主题」

2. **配置CodeCommit通知**：
   - 导航到 `CodeCommit` > 选择您的仓库
   - 点击 `设置` > `通知` > `创建通知规则`
   - 名称：`Jenkins-Build-Trigger`
   - 事件类型：选择 `推送`
   - 资源：选择 `所有分支和标签` 或特定分支（如 `refs/heads/develop`）
   - 目标：选择 `Amazon SNS` 并选择您刚创建的SNS主题
   - 点击「创建」

3. **创建Lambda函数**：
   - 导航到 `Lambda` > `函数` > `创建函数`
   - 选择「从头开始创建」
   - 名称：`jenkins-build-trigger`
   - 运行时：选择 `Python 3.9` 或更高版本
   - 执行角色：创建或选择有适当权限的角色
   - 点击「创建函数」

4. **配置Lambda代码**：
   - 在代码编辑器中，粘贴以下代码并修改相应部分：
```python
def lambda_handler(event, context):
    import requests
    import json
    import base64
    from urllib.parse import quote
    
    # 配置Jenkins信息
    jenkins_url = "http://您的Jenkins服务器地址:端口"
    job_name = "您的项目名称"
    jenkins_user = "您的Jenkins用户名"
    jenkins_api_token = "您的Jenkins API令牌"
    
    # 构建Jenkins构建URL
    build_url = f"{jenkins_url}/job/{quote(job_name)}/build"
    
    # 发送构建请求到Jenkins
    try:
        # 构建基本认证头
        auth = f"{jenkins_user}:{jenkins_api_token}"
        auth_encoded = base64.b64encode(auth.encode()).decode()
        
        headers = {
            'Authorization': f'Basic {auth_encoded}',
            'Content-Type': 'application/json'
        }
        
        # 发送构建请求
        response = requests.post(build_url, headers=headers, timeout=10)
        
        # 检查响应
        if response.status_code == 201:
            return {
                'statusCode': 200,
                'body': json.dumps('成功触发Jenkins构建')
            }
        else:
            return {
                'statusCode': response.status_code,
                'body': json.dumps(f'触发Jenkins构建失败: {response.text}')
            }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f'Lambda函数执行失败: {str(e)}')
        }
```

5. **添加SNS触发器到Lambda**：
   - 在Lambda函数配置页面，点击「添加触发器」
   - 选择「SNS」
   - 选择您之前创建的SNS主题
   - 点击「添加」

6. **生成Jenkins API令牌**：
   - 登录Jenkins
   - 进入您的用户配置页面（右上角用户名 -> 配置）
   - 向下滚动到「API令牌」部分
   - 点击「添加新令牌」
   - 生成后保存令牌（它只显示一次）

7. **测试设置**：
   - 向CodeCommit仓库推送一个新的提交
   - 检查Lambda函数的CloudWatch日志
   - 确认Jenkins构建已被触发

**优点**：
- 实时触发构建，无需等待轮询
- 减少不必要的Git请求
- 更高效的资源利用

**缺点**：
- 配置较复杂
- 需要管理额外的AWS资源
- 需要处理网络和安全配置

## 4. 构建参数说明

Jenkinsfile中的主要配置参数：

- `PROJECT_DIR`：项目目录名（CICD_iOS）
- `WORKSPACE_FILE`：工作空间文件（CICD_iOS.xcworkspace）
- `SCHEME_NAME`：构建方案名称（CICD_iOS）
- `CONFIGURATION`：构建配置（Release）
- `SDK`：目标SDK（iphoneos）

## 5. 故障排除

### 4.1 常见问题

- **构建失败，提示证书问题**：检查CODE_SIGN相关配置，当前Jenkinsfile配置为不进行代码签名
- **依赖安装失败**：确保Jenkins服务器已安装CocoaPods
- **权限问题**：检查Jenkins用户对项目目录的访问权限

### 4.2 日志查看

- Jenkins构建日志提供详细的错误信息
- 检查Xcode构建日志以获取具体的编译错误

## 6. 后续优化方向

- 添加代码质量检查（如SwiftLint）
- 实现自动签名和打包IPA
- 集成测试报告生成
- 添加部署到TestFlight或App Store的步骤
- 配置构建缓存以提高构建速度