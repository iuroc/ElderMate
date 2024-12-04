import { ChatCompletions } from "./ChatCompletions"
import { ClientOptions } from "./openai@4.73.1"

class Chat {
    client: OpenAI
    completions: ChatCompletions

    constructor(client: OpenAI) {
        this.client = client
        this.completions = new ChatCompletions(this.client)
    }
}

export class OpenAI {
    private clientOptions: ClientOptions = {}
    chat = new Chat(this)

    get apiKey() {
        return this.clientOptions.apiKey
    }

    get organization() {
        return this.clientOptions.organization
    }

    get project() {
        return this.clientOptions.project
    }

    get baseURL() {
        return this.clientOptions.baseURL
    }

    constructor(clientOptions?: ClientOptions) {
        this.clientOptions.apiKey = clientOptions?.apiKey
        this.clientOptions.organization = clientOptions?.organization
        this.clientOptions.project = clientOptions?.project
        this.clientOptions.baseURL = clientOptions?.baseURL ?? 'https://api.openai.com/v1'
    }
}