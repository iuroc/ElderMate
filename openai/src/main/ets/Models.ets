import type { OpenAI } from './OpenAI';
import type { Model } from './openai@4.73.1/resources/models';
import { rcp } from '@kit.RemoteCommunicationKit'
import { buffer } from '@kit.ArkTS';

export class Models {
    openai: OpenAI

    get apiURL() {
        return this.openai.options.baseURL + '/models'
    }

    get apiKey() {
        return this.openai.options.apiKey
    }

    constructor(openai: OpenAI) {
        this.openai = openai
    }

    /**
     * Lists the currently available models, and provides basic information about each one such as the owner and availability.
     * @param options
     * @returns
     */
    async list(options?: ModelsListOptions): Promise<Model[]> {
        const headers: rcp.RequestHeaders = {
            'content-type': 'application/json',
            'authorization': `Bearer ${this.apiKey}`
        }
        const session = rcp.createSession({
            headers,
            requestConfiguration: options?.requestConfiguration
        })
        const response = await session.get(this.apiURL)
        const body = JSON.parse(buffer.from(response.body).toString('utf-8')) as ModelsResponse
        return body.data
    }
}

interface ModelsResponse {
    object: 'list',
    data: Model[]
}

interface ModelsListOptions {
    requestConfiguration?: rcp.Configuration
}