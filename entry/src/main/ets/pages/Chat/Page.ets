import { MainPage as ChatPage, MessageData } from '@iuroc/chat-page'
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

const defaultMessageDataList: MessageData[] = [
    new MessageData({ role: null, content: '我是智能聊天助手，您可以问我任何问题~' }),
    new MessageData({
        role: 'system',
        content: '你是一个智能老年人生活助手，你的职责是帮助老年人解答生活中遇到的各种问题，并以亲切有趣的风格生成适合老年人的回答。',
        hidden: true,
    })
]

@Builder
export function PageBuilder() {
    ChatPage({
        // 配置用户首选项
        dataPreferences,
        // 配置关系型数据库
        getRdbStore,
        // 配置创建新对话时默认填充的消息列表
        defaultMessageDataList,
    })
}