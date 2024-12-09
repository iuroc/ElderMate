# Changelog

## [v1.0.8] 2024.12.10

更新仓库地址，更新 `oh-package.json5` 的仓库地址。

## [v1.0.7] 2024.12.9

新增 `models.list` API，支持获取当前接口的可用模型列表。

默认使用 `system` 代理，绕过 SSL 验证以提升更多三方接口的接入兼容性。

## [v1.0.6] 2024.12.9

优化细节。

## [v1.0.5] 2024.12.6

修改 `create` 方法的参数类型定义。

## [v1.0.4] 2024.12.6

再次调整导出代码，外部直接访问子目录时，依然会有不确定的报错，但是不影响运行，等待测试解决。

## [v1.0.3] 2024.12.6

调整 Index.ets 的导出代码，实现无需填写子目录路径，就能导入其中的资源。

## [v1.0.2] 2024.12.6

`ChatCompletions.create` 方法新增 `requestConfiguration?: rcp.Configuration` 参数。

## [v1.0.1] 2024.12.5

提供完整的 `oh-package.json5` 文件，完善 `keywords` 信息。

## [v1.0.0] 2024.12.5

OpenAI 请求工具库，基本保留原 npm 库 TypeScript 定义。