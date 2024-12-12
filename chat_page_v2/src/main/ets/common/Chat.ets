import { defaultChatModel, defaultChatTitle } from "./config"

export interface ChatInit {
    id?: number
    title?: string
    model?: string
    createTime?: Date
}

let NEXT_ID = 0

@ObservedV2
export class Chat implements ChatInit {
    @Trace id: number
    @Trace title: string
    @Trace model: string
    @Trace createTime: Date

    constructor(init: ChatInit) {
        this.id = init.id ?? NEXT_ID++
        this.title = init.title || defaultChatTitle
        this.model = init.model || defaultChatModel
        this.createTime = init.createTime || new Date()
    }
}