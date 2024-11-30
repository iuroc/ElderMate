export type MessageRole = 'user' | 'assistant' | 'system' | 'info'

/** 消息列表项数据 */
export type IMessageData = Required<MessageDataInit>

export interface MessageDataInit {
    role: MessageRole
    content: string
    createTime?: Date
    hidden?: boolean
    uuid?: string
    selected?: boolean
}