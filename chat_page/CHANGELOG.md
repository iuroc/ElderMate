# Changelog

## [v1.0.6] 2025.3.24

修复 README 中图片展示。

## [v1.0.5] 2025.3.24

修复跨项目 HAR 包内无法使用 Context 访问字符串资源的问题，虽未彻底解决，但也只是牺牲了部分国家化处理，中文语境下无任何影响，后续寻求解决办法。

## [v1.0.4] 2025.1.19

修复 `@iuroc/bootstrap5-color` 包缺失问题。

## [v1.0.3] 2025.1.17

修复聊天助手 Failed writing received data to disk/application
报错，详情 [https://developer.huawei.com/consumer/cn/forum/topic/0202172433837171168](https://developer.huawei.com/consumer/cn/forum/topic/0202172433837171168)。

## [v1.0.2] 2024.12.13

去除对父组件 `@Provide pathInfos` 变量的依赖，采用 `on + off`
的方式创建和销毁键盘拉起事件，确保事件仅作用与所在 `NavDestination`。

## [v1.0.1] 2024.12.9

支持 `defaultMessageDataList` 构造参数，用于配置创建新对话时默认填充的消息列表。

## [v1.0.0] 2024.12.7

v1.0.0，初始版本，基本完成全部功能开发。