import { ChatCompletionCreateParamsStreaming } from './npm@4.73.1/resources/chat'
import type { OpenAI } from './OpenAI'

export class ChatCompletions {
    constructor(openai: OpenAI) {

    }

    create(body: ChatCompletionCreateParamsStreaming) {
        console.log(JSON.stringify(body))
    }
}