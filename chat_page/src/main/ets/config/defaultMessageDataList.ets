import { MessageData } from '../components/MessageListItem'

/** 默认消息列表，点击清空当前消息列表后，可以重置为此列表 */
export const defaultMessageDataList: MessageData[] = [
    new MessageData({ role: null, content: '我是智能聊天助手，您可以问我任何问题~' }),
    new MessageData({
        role: 'system',
        content: '你是一个智能老年人生活助手，你的职责是帮助老年人解答生活中遇到的各种问题，并以亲切有趣的风格生成适合老年人的回答。',
        hidden: false,
    })
]