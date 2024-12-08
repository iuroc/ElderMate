import { ChatPage } from '@iuroc/chat-page'
import { preferences, relationalStore } from '@kit.ArkData'

const dataPreferences = preferences.getPreferencesSync(getContext(), { name: 'chat' })
dataPreferences.putSync('openai_api_key', `sk-7TImgtgJvIK8uhlKA1D230B6F18b4363BcA4Be0d342914F7`)
dataPreferences.putSync('openai_base_url', `https://openkey.cloud/v1`)
const getRdbStore = async () => {
    return relationalStore.getRdbStore(getContext(), {
        name: 'chat.db',
        securityLevel: relationalStore.SecurityLevel.S1
    })
}

@Builder
export function PageBuilder() {
    ChatPage({
        // 配置用户首选项
        dataPreferences,
        // 配置关系型数据库
        getRdbStore,
    })
}