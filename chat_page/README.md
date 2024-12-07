# @iuroc/chat-page

基于 OpenAI API 的智能聊天页面组件，根组件为 `NavDestination`。

![](./image/01.png)

## 安装模块

```shell
ohpm install @iuroc/chat-page
```

## 使用模块

```extendtypescript
import { ChatPage } from '@iuroc/chat-page'
import { preferences, relationalStore } from '@kit.ArkData'

const dataPreferences = preferences.getPreferencesSync(getContext(), { name: 'chat' })
const getRdbStore = async () => {
    return relationalStore.getRdbStore(getContext(), {
        name: 'chat.db',
        securityLevel: relationalStore.SecurityLevel.S1
    })
}

@Builder
export function PageBuilder() {
    ChatPage({ dataPreferences, getRdbStore })
}
```