import { OpenAI } from './OpenAI'
import { ChatCompletionChunk } from './openai@4.73.1/resources'

export function testOpenAI() {
    return new OpenAI({
        apiKey: `sk-7TImgtgJvIK8uhlKA1D230B6F18b4363BcA4Be0d342914F7`,
        baseURL: `https://openkey.cloud/v1`
    })
}

export async function testChat() {
    const openai = testOpenAI()
    const onData = async (chunks: ChatCompletionChunk[]) => {
        console.log(chunks.map(chunk => chunk.choices[0].delta.content).join(''))
    }

    const result = openai.chat.completions.create({
        model: 'gpt-4o-mini',
        messages: [
            { role: 'user', content: '写500字作文' }
        ],
        stream: true
    }, { onData })
}

export async function testModels() {
    const openai = testOpenAI()
    openai.models.list().then(result => {
        console.log(JSON.stringify(result))
    })
}