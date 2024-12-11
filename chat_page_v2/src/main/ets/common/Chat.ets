import { defaultChatModel, defaultChatTitle } from "./config"

export interface ChatInit {
    id?: number
    title?: string
    model?: string
    createTime?: Date
}

@ObservedV2
export class Chat implements ChatInit {
    @Trace id: number
    @Trace title: string
    @Trace model: string
    @Trace createTime: Date

    constructor(init: ChatInit) {
        this.id = init.id ?? 0
        this.title = init.title || defaultChatTitle
        this.model = init.model || defaultChatModel
        this.createTime = init.createTime || new Date()
    }
}