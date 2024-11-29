import { OpenAI } from './OpenAI'

export function testOpenAI() {
    const openai = new OpenAI({
        baseURL: `https://openkey.cloud/v1`,
        apiKey: `sk-7TImgtgJvIK8uhlKA1D230B6F18b4363BcA4Be0d342914F7`
    })

    openai.chat.completions.create({
        model: 'gpt-4o-mini',
        messages: [
            { role: 'system', content: '' },
            { role: 'user', content: '' },
        ],
        stream: true
    })
}