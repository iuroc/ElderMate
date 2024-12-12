# Changelog

## [v1.0.2] 2024.12.13

去除对父组件 `@Provide pathInfos` 变量的依赖，采用 `on + off`
的方式创建和销毁键盘拉起事件，确保事件仅作用与所在 `NavDestination`。

## [v1.0.1] 2024.12.9

支持 `defaultMessageDataList` 构造参数，用于配置创建新对话时默认填充的消息列表。

## [v1.0.0] 2024.12.7

v1.0.0，初始版本，基本完成全部功能开发。