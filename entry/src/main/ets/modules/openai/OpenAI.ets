import { ChatCompletions } from './ChatCompletions'

interface OpenAIOptions {
    /** https://api.openai.com/v1 */
    baseURL?: string
    apiKey?: string
    organization?: string
    project?: string
}


// 原则：全力沿用官方标识符命名和文件目录结构，可对原版进行删减

export class OpenAI {
    private options: OpenAIOptions = {}
    public chat: Chat = {
        completions: new ChatCompletions(this)
    }

    constructor(options?: OpenAIOptions) {
        this.options.apiKey = options?.apiKey
        this.options.baseURL = options?.baseURL || 'https://api.openai.com/v1'
        this.options.organization = options?.organization
        this.options.project = options?.project
    }
}

interface Chat {
    completions: ChatCompletions
}