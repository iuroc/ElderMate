import {
    ChatCompletionCreateParams,
    ChatCompletionCreateParamsNonStreaming,
    ChatCompletionCreateParamsStreaming
} from './openai@4.73.1/resources/chat'
import { ChatCompletionChunk, ChatCompletionCreateParamsBase } from './openai@4.73.1/resources/chat/completions'
import type { OpenAI } from './OpenAI'
import { rcp } from '@kit.RemoteCommunicationKit'
import { buffer } from '@kit.ArkTS'

export class ChatCompletions {
    private client: OpenAI

    get apiURL() {
        return this.client.options.baseURL + `/chat/completions`
    }

    get apiKey() {
        return this.client.options.apiKey
    }

    constructor(client: OpenAI) {
        this.client = client
    }

    create(
        body: ChatCompletionCreateParamsNonStreaming,
        options?: ChatCompletionsCreateOptions
    ): ChatCompletionsReturnType

    create(
        body: ChatCompletionCreateParamsStreaming,
        options?: ChatCompletionsCreateOptions
    ): ChatCompletionsReturnType

    create(
        body: ChatCompletionCreateParamsBase,
        options?: ChatCompletionsCreateOptions
    ): ChatCompletionsReturnType

    create(
        body: ChatCompletionCreateParams,
        options?: ChatCompletionsCreateOptions
    ): ChatCompletionsReturnType {
        const headers: rcp.RequestHeaders = {
            'content-type': 'application/json',
            'authorization': `Bearer ${this.apiKey}`
        }
        const session = rcp.createSession({
            headers,
            requestConfiguration: options?.requestConfiguration
        })
        let oldString = ''
        const destination: rcp.ResponseBodyDestination | undefined = options?.onData
            ? {
                kind: 'stream', stream: {
                    async write(data) {
                        const rawString = buffer.from(data).toString('utf-8')
                        const workString = oldString + rawString
                        oldString = ''
                        const lines = workString.split('\n')
                        const result: ChatCompletionChunk[] = []
                        for (const line of lines) {
                            if (line.startsWith('data: ')) {
                                try {
                                    const item = JSON.parse(line.slice(6)) as ChatCompletionChunk
                                    result.push(item)
                                } catch {
                                    oldString += line
                                }
                            } else if (line.trim().length > 0) {
                                oldString += line
                            }
                        }
                        await options.onData!(result)
                    }
                }
            } : undefined
        return {
            session,
            response: session.post(this.apiURL, JSON.stringify(body), destination).finally(() => {
                console.log('session.close()', session)
                session.close()
            })
        }
    }
}

export interface ChatCompletionsReturnType {
    session: rcp.Session
    response: Promise<rcp.Response>
}

export interface ChatCompletionsCreateOptions {
    onData?: OnDataCallback
    requestConfiguration?: rcp.Configuration
}

export type OnDataCallback = (chunks: ChatCompletionChunk[]) => Promise<void | number> | void | number