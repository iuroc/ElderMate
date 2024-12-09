import { MessageData } from '../components/MessageListItem'

/** 默认消息列表，当 `ChatPage` 组件未构造传参 `defaultMessageDataList` 时，
 * 将使用本方法返回的消息列表作为默认消息列表。 */
export function makeDefaultMessageDataList(): MessageData[] {
    return [
        new MessageData({ role: null, content: '我是智能聊天助手，您可以问我任何问题~' }),
    ]
}