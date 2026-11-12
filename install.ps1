$ErrorActionPreference = 'Stop'

$root = $PSScriptRoot
$homeDir = $env:USERPROFILE
$bundleDst = Join-Path $homeDir '.dsh\bundles\plan-exec'

# 1. 读子代理模型配置
$cfgPath = Join-Path $root 'subagent-model.json'
if (-not (Test-Path $cfgPath)) { throw '缺少 subagent-model.json（就在 install.ps1 旁边）' }
$cfg = [System.IO.File]::ReadAllText($cfgPath, [System.Text.Encoding]::UTF8) | ConvertFrom-Json
$provider = "$($cfg.provider)".Trim()
$model = "$($cfg.model)".Trim()
if (($provider -and -not $model) -or ($model -and -not $provider)) {
    throw 'subagent-model.json 里 provider 和 model 要么都填，要么都留空'
}

# 2. 复制预设
if (Test-Path $bundleDst) { Remove-Item $bundleDst -Recurse -Force }
New-Item -ItemType Directory -Force -Path (Split-Path $bundleDst) | Out-Null
Copy-Item (Join-Path $root 'plan-exec') $bundleDst -Recurse -Force

# 3. 把模型写进预设 YAML；留空则删掉 agentOptions（跟随会话模型）
$yamlPath = Join-Path $bundleDst 'cordis.patch.yml'
$yaml = [System.IO.File]::ReadAllText($yamlPath, [System.Text.Encoding]::UTF8)
if ($provider -and $model) {
    $yaml = $yaml.Replace('__SUBAGENT_PROVIDER__', $provider).Replace('__SUBAGENT_MODEL__', $model)
    $mode = "固定 $provider / $model"
} else {
    $pattern = '(?m)^[ \t]+agentOptions:\r?\n[ \t]+provider: __SUBAGENT_PROVIDER__\r?\n[ \t]+model: __SUBAGENT_MODEL__\r?\n'
    $yaml = [regex]::Replace($yaml, $pattern, '')
    $mode = '跟随当前会话模型'
}
if ($yaml.Contains('__SUBAGENT_') -or ($provider -and -not $yaml.Contains('agentOptions'))) {
    throw '写预设 YAML 失败：占位符没有正确替换/删除'
}
[System.IO.File]::WriteAllText($yamlPath, $yaml, [System.Text.UTF8Encoding]::new($false))

Write-Host '已安装到：'
Write-Host "  $bundleDst"
Write-Host ''
Write-Host "子代理模型：$mode"
Write-Host ''
Write-Host '下一步：'
Write-Host '  1. 重启 DSH'
Write-Host "  2. dsh plugin --profile default add link:$bundleDst"
Write-Host '     （profile 名按你自己的改；GUI 插件页也能装本地 bundle）'
Write-Host '  3. 新建会话，预设下拉选「规划-执行协作」'
