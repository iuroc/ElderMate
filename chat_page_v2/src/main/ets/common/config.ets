import { BSColorNameMap } from '@iuroc/bootstrap5-color'
import { Message } from './Message'

export const defaultBaseURL = 'https://api.openai.com/v1'

export const defaultChatModel = 'gpt-4o-mini'

export const defaultChatTitle = '新的聊天'

export const defaultThemeColorName: BSColorNameMap = 'success'

export const defaultMessages: Message[] = [
    new Message({ role: null, content: '我是智能聊天助手，您可以问我任何问题~' }),
]