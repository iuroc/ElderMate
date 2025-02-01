import { http } from "@kit.NetworkKit"
import { apiOrigin } from "../../../common/config"
import { url } from "@kit.ArkTS"
import { getToken } from "../../Login/utils"
import { ApiResponse } from "../../../common/types"

/**
 * 查看日期是否比今天更早
 * @param date
 * @returns
 */
export function isBeforeToday(date: Date): boolean {
    return isABeforeB(date, new Date())
}

/**
 * 判断日期 A 是否比日期 B 早，这里只比较日期，不包含世间
 *
 * 比如 2025-01-01 比 2025-01-02 早
 * @param a
 * @param b
 */
export function isABeforeB(a: Date, b: Date): boolean {
    a.setHours(0, 0, 0, 0)
    b.setHours(0, 0, 0, 0)
    return a.getTime() < b.getTime()
}

/**
 * 计算两个 Date 之间包含多少天（包含起止日期）
 * @param startDate
 * @param endDate
 * @returns
 */
export function daysBetweenInclusive(startDate: Date, endDate: Date): number {
    const start = new Date(startDate)
    start.setHours(0, 0, 0, 0)
    const end = new Date(endDate)
    end.setHours(0, 0, 0, 0)
    const diffTime = end.getTime() - start.getTime()
    const diffDays = Math.abs(diffTime) / (1000 * 60 * 60 * 24)
    return diffDays + 1
}

export interface CreateMedAlertConfig {
    name: string
    useCountPerDay: number
    description: string
    startDate: Date
    endDate: Date
    id?: number
    createTime?: Date
}

export interface CreateMedAlertResult {
    id: number
    createTime: string
}

export async function createMedAlert(config: CreateMedAlertConfig): Promise<CreateMedAlertResult | null> {
    const request = http.createHttp()
    const params = new url.URLParams({
        name: config.name,
        useCountPerDay: config.useCountPerDay.toString(),
        description: config.description,
        startDate: config.startDate.getTime().toString(),
        endDate: config.endDate.getTime().toString(),
    })
    if (config.id !== undefined) {
        params.set('id', config.id.toString())
    }
    const response = await request.request(apiOrigin + '/api/medAlert/create', {
        method: http.RequestMethod.POST,
        extraData: params.toString(),
        expectDataType: http.HttpDataType.OBJECT,
        header: {
            token: await getToken(),
            'Content-Type': 'application/x-www-form-urlencoded'
        },
    })
    const result = response.result as ApiResponse<CreateMedAlertResult>
    if (result.success) {
        return result.data
    }
    throw new Error(result.message)
}