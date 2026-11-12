# DSH 预设：规划-执行协作（plan-exec）

一个 DeepSeek Harness（DSH）的 agent 预设包。主会话当「规划队长」，负责理解需求、定方案、拆任务和验收；具体执行（勘察、改文件、跑命令）交给子代理，主会话的上下文和贵模型只花在判断与验收上。

## 装之前

- 需要 DSH Desktop（或支持 `agent-preset` 的 dsh）。包里只有预设定义和安装脚本，不带 DSH 本体，也不带任何模型服务。
- 装完必须重启一次 DSH 才会加载。

## 安装

解压后在本目录打开 PowerShell：

```powershell
.\install.ps1
```

脚本做两件事：

1. 读 `subagent-model.json`，决定子代理用哪个模型（见下一节）
2. 把 `plan-exec` 复制到 `%USERPROFILE%\.dsh\bundles\plan-exec`

然后重启 DSH，并把本地 bundle 挂进你的 profile：

```powershell
dsh plugin --profile default add "link:$env:USERPROFILE\.dsh\bundles\plan-exec"
```

`default` 换成你自己的 profile 名（一般是 `default` 或 `desktop`）。GUI 的插件页也可以直接选本地目录安装。

重启后新建会话，在预设下拉里选「规划-执行协作」。

## 子代理模型怎么配（重点）

只需要改一个文件：包里的 `subagent-model.json`。

```json
{
  "provider": "",
  "model": ""
}
```

- **都留空（默认）**：子代理跟随你当前会话选的模型。谁装都能跑，但不会省 token。
- **都填上**：子代理固定用这个模型，比如填你已注册的便宜模型。队长的贵模型只花在规划与验收上。

改完保存，重新运行一次 `.\install.ps1`，再重启 DSH。以后换模型也是改这个 json、重跑脚本，不用碰 YAML。

`provider` / `model` 必须是你的 DSH 里已经注册好的标识（`/model` 列表里显示的那个，不是界面上起的别名）。

`subagent_fork`（继承本会话上下文的派法）的模型始终跟随队长，不受这个文件影响。

## 包里有什么

| 路径 | 作用 |
|---|---|
| `subagent-model.json` | 子代理模型设置（改这里，不用改 YAML） |
| `plan-exec/` | 预设定义（`package.json` + `cordis.patch.yml`） |
| `install.ps1` | 安装脚本（复制文件 + 把模型写进预设） |
| `README.md` | 本文件 |

## 卸载

删掉这个目录后重启 DSH：

- `%USERPROFILE%\.dsh\bundles\plan-exec`

如果已经用 `dsh plugin add` 挂过，先在插件页或命令行里移除该 bundle。

## License

MIT。见 [LICENSE](LICENSE)。
