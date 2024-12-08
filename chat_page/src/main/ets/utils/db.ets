import { ChatModel } from '@iuroc/openai/src/main/ets/openai@4.73.1/resources/chat/chat'
import { ChatCompletionMessageParam_role } from '@iuroc/openai/src/main/ets/types'
import { relationalStore } from '@kit.ArkData'
import { fileIo, fileUri, picker } from '@kit.CoreFileKit'
import { MessageData } from '../components/MessageListItem'
import { defaultMessageDataList } from '../config/defaultMessageDataList'
import { getDatetimeString } from './utils'

/**
 * 初始化数据表
 * @throws { BusinessError }
 * @param rdbStore
 */
export async function initTables(rdbStore: relationalStore.RdbStore) {
    await rdbStore.executeSql(`CREATE TABLE IF NOT EXISTS "chat" (
        "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        "title" TEXT NOT NULL,
        "model" TEXT NOT NULL,
        "create_time" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    )`)
    await rdbStore.executeSql(`CREATE TABLE IF NOT EXISTS "message" (
        "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        "role" TEXT,
        "content" TEXT NOT NULL,
        "in_request" INTEGER NOT NULL,
        "hidden" INTEGER NOT NULL,
        "chat_id" INTEGER NOT NULL,
        "send_time" DATETIME NOT NULL,
        "create_time" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY ("chat_id") REFERENCES "chat" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION
    )`)
}

/** 将沙箱中的数据库目录复制到选择器选择的目录 */
export async function copyDatabaseDir() {
    const databaseDir = getContext().databaseDir
    const documentViewPicker = new picker.DocumentViewPicker()
    const documentSaveOptions = new picker.DocumentSaveOptions()
    const saveUris = await documentViewPicker.save(documentSaveOptions)
    const savePath = new fileUri.FileUri(saveUris[0]).path
    fileIo.unlinkSync(savePath)
    fileIo.mkdirSync(savePath)
    fileIo.copyDirSync(databaseDir, savePath)
    console.log('已复制到', savePath)
}

export function getMessagesByChatID(rdbStore: relationalStore.RdbStore, chatId: number): MessageData[] {
    const result = rdbStore.querySqlSync(`SELECT * FROM "message" WHERE "chat_id" = ?`, [chatId])
    const messageDataList: MessageData[] = []
    while (result.goToNextRow()) {
        messageDataList.push(new MessageData({
            id: result.getLong(result.getColumnIndex('id')),
            role: result.getString(result.getColumnIndex('role')) as ChatCompletionMessageParam_role | null,
            content: result.getString(result.getColumnIndex('content')),
            inRequest: !!result.getLong(result.getColumnIndex('in_request')),
            hidden: !!result.getLong(result.getColumnIndex('hidden')),
            sendTime: new Date(result.getString(result.getColumnIndex('send_time'))),
        }))
    }
    return messageDataList
}

/**
 * 查询最新一条 Chat 表记录
 * @param rdbStore
 */
export function getLatestChat(rdbStore: relationalStore.RdbStore): ChatData | null {
    const result = rdbStore.querySqlSync(`SELECT * FROM "chat" ORDER BY "id" DESC LIMIT 1`)
    if (result.goToNextRow()) {
        return getChatDataFromResultSet(result)
    }
    return null
}

/**
 * 返回 `chat` 表的全部记录，已自动排序，ID 大的在前面
 * @param rdbStore
 * @returns
 */
export function getAllChatDataSorted(rdbStore: relationalStore.RdbStore): ChatData[] {
    const result = rdbStore.querySqlSync(`SELECT * FROM "chat" ORDER BY "id" DESC`)
    const chatDataList: ChatData[] = []
    while (result.goToNextRow()) {
        chatDataList.push(getChatDataFromResultSet(result))
    }
    return chatDataList
}

/**
 * 将 `chat` 表的 `SELECT *` 查询结果转换为 `ChatData` 对象
 * @param result
 * @returns
 */
function getChatDataFromResultSet(result: relationalStore.ResultSet): ChatData {
    return new ChatData(
        result.getLong(result.getColumnIndex('id')),
        result.getString(result.getColumnIndex('title')),
        result.getString(result.getColumnIndex('model')) as ChatModel,
        new Date(result.getString(result.getColumnIndex('create_time'))),
    )
}

export function booleanToNumber(value: boolean): number {
    return value ? 1 : 0
}

export function createChat(
    rdbStore: relationalStore.RdbStore,
    title: string,
    model: ChatModel
): ChatData {
    const createTime = new Date()
    const id = rdbStore.insertSync('chat', {
        title,
        model,
        create_time: getDatetimeString(createTime)
    })
    return new ChatData(id, title, model, createTime)
}

// interface MessageInsertValues {
//     role: ChatCompletionMessageParam_role | null
//     content: string
//     in_request: number
//     hidden: number
//     chat_id: number
//     send_time: string
// }

/**
 * 批量插入消息数据到 `message` 表
 * @param rdbStore
 * @param chatId chat 表的记录 id
 * @param messageDataList 需要插入的消息数据列表
 * @returns 如果操作成功，返回插入的数据个数，否则返回 -1
 */
export function insertMessages(
    rdbStore: relationalStore.RdbStore,
    chatId: number,
    messageDataList: MessageData[]
) {
    const valuesList = messageDataList.map(item => {
        return messageDataToInsertValues(chatId, item)
    })
    return rdbStore.batchInsertSync('message', valuesList)
}

function messageDataToInsertValues(chatId: number, messageData: MessageData): relationalStore.ValuesBucket {
    return {
        role: messageData.role,
        content: messageData.content,
        in_request: booleanToNumber(messageData.inRequest),
        hidden: booleanToNumber(messageData.hidden),
        chat_id: chatId,
        send_time: getDatetimeString(messageData.sendTime),
    }
}

export function insertMessage(
    rdbStore: relationalStore.RdbStore,
    chatId: number,
    messageData: MessageData
): number {
    return rdbStore.insertSync('message', messageDataToInsertValues(chatId, messageData))
}

@ObservedV2
export class ChatData {
    id: number
    title: string
    model: ChatModel
    createTime: Date

    constructor(id: number, title: string, model: ChatModel, createTime: Date) {
        this.id = id
        this.title = title
        this.model = model
        this.createTime = createTime
    }
}

export function updateMessage(rdbStore: relationalStore.RdbStore, values: relationalStore.ValuesBucket, id: number) {
    const predicates = new relationalStore.RdbPredicates('message')
    predicates.equalTo('id', id)
    rdbStore.updateSync(values, predicates)
}

export function deleteMessageById(rdbStore: relationalStore.RdbStore, id: number) {
    const predicates = new relationalStore.RdbPredicates('message')
    predicates.equalTo('id', id)
    rdbStore.deleteSync(predicates)
}

/**
 * 根据 `chatId` 删除属于该 `chat` 的全部 `message`
 * @param rdbStore
 * @param chatId
 */
export function deleteMessagesByChatId(rdbStore: relationalStore.RdbStore, chatId: number): number {
    const predicates = new relationalStore.RdbPredicates('message')
    predicates.equalTo('chat_id', chatId)
    return rdbStore.deleteSync(predicates)
}

/** 创建新的 chat 记录，并重置当前的聊天记录列表为新 chat 的
 *
 * @deprecated
 */
export function createNewChatForPage(rdbStore: relationalStore.RdbStore, chatDataList: ChatData[], model: ChatModel) {
    const newChatData = createChat(rdbStore, '新的聊天', model)
    insertMessages(rdbStore, newChatData.id, defaultMessageDataList())
    chatDataList.push(newChatData)
    return newChatData
}

/**
 * 对 `chatDataList` 排序，`id` 更大的排在前面，第一项表示最新插入的记录
 */
export function sortChatList(chatDataList: ChatData[]): ChatData[] {
    return chatDataList.sort((a, b) => b.id - a.id)
}

/** 根据 chat_id 删除 chat，注意需要先删除 message，否则有外键冲突 */
export function deleteChatById(rdbStore: relationalStore.RdbStore, id: number) {
    const predicates = new relationalStore.RdbPredicates('chat')
    predicates.equalTo('id', id)
    rdbStore.deleteSync(predicates)
}