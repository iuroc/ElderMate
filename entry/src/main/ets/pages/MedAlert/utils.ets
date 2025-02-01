import { http } from '@kit.NetworkKit'
import { apiOrigin } from '../../common/config'
import { ApiResponse } from '../../common/types'
import { getToken } from '../Login/utils'
import { url } from '@kit.ArkTS'

export async function getMedAlertList(date = new Date(), page: number = 0, pageSize: number = 120) {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/medAlert/list', {
        method: http.RequestMethod.POST,
        expectDataType: http.HttpDataType.OBJECT,
        extraData: new url.URLParams({
            page: page.toString(),
            pageSize: pageSize.toString(),
            date: date.getTime().toString()
        }).toString(),
        header: {
            token: await getToken(),
            'Content-Type': 'application/x-www-form-urlencoded'
        }
    })
    const result = response.result as ApiResponse<MedAlertListItem[]>
    if (result.success) {
        return result.data
    }
    throw new Error(result.message)
}

/**
 * 删除用药提醒
 *
 * @throws { Error }
 * @param id
 */
export async function deleteMedAlert(id: number) {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/medAlert/delete', {
        method: http.RequestMethod.POST,
        expectDataType: http.HttpDataType.OBJECT,
        extraData: new url.URLParams({
            id: id.toString()
        }).toString(),
        header: {
            token: await getToken(),
            'Content-Type': 'application/x-www-form-urlencoded'
        }
    })
    const result = response.result as ApiResponse
    if (!result.success) {
        throw new Error(result.message)
    }
}

export interface MedAlertListItem {
    id: number
    name: string
    useCountPerDay: number
    description: string
    startDate: string
    endDate: string
    createTime: string
}