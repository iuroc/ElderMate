# @iuroc/openai

> OpenAI 请求工具库，基本保留原 npm 库 TypeScript 定义。

## 安装使用

```shell
ohpm install @iuroc/openai
```

## 使用示例

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

> 使用 `onData` 回调函数时，注意 `chunk.choices` 有可能是空数组，建议加上 `?` 去获取内容。

```extendtypescript
const onData: OnDataCallback = chunks => {
    const newContent = chunks.map(chunk => chunk.choices[0]?.delta.content).join('')
    console.log(newContent)
}

const result = openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [
        { role: 'user', content: 'hello' }
    ],
    stream: true
}, { onData })
```