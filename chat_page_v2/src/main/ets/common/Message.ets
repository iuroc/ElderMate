export type MessageRole = 'system' | 'user' | 'assistant' | null

export interface MessageInit {
    id?: number
    /** 消息是否需要加入请求体，默认 `true` */
    inRequest?: boolean
    /** 消息角色，默认 `null` */
    role?: MessageRole
    /** 消息气泡内容 */
    content: string
    /** 是否隐藏组件，默认 `false` */
    hidden?: boolean
    /** 是否选中组件，默认 `false` */
    selected?: boolean
    /** 消息发送时间，默认 `new Date()` */
    sendTime?: Date
}

@ObservedV2
export class Message implements MessageInit {
    @Trace id: number
    @Trace inRequest: boolean
    @Trace role: MessageRole
    @Trace content: string
    @Trace hidden: boolean
    @Trace selected: boolean
    @Trace sendTime: Date

    constructor(init: MessageInit) {
        this.id = init.id ?? 0
        this.inRequest = init.inRequest ?? true
        this.role = init.role ?? null
        this.content = init.content
        this.hidden = init.hidden ?? false
        this.selected = init.selected ?? false
        this.sendTime = init.sendTime ?? new Date()
    }
}