import { MessageData } from '../components/MessageListItem'

/** 演示消息列表 */
export function exampleMessageDataList(): MessageData[] {
    return [
        new MessageData({
            role: 'user',
            content: '今天的天气怎么样？',
        }),
        new MessageData({
            role: 'assistant',
            content: '今天阳光明媚，气温在25度左右，非常适合外出活动。',
        }),
        new MessageData({
            role: 'user',
            content: '你有没有推荐的好书或者电影，可以分享一下你的感受吗？',
        }),
        new MessageData({
            role: 'assistant',
            content: '最近我读了一本很不错的书，叫《追风筝的人》。这本书讲述了友谊和背叛的故事，情感非常细腻，让我感触很深。我推荐你也去看看。同时，最近看的电影《摔跤吧！爸爸》也很有启发性，它展现了一个父亲为了支持女儿追求梦想所付出的努力，非常感人。',
        }),
        new MessageData({
            role: 'user',
            content: '你平时喜欢做哪些运动来保持健康？',
        }),
        new MessageData({
            role: 'assistant',
            content: '我平时最喜欢的运动是跑步和游泳。每周我都会尽量去跑步三次，大约30分钟到一个小时，感觉非常放松。而游泳则是我喜欢的夏季运动，它不仅锻炼全身肌肉，还能让我在水中感受到凉爽，尤其是在炎热的天气里。',
        })
    ]
}