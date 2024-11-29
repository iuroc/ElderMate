import { OpenAI } from './OpenAI'
import { ChatCompletionCreateParamsStreaming } from './npm@4.73.1/resources/chat'

export function testOpenAI() {
    const openai = new OpenAI({
        baseURL: `https://openkey.cloud/v1`,
        apiKey: `sk-7TImgtgJvIK8uhlKA1D230B6F18b4363BcA4Be0d342914F7`
    })

    const body: ChatCompletionCreateParamsStreaming = {
        model: 'gpt-4o-mini',
        messages: [
            { role: 'user', content: '请写一篇500字作文' },
        ],
        stream: true
    }

    openai.chat.completions.create(body, async chunks => {
        chunks.forEach(chunk => {
            console.log(chunk.choices[0].delta.content)
        })
    })
}