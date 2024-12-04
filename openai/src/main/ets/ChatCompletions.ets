import { OpenAI } from "./OpenAI"


export class ChatCompletions {
    client: OpenAI

    constructor(client: OpenAI) {
        this.client = client
    }
}