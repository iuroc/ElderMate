## example

```extendtypescript
import { OpenAI } from '@iuroc/openai'

const openai = new OpenAI({
    apiKey: 'sk-xxxx',
    baseURL: 'https://api.openai.com/v1'
})
const result = openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [
        { role: 'user', content: 'hello' }
    ]
})

const response = result.response
const session = result.session
```

### 终止请求

```extendtypescript
session.cancel()
```

### 等待请求完成

```extendtypescript
// Promise 方式
await response

// Callback 方式
response.then(() => {

})
```

### 流式输出

```extendtypescript
const onData: OnDataCallback = chunks => {
    const newContent = chunks.map(chunk => chunk.choices[0].delta.content).join('')
    console.log(newContent)
}

const result = openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [
        { role: 'user', content: 'hello' }
    ],
    stream: true
}, onData)
```