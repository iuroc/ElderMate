import {
    ChatCompletionCreateParams,
    ChatCompletionCreateParamsNonStreaming,
    ChatCompletionCreateParamsStreaming
} from './openai@4.73.1/resources/chat'
import { ChatCompletionChunk, ChatCompletionCreateParamsBase } from './openai@4.73.1/resources/chat/completions'
import type { OpenAI } from './OpenAI'
import { rcp } from '@kit.RemoteCommunicationKit'
import { buffer } from '@kit.ArkTS'
import { BusinessError } from '@kit.BasicServicesKit'

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
        let allResponseText = ''
        const destination: rcp.ResponseBodyDestination | undefined = options?.onData
            ? {
                kind: 'stream', stream: {
                    async write(data) {
                        const rawString = buffer.from(data).toString('utf-8')
                        allResponseText += rawString
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
        const response = session.post(this.apiURL, JSON.stringify(body), destination)
        response.then(() => {
            if (allResponseText.trim().startsWith('data: ')) {
                return
            }
            try {
                const error = JSON.parse(allResponseText) as ErrorJSON
                if (error.error?.message) {
                    options?.onError?.(new Error(error.error.message))
                }
            } finally {
            }
        }).catch((error: BusinessError<string>) => options?.onError?.(new Error(error.data)))
            .finally(() => {
                session.close()
            })
        return {
            session,
            response
        }
    }
}

export interface ErrorJSON {
    error?: Record<'message', string | undefined>
}

export interface ChatCompletionsReturnType {
    session: rcp.Session
    response: Promise<rcp.Response>
}

export interface ChatCompletionsCreateOptions {
    onData?: OnDataCallback
    onError?: OnErrorCallback
    requestConfiguration?: rcp.Configuration
}

export type OnErrorCallback = (error: Error) => void

export type OnDataCallback = (chunks: ChatCompletionChunk[]) => Promise<void | number> | void | number