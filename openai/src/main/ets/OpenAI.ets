import { ChatCompletions } from './ChatCompletions'
import { Models } from './Models'
import { ClientOptions } from './openai@4.73.1'

// 原则：全力沿用官方标识符命名和文件目录结构，可对原版进行删减

export class OpenAI {
    options: ClientOptions = {}
    public chat: Chat = {
        completions: new ChatCompletions(this)
    }
    public models: Models = new Models(this)

    constructor(options?: ClientOptions) {
        this.options.apiKey = options?.apiKey
        this.options.baseURL = options?.baseURL || 'https://api.openai.com/v1'
        this.options.organization = options?.organization
        this.options.project = options?.project
    }
}

interface Chat {
    completions: ChatCompletions
}